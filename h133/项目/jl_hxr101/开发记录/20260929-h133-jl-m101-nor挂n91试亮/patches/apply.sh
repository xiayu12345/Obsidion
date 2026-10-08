#!/bin/sh
# 给没有 jl_hxr_n91 的树：装上驱动，并把 p1_nor_JL_M101 改成这块屏。
# 只动京龙 NOR。eMMC M101、HXR 板件不改。
# 用法：在任意目录执行。驱动已在、板级已改时会跳过对应步骤。
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

install_file "$DIR/files/kernel-jl_hxr_n91.c" \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_hxr_n91.c
install_file "$DIR/files/kernel-jl_hxr_n91.h" \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_hxr_n91.h
install_file "$DIR/files/uboot-jl_hxr_n91.c" \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/jl_hxr_n91.c
install_file "$DIR/files/uboot-jl_hxr_n91.h" \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/jl_hxr_n91.h

python3 - "$ROOT" <<'PY'
import sys
from pathlib import Path

ROOT = Path(sys.argv[1])

KCONFIG_BLOCK = """config LCD_SUPPORT_JL_HXR_N91
	bool "LCD support HXR10106B-28 N91 ILI9881C init"
	default n
	---help---
		Jinglong HXR10106B-28 N91 init code (ILI9881C).
		Panel jl_hxr_n91. Init from N91ILI9881最新版本.txt.

"""

def read(path: Path) -> str:
    if not path.is_file():
        raise SystemExit(f"missing {path}")
    return path.read_text(encoding="utf-8")

def write(path: Path, old: str, new: str, note: str) -> None:
    if new == old:
        print(f"==> skip {note}")
        return
    path.write_text(new, encoding="utf-8")
    print(f"==> {note}")

def insert_after(text: str, anchor: str, addition: str, marker: str) -> str:
    if marker in text:
        return text
    if anchor not in text:
        raise SystemExit(f"anchor not found while inserting {marker!r}:\n{anchor}")
    return text.replace(anchor, anchor + addition, 1)

def insert_kconfig(text: str) -> str:
    marker = "config LCD_SUPPORT_JL_HXR_N91"
    if marker in text:
        return text
    key = "config LCD_SUPPORT_JL_M101_JD9365DA"
    start = text.find(key)
    if start < 0:
        raise SystemExit("Kconfig has no LCD_SUPPORT_JL_M101_JD9365DA")
    nxt = text.find("\nconfig ", start + len(key))
    if nxt < 0:
        raise SystemExit("Kconfig: no config entry after JD9365DA")
    return text[: nxt + 1] + KCONFIG_BLOCK + text[nxt + 1 :]

def enable_symbol(text: str, where: str) -> str:
    on = "CONFIG_LCD_SUPPORT_JL_HXR_N91=y"
    if on in text:
        return text
    off = "# CONFIG_LCD_SUPPORT_JL_HXR_N91 is not set"
    if off in text:
        return text.replace(off, on, 1)
    anchor = "CONFIG_LCD_SUPPORT_JL_M101_JD9365DA=y\n"
    if anchor not in text:
        raise SystemExit(f"{where}: no JD9365DA symbol to hang N91 on")
    return text.replace(anchor, anchor + on + "\n", 1)

pairs = [
    (
        ROOT / "kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/Makefile",
        "disp-$(CONFIG_LCD_SUPPORT_JL_M101_JD9365DA) += lcd/jl_m101_jd9365da.o\n",
        "disp-$(CONFIG_LCD_SUPPORT_JL_HXR_N91) += lcd/jl_hxr_n91.o\n",
        "lcd/jl_hxr_n91.o",
    ),
    (
        ROOT / "brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/Makefile",
        "disp-$(CONFIG_LCD_SUPPORT_JL_M101_JD9365DA) += lcd/jl_m101_jd9365da.o\n",
        "disp-$(CONFIG_LCD_SUPPORT_JL_HXR_N91) += lcd/jl_hxr_n91.o\n",
        "lcd/jl_hxr_n91.o",
    ),
    (
        ROOT / "kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.c",
        "#ifdef CONFIG_LCD_SUPPORT_JL_M101_JD9365DA\n\t&jl_m101_jd9365da_panel,\n#endif\n",
        "#ifdef CONFIG_LCD_SUPPORT_JL_HXR_N91\n\t&jl_hxr_n91_panel,\n#endif\n",
        "jl_hxr_n91_panel",
    ),
    (
        ROOT / "brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.c",
        "#ifdef CONFIG_LCD_SUPPORT_JL_M101_JD9365DA\n\t&jl_m101_jd9365da_panel,\n#endif\n",
        "#ifdef CONFIG_LCD_SUPPORT_JL_HXR_N91\n\t&jl_hxr_n91_panel,\n#endif\n",
        "jl_hxr_n91_panel",
    ),
    (
        ROOT / "kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.h",
        "#ifdef CONFIG_LCD_SUPPORT_JL_M101_JD9365DA\nextern struct __lcd_panel jl_m101_jd9365da_panel;\n#endif\n",
        "#ifdef CONFIG_LCD_SUPPORT_JL_HXR_N91\nextern struct __lcd_panel jl_hxr_n91_panel;\n#endif\n",
        "jl_hxr_n91_panel",
    ),
    (
        ROOT / "brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.h",
        "#ifdef CONFIG_LCD_SUPPORT_JL_M101_JD9365DA\nextern __lcd_panel_t jl_m101_jd9365da_panel;\n#endif\n",
        "#ifdef CONFIG_LCD_SUPPORT_JL_HXR_N91\nextern __lcd_panel_t jl_hxr_n91_panel;\n#endif\n",
        "jl_hxr_n91_panel",
    ),
]

for path, anchor, addition, marker in pairs:
    old = read(path)
    new = insert_after(old, anchor, addition, marker)
    write(path, old, new, f"register {path.relative_to(ROOT)}")

for rel in (
    "kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/Kconfig",
    "brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/Kconfig",
):
    path = ROOT / rel
    old = read(path)
    new = insert_kconfig(old)
    write(path, old, new, f"kconfig {rel}")

for rel in (
    "brandy/brandy-2.0/u-boot-2018/configs/sun8iw20p1_defconfig",
    "brandy/brandy-2.0/u-boot-2018/configs/sun8iw20p1_nor_defconfig",
    "brandy/brandy-2.0/u-boot-2018/configs/sun8iw20p1_auto_nor_defconfig",
    "device/config/chips/h133/configs/p1_nor_JL_M101/linux-5.4/config-5.4",
    "device/config/chips/h133/configs/p1_nor_JL_M101/openwrt/bsp_defconfig",
):
    path = ROOT / rel
    old = read(path)
    new = enable_symbol(old, rel)
    write(path, old, new, f"enable N91 {rel}")

LINUX_OLD = """\t/* 京龙 JL-M101B196 / JD9365DA-H3；init 见 jl_m101_jd9365da.c */
\tlcd_driver_name     = "jl_m101_jd9365da";
\tlcd_backlight       = <200>;
\tlcd_if              = <4>;

\tlcd_x               = <800>;
\tlcd_y               = <1280>;
\tlcd_width           = <135>;
\tlcd_height          = <216>;
\tlcd_dclk_freq       = <70>;"""

LINUX_NEW = """\t/* 试亮：HXR10106B-28 / ILI9881C-0H；N91 发码见 jl_hxr_n91.c。京龙 NOR 原屏是 JD9365DA */
\tlcd_driver_name     = "jl_hxr_n91";
\t/* 试机确认：pwm_pol=1 低有效，15→导通约94% */
\tlcd_backlight       = <15>;
\tlcd_if              = <4>;

\tlcd_x               = <800>;
\tlcd_y               = <1280>;
\tlcd_width           = <135>;
\tlcd_height          = <216>;
\t/* N91 PLL_CLOCK=421 → 像素钟约70.2MHz；dts×1.5，47→约70.5MHz≈60Hz。勿填 70 */
\tlcd_dclk_freq       = <47>;"""

PORCH_OLD = """\t/* vendor: HSA20 HBP20 HFP40 / VSA4 VBP20 VFP20 → Allwinner ht/hbp/vt/vbp */
\tlcd_hbp             = <40>;
\tlcd_ht              = <880>;
\tlcd_hspw            = <20>;
\tlcd_vbp             = <24>;
\tlcd_vt              = <1324>;
\tlcd_vspw            = <4>;"""

PORCH_NEW = """\t/* N91: HSA20 HBP20 HFP40 / VSA4 VBP12 VFP30 */
\tlcd_hbp             = <40>;
\tlcd_ht              = <880>;
\tlcd_hspw            = <20>;
\tlcd_vbp             = <16>;
\tlcd_vt              = <1326>;
\tlcd_vspw            = <4>;"""

UBOOT_OLD = """\t/* 与内核一致：京龙 JL-M101 / JD9365DA；U-Boot 侧 panel 见 jl_m101_jd9365da.c */
\tlcd_driver_name     = "jl_m101_jd9365da";
\tlcd_backlight       = <200>;
\tlcd_if              = <4>;

\tlcd_x               = <800>;
\tlcd_y               = <1280>;
\tlcd_width           = <135>;
\tlcd_height          = <216>;
\tlcd_dclk_freq       = <70>;"""

UBOOT_NEW = """\t/* 与内核一致：试亮 HXR10106B-28 N91；U-Boot 侧 panel 见 jl_hxr_n91.c */
\tlcd_driver_name     = "jl_hxr_n91";
\t/* 试机确认：pwm_pol=1 低有效，15→导通约94% */
\tlcd_backlight       = <15>;
\tlcd_if              = <4>;

\tlcd_x               = <800>;
\tlcd_y               = <1280>;
\tlcd_width           = <135>;
\tlcd_height          = <216>;
\t/* N91 PLL_CLOCK=421 → 像素钟约70.2MHz；dts×1.5，47→约70.5MHz≈60Hz。勿填 70 */
\tlcd_dclk_freq       = <47>;"""

UBOOT_PORCH_OLD = """\tlcd_hbp             = <40>;
\tlcd_ht              = <880>;
\tlcd_hspw            = <20>;
\tlcd_vbp             = <24>;
\tlcd_vt              = <1324>;
\tlcd_vspw            = <4>;"""

UBOOT_PORCH_NEW = """\t/* N91: HSA20 HBP20 HFP40 / VSA4 VBP12 VFP30 */
\tlcd_hbp             = <40>;
\tlcd_ht              = <880>;
\tlcd_hspw            = <20>;
\tlcd_vbp             = <16>;
\tlcd_vt              = <1326>;
\tlcd_vspw            = <4>;"""

def patch_lcd(path: Path, pairs) -> None:
    text = read(path)
    if 'lcd_driver_name     = "jl_hxr_n91"' in text:
        print(f"==> lcd already N91 {path.relative_to(ROOT)}")
        return
    orig = text
    for a, b in pairs:
        if a not in text:
            raise SystemExit(f"lcd block not found in {path}")
        text = text.replace(a, b, 1)
    if text == orig:
        raise SystemExit(f"lcd block not replaced in {path}")
    path.write_text(text, encoding="utf-8")
    print(f"==> lcd patched {path.relative_to(ROOT)}")

chip = ROOT / "device/config/chips/h133/configs/p1_nor_JL_M101"
patch_lcd(chip / "linux-5.4/board.dts", [(LINUX_OLD, LINUX_NEW), (PORCH_OLD, PORCH_NEW)])
patch_lcd(chip / "uboot-board.dts", [(UBOOT_OLD, UBOOT_NEW), (UBOOT_PORCH_OLD, UBOOT_PORCH_NEW)])
print("==> p1_nor_JL_M101 ready for jl_hxr_n91")
PY

echo "==> OK"
echo "next: ./tools/build_p1_nor_JL_M101.sh kernel"
echo "U-Boot 日志应出现 jl_hxr_n91: panel_init"
