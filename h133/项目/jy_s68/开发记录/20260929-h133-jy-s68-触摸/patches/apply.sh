#!/bin/sh
# 金运 S68 触摸：TWI2 PG6/PG7，INT PG5，RST PG4，固件 QD101T41A01-K。
set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$DIR/../../../../.." && pwd)

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: $ROOT is not AI-tq SDK root" >&2
	exit 1
fi

install_file() {
	src=$1
	dst=$2
	if [ -f "$dst" ]; then
		echo "==> keep $dst"
		return 0
	fi
	mkdir -p "$(dirname "$dst")"
	cp -a "$src" "$dst"
	echo "==> install $dst"
}

install_file "$DIR/files/gsl3670_jys68.bin" \
	"$ROOT/openwrt/target/h133/h133-p1_nor_JY_S68/busybox-init-base-files/lib/firmware/gsl_firmware/gsl3670_jys68.bin"
install_file "$DIR/files/GSL3670_JY_S68.h" \
	"$ROOT/kernel/linux-5.4/drivers/input/touchscreen/gslx680new/GSL3670_JY_S68.h"

python3 - "$ROOT" <<'PY'
from pathlib import Path
import sys

ROOT = Path(sys.argv[1])
dts = ROOT / "device/config/chips/h133/configs/p1_nor_JY_S68/linux-5.4/board.dts"
if not dts.exists():
    raise SystemExit("missing p1_nor_JY_S68, run 新建板件 first")

text = dts.read_text(encoding="utf-8")
if "gsl3670_jys68" in text and "PG 4 GPIO_ACTIVE_HIGH" in text and 'pins = "PG6", "PG7"' in text:
    print(f"==> touch already JY {dts.relative_to(ROOT)}")
else:
    old_pins = '''	twi2_pins_a: twi2@0 {
		pins = "PC0", "PC1";
		function = "twi2";
		drive-strength = <10>;
	};

	twi2_pins_b: twi2@1 {
		pins = "PC0", "PC1";
		function = "gpio_in";
	};'''
    new_pins = '''	/* S68 CTP：原理图 I2C2 = TWI2，PG6=SCL PG7=SDA */
	twi2_pins_a: twi2@0 {
		pins = "PG6", "PG7";
		function = "twi2";
		drive-strength = <10>;
	};

	twi2_pins_b: twi2@1 {
		pins = "PG6", "PG7";
		function = "gpio_in";
	};'''
    old_twi1 = '''	twi_drv_used = <1>;
	dmas = <&dma 44>, <&dma 44>;
	dma-names = "tx", "rx";
	status = "okay";

	/* JL-M101 板载 GSL3670 @ TWI1 PG8/PG9, INT/RST PG3/PG2, I2C 0x40；固件 conf_3670(3)+GSL3670_JL_M101.h（800×1280）；IRQ 下降沿 */
	ctp@40 {
		compatible = "allwinner,gslX680";
		device_type = "ctp";
		reg = <0x40>;
		status = "okay";
		ctp_name = "gsl3670";
		ctp_twi_id = <0x1>;
		ctp_twi_addr = <0x40>;
		/* exchange 后 1280×800；report 保持同量程，对齐 LVGL（disp_rotate=3） */
		ctp_screen_max_x = <1280>;
		ctp_screen_max_y = <800>;
		ctp_report_max_x = <1280>;
		ctp_report_max_y = <800>;
		ctp_revert_x_flag = <0x0>;
		ctp_revert_y_flag = <0x0>;
		ctp_exchange_x_y_flag = <0x1>;
		ctp_int_port = <&pio PG 3 GPIO_ACTIVE_HIGH>;
		ctp_wakeup = <&pio PG 2 GPIO_ACTIVE_HIGH>;
	};
};'''
    new_twi1 = '''	/* PG8/PG9 是板载 BL24C02，不是触摸 */
	twi_drv_used = <0>;
	status = "okay";
};'''
    old_twi2 = '''&twi2 {
	/* AC107 TWI: 100 kHz, PIO mode (avoid DMA timeout on bring-up) */
	clock-frequency = <100000>;
	pinctrl-0 = <&twi2_pins_a>;
	pinctrl-1 = <&twi2_pins_b>;
	pinctrl-names = "default", "sleep";
	twi_drv_used = <0>;
	status = "okay";
	/* CTP on TP-H10: TWI1 @ PG8/PG9 — not twi2@PC0/1; old gt9xx/fts nodes removed */

	ac107_0: ac107@36 {
		compatible = "ac107_0";
		reg = <0x36>;
		#sound-dai-cells = <0>;
		ac107_dvcc_1v8 = "ac107_dvcc_1v8";
		ac107_avcc_vccio_3v3 = "ac107_avcc_vccio_3v3";
	};
};'''
    new_twi2 = '''&twi2 {
	/* S68 GSL3670：TWI2 PG6/PG7，400 kHz + DMA，与京龙触摸总线设置一致 */
	clock-frequency = <400000>;
	pinctrl-0 = <&twi2_pins_a>;
	pinctrl-1 = <&twi2_pins_b>;
	pinctrl-names = "default", "sleep";
	twi_drv_used = <1>;
	dmas = <&dma 44>, <&dma 44>;
	dma-names = "tx", "rx";
	status = "okay";

	/* QD101T41A01-K / GSL3670，I2C 0x40；INT=PG5 RST=PG4；固件 gsl3670_jys68.bin */
	ctp@40 {
		compatible = "allwinner,gslX680";
		device_type = "ctp";
		reg = <0x40>;
		status = "okay";
		ctp_name = "gsl3670_jys68";
		ctp_twi_id = <0x2>;
		ctp_twi_addr = <0x40>;
		/* 屏 800×1280，exchange 后给 LVGL 1280×800，和克隆来的 disp_rotate=3 对齐 */
		ctp_screen_max_x = <1280>;
		ctp_screen_max_y = <800>;
		ctp_report_max_x = <1280>;
		ctp_report_max_y = <800>;
		ctp_revert_x_flag = <0x0>;
		ctp_revert_y_flag = <0x0>;
		ctp_exchange_x_y_flag = <0x1>;
		ctp_int_port = <&pio PG 5 GPIO_ACTIVE_HIGH>;
		ctp_wakeup = <&pio PG 4 GPIO_ACTIVE_HIGH>;
	};

	/* 金运原理图这条 I2C 是触摸，没有 AC107 */
	ac107_0: ac107@36 {
		compatible = "ac107_0";
		reg = <0x36>;
		#sound-dai-cells = <0>;
		ac107_dvcc_1v8 = "ac107_dvcc_1v8";
		ac107_avcc_vccio_3v3 = "ac107_avcc_vccio_3v3";
		status = "disabled";
	};
};'''
    for name, old, new in (
        ("pins", old_pins, new_pins),
        ("twi1", old_twi1, new_twi1),
        ("twi2", old_twi2, new_twi2),
    ):
        if old not in text:
            raise SystemExit(f"touch block {name} missing in {dts}")
        text = text.replace(old, new, 1)
    dts.write_text(text, encoding="utf-8")
    print(f"==> touch {dts.relative_to(ROOT)}")

old_fw = 'CONFIG_EXTRA_FIRMWARE="gsl_firmware/gsl3670.bin"'
new_fw = 'CONFIG_EXTRA_FIRMWARE="gsl_firmware/gsl3670_jys68.bin"'
for rel in (
    "device/config/chips/h133/configs/p1_nor_JY_S68/linux-5.4/config-5.4",
    "device/config/chips/h133/configs/p1_nor_JY_S68/openwrt/bsp_defconfig",
):
    p = ROOT / rel
    src = p.read_text(encoding="utf-8")
    if new_fw in src:
        print(f"==> firmware already {p.relative_to(ROOT)}")
        continue
    if old_fw not in src:
        raise SystemExit(f"EXTRA_FIRMWARE missing in {p}")
    p.write_text(src.replace(old_fw, new_fw, 1), encoding="utf-8")
    print(f"==> firmware {p.relative_to(ROOT)}")

stale = ROOT / "openwrt/target/h133/h133-p1_nor_JY_S68/busybox-init-base-files/lib/firmware/gsl_firmware/gsl3670.bin"
if stale.exists():
    stale.unlink()
    print("==> remove cloned gsl3670.bin")

print("==> touch ready")
PY

echo "==> OK"
