# 02 — 驱动与 DTS

## 1. 驱动（共享文件，按 DTS 开关）

`kernel/linux-5.4/drivers/input/sensor/sunxi_gpadc.c`

| 行为 | 约定 |
|---|---|
| 启用条件 | DTS 有合法 `gpio_pin` 才 `has_mux`；其它板无此属性，逻辑与改前相同 |
| 空闲 | ~20ms 翻转 PG18；`key_held` 时停，避免两组电压搅在一起 |
| 键码 | `keyN_val` = GPIO 低（A）；`BkeyN_val` 缺省则同 A |
| 上报 | 按下只报一次 down，松开报 up（`last_report_code` 门控） |
| 日志 | `gpadc key down group=%d idx=%u linux=%u mv=%u` |

`group` 就是 `ischannelB`：1=GPIO 高 / B 组，0=GPIO 低 / A 组。

## 2. 本板 `&gpadc`

```dts
&gpadc {
	channel_num = <1>;
	channel_select = <1>;
	channel_data_select = <1>;
	channel_compare_select = <1>;
	channel_cld_select = <1>;
	channel_chd_select = <1>;
	channel0_compare_lowdata = <1700000>;
	channel0_compare_higdata = <1200000>;
	gpio_pin = <&pio PG 18 GPIO_ACTIVE_HIGH>;
	key_cnt = <10>;
	/* keyN_val=GPIO低/界面；BkeyN_val=GPIO高/音效 */
	...
	status = "okay";
};
```

京龙 5 键电压（210/410/590/750/880）是另一套电阻网，**不能**用在本板。按键补丁也不打包 I2S/PWM 等其它 WIP。

`compare_higdata` 须大于最高有效键（1078 mV）且小于空闲（~1800 mV）。本板沿用 `1200000` µV。

## 3. 内核配置

OpenWrt 编核吃的是 **`openwrt/bsp_defconfig`**，不是 `linux-5.4/config-5.4`。

调试阶段开过 `CONFIG_GPIO_SYSFS=y` 才能 `/sys/class/gpio` 手翻 PG18。量完电压后驱动自己 `gpio_request`，量产可以不开 SYSFS；本树仍打开，方便以后再测。

改 `bsp_defconfig` 后文件时间须新于 `out/h133/kernel/build/.config`，否则 Make 不重配。
