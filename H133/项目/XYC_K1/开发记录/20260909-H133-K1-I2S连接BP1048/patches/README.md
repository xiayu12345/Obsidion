# 补丁说明

相对 `汇音项目-release` 的 I2S 接入 + BP1048 协议。工作区已经落地。不要把已回退的 16bit MSB / `snd_sunxi_i2s.c` TXIM 打进去。I2S 驱动本身不用改。

截图里还有 LCD、触摸、`sunxi-daudio.c` 等，那些不是这条音频通路，不在本目录。

## 0001-h133-k1-i2s1-dts.patch

把 I2S1 从 TP-H10 AC107 录音残留改成 K1 播放通路：

- PG 组 3.3V（`vcc-pg-supply`）。
- PG11 从 WiFi 32k fanout 改回 I2S1-MCLK。
- 脚复用 PG11–PG15（MCLK/LRCK/BCLK/DIN0/DOUT0）。
- 打开 `i2s1_mach` 播放（去掉 `capture-only`，dummy codec）。
- H133 从机：BCLK/LRCK 由 BP1048 出，H133 只出 256fs MCLK。

只改 `linux-5.4/board.dts`。同目录 `board.dts` 是符号链接。

## 0002-h133-k1-alsa-i2s-route.patch

默认播放接到 `hw:sndi2s1`：

- `asound.conf`：新增 `PlaybackI2S`，`pcm.!default` 指向它。
- `audio_route.sh`：增加 `i2s`，`auto` 默认 `i2s`。
- `audio_output.mode` / `setting.ini` 的 `sound_output=5`。
- `audio_configuration.xml`、tplayer、desk 设置页把 I2S 映射到 `OUT_CVBS`→`sndi2s1`。

原 SPDIF / HDMI / LINEOUT 仍可手动切。`setting.ini` 里的横屏坐标不在本补丁。

## 0003-h133-k1-bp1048-uart.patch

K1 用 BP1048 协议，不再走 TP-H10 的 AF55 SPDIF MCU：

- 新增 `dsp1048.sh`（开机只解静音+音量，不发 And 模式）。
- 新增 `/etc/dsp1048.protocol` 作为板型标记。
- `rc.final` 调 `dsp1048.sh boot`。
- `mcu_spdif_init.sh` 空操作。
- `desk_mcu_quick.c` 走 FIFO，不关 ttyS3。
- MixStation / aas 见到 protocol 文件就不要把串口改回 115200。

## 应用

在 `AI-tq` 根目录：

```sh
AI-skiil/板件开发记录/XYC_K1/20260909-H133-K1-I2S连接BP1048/patches/apply.sh
```

当前工作区已经落地，再打会提示 already applied 或 hunk 对不上（DTS 里还有其它板级改动）。

## 验证

```sh
rg 'frame-master.*i2s1_codec|PG11.*PG12.*PG13' \
  device/config/chips/h133/configs/p1_nor_XYC_K1/linux-5.4/board.dts
rg 'PlaybackI2S' openwrt/target/h133/h133-p1_nor_XYC_K1/busybox-init-base-files/etc/asound.conf
rg 'dsp1048.sh boot' openwrt/target/h133/h133-p1_nor_XYC_K1/busybox-init-base-files/etc/init.d/rc.final
rg 'send_mode 0|And / I2S' \
  openwrt/target/h133/h133-p1_nor_XYC_K1 \
  platform/thirdparty/gui/lvgl-8/app_depend/desk_huiyin
```

前三条应命中。最后一条应无匹配。
