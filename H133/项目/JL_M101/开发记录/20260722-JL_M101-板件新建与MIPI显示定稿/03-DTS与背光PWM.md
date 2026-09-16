---
project: JL_M101
kind: log
date: 2026-07-22
---

# 03 — DTS、时序与背光 PWM

## 3.1 lcd0 定稿片段（内核 `linux-5.4/board.dts`）

与 U-Boot `uboot-board.dts` 的 lcd0 **保持同步**（除 `disp_init_enable` 可不同）。

```dts
&lcd0 {
	lcd_used            = <1>;
	lcd_driver_name     = "jl_m101_jd9365da";
	lcd_backlight       = <200>;
	lcd_if              = <4>;          /* DSI */

	lcd_x               = <800>;
	lcd_y               = <1280>;
	lcd_width           = <135>;
	lcd_height          = <216>;
	lcd_dclk_freq       = <70>;

	/* s10：LCD-PWM=PB12/PWM0 → PT4117B EN，PWM_Frequence=50KHz */
	lcd_pwm_used        = <1>;
	lcd_pwm_ch          = <0>;
	lcd_pwm_freq        = <50000>;
	lcd_pwm_pol         = <1>;
	lcd_pwm_max_limit   = <255>;

	/* vendor HSA20 HBP20 HFP40 / VSA4 VBP20 VFP20 */
	lcd_hbp             = <40>;
	lcd_ht              = <880>;
	lcd_hspw            = <20>;
	lcd_vbp             = <24>;
	lcd_vt              = <1324>;
	lcd_vspw            = <4>;

	lcd_dsi_if          = <0>;          /* video；burst=2 已试，无图非此因 */
	lcd_dsi_lane        = <4>;
	lcd_dsi_format      = <0>;
	lcd_dsi_te          = <0>;
	lcd_dsi_eotp        = <0>;

	lcd_gpio_0          = <&pio PB 11 GPIO_ACTIVE_HIGH>; /* RESET */
	/* 禁止：lcd_bl_en = PB12（8733 旧写法；本板 PB12 是 PWM） */
	pinctrl-0 = <&dsi4lane_pins_a>;
	pinctrl-1 = <&dsi4lane_pins_b>;
};
```

Porch 换算备忘：

| Vendor | Allwinner |
|---|---|
| HSA=20, HBP=20, HFP=40 | `hspw=20`，`hbp=HSA+HBP=40`，`ht=800+40+40=880` |
| VSA=4, VBP=20, VFP=20 | `vspw=4`，`vbp=24`，`vt=1280+24+20=1324` |

## 3.2 PWM0 @ PB12（原理图强制）

`s10-h133-v1_0625.pdf` LCM 页：

- `LCD-PWM` → RL≈0R → **PT4117B EN**
- 标注 **`PWM_Frequence=50KHz`**（不是 500Hz）
- SoC：`PB12` 复用含 **PWM0**（pinctrl `mux=0x3`）

内核 DTS 增加：

```dts
pwm0_pin_a: pwm0@0 {
	pins = "PB12";
	function = "pwm0";
	drive-strength = <10>;
	bias-pull-up;
};
pwm0_pin_b: pwm0@1 {
	pins = "PB12";
	function = "gpio_in";
	bias-disable;
};

&pwm0 {
	pinctrl-names = "active", "sleep";
	pinctrl-0 = <&pwm0_pin_a>;
	pinctrl-1 = <&pwm0_pin_b>;
	status = "okay";
};
```

U-Boot：在 `&pio` 下同样定义 `pwm0_pin_*`（`muxsel=<3>`），`&pwm0` status okay。

**注意：** 板级另有 `pwm7@PD22`（其它用途）、`pwm3@PB0`（CPU 调压等）——与 LCD 背光无关，勿把 `lcd_pwm_ch` 配成 7。

## 3.3 USB 与 LCD 脚冲突（必改）

8733/p1_nor 残留曾把：

```dts
usb_id_gpio       = <&pio PB 11 …>;
usb_det_vbus_gpio = <&pio PB 12 …>;
```

配在 `usbc0`。本板 **必须注释掉**，否则：

- PB11 被 USB 抢走 → RESET 脉冲发不出去，线可能浮在屏内上拉约 1.8V  
- PB12 无法作 PWM0  

本板 `usbc0` 已注释这两行，并加中文注释说明原因。

## 3.4 转接板 RESET 分压（硬件，软件无法替代）

CON5 旁：

| 档 | R52 | R53 |
|---|---|---|
| **3.3V-RESET（本屏 VCC=3.3V 应用）** | **0R** | **NC** |
| 1.8V-RESET | 1.5K | 1.8K |

屏侧 RESET 静态约 1.8V 且 VCC=3.3V 时，往往 **低于 VIH≈0.7×3.3≈2.31V**，灌码无效。

**禁止：** 用外部恒压 3.3V 灌 RESET——会与 PB11 对打，破坏 H→L→H 脉冲。

改档前：量 **R52 靠主板 `LCD-RST` 输入端**；若已是 3.3V，则当前是分压档，改 R52/R53 即可。

## 3.5 MIPI 走线（转接板）

CON5：D0–D3 + CLK 差分经 2.2Ω 串阻；`lcd_if=4` + `dsi4lane` pinctrl（PD 组）。  
无图且软件/RESET 都正常时：示波器看 CON5 **MIPI-CKP/N（pin15/16 一带）** 是否有 HS。

## 3.6 U-Boot disp

```dts
disp_init_enable = <0>;   /* 调屏/定稿期：避免 smooth 跳过内核 panel_init */
```

内核侧 `&disp` 仍可 `disp_init_enable=<1>`（Linux 自己开屏）。
