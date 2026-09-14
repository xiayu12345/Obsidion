# libaudioroute HDMI 杜比透传 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | **2026-08-22** |
| 首验板型 | `p1_nor_JL_M101`（京龙 10.1" MIPI，TP-H10 功放） |
| 目标 | 设置切 **HDMI/ARC** 后，tplayer 播放 **AC3/EAC3** 可透传至电视；PCM（AAC 等）正常出声 |
| 状态 | **JL_M101 实机验收通过** |
| 定稿镜像 | `out/h133_linux_p1_nor_JL_M101_uart0_nor.img` md5 `9a45687c8c83d2a2478124ff9c6523e8` |
| 待办 | [设置切换后路由不同步](../20260822-设置切换后播放器路由不同步.md)、[音频路由架构](../音频路由架构.md)、[4K 板移植](../20260822-4K板libaudioroute移植指南.md) |

---

## 阅读

| 文档 | 内容 |
|---|---|
| [开发记录.md](./开发记录.md) | 背景、链路、踩坑、验收 log |

## 补丁

路径：[patches/](./patches/)

| 文件 | 作用 |
|---|---|
| `01-board-audio_configuration.xml.patch` | `OUT_HDMI_ARC` → **sndi2s2**（非 sndowa） |
| `02-defconfig-libaudioroute.patch` | JL_M101 打开 `CONFIG_TR_AUDIO_API_LIBAUDIOROUTE` |
| `03-platform-tsound_ctrl.c.patch` | tplayer 透传 + 跨进程路由同步（相对 H133-0820 SDK） |
| `04-platform-AudioPortAlsaConfig.cpp.patch` | `direct_mode` 直写 PCM，绕过 amix |
| `apply-jl-m101-hdmi-dolby.sh` | 一键落地 |

```bash
# SDK 根目录；JL_M101 须已落地 20260722 显示定稿
bash H133-AI-Skills/杜比播放/开发记录/20260822-libaudioroute-HDMI透传落地/patches/apply-jl-m101-hdmi-dolby.sh
./tools/build_p1_nor_JL_M101.sh rootfs
```

> **说明**：`03-platform-tsound_ctrl.c.patch` 以 **H133-0820 SDK** 为基线。若 AIKTV 树已合入本次改动，再 apply 会冲突，以当前源码为准。

## 硬件音频拓扑（JL_M101）

| 路由 | 声卡 | 用途 |
|---|---|---|
| 喇叭 / 光纤（MCU） | **sndowa** | `OUT_SPK` / `OUT_OWA` |
| HDMI / ARC | **sndi2s2** | `OUT_HDMI_ARC`，PCM + IEC61937 透传 |

设置 UI：`Speaker(0)` → `audio_output.mode=spdif`；`ARC(1)` → `hdmi`。
