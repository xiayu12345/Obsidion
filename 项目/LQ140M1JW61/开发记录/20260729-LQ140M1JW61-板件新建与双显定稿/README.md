---
project: LQ140M1JW61
kind: log
date: 2026-07-29
---

# LQ140M1JW61 板件新建与双显定稿 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | 2026-07-29（LCD+HDMI 双显实机正常） |
| 板型 | **`p1_nor_LQ140M1JW61`** |
| 屏 | Sharp **LQ140M1JW61** 1920×1080 eDP，经 **QE01MIPI001-V01**（SoC MIPI 4-lane） |
| panel | `lq140_mipi2edp` |
| 副屏 | HDMI 1080p（`dual_display_rot=0`，直出） |
| 板级档案 | [board-profile-p1_nor_LQ140M1JW61.md](../../../../skills/h133-display/board-profile-p1_nor_LQ140M1JW61.md) |
| 镜像 | `out/h133_linux_p1_nor_LQ140M1JW61_uart0_nor.img` |
| 辅 | [../20260729-LQ140M1JW61-双显LCD-HDMI排查.bak/](../20260729-LQ140M1JW61-双显LCD-HDMI排查.bak/)（早期短记，以本文为准） |

---

## 阅读顺序

| 步骤 | 文档 | 内容 |
|---|---|---|
| 0 | [00-总览与定稿.md](./00-总览与定稿.md) | 结论、对照表、与其它板隔离 |
| 1 | [01-板件新建.md](./01-板件新建.md) | 板级 / OpenWrt / 编译脚本 / 公共挂钩 |
| 2 | [02-panel与init.md](./02-panel与init.md) | `lq140_mipi2edp`、无 DCS、仅 `dsi_clk_enable` |
| 3 | [03-DTS与双显.md](./03-DTS与双显.md) | lcd0 时序、fb0、`dual_display_rot`、旋转=0 |
| 4 | [04-实机调试与踩坑.md](./04-实机调试与踩坑.md) | 全绿/偏绿横纹、配置生效、`dev_disp` 回退对照 |
| 5 | [05-编译与验收.md](./05-编译与验收.md) | 编译、验收清单、回归 |

**建议：** 复盘 → 先 **00/04**；干净树落地 → **补丁**；只查 panel/DTS → **02/03**。

---

## 补丁（相对干净基线）

路径：[patches/](./patches/)

| 文件 | 内容 |
|---|---|
| `01-kernel-uboot-panel.patch` | 内核+U-Boot `lq140_mipi2edp` + Kconfig/panels/Makefile 注册；U-Boot defconfig |
| `02-board-tree.patch` | `p1_nor_LQ140M1JW61` + OpenWrt target + `build_*.sh` |
| `03-shared-hooks.patch` | 兄弟板 `not set`、`.openwrt_targets`、`libtmedia` WB=0 |
| `04-docs.patch` | 本定稿文档 + board-profile + 开发记录索引 |
| `lq140-display-final.patch` | 以上合并（**干净树一键落地**） |
| `apply-lq140-display-final.sh` | 应用 |
| `gen-lq140-display-final-patch.sh` | 从当前树重生成 |

```bash
# 干净 SDK 根目录
bash H133-AI-Skills/开发记录/板件开发记录/LQ140M1JW61/20260729-LQ140M1JW61-板件新建与双显定稿/patches/apply-lq140-display-final.sh

# 分段
bash …/patches/apply-lq140-display-final.sh 01

# 重生成（已有出图树）
bash …/patches/gen-lq140-display-final-patch.sh
```

`bootlogo.bmp`、编译中间物（`*.su`）不进补丁；apply 时若缺 bootlogo 会从参照板复制。

> 若树里**已经**有 LQ140 板，再 apply 会报 already exists，属正常。

---

*2026-07-29：双显定稿；`dev_disp.c` 无保留改动；文档与 final 补丁齐备。*
