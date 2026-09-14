---
project: ZS101
kind: log
date: 2026-08-25
---

# ZS101 ILI9881C MIPI 显示点亮 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | **2026-08-25 实机点亮** |
| 板型 | **`p1_nor_ZS101`** |
| 屏 | 中深 ZS101NI4042J4H8II-B，**800×1280 MIPI**，IC **ILI9881C** |
| panel | `zs101_ili9881c` |
| 记录 | [开发记录.md](./开发记录.md) |
| 资料梳理 | [../20260817-纽曼ZS101-资料梳理与待确认/](../20260817-纽曼ZS101-资料梳理与待确认/README.md) |
| 触摸 | [../20260827-ZS101-GT928触摸适配/](../20260827-ZS101-GT928触摸适配/README.md) |

---

## 补丁（只含屏幕）

路径：[patches/](./patches/)

不含音频/投屏/`tsound_ctrl`。不含 OpenWrt 整包（WiFi/蓝牙等）；板级树其余仍从 JL_M101 克隆。

| 文件 | 内容 |
|---|---|
| `01-kernel-uboot-panel.patch` | kernel+U-Boot `zs101_ili9881c` + Kconfig/`panels`/`Makefile` + U-Boot `LCD_SUPPORT_ZS101_ILI9881C` |
| `02-board-display.patch` | 本板 `board.dts` / `uboot-board.dts` / `bsp_defconfig` / `setting.ini` / 编译脚本 |
| `03-shared-hooks.patch` | libtmedia `VIDEO_WB=90` 加上本 target；`.openwrt_targets` 登记 |
| `zs101-display.patch` | 以上合并 |
| `apply-zs101-display.sh` | 应用 |
| `gen-zs101-display-patch.sh` | 相对 `qj/main` 重生成 |

```bash
# 干净 SDK 根（需已有 p1_nor_JL_M101 克隆能力；本补丁补屏）
bash H133-AI-Skills/开发记录/板件开发记录/ZS101/20260825-ZS101-ILI9881C-MIPI显示点亮/patches/apply-zs101-display.sh

./tools/build_p1_nor_ZS101.sh full
```

当前出图树再 apply 会 already exists，属正常。
