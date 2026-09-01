---
project: p1_nor_4k
kind: docs
---

# H133 HDMI 音频透传方案

给老板评估用。对方给的是 SPDIF 透传补丁；HDMI 是仿照同一条 `nNeedDirect` 分支，只换最后一公里 sink。

对照备份：

- 对方补丁：`备份-不允许拿这里的东西退回代码/透传/`
- 能出声的快照：`备份-不允许拿这里的东西退回代码/成功，但卡顿，mp4声音低沉/`
- 当前工程树未合入

**评估时先看 `nNeedDirect` 分支，不要只看 HDMI 设备名。** 透传不是 HDMI 驱动旁路。

---

## 一句话

Player 按 codec 置 `nNeedDirect=1` 后，解码器不再真解码，改把 bitstream 原样排队，打成 IEC61937，再按路由写 SPDIF 或 HDMI。HDMI 和 SPDIF 共用前四层，只在 sink 分叉。

---

## 端到端链路

```
Parser (mkv/mov/ts)
    │
    ▼
PlayerSetAudioStreamInfo          ← 关键分叉在这里，不在 HDMI 驱动
    │
    ├─ AC3 / EAC3 / DTS     nNeedDirect=1
    │       │
    │       ▼
    │   adecoderPassthough        不解码，原样排队
    │       │
    │       ▼
    │   IEC61937 打包             SPDIFEncoder 共用
    │       │
    │       ├─ HDMI sink          mixer + hw:sndi2s2
    │       └─ SPDIF sink         PlaybackSPDIF
    │
    └─ AAC / MP3 / 其它     nNeedDirect=0
            │
            ▼
        libadecoder.so            真解码成 PCM
            │
            ▼
        EQ / amix / PCM 设备
```

`nNeedDirect=0` 时：第 3 层改走 `libadecoder.so`，第 4 层不打 IEC，第 5 层走 PCM 设备。

---

## nNeedDirect 分叉（方案关键）

| | PCM 正常路 `nNeedDirect=0` | Raw 透传路 `nNeedDirect=1` |
|---|---|---|
| 解码器 | `AudioDecCompCreate` 打开 `libadecoder.so`，真解码成 PCM | 挂 `adec_passth`，不解码 |
| 后处理 | EQ / 增益 / surround / amix 全开 | 全部跳过（`direct_mode`） |
| HDMI 设备 | `PlaybackHDMI`，mixer 保持 PCM | mixer 设 AC3/DTS/DDP，写 `hw:sndi2s2` |
| 谁走这条 | AAC、MP3、普通 MP4 **必须**走这条 | 仅 AC3 / EAC3 / DTS |

这个开关错了，AAC/MP4 也会走假解码，声音会低沉或怪。

原厂头文件已预留语义（`adecoder.h`）：

- `nRoutine`：0=PCM，1=HDMI raw，2=SPDIF raw
- `nNeedDirect`：0=不走 raw，1=走 raw
- `ulMode`：0=PCM，1=HDMI，2=SPDIF

方案对齐这个语义，不是另起一套。

---

## 五层各自干什么

| 层 | 文件 / 补丁 | 做什么 | 谁加的 |
|---|---|---|---|
| 1 Parser | `cedarx.diff`：mkv / mov / ts | EAC3 必须识别成 EAC3，不能再并到 AC3。否则后面 `nDataType` 会错，IEC 打包和 HDMI mixer 都会跟错。 | 对方补丁 |
| 2 Player 置位 | `player.c` `PlayerSetAudioStreamInfo` | AC3→raw AC3；EAC3→DDP；DTS→DTS；并置 `nNeedDirect=1`。`PlayerInitialAudio` 把这个值传给 `AudioDecCompCreate`。 | 对方补丁 |
| 3 假解码器 | `adecoderPassthough.c` | 接口形状和真解码器一样，但 Decode 只是把 bitstream 排队交给 Render。`Create` 时 `isNeedDirect==1` 走 `memcpy(&AlibItf, &adec_passth)`。 | 对方补丁 |
| 4 IEC61937 | `SunxiPassthough` + `SPDIFEncoder` | 扫 AC3/DTS 帧，加 Pa/Pb 前导，打成 IEC burst。HDMI 和 SPDIF 共用这一层——HDMI 透传也是 IEC 60958/61937。 | 对方补丁 |
| 5 Sink | `tsound_ctrl.c` + `libaudioroute.diff` | SPDIF：`PlaybackSPDIF`。HDMI（仿写）：读 `/etc/audio_output.mode`，`setHdmiRawFlag`，开 `hw:sndi2s2`/`sndhdmi`，按 period 切片写。关设备时 mixer 拉回 PCM。 | HDMI 是仿写 |

---

## codec → 输出参数

| 容器 codec | nDataType | IEC 采样率 | period_size | HDMI mixer |
|---|---|---|---|---|
| AC3 | `AUDIO_RAW_DATA_AC3` | 48000 | 1536 | AC3 |
| EAC3 | `AUDIO_RAW_DATA_DOLBY_DIGITAL_PLUS` | 192000 | 1536 | DOLBY_DIGITAL_PLUS |
| EAC3_JOC | `AUDIO_RAW_DATA_EAC3_JOC` | 192000 | 1536 | DOLBY_DIGITAL_PLUS |
| DTS / DTS_HD | `AUDIO_RAW_DATA_DTS` / `DTS_HD` | 48000 | 512 | DTS |
| AAC 等其它 | 不置位，保持 PCM | 片源采样率 | 默认 | PCM |

置位代码在 `PlayerSetAudioStreamInfo`：

```c
switch (pStreamInfo[i].eCodecFormat) {
    case AUDIO_CODEC_FORMAT_AC3:
        nNeedDirect = 1; nDataType = AUDIO_RAW_DATA_AC3; break;
    case AUDIO_CODEC_FORMAT_EAC3:
        nNeedDirect = 1; nDataType = AUDIO_RAW_DATA_DOLBY_DIGITAL_PLUS; break;
    case AUDIO_CODEC_FORMAT_EAC3_JOC:
        nNeedDirect = 1; nDataType = AUDIO_RAW_DATA_EAC3_JOC; break;
    case AUDIO_CODEC_FORMAT_DTS:
        nNeedDirect = 1; nDataType = AUDIO_RAW_DATA_DTS; break;
    case AUDIO_CODEC_FORMAT_DTS_HD:
        nNeedDirect = 1; nDataType = AUDIO_RAW_DATA_DTS_HD; break;
    default:
        break; /* AAC 等保持 0，走 PCM */
}
```

`AudioDecCompCreate(nNeedDirect)`：

- `0`：`dlopen("libadecoder.so")`，真解码
- `1`：`memcpy(&p->AlibItf, &adec_passth, ...)`，假解码

Render 再通过 `AudioDecCompGetAudioDataType` 把 `nNeedDirect` / `nDataType` 传给 `SoundDeviceSetFormat`。非透传 codec 若被误标，这里会强制打回 PCM。

---

## HDMI 相对 SPDIF，只多了什么

前四层不动。仿写集中在 `tsound_ctrl.c` 的 ALSALIB 路径。

| 点 | 对方 SPDIF | 仿写 HDMI |
|---|---|---|
| 路由 | `PlaybackSPDIF` | `/etc/audio_output.mode`：`spdif` / `hdmi` / `dual` |
| 设备 | `PlaybackSPDIF` | `hw:sndi2s2,0`，失败再 `hw:sndhdmi,0` |
| 硬件格式 | SPDIF 口默认吃 IEC | `setHdmiRawFlag`：`audio data format` = AC3/DTS/DDP |
| 写数据 | IEC burst 一次写 | HDMI 按 `period_size` 切片写 |
| 退出 | 关 passth | mixer 强制拉回 PCM，防下一首 AAC 还走 raw |

`libaudioroute.diff` 给 PCM 口加了 `setPeriodSize` / `setPeriodCount` / `setDirectMode`。`direct_mode=1` 时跳过 amix，直接 `pcm_writei`。

---

## 给老板的判断点

方向对：

- 原厂头文件已预留 `nRoutine`：0=PCM，1=HDMI raw，2=SPDIF raw。方案对齐这个语义。
- HDMI 音频透传行业惯例就是 IEC61937 over HDMI，不必另做一套打包。
- PCM 和 raw 在 Player 入口就分叉，后面各层只读 `nNeedDirect`，链路清楚。

这版快照的风险：

- 能出声，但卡顿；MP4 声音低沉。优先查 PCM 回退是否干净：mixer 残留 raw、period / start_threshold 污染 PCM 路。
- `nNeedDirect` 误置 = 假解码器吃 AAC，听感就是闷、低、不同步。
- EAC3 走 192 kHz。Parser 若仍把 `A_EAC3` 并成 AC3，HDMI mixer 和 IEC 会各说各话。

---

## 合入范围（评估用，未改当前工程）

对方：

- `透传/cedarx.diff`
- `透传/adecoderPassthough.c`
- `透传/tsound_ctrl.diff`
- `透传/libaudioroute.diff`
- `透传/spdif/`

仿写：

- `tsound_ctrl.c` 的 HDMI 路由、mixer、`hw:sndi2s2`、IEC 切片写
- `/etc/audio_output.mode`：`spdif` / `hdmi` / `dual`
