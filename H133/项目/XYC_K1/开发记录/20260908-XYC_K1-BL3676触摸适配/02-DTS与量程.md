# 02 — DTS 与量程

只改本板 `linux-5.4/board.dts` 的 `&twi1`。U-Boot DTS **没有** CTP 节点。

```text
device/config/chips/h133/configs/p1_nor_XYC_K1/linux-5.4/board.dts
```

## 2.1 定稿节点

```dts
&twi1 {
	clock-frequency = <400000>;
	pinctrl-0 = <&twi1_pins_a>;
	pinctrl-1 = <&twi1_pins_b>;
	pinctrl-names = "default", "sleep";
	/* CPU 模式；=1 走 DMA，本板 TWI1 申请不到通道，CTP I2C 写失败 */
	twi_drv_used = <0>;
	status = "okay";

	/* BL3676：TWI1 PG8/PG9，RST=PG2，INT=PG3，I2C 0x2C；gpios[0]=RST [1]=INT */
	betterlife_ts@2c {
		compatible = "BTL,betterlife_ts";
		reg = <0x2c>;
		status = "okay";
		gpios = <&pio PG 2 GPIO_ACTIVE_HIGH>, <&pio PG 3 GPIO_ACTIVE_HIGH>;
		TP_MAX_X = <1280>;
		TP_MAX_Y = <800>;
	};
};
```

从 JYY070 克隆下来是 `ctp@40` / `allwinner,gslX680`。本板删掉 GSL 节点，不要 disabled 留着抢地址。

---

## 2.2 `TP_MAX` 就是 ABS 量程

驱动 `of_property_read_u32(TP_MAX_X/Y)`，再 `input_set_abs_params(..., 0, ts->TP_MAX_*)`。大于量程的点被裁掉。

模组原生约 **1280×800**（四角 raw 见 [测试方法.md](./测试方法.md)）。克隆时沿用 JYY 占位 **1024×600**，四角会被贴边、中间偏。定稿跟 `lcd_x/y`、`fb0` 一样 1280×800。

本驱动 **没有** GSL 那套 `ctp_report_max` / `revert` / `exchange`。方向不对先看模组朝向和 `tp_rotate`，不要抄 GSL 属性进这个节点。

---

## 2.3 `twi_drv_used` 必须 0

`=1` 走 DMA。本板 TWI1 申请不到通道，probe 阶段 I2C 写失败。JYY070 已经是 0，克隆后不要改回去。

---

## 2.4 内核开关

OpenWrt 内核吃 **`openwrt/bsp_defconfig`**，不是 `linux-5.4/config-5.4`。

```text
CONFIG_TOUCHSCREEN_BETTERLIFE_TS=y
# CONFIG_TOUCHSCREEN_GSLX680NEW is not set
# CONFIG_TOUCHSCREEN_GT9XXNEW_TS is not set
```

`input_symlink.sh` 匹配 `*betterlife*`（设备名 `betterlife-touch`，`*touch*` 也能中）。
