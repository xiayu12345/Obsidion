---
project: JL_M101
kind: fix
date: 2026-07-30
---

# 补丁说明

| 文件 | 说明 |
|------|------|
| [01-de-rtmx-coarse-linebuf.patch](./01-de-rtmx-coarse-linebuf.patch) | `de_rtmx_get_coarse_fac`：源=屏且宽≤linebuf 才 return；超宽强制 coarse |

```bash
# 于 H133-AIKTV 仓库根目录
patch -p1 < H133-AI-Skills/开发记录/系统BUG修复/20260730-HDMI同显-DE1-linebuf超宽1比1黑边/patches/01-de-rtmx-coarse-linebuf.patch
```
