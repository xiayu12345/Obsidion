H133 HDMI 音频透传问题（对照官方透传）

cedarx 那一层我们按补丁合进去了：EAC3 能从 AC3 里拆出来，nNeedDirect=1，adecoderPassthough 不解 PCM，SunxiPassthough 打 IEC61937。AC3 用 48k，EAC3 用 192k，2ch S16。这块两边差不多。

对不上的是出口。

官方补丁是按 LIBAUDIOROUTE + TinyALSA 写的。tsound_ctrl 只改了 #ifdef TPLAYER_AUDIO_API_LIBAUDIOROUTE，direct_mode 也只在 AudioPortTinyAlsaConfig 里跳过 amix，AudioPortAlsaConfig 还是每次 amix_dev_do。官方没有指定 HDMI 设备，也没设 audio data format。

我们这边 Tina 默认是 CONFIG_TR_AUDIO_API_ALSA_LIB=y，libaudioroute 没开。补丁原样合进来，透传写不到 HDMI 上。所以 ALSALIB 这路是我们自己接的：mixer 设 audio data format（AC3 / DOLBY_DIGITAL_PLUS），设备开 hw:sndi2s2,0，再把 IEC 写进去。



官方结构：

  片源 AC3/EAC3/DTS
        |
        v
  cedarx parser
        |
        v
  adecoderPassthough（不解 PCM）
        |
        v
  SunxiPassthough → IEC61937
        |
        v
  tsound_ctrl（LIBAUDIOROUTE）
        |
        v
  TinyALSA direct_mode=1（跳过 amix）
        |
        v
  pcm_writei → OUT_DEFAULT
        |
        v
  当前路由声卡（不设 audio data format）


我们现在的结构：

  片源 AC3/EAC3/DTS
        |
        v
  cedarx parser
        |
        v
  adecoderPassthough（不解 PCM）
        |
        v
  SunxiPassthough → IEC61937
        |
        v
  tsound_ctrl（ALSALIB）
        |
        v
  mixer: audio data format = AC3 / DOLBY_DIGITAL_PLUS
        |
        v
  hw:sndi2s2,0   2ch S16  AC3=48k / EAC3=192k
        |
        v
  内核 snd_sunxi_pcm_hdmi
  hdmi_fmt>PCM：61937 → 60958
        |
        v
  HDMI TX infoframe data_raw
        |
        v
  外接功放


官方补丁原样合到我们板上，断在这里：

                    官方 cedarx + IEC
                            |
              +-------------+-------------+
              |                           |
              v                           v
     官方 LIBAUDIOROUTE              我们 ALSA_LIB
     TinyALSA direct_mode            tsound_ctrl 没有这条分支
              |                           |
              v                           v
     没设 audio data format          写不到 HDMI raw
              |
              v
     内核当 PCM，infoframe 不是 Dolby

     问题：HDMI输出给音响只能听见断断续续的咔咔咔声音不能听到任何文字声音


2026-08-20 透传卡顿 / kernel panic 修复记录

现象：
  1. EAC3 / Atmos 透传到 HDMI 后，功放在 Dolby / Surround 间来回跳，声音明显卡顿。
  2. 增大 HDMI passthrough ALSA buffer 后，设备出现 Bad page map / Bad page state，严重时重新上电后也会 kernel panic。

判断：
  1. 用户态 EAC3/JOC 的 IEC61937 burst 不是每次输入都会立刻吐出 outBuffer；无 burst 时直接返回会让 ALSA HDMI raw buffer 饿死，造成 XRUN 和功放格式抖动。
  2. 内核 `snd_sunxi_pcm_hdmi.c` raw 模式会为 61937->60958 额外分配 2 倍 DMA shadow buffer，但释放时依赖 `snd_pcm_lib_buffer_bytes(substream) * 2`。该值受 raw 模式下 `runtime->buffer_size` 翻倍/还原影响，可能和真实分配大小不一致，导致释放错误大小并破坏页表。
  3. `sunxi_pcm_copy_raw()` 在写 60958 shadow buffer 前没有检查 `2 * hwoff + 2 * bytes` 是否超过 raw DMA shadow buffer；普通 PCM DMA 区也需要先检查 `hwoff + bytes`。
  4. `SunxiPassthough::writeDataBurst()` 只检查 `mByteCursor <= outputTempBufferSize`，没有检查 `mByteCursor + numBytes`，存在输出临时 buffer 越界风险；`AUDIO_RAW_DATA_EAC3_JOC` 也应走 EAC3 IEC buffer 大小。

改动：
  1. `kernel/linux-5.4/sound/soc/sunxi_v2/snd_sunxi_pcm_hdmi.c`
     - 在 `g_pcm` 中记录 `raw_dma_bytes`，分配和释放都使用真实字节数。
     - `dmaengine_slave_config()` 失败时释放已分配 raw DMA 并恢复 `substream->dma_buffer.addr`。
     - `sunxi_pcm_copy_raw()` 写普通 DMA 和 raw DMA shadow buffer 前都做边界检查，越界返回 `-EINVAL`。

  2. `platform/allwinner/multimedia/libtmedia/tplayer/awsink/spdif/SunxiPassthough.cpp`
     - `AUDIO_RAW_DATA_EAC3_JOC` 使用 EAC3 IEC61937 输出缓存大小。
     - `writeDataBurst()` 改为检查剩余容量，避免 `mByteCursor + numBytes` 写越界。

  3. `platform/allwinner/multimedia/libtmedia/tplayer/awsink/tsound_ctrl.c` / `tsound_ctrl.h`
     - 恢复 ALSALIB 直写 HDMI raw 所需的 route、双输出、状态字段和 reopen 入口。
     - EAC3/JOC HDMI passthrough 使用 `192000Hz / 2ch / S16`，period 调整为 `3072 * 8`，在 HDMI `periods_max=8` 和 128KB playback-cma 限制内提供约 128ms 缓冲。
     - 不恢复高 `start_threshold`，避免启动前在 raw 驱动翻倍状态下堆太多数据。
     - 仅在 HDMI raw 已 `RUNNING` 且缓冲低于 2 个 period 时补一包 IEC 0，填补 burst 空窗，缓解残余 XRUN。

验证：
  1. 当时已重新编译内核，`snd_sunxi_pcm_hdmi.o` 有重新编译记录。
  2. 当时已重编 `libtmedia` 并打包 `p1_nor_8733` 镜像。
  3. 已在当前回退后的源码上校验补丁：`git apply --check 开发记录/H133-HDMI透传卡顿与raw-DMA修复.patch` 通过。
  4. 上次打包镜像：
     `/home/xia/Work/H133-HDMI/out/h133_linux_p1_nor_8733_uart0_nor.img`
     MD5：`77ad99945c584d65b099e4228a419bae`

补丁文件：
  `开发记录/H133-HDMI透传卡顿与raw-DMA修复.patch`
