---
project: ZS101
kind: log
---

# ZS101 — 文档索引

| 项 | 内容 |
|---|---|
| 项目 | **纽曼** |
| 板型 | `p1_nor_ZS101`（**NOR**） |
| 基线 | 自 `p1_nor_JL_M101` 整树克隆（同 800×1280 MIPI、rot=3、RTL8733BU） |
| 目标屏 | 中深 **ZS101NI4042J4H8II-B** 10.1" **800×1280 MIPI**，IC **ILI9881C** |
| panel | `zs101_ili9881c` |
| 状态 | **2026-08-25 显示点亮**；**2026-08-27 GT928 触摸定稿** |
| 板级档案 | [board-profile-p1_nor_ZS101.md](../../../skills/h133-display/board-profile-p1_nor_ZS101.md) |

## 专题记录

| 目录 | 说明 |
|------|------|
| [20260827-ZS101-GT928触摸适配/](./20260827-ZS101-GT928触摸适配/README.md) | **FXT101041 GT928** 四角 1:1 + [patches/](./20260827-ZS101-GT928触摸适配/patches/) |
| [20260825-ZS101-ILI9881C-MIPI显示点亮/](./20260825-ZS101-ILI9881C-MIPI显示点亮/README.md) | **实机点亮** + [patches/](./20260825-ZS101-ILI9881C-MIPI显示点亮/patches/)（只含屏幕） |
| [20260817-纽曼ZS101-资料梳理与待确认/](./20260817-纽曼ZS101-资料梳理与待确认/README.md) | 规格书/init 梳理、旋转结论、克隆范围 |

## 编译（克隆落地后）

```bash
# 干净树：先显示、再触摸
bash H133-AI-Skills/开发记录/板件开发记录/ZS101/20260825-ZS101-ILI9881C-MIPI显示点亮/patches/apply-zs101-display.sh
bash H133-AI-Skills/开发记录/板件开发记录/ZS101/20260827-ZS101-GT928触摸适配/patches/apply-zs101-gt928-tp.sh
./tools/build_p1_nor_ZS101.sh kernel
./tools/build_p1_nor_ZS101.sh full
# 产物：out/h133_linux_p1_nor_ZS101_uart0_nor.img
```
