---
project: JL_M101
kind: log
date: 2026-08-25
---

# 三路旋转 — 新板对照补丁

架构（`dual_display_rot` 解析、sunxifb 软转、`VIDEO_WB_MIRROR_ROTATE`）**已在本 SDK 树**。  
**不要**对当前树 `git apply` 本目录；按 [如何修改.md](../如何修改.md) 对着改本板文件。

| 文件 | 改哪一路 |
|---|---|
| [01-hdmi-dts-dual-display-rot.example.patch](./01-hdmi-dts-dual-display-rot.example.patch) | DTS `dual_display_rot` |
| [02-ui-setting-ini-disp-rotate.example.patch](./02-ui-setting-ini-disp-rotate.example.patch) | ini `disp_rotate` / `video_rotate` |
| [03-video-libtmedia-wb-rotate.example.patch](./03-video-libtmedia-wb-rotate.example.patch) | Makefile 点名本 target |

`<BOARD>` 换成真实板名（如 `p1_nor_ZS101`）。竖屏套件用注释里的 3 / 90；横屏改成 0。

历史实现补丁（已打进树，仅查阅）：

- HDMI DTS 可配：JYY070 `20260708-JYY070-LVDS显示开发/patches/`
- 视频 WB 宏：`JYY070/20260713-JYY070-视频WB-mirror旋转/jyy070-video-wb-mirror-rotate.patch`
