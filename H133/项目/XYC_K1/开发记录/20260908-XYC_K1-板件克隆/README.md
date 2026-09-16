---
project: XYC_K1
kind: log
date: 2026-09-08
---

# 20260908 — p1_nor_XYC_K1 板件克隆（只做板级）

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-08 |
| 板型 | **`p1_nor_XYC_K1`** |
| 基线 | `p1_nor_JYY070` |
| 状态 | SDK 已克隆；**未实机点亮**；CTP **BL3676** 已接入 |

从 JYY070 整树克隆独立板级。原理图有 16P LVDS + CON5 MIPI + PT4117；屏规格书未到，时序占位。

## 落地

| 项 | 值 |
|---|---|
| lunch | `h133-p1_nor_XYC_K1-tina` |
| panel | 暂用 `jyy070_lvds`（空 init）；规格书到了再独立 panel |
| lcd | `lcd_if=3`，时序暂 1024×600（JYY070 占位） |
| RESET / PWM | PB11 / PB12 PWM0@50kHz → PT4117B |
| U-Boot | `disp_init_enable=0` |
| CTP | BL3676 `betterlife_ts@2c`，I2C `0x2C`，RST=PG2，INT=PG3；量程暂 1024×600 |

## 编译

```bash
./tools/build_p1_nor_XYC_K1.sh kernel
./tools/build_p1_nor_XYC_K1.sh full
# 产物：out/h133_linux_p1_nor_XYC_K1_uart0_nor.img
```

禁止改兄弟板 DTS、改 `jyy070_lvds.c`。
