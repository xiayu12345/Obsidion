---
project: LQ190
kind: log
---

# LQ190 — 文档索引

| 项 | 内容 |
|---|---|
| 板型 | `p1_nor_LQ190`（**NOR**） |
| 基线 | 自 `p1_nor_LQ140M1JW61` 整树克隆（横屏、rot=0、RTL8733BU） |
| 目标屏 | Sharp **LQ190E1LX65** 1280×1024 LVDS + 鸿博 **GM8775C** MIPI→LVDS |
| panel | `lq190_mipi2edp`（名称历史占位 eDP；链路为 MIPI→LVDS） |
| 状态 | **2026-08-12 显示已定稿（实机清晰；灌表 `0x13=0x63`）** |
| 板级档案 | [board-profile-p1_nor_LQ190.md](../../../skills/h133-display/board-profile-p1_nor_LQ190.md) |

## 专题记录

| 目录 | 说明 |
|------|------|
| [20260811-LQ190-GM8775C-MIPI显示定稿/](./20260811-LQ190-GM8775C-MIPI显示定稿/README.md) | **出图定稿（08-12：`0x13=0x63` 消糊）** + [patches/](./20260811-LQ190-GM8775C-MIPI显示定稿/patches/) |
| [20260810-背光BL-EN拉高实机验证/](./20260810-LQ190-背光BL-EN拉高实机验证/README.md) | J9534 `LCD-BL-EN`=PG15；实机 3.3V |
| [20260807-鸿博LQ190E1LX65-资料梳理与待确认/](./20260807-鸿博LQ190E1LX65-资料梳理与待确认/README.md) | 早期资料梳理（历史） |

## 编译

```bash
./tools/build_p1_nor_LQ190.sh kernel
./tools/build_p1_nor_LQ190.sh full
# 产物：out/h133_linux_p1_nor_LQ190_uart0_nor.img
```
