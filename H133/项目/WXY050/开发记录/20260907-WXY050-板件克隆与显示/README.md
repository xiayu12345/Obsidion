---
project: WXY050
kind: log
date: 2026-09-07
---

# 20260907 — p1_nor_WXY050 板件克隆（只做显示）

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-07 |
| 板型 | **`p1_nor_WXY050`** |
| 基线 | `p1_nor_JL_M101` |
| 状态 | SDK 已克隆；**未实机点亮**；触摸 DTS **disabled** |

从京龙整树克隆独立板级，只换 5" ST7121P panel / 时序 / fb0。触摸等厂商资料。

## 落地

| 项 | 值 |
|---|---|
| lunch | `h133-p1_nor_WXY050-tina` |
| panel | `wxy050_st7121p`（SSD2828 `SSD_SEND(0x11,…)` → `dsi_dcs_wr`） |
| lcd | 720×1280，4-lane，`dclk=78`，`hspw/hbp/ht=4/44/804`，`vspw/vbp/vt=4/34/1594` |
| RESET / PWM | PB11 / PB12 PWM0@50kHz（跟京龙脚，电平/背光电流仍按 [20260902](../20260902-WXY050-资料梳理与JL硬件评估/README.md) 改硬件） |
| U-Boot | `disp_init_enable=0` |
| CTP | `ctp@40` **disabled**（不要 GSL3670） |
| `disp_rotate` | **3** |

## 编译

```bash
./tools/build_p1_nor_WXY050.sh kernel
./tools/build_p1_nor_WXY050.sh full
# 产物：out/h133_linux_p1_nor_WXY050_uart0_nor.img
```

禁止改兄弟板 DTS、改 `default_panel.c` / `jl_m101_jd9365da.c`。
