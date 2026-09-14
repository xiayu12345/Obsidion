---
project: WXY050
kind: log
---

# WXY050 ST7121P MIPI — 文档索引

| 项 | 内容 |
|---|---|
| 项目 | **未写明**（资料在 `硬件资料/5寸屏幕/`） |
| 板型 | `p1_nor_WXY050`（从 `p1_nor_JL_M101` 克隆） |
| 屏 | 婺芯源 **WXY050M022LA1201-SW2**，5.0" **720×1280 MIPI 4-lane**，IC **ST7121P** |
| panel | `wxy050_st7121p` |
| 状态 | **2026-09-07 SDK 已克隆**；未点亮；触摸 disabled |
| 板级档案 | [board-profile-p1_nor_WXY050.md](../../../skills/h133-display/board-profile-p1_nor_WXY050.md) |

## 专题记录

| 目录 | 说明 |
|------|------|
| [20260907-WXY050-板件克隆与显示/](./20260907-WXY050-板件克隆与显示/README.md) | 克隆范围、时序、编译 |
| [20260902-WXY050-资料梳理与JL硬件评估/](./20260902-WXY050-资料梳理与JL硬件评估/README.md) | 规格/init；京龙 CON5 **不能对插** |

## 编译

```bash
./tools/build_p1_nor_WXY050.sh kernel
./tools/build_p1_nor_WXY050.sh full
# 产物：out/h133_linux_p1_nor_WXY050_uart0_nor.img
```
