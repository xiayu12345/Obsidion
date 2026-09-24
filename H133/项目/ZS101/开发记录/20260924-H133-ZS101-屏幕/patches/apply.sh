#!/bin/sh
# 把 ZS 板接到 zs101_ili9881c。屏驱源码需已在树里。
set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$DIR/../../../../.." && pwd)

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: $ROOT is not AI-tq SDK root" >&2
	exit 1
fi

cd "$ROOT"

if patch -p1 --forward --dry-run < "$DIR/01-libtmedia-rotate.patch" >/dev/null 2>&1; then
	echo "==> apply 01-libtmedia-rotate.patch"
	patch -p1 --forward < "$DIR/01-libtmedia-rotate.patch"
else
	echo "==> skip 01-libtmedia-rotate.patch (already applied or context mismatch)"
fi

python3 - "$ROOT" <<'PY'
import sys
from pathlib import Path

ROOT = Path(sys.argv[1])
DST = ROOT / "device/config/chips/h133/configs/p1_nor_ZS101"
OWT = ROOT / "openwrt/target/h133/h133-p1_nor_ZS101"
if not DST.exists():
    raise SystemExit("missing p1_nor_ZS101, run 新建板件 first")

LINUX_LCD_BLOCK = r'''	/* 群创 10.1 (T2) ZS101NI4042J4H8II-B / ILI9881C-0D；init 见 zs101_ili9881c.c */
	lcd_driver_name     = "zs101_ili9881c";
	/* PT4117B：RL7=1.1Ω，100% 高电平≈182mA，对齐屏 If=180mA */
	lcd_backlight       = <255>;
	lcd_if              = <4>;

	lcd_x               = <800>;
	lcd_y               = <1280>;
	lcd_width           = <135>;
	lcd_height          = <216>;
	/* dts×1.5=实际像素钟；49→约73.5MHz≈60Hz */
	lcd_dclk_freq       = <49>;

	/* LCD-PWM=PB12/PWM0 */
	lcd_pwm_used        = <1>;
	lcd_pwm_ch          = <0>;
	lcd_pwm_freq        = <50000>;
	/* PT4117B EN 高电平导通；PG17 = LCD-BL-EN */
	lcd_pwm_pol         = <0>;
	lcd_pwm_max_limit   = <255>;
	lcd_bl_en           = <&pio PG 17 GPIO_ACTIVE_HIGH>;

	/* HSA16 HBP60 HFP60 / VSA4 VBP10 VFP10 */
	lcd_hbp             = <76>;
	lcd_ht              = <936>;
	lcd_hspw            = <16>;
	lcd_vbp             = <14>;
	lcd_vt              = <1304>;
	lcd_vspw            = <4>;'''

UBOOT_LCD_BLOCK = LINUX_LCD_BLOCK.replace(
    "群创 10.1 (T2) ZS101NI4042J4H8II-B / ILI9881C-0D；init 见 zs101_ili9881c.c",
    "与内核一致：群创 ZS101NI4042J4H8II-B / ILI9881C-0D；U-Boot 侧 panel 见 zs101_ili9881c.c",
)

import re
LCD_RE = re.compile(
    r"\t/\* [^\n]*jl_m101_jd9365da\.c \*/\n"
    r"\tlcd_driver_name\s+=\s+\"jl_m101_jd9365da\";\n"
    r".*?\n"
    r"\tlcd_vspw\s+=\s+<\d+>;",
    re.S,
)

def patch_lcd(path: Path, block: str):
    text = path.read_text(encoding="utf-8")
    if 'lcd_driver_name     = "zs101_ili9881c"' in text:
        print(f"==> lcd already ZS {path.relative_to(ROOT)}")
        return
    new, n = LCD_RE.subn(block, text, count=1)
    if n != 1:
        raise SystemExit(f"lcd block not replaced in {path} (n={n})")
    path.write_text(new, encoding="utf-8")
    print(f"==> lcd {path.relative_to(ROOT)}")

def set_lcd_kconfig(path: Path):
    if not path.exists():
        return
    text = path.read_text(encoding="utf-8")
    orig = text
    text = text.replace(
        "CONFIG_LCD_SUPPORT_JL_M101_JD9365DA=y",
        "# CONFIG_LCD_SUPPORT_JL_M101_JD9365DA is not set\nCONFIG_LCD_SUPPORT_ZS101_ILI9881C=y",
    )
    if text != orig:
        path.write_text(text, encoding="utf-8")
        print(f"==> lcd kconfig {path.relative_to(ROOT)}")

patch_lcd(DST / "linux-5.4/board.dts", LINUX_LCD_BLOCK)
patch_lcd(DST / "uboot-board.dts", UBOOT_LCD_BLOCK)
set_lcd_kconfig(DST / "linux-5.4/config-5.4")
set_lcd_kconfig(DST / "openwrt/bsp_defconfig")

ini = OWT / "busybox-init-base-files/etc/setting.ini"
if ini.exists():
    t = ini.read_text(encoding="utf-8")
    nt = t.replace("disp_rotate = 1\n", "disp_rotate = 3\n", 1)
    if nt != t:
        ini.write_text(nt, encoding="utf-8")
        print("==> disp_rotate = 3")
    else:
        print("==> disp_rotate already set")

print("==> screen ready")
PY

echo "==> OK"
echo "next: 触摸"
