# 03 — DTS 与背光

## 3.1 lcd0（内核 `linux-5.4/board.dts` 与 `uboot-board.dts` 同步）

```dts
&lcd0 {
	lcd_used            = <1>;
	lcd_driver_name     = "xyc_k1_lvds";
	lcd_backlight       = <210>;
	lcd_if              = <3>;

	lcd_x               = <1280>;
	lcd_y               = <800>;
	lcd_width           = <303>;
	lcd_height          = <190>;
	lcd_dclk_freq       = <69>;

	lcd_pwm_used        = <0>;
	lcd_bl_en           = <&pio PB 12 GPIO_ACTIVE_HIGH>;

	lcd_hbp             = <80>;
	lcd_ht              = <1416>;
	lcd_hspw            = <32>;
	lcd_vbp             = <10>;
	lcd_vt              = <816>;
	lcd_vspw            = <6>;

	lcd_lvds_if         = <0>;
	lcd_lvds_colordepth = <1>;
	lcd_lvds_mode       = <0>;
	lcd_frm             = <1>;

	pinctrl-0 = <&lvds0_pins_a>;
	pinctrl-1 = <&lvds0_pins_b>;
};
```

无 `lcd_gpio_0`（PB11 只到 MIPI CON5）。

---

## 3.2 背光：GPIO EN，不是 PWM

原理图标 **LCD-PWM=PB12 → PT4117 EN，50kHz**。实机 14.1" 灯条：`lcd_pwm_pol=1` 时脚大部分时间低，EN 启不来。

定稿：

| 项 | 值 |
|---|---|
| `lcd_pwm_used` | 0 |
| `lcd_bl_en` | PB12 HIGH |
| panel | `LCD_bl_open` 只调 `sunxi_lcd_backlight_enable` |

---

## 3.3 pwm0：必须 okay，不许 disabled

全志父节点 `sunxi-pwms` 遍历 pwm0~7。`of_find_device_by_node` 在通道 **disabled** 时返回 NULL → `sunxi_pwm_probe` 空指针，开机 panic。

`p1_nor_4k` 已写过这坑。

```dts
&pwm0 {
	/* 父 pwm 扫 pwm0~7，disabled 会 probe 空指针；本板 PB12 当 GPIO EN，不配 pinctrl */
	status = "okay";
};
```

**不要**给 pwm0 配 `pinctrl-0 = pwm0_pin_a`，否则 PB12 被复用成 PWM，GPIO EN 抢不到脚。

---

## 3.4 USB 脚冲突

模板 `usbc0` 用 PB11=ID、PB12=VBUS。本板这两脚是 LCD-RST / 背光 EN。

```dts
&usbc0 {
	/* usb_id_gpio = <&pio PB 11 GPIO_ACTIVE_HIGH>; */
	/* usb_det_vbus_gpio = <&pio PB 12 GPIO_ACTIVE_HIGH>; */
};
```

与京龙板相同做法。

---

## 3.5 disp / HDMI

```dts
&disp {
	disp_init_enable      = <1>;
	screen0_output_type   = <1>;   /* LCD → DE0 / TCON0 */
	chn_cfg_mode          = <1>;   /* 双 DE */
	fb0_width             = <1280>;
	fb0_height            = <800>;
};
```

HDMI **不是** DE0 直出：DE0 writeback YUV420 → DE1 HDMI。写回跟 DE0 vsync（LCD TCON0）绑在一起。YUV 全 0 → **HDMI 纯绿**。排绿屏先看 TCON0 有没有 vsync，不要先改 HDMI。

---

## 3.6 CTP

**BL3676** `betterlife_ts@2c`，I2C `0x2C`，RST=PG2，INT=PG3，`TP_MAX=1280×800`。

完整过程、踩坑、验收、子集补丁：[20260908-XYC_K1-BL3676触摸适配](../20260908-XYC_K1-BL3676触摸适配/README.md)。本定稿补丁已含驱动和 DTS，当前出图树不必再打触摸补丁。
