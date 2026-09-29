#!/bin/sh
# 在 20260918 独立 HXR 板件（屏驱仍是 jl_hxr_ili9881c / dclk=49）之上，换成 N91 发码。
# 用法：在任意目录执行。当前工作区若已合入，会跳过已打过的 hunk。
set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$DIR/../../../../.." && pwd)

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: $ROOT is not AI-tq SDK root" >&2
	exit 1
fi

cd "$ROOT"

install_file() {
	src=$1
	dst=$2
	mkdir -p "$(dirname "$dst")"
	cp -a "$src" "$dst"
	echo "==> install $dst"
}

apply_patch() {
	p=$1
	if patch -p1 --forward --dry-run < "$DIR/$p" >/dev/null 2>&1; then
		echo "==> apply $p"
		patch -p1 --forward < "$DIR/$p"
	else
		echo "==> skip $p (already applied or context mismatch)"
	fi
}

install_file "$DIR/files/kernel-jl_hxr_n91.c" \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_hxr_n91.c
install_file "$DIR/files/kernel-jl_hxr_n91.h" \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_hxr_n91.h
install_file "$DIR/files/uboot-jl_hxr_n91.c" \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/jl_hxr_n91.c
install_file "$DIR/files/uboot-jl_hxr_n91.h" \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/jl_hxr_n91.h

apply_patch 01-register-jl_hxr_n91.patch

python3 - "$ROOT" <<'PY'
import re, sys
from pathlib import Path

ROOT = Path(sys.argv[1])
CHIP = ROOT / "device/config/chips/h133/configs"

LINUX_OLD = '''	/* 京龙 HXR10106B-28 / ILI9881C-0H；init 见 jl_hxr_ili9881c.c */
	lcd_driver_name     = "jl_hxr_ili9881c";
	lcd_backlight       = <200>;
	lcd_if              = <4>;

	lcd_x               = <800>;
	lcd_y               = <1280>;
	lcd_width           = <135>;
	lcd_height          = <216>;
	/* dts×1.5=实际像素钟；49→约73.5MHz≈60Hz，勿填厂家 73（会跑成 ~110MHz/90Hz） */
	lcd_dclk_freq       = <49>;'''

LINUX_NEW = '''	/* 京龙 HXR10106B-28 / ILI9881C-0H；N91 发码见 jl_hxr_n91.c */
	lcd_driver_name     = "jl_hxr_n91";
	/* 试机确认：pwm_pol=1 低有效，15→导通约94% */
	lcd_backlight       = <15>;
	lcd_if              = <4>;

	lcd_x               = <800>;
	lcd_y               = <1280>;
	lcd_width           = <135>;
	lcd_height          = <216>;
	/* N91 PLL_CLOCK=421 → 像素钟约70.2MHz；dts×1.5，47→约70.5MHz≈60Hz。勿填 70 */
	lcd_dclk_freq       = <47>;'''

UBOOT_OLD = '''	/* 与内核一致：京龙 HXR10106B-28 / ILI9881C；U-Boot 侧 panel 见 jl_hxr_ili9881c.c */
	lcd_driver_name     = "jl_hxr_ili9881c";
	lcd_backlight       = <200>;
	lcd_if              = <4>;

	lcd_x               = <800>;
	lcd_y               = <1280>;
	lcd_width           = <135>;
	lcd_height          = <216>;
	/* dts×1.5=实际像素钟；49→约73.5MHz≈60Hz，勿填厂家 73 */
	lcd_dclk_freq       = <49>;'''

UBOOT_NEW = '''	/* 与内核一致：HXR10106B-28 N91；U-Boot 侧 panel 见 jl_hxr_n91.c */
	lcd_driver_name     = "jl_hxr_n91";
	/* 试机确认：pwm_pol=1 低有效，15→导通约94% */
	lcd_backlight       = <15>;
	lcd_if              = <4>;

	lcd_x               = <800>;
	lcd_y               = <1280>;
	lcd_width           = <135>;
	lcd_height          = <216>;
	/* N91 PLL_CLOCK=421 → 像素钟约70.2MHz；dts×1.5，47→约70.5MHz≈60Hz。勿填 70 */
	lcd_dclk_freq       = <47>;'''

PORCH_OLD = '''	/* HSA16 HBP60 HFP60 / VSA4 VBP10 VFP10 */
	lcd_hbp             = <76>;
	lcd_ht              = <936>;
	lcd_hspw            = <16>;
	lcd_vbp             = <14>;
	lcd_vt              = <1304>;
	lcd_vspw            = <4>;'''

PORCH_NEW = '''	/* N91: HSA20 HBP20 HFP40 / VSA4 VBP12 VFP30 */
	lcd_hbp             = <40>;
	lcd_ht              = <880>;
	lcd_hspw            = <20>;
	lcd_vbp             = <16>;
	lcd_vt              = <1326>;
	lcd_vspw            = <4>;'''

UBOOT_PORCH_OLD = '''	lcd_hbp             = <76>;
	lcd_ht              = <936>;
	lcd_hspw            = <16>;
	lcd_vbp             = <14>;
	lcd_vt              = <1304>;
	lcd_vspw            = <4>;'''

UBOOT_PORCH_NEW = '''	lcd_hbp             = <40>;
	lcd_ht              = <880>;
	lcd_hspw            = <20>;
	lcd_vbp             = <16>;
	lcd_vt              = <1326>;
	lcd_vspw            = <4>;'''

def patch_text(path: Path, pairs):
    text = path.read_text(encoding="utf-8")
    orig = text
    for a, b in pairs:
        if a in text:
            text = text.replace(a, b, 1)
    if 'lcd_driver_name     = "jl_hxr_n91"' in text and text == orig:
        print(f"==> lcd already N91 {path.relative_to(ROOT)}")
        return
    if text == orig:
        raise SystemExit(f"lcd block not replaced in {path}")
    path.write_text(text, encoding="utf-8")
    print(f"==> lcd patched {path.relative_to(ROOT)}")

def enable_n91(path: Path):
    text = path.read_text(encoding="utf-8")
    if "CONFIG_LCD_SUPPORT_JL_HXR_N91=y" in text:
        print(f"==> N91 already on {path.relative_to(ROOT)}")
        return
    line = "CONFIG_LCD_SUPPORT_JL_HXR_ILI9881C=y"
    if line not in text:
        raise SystemExit(f"no ILI9881C config in {path}")
    text = text.replace(line, line + "\nCONFIG_LCD_SUPPORT_JL_HXR_N91=y", 1)
    path.write_text(text, encoding="utf-8")
    print(f"==> N91 enabled {path.relative_to(ROOT)}")

for board in ("p1_nor_JL_HXR101", "p1_emmc_JL_HXR101"):
    patch_text(CHIP / board / "linux-5.4/board.dts", [
        (LINUX_OLD, LINUX_NEW),
        (PORCH_OLD, PORCH_NEW),
    ])
    patch_text(CHIP / board / "uboot-board.dts", [
        (UBOOT_OLD, UBOOT_NEW),
        (UBOOT_PORCH_OLD, UBOOT_PORCH_NEW),
    ])
    enable_n91(CHIP / board / "linux-5.4/config-5.4")
    enable_n91(CHIP / board / "openwrt/bsp_defconfig")

print("==> HXR boards on jl_hxr_n91")
PY

echo "==> OK"
echo "next: ./tools/build_p1_nor_JL_HXR101.sh kernel"
echo "      ./tools/build_p1_emmc_JL_HXR101.sh kernel"
