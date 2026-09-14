---
project: JYY070
kind: log
date: 2026-07-08
---

# JYY070 LVDS 显示开发 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | 2026-07-08（索引）；**定稿状态见板级档案 2026-07-17** |
| 板型 | `p1_nor_JYY070`（主验证）；`p1_nor`（MIPI 竖屏回归对照） |
| 屏参 | JYY070BD35L27A1-50，7" **1024×600 LVDS** 横屏 |
| 设计原则 | **与 p1_nor 异显同框架**；UI **1280×800** → DE0 缩放到 **1024×600** |
| 合并补丁 | [patches/jyy070-lvds-display-phase1-5.patch](./patches/jyy070-lvds-display-phase1-5.patch) |
| 实机镜像 | `out/h133_linux_p1_nor_JYY070_uart0_nor.img` |
| **当前定稿** | [board-profile-p1_nor_JYY070.md](../../../../skills/h133-display/board-profile-p1_nor_JYY070.md)（UI `disp_rotate=0` / 触摸 `tp_rotate=0` / 视频 `VIDEO_WB_MIRROR_ROTATE=0`） |

---

## 阅读顺序

| 步骤 | 文档 | 内容 | 补丁段 |
|---|---|---|---|
| 0 | [00-背景与路径统一.md](./00-背景与路径统一.md) | 目标、p1_nor 对照、fix_lcd 废弃、统一链路 | — |
| 1 | [01-kernel-panel驱动.md](./01-kernel-panel驱动.md) | 内核 `jyy070_lvds.c` panel | `01-kernel-panel` |
| 2 | [02-uboot-panel启动logo.md](./02-uboot-panel启动logo.md) | U-Boot logo / panel | `02-uboot-panel` |
| 3 | [03-DTS切换LVDS.md](./03-DTS切换LVDS.md) | MIPI→LVDS，`fb0=1024×600` | `03-dts` |
| 4 | [04-app层与sunxifb统一路径.md](./04-app层与sunxifb统一路径.md) | desk 启动、Makefile、**sunxifb 统一路径** | `04` + `sunxifb` |
| 5 | [05-HDMI异显dual_display_rot.md](./05-HDMI异显dual_display_rot.md) | 内核 G2D 旋转 DTS 可配，`= <0>` | `05-dual-display-rot` |
| 7 | [07-DE硬件缩放1280x800.md](./07-DE硬件缩放1280x800.md) | **fb0=1280×800**，DE0 缩放到 1024×600 | `06-dts-hw-scale` |
| 6 | [06-编译与实机验证.md](./06-编译与实机验证.md) | 打补丁、编译、串口验收 | — |

**建议：** 先读 **00** 理解为何统一路径，再按 1→6 顺序实施；若只改 sunxifb，直接看 **04** 和 **06**。

---

## 补丁工具

```bash
# 一键应用阶段 1～5
bash H133-AI-Skills/开发记录/板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/patches/apply-jyy070-lvds-display.sh

# 重新生成合并补丁
bash H133-AI-Skills/开发记录/板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/patches/gen-jyy070-lvds-display-patch.sh
```

---

## 与 bringup 资料包的关系

| 本目录 | bringup 目录 |
|---|---|
| 阶段 1～3 概要 + 补丁段 | [01-LVDS显示驱动开发记录.md](../../JYY070-7寸LVDS屏-bringup/01-LVDS显示驱动开发记录.md) 详述硬件/时序 |
| 04 sunxifb **统一路径**（当前采用） | [02-rotate0双缓冲修复](../../JYY070-7寸LVDS屏-bringup/02-rotate0双缓冲修复记录.md) 的 **fix_lcd 方案已废弃** |
| 05 dual_display_rot | [03-HDMI双显旋转DTS可配](../../JYY070-7寸LVDS屏-bringup/03-HDMI双显旋转DTS可配开发记录.md) 原理详解 |

> **勿混打：** `bringup/patches/04-app-sunxifb.patch` 内 sunxifb 段为旧 fix_lcd；本目录 phase1-5 已替换为统一路径。

---

*2026-07-08：文档拆分为分步阅读；实机 log 确认 dual_display_rot=0、无 fix_lcd。*
