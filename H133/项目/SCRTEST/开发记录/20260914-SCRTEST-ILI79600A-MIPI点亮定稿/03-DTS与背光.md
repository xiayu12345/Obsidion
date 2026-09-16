# 03 — DTS 与背光

内核 `linux-5.4/board.dts` 与 `uboot-board.dts` 的 lcd0 **必须同一套**（smooth display 继承 U-Boot TCON）。

## 3.1 lcd0 定稿

```dts
&lcd0 {
	lcd_used            = <1>;
	lcd_driver_name     = "scrtest_ili79600a";
	lcd_backlight       = <200>;
	lcd_if              = <4>;

	lcd_x               = <1200>;
	lcd_y               = <1920>;
	lcd_width           = <180>;
	lcd_height          = <288>;
	lcd_dclk_freq       = <110>;

	lcd_pwm_used        = <1>;
	lcd_pwm_ch          = <0>;
	lcd_pwm_freq        = <50000>;
	lcd_pwm_pol         = <1>;
	lcd_pwm_max_limit   = <255>;

	lcd_hbp             = <24>;
	lcd_ht              = <1244>;
	lcd_hspw            = <4>;
	lcd_vbp             = <66>;
	lcd_vt              = <2256>;
	lcd_vspw            = <2>;

	lcd_dsi_if          = <0>;
	lcd_dsi_lane        = <4>;
	lcd_dsi_format      = <0>;

	lcd_gpio_0          = <&pio PB 11 GPIO_ACTIVE_HIGH>;
};
```

`fb0_width/height`：1200×1920。

---

## 3.2 背光

s10：`LCD-PWM=PB12/PWM0` → PT4117B EN，**50kHz**。本板 `pwm_pol=1`（跟京龙）。`&pwm0` 保持 **okay + pinctrl**，不要 disabled（会 panic）。

---

## 3.3 旋转 / 触摸

| 项 | 值 |
|---|---|
| `setting.ini` `disp_rotate` | **1**（竖屏物理 + Guider 1280×800） |
| `video_rotate` | **2** |
| `video_screen` | 1200×1920 |
| `ctp@40` | **disabled** |

板上 UDISK `setting.ini` 会覆盖。
