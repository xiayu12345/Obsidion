# H133 p1_nor_WXY050 板级档案（婺芯源 5" MIPI / ST7121P）

> **2026-09-07 SDK 已克隆**（基线 `p1_nor_JL_M101`）。**尚未点亮**。触摸 DTS 已关，等厂商资料。  
> 京龙转接板：见 [20260902 资料梳理](../../开发记录/板件开发记录/WXY050/20260902-WXY050-资料梳理与JL硬件评估/README.md)。  
> 克隆记录：[20260907 板件克隆](../../开发记录/板件开发记录/WXY050/20260907-WXY050-板件克隆与显示/README.md)

## 工程标识

| 项 | 值 |
|----|-----|
| 项目 | **未写明** |
| 板级 | **p1_nor_WXY050**（NOR） |
| 屏 | 婺芯源 **WXY050M022LA1201-SW2**，5.0" **720×1280 MIPI 4-lane**，IC **ST7121P** |
| 驱动名 | `wxy050_st7121p` |
| UI / fb0 | 物理 **720×1280**；`disp_rotate=3` → LVGL **1280×720**（未实机） |
| 触摸 | ST7121P TDDI；本板 `ctp@40` **disabled**（不是 GSL3670） |
| WiFi | RTL8733BU |
| lunch | `h133-p1_nor_WXY050-tina` |
| 镜像 | `out/h133_linux_p1_nor_WXY050_uart0_nor.img` |
| 板级配置 | `device/config/chips/h133/configs/p1_nor_WXY050/` |
| OpenWrt target | `openwrt/target/h133/h133-p1_nor_WXY050/` |
| 编译 | `./tools/build_p1_nor_WXY050.sh [full\|kernel\|rootfs]` |
| 基线 | `p1_nor_JL_M101` |

## 板件隔绝

| 允许 | 禁止 |
|------|------|
| 只改本板 `configs/p1_nor_WXY050/`、`h133-p1_nor_WXY050/` | 改 JL_M101 / 8733 DTS 迁就本屏 |
| 独立 `wxy050_st7121p.c` | 改 `jl_m101_jd9365da.c` / `default_panel.c` |
| 京龙 CON5 作调试夹具时用转接线 | 把 5" FPC 直接插进 CON5 40P |

## 显示（资料推算，未实机）

| 项 | 值 |
|----|-----|
| `lcd_driver_name` | `wxy050_st7121p` |
| 分辨率 | **720×1280** |
| DSI | `lcd_if=4`，**4-lane**，`dsi_if=0` |
| 时序 | HSA4 HBP40 HFP40 / VSA4 VBP30 VFP280；PCLK **78 MHz** |
| Allwinner | `hspw=4` `hbp=44` `ht=804`；`vspw=4` `vbp=34` `vt=1594`；`lcd_dclk_freq=78` |
| RESET / PWM | PB11 / PB12 PWM0@50kHz；**RESET 须 1.8V 档，背光勿用京龙 160mA** |
| U-Boot | `disp_init_enable=0` |

Init：`SSD_SEND(0x11,…)` → `dsi_dcs_wr`。H133 **不需要 SSD2828**。

## 京龙硬件结论

H133 MIPI **能驱**；CON5 **不能对插**。缺 IOVCC 1.8V，RESET 改 1.8V 档，背光 18V/40mA 单独处理。触摸走 FPC 29–32，**GSL3670 用不了**。

## 硬件资料

- `H133-AI-Skills/硬件资料/5寸屏幕/WXY050M022LA1201-SW2.pdf`
- `…/ST7121P_Datasheet_V1.0(3)(1).pdf`
- `…/ST7121P_MDT5.0(MLAG050WQ11 G)_initial code_gamma2.2_260819 - 副本.txt`
- `…/e81ba693bfa54a40f410624b956df620.png`
- 转接板：`硬件资料/四川京龙/s10-h133-v1_0625.pdf`

## 编译

```bash
./tools/build_p1_nor_WXY050.sh kernel
./tools/build_p1_nor_WXY050.sh full
```
