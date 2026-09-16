---
project: JL_M101
kind: fix
date: 2026-07-30
---

# HDMI 同显：DE1 linebuf 超宽 1:1 黑边

| 项 | 内容 |
|----|------|
| 日期 | 2026-07-30 |
| 现象板 | 主要在 `p1_nor_LQ140M1JW61`（LCD=HDMI=1080p、`dual_display_rot=0`）暴露 |
| 补丁范围 | **公共内核** `de_rtmx.c`（全 H133 同套 DE 驱动） |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/01-de-rtmx-coarse-linebuf.patch](./patches/01-de-rtmx-coarse-linebuf.patch) |
