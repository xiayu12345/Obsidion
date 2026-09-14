---
project: JL_M101
kind: log
date: 2026-08-25
---

# 三路旋转控制（定稿）

| 项 | 内容 |
|---|---|
| 日期 | 2026-08-25 |
| 范围 | **架构级**（disp / sunxifb / tplayer，非单板专属） |
| 状态 | **定稿**：机制已在树；新板只改三路旋钮 |
| 正文 | [开发记录.md](./开发记录.md) |
| 改法 | [如何修改.md](./如何修改.md) |
| 补丁 | [patches/](./patches/)（新板对照片段，**勿对当前树 git apply**） |

## 一句话

三路独立：UI = ini `disp_rotate`；HDMI = DTS `dual_display_rot`；视频 WB = Makefile `VIDEO_WB_MIRROR_ROTATE`。

## 典型组合

| 面板 | UI | HDMI | 视频 WB |
|---|---|---|---|
| 竖屏 MIPI（ZS101 / p1_nor / 8733） | `3` | `3` | `90` |
| 横屏 LVDS/LCD（JYY070 / LQ140） | `0` | `0` | `0` |

新板逐步改：[如何修改.md](./如何修改.md)
