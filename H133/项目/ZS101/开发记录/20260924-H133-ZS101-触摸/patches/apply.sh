#!/bin/sh
# ZS 板触摸换成 GT928。CTP_CFG_GROUP2 需已在 gt9xx.h。
set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$DIR/../../../../.." && pwd)

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: $ROOT is not AI-tq SDK root" >&2
	exit 1
fi

python3 - "$ROOT" <<'PY'
import re, sys
from pathlib import Path

ROOT = Path(sys.argv[1])
DST = ROOT / "device/config/chips/h133/configs/p1_nor_ZS101"
path = DST / "linux-5.4/board.dts"
if not path.exists():
    raise SystemExit("missing p1_nor_ZS101, run 新建板件 first")

CTP_OLD = '''	/* JL-M101 板载 GSL3670 @ TWI1 PG8/PG9, INT/RST PG3/PG2, I2C 0x40；固件 conf_3670(3)+GSL3670_JL_M101.h（800×1280）；IRQ 下降沿 */
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
		ctp_exchange_x_y_flag = <0x1>;'''

CTP_NEW = '''	/* 纽曼 FXT101041 / GT928 @ TWI1 PG8/PG9, INT/RST PG3/PG2, I2C 0x5d；cfg GROUP2 1280×800 */
	ctp@5d {
		compatible = "allwinner,goodix";
		device_type = "ctp";
		reg = <0x5d>;
		status = "okay";
		ctp_name = "gt928_fxt101041";
		ctp_twi_id = <0x1>;
		ctp_twi_addr = <0x5d>;
		ctp_screen_max_x = <1280>;
		ctp_screen_max_y = <800>;
		ctp_revert_x_flag = <0x0>;
		ctp_revert_y_flag = <0x1>;
		ctp_exchange_x_y_flag = <0x0>;'''

text = path.read_text(encoding="utf-8")
if "gt928_fxt101041" in text:
    print(f"==> touch already ZS {path.relative_to(ROOT)}")
else:
    if CTP_OLD not in text:
        raise SystemExit(f"ctp block missing in {path}")
    path.write_text(text.replace(CTP_OLD, CTP_NEW, 1), encoding="utf-8")
    print(f"==> touch {path.relative_to(ROOT)}")

def set_tp_kconfig(p: Path):
    if not p.exists():
        return
    src = p.read_text(encoding="utf-8")
    text = re.sub(
        r"^CONFIG_EXTRA_FIRMWARE=.*\nCONFIG_EXTRA_FIRMWARE_DIR=.*\n",
        "# CONFIG_EXTRA_FIRMWARE is not set\n",
        src, count=1, flags=re.M)
    text = text.replace(
        "CONFIG_TOUCHSCREEN_GSLX680NEW=y\n# CONFIG_TOUCHSCREEN_GT9XXNEW_TS is not set",
        "# CONFIG_TOUCHSCREEN_GSLX680NEW is not set\nCONFIG_TOUCHSCREEN_GT9XXNEW_TS=y",
    )
    if text != src:
        p.write_text(text, encoding="utf-8")
        print(f"==> touch kconfig {p.relative_to(ROOT)}")
    else:
        print(f"==> touch kconfig already {p.relative_to(ROOT)}")

set_tp_kconfig(DST / "linux-5.4/config-5.4")
set_tp_kconfig(DST / "openwrt/bsp_defconfig")
print("==> touch ready")
PY

echo "==> OK"
