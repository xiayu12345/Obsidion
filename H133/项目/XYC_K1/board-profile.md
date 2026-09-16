# H133 p1_nor_XYC_K1 板级档案（鑫宇宸 H133-K1 LVDS）

> **当前定稿（2026-09-08）**。LCD + HDMI 已出图，背光 GPIO 常亮。板差异只进本板件目录。

## 工程标识

| 项 | 值 |
|----|-----|
| 板级 | **p1_nor_XYC_K1** |
| 项目 | 鑫宇宸（资料在 `硬件资料/鑫宇宸/`） |
| 原理图 | `H133-K1原理图.pdf`（h133-k1-v0_0825） |
| 屏 | **LTN141AT0-001**（同系列 AT02/AT13），14.1" **1280×800 LVDS 1ch 6-bit** DE-only |
| panel | **`xyc_k1_lvds`** |
| UI / fb0 | **1280×800**（与物理屏一致，无 DE 缩放） |
| 触摸 | **BL3676**（`betterlife_ts@2c`，I2C `0x2C`） |
| WiFi | **RTL8733BU**（随 JYY070 基线） |
| lunch | `h133-p1_nor_XYC_K1-tina` |
| 镜像 | `out/h133_linux_p1_nor_XYC_K1_uart0_nor.img` |
| 板级配置 | `device/config/chips/h133/configs/p1_nor_XYC_K1/`（`device/product/configs/p1_nor_XYC_K1` 同 inode） |
| OpenWrt target | `openwrt/target/h133/h133-p1_nor_XYC_K1/` |

## 板件隔绝

| 允许 | 禁止 |
|------|------|
| 只改 `configs/p1_nor_XYC_K1/**`、`h133-p1_nor_XYC_K1/**` | 改 `p1_nor_JYY070` / 其它板 DTS 迁就本屏 |
| 独立 `xyc_k1_lvds.c` | 改 `jyy070_lvds.c` / `default_panel.c` |
| 本板 `usbc0` 注释 PB11/PB12 | 把 USB ID/VBUS 脚改回共享板 |

## 显示定稿

| 项 | 取值 |
|----|-----|
| `lcd_driver_name` | `xyc_k1_lvds` |
| `lcd_if` | 3（LVDS） |
| `lcd_x/y` | 1280 / 800 |
| `lcd_dclk_freq` | **69**（AT13 typ 69.3MHz） |
| porch | `hbp=80` `ht=1416` `hspw=32` / `vbp=10` `vt=816` `vspw=6` |
| LVDS | 1ch、`colordepth=1`（6bit）、`frm=1`、NS |
| `fb0` | 1280×800 |
| `chn_cfg_mode` | 1（双 DE：LCD=DE0，HDMI 写回） |
| `screen0_output_type` | 1（LCD） |
| U-Boot `disp_init_enable` | **1** |
| `setting.ini` | `disp_rotate=0`，`tp_rotate=0` |

## 背光（定稿）

| 项 | 取值 |
|----|-----|
| 硬件 | LCD-PWM=**PB12** → PT4117B **EN**（高电平才工作） |
| 软件 | **`lcd_pwm_used=0`**，`lcd_bl_en = PB12 GPIO_ACTIVE_HIGH` |
| `&pwm0` | **`status=okay`，不配 pinctrl**（disabled 会 `sunxi_pwm_probe` 空指针崩机） |
| 灯条供电 | 16P LVDS **没有**背光脚；灯走 PT4117 `VLED+/VLED-`（CON5 / CN6） |

`lcd_pwm_pol=1`（active low）会让 PB12 大部分时间低，14.1" 灯条启不来。PWM 调光留到灯亮之后再开（到时 `pwm_pol=0` 并给 pwm0 配 pinctrl）。

## 触摸

专题：[20260908-BL3676触摸适配](../../开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-BL3676触摸适配/README.md)

| 属性 | 值 |
|------|-----|
| 芯片 | BL3676，`compatible = "BTL,betterlife_ts"` |
| 总线 | TWI1 PG8/PG9，`twi_drv_used=0`（DMA 会申请不到通道） |
| 地址 | `0x2C` |
| RST / INT | PG2 / PG3（`gpios[0]`/`[1]`） |
| `TP_MAX_X/Y` | 1280 / 800 |
| 驱动 | `kernel/.../touchscreen/betterlife_ts/` |
| `bsp_defconfig` | `CONFIG_TOUCHSCREEN_BETTERLIFE_TS=y`，GSL/GT9xx **not set** |

## 旋转

| 链路 | 本板 |
|------|------|
| UI `disp_rotate` | **0** |
| 触摸 `tp_rotate` | **0** |
| `dual_display_rot` | **0** |
| 视频 WB | 横屏应对齐 JYY070=`0`；`libtmedia` **尚未加本 target 挂钩**（播 MV 前补） |

## 编译

```bash
export PATH="/root/Work/H133-AIKTV/prebuilt/hostbuilt/make4.1/bin:$PATH"
./tools/build_p1_nor_XYC_K1.sh kernel
./tools/build_p1_nor_XYC_K1.sh full
# 产物：out/h133_linux_p1_nor_XYC_K1_uart0_nor.img
```

NOR U-Boot **不要** `./build.sh bootloader uboot force`（会 distclean 并把 XYC panel 打掉）。应用 `sun8iw20p1_nor_defconfig`，产物是 `u-boot-spinor-sun8iw20p1.bin`。

## 相关开发记录

- [20260908-板件克隆与LVDS点亮定稿](../../开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/README.md)
- [20260908-BL3676触摸适配](../../开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-BL3676触摸适配/README.md)
- [20260909-GPADC双组20键](../../开发记录/板件开发记录/XYC_K1/20260909-XYC_K1-GPADC双组20键/README.md)
