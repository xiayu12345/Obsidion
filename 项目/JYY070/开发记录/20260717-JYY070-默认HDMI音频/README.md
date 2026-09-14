---
project: JYY070
kind: log
date: 2026-07-17
---

# JYY070 默认声音输出切 HDMI — 补丁

| 项 | 内容 |
|---|---|
| 日期 | 2026-07-17 |
| 板型 | `p1_nor_JYY070` |
| 补丁 | [jyy070-default-hdmi-audio.patch](./jyy070-default-hdmi-audio.patch) |

## 改动

| 文件 | 内容 |
|------|------|
| `setting.ini` | `sound_output = 1`（HDMI/ARC） |
| `audio_output.mode` | `hdmi` |
| `asound.conf` | 默认 `PlaybackHDMI` / `sndi2s2` |

不含 `tp_rotate` 等其它改动。

## 应用

```bash
cd /path/to/H133-AIKTV
patch -p1 < H133-AI-Skills/开发记录/板件开发记录/JYY070/20260717-JYY070-默认HDMI音频/jyy070-default-hdmi-audio.patch
./tools/build_p1_nor_JYY070.sh rootfs
```

板上若有 `/mnt/UDISK/setting.ini` 且 `sound_output=0`，会覆盖工厂默认，需改成 `1` 或删除该文件。
