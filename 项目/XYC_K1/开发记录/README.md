---
project: XYC_K1
kind: log
---

# 鑫宇宸 H133-K1 LVDS — 文档索引

| 项 | 内容 |
|---|---|
| 项目 | 鑫宇宸（资料在 `硬件资料/鑫宇宸/`） |
| 板型 | `p1_nor_XYC_K1`（从 `p1_nor_JYY070` 克隆） |
| 原理图 | `H133-K1原理图.pdf`（h133-k1-v0_0825），框图 **LVDS 768p** |
| 屏 | **缺规格书**；时序暂用 JYY070 占位 |
| 触摸 | BL3676 I2C `0x2C`（驱动已接入） |
| 状态 | **2026-09-08 SDK 已克隆**；未点亮 |

## 专题记录

| 目录 | 说明 |
|------|------|
| [20260908-XYC_K1-板件克隆/](./20260908-XYC_K1-板件克隆/README.md) | 克隆范围、PWM/CTP、编译 |

## 编译

```bash
./tools/build_p1_nor_XYC_K1.sh kernel
./tools/build_p1_nor_XYC_K1.sh full
# 产物：out/h133_linux_p1_nor_XYC_K1_uart0_nor.img
```
