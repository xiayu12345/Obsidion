# 02 — DTS 与配置

## 1. DTS（`&twi1`）

```text
device/config/chips/h133/configs/p1_nor_LQ140M1JW61/linux-5.4/board.dts
```

（`board.dts` 为指向该文件的符号链接。）

```dts
&twi1 {
	clock-frequency = <400000>;
	/* ... pinctrl / dma ... */
	status = "okay";

	/* 原厂 Jadard JD9366TS：I2C 0x68，RST PG2，INT PG3 */
	jadard@68 {
		compatible = "jadard,jdcommon";
		reg = <0x68>;
		status = "okay";
		jadard,panel-sense-nums = <30 48>;
		/* 物理竖屏 1200×1920；按移植指南对调 → 驱动交换 XY */
		jadard,panel-coords = <0 1920 0 1200>;
		jadard,panel-max-points = <10>;
		jadard,int-is-edge = <1>;
		jadard,irq-gpio = <&pio PG 3 GPIO_ACTIVE_HIGH>;
		jadard,rst-gpio = <&pio PG 2 GPIO_ACTIVE_HIGH>;
	};
};
```

说明：

- 不要写 `ctp_*` / `compatible = "jadard,jd9366ts"`（自写调试驱动已删）。
- 移植指南：`<0 W 0 H>` → `<0 H 0 W>` 时，`JD_X_RES > JD_Y_RES`，驱动上报交换 XY。
- Y 镜像不在 DTS，在 `jadard_common.c`（见 [03](./03-改动与踩坑.md)）。

---

## 2. `bsp_defconfig`

```text
# CONFIG_TOUCHSCREEN_GT9XXNEW_TS is not set
CONFIG_TOUCHSCREEN_JADARD_CHIPSET=y
CONFIG_TOUCHSCREEN_JADARD_MODULE=y
CONFIG_TOUCHSCREEN_JADARD_IC_JD9366TP=y
```

---

## 3. userspace

| 项 | 取值 | 说明 |
|---|---|---|
| `disp_rotate` | `3` | 竖屏 fb → LVGL 1920×1200 |
| `tp_rotate` | `0` | 轴已在驱动内处理，桌面不再旋 |

输入名一般为 `jadard_tp`（`/dev/input/event*`）。
