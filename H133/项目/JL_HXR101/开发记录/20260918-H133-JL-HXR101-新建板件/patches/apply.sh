#!/bin/sh
# 相对已有 p1_{emmc,nor}_JL_M101（屏驱仍是 jl_m101_jd9365da）的树。
# 用法：在任意目录执行。当前工作区若已合入，会跳过已打过的 hunk。
set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$DIR/../../../.." && pwd)

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: $ROOT is not AI-tq SDK root" >&2
	exit 1
fi

cd "$ROOT"

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

apply_patch() {
	p=$1
	if patch -p1 --forward --dry-run < "$DIR/$p" >/dev/null 2>&1; then
		echo "==> apply $p"
		patch -p1 --forward < "$DIR/$p"
	else
		echo "==> skip $p (already applied or context mismatch)"
	fi
}

echo "==> install panel sources"
install_file "$DIR/files/kernel-jl_hxr_ili9881c.c" \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_hxr_ili9881c.c
install_file "$DIR/files/kernel-jl_hxr_ili9881c.h" \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_hxr_ili9881c.h
install_file "$DIR/files/uboot-jl_hxr_ili9881c.c" \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/jl_hxr_ili9881c.c
install_file "$DIR/files/uboot-jl_hxr_ili9881c.h" \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/jl_hxr_ili9881c.h

install_file "$DIR/files/build_p1_emmc_JL_HXR101.sh" tools/build_p1_emmc_JL_HXR101.sh
install_file "$DIR/files/build_p1_nor_JL_HXR101.sh" tools/build_p1_nor_JL_HXR101.sh
chmod +x tools/build_p1_emmc_JL_HXR101.sh tools/build_p1_nor_JL_HXR101.sh

apply_patch 01-kernel-uboot-hxr-panel.patch
apply_patch 02-pack-libtmedia-readme.patch

python3 - "$ROOT" <<'PY'
import os, re, shutil, sys
from pathlib import Path

ROOT = Path(sys.argv[1])
CHIP = ROOT / "device/config/chips/h133/configs"
OWT = ROOT / "openwrt/target/h133"

HXR_LINUX_LCD = '''	/* 京龙 HXR10106B-28 / ILI9881C-0H；init 见 jl_hxr_ili9881c.c */
	lcd_driver_name     = "jl_hxr_ili9881c";
	lcd_backlight       = <200>;
	lcd_if              = <4>;

	lcd_x               = <800>;
	lcd_y               = <1280>;
	lcd_width           = <135>;
	lcd_height          = <216>;
	/* dts×1.5=实际像素钟；49→约73.5MHz≈60Hz，勿填厂家 73（会跑成 ~110MHz/90Hz） */
	lcd_dclk_freq       = <49>;

	/* s10：LCD-PWM=PB12/PWM0 → PT4117B EN，原理图 PWM_Frequence=50KHz */
	lcd_pwm_used        = <1>;
	lcd_pwm_ch          = <0>;
	lcd_pwm_freq        = <50000>;
	lcd_pwm_pol         = <1>;
	lcd_pwm_max_limit   = <255>;

	/* HSA16 HBP60 HFP60 / VSA4 VBP10 VFP10 */
	lcd_hbp             = <76>;
	lcd_ht              = <936>;
	lcd_hspw            = <16>;
	lcd_vbp             = <14>;
	lcd_vt              = <1304>;
	lcd_vspw            = <4>;'''

HXR_UBOOT_LCD = '''	/* 与内核一致：京龙 HXR10106B-28 / ILI9881C；U-Boot 侧 panel 见 jl_hxr_ili9881c.c */
	lcd_driver_name     = "jl_hxr_ili9881c";
	lcd_backlight       = <200>;
	lcd_if              = <4>;

	lcd_x               = <800>;
	lcd_y               = <1280>;
	lcd_width           = <135>;
	lcd_height          = <216>;
	/* dts×1.5=实际像素钟；49→约73.5MHz≈60Hz，勿填厂家 73 */
	lcd_dclk_freq       = <49>;

	/* s10：LCD-PWM=PB12/PWM0，PWM_Frequence=50KHz */
	lcd_pwm_used        = <1>;
	lcd_pwm_ch          = <0>;
	lcd_pwm_freq        = <50000>;
	lcd_pwm_pol         = <1>;
	lcd_pwm_max_limit   = <255>;
	lcd_hbp             = <76>;
	lcd_ht              = <936>;
	lcd_hspw            = <16>;
	lcd_vbp             = <14>;
	lcd_vt              = <1304>;
	lcd_vspw            = <4>;'''

LCD_BLOCK_RE = re.compile(
    r"\t/\* [^\n]*\n"
    r"\tlcd_driver_name\s+=\s+\"jl_m101_jd9365da\";\n"
    r".*?\n"
    r"\tlcd_vspw\s+=\s+<\d+>;",
    re.S,
)

def rsync_tree(src: Path, dst: Path):
    if dst.exists():
        print(f"==> keep {dst.relative_to(ROOT)}")
        return False
    shutil.copytree(src, dst, symlinks=True, copy_function=shutil.copy2)
    print(f"==> copy {src.name} -> {dst.name}")
    return True

def patch_lcd(path: Path, replacement: str):
    text = path.read_text(encoding="utf-8")
    if 'lcd_driver_name     = "jl_hxr_ili9881c"' in text:
        print(f"==> lcd already HXR {path.relative_to(ROOT)}")
        return
    new, n = LCD_BLOCK_RE.subn(replacement, text, count=1)
    if n != 1:
        raise SystemExit(f"lcd block not replaced in {path} (n={n})")
    path.write_text(new, encoding="utf-8")
    print(f"==> lcd patched {path.relative_to(ROOT)}")

def set_kconfig(path: Path, jl_on: bool, hxr_on: bool):
    text = path.read_text(encoding="utf-8")
    if not re.search(r"^#? ?CONFIG_LCD_SUPPORT_JL_M101_JD9365DA", text, re.M):
        print(f"==> no JL_M101 in {path.relative_to(ROOT)}")
        return
    text = re.sub(
        r"^#? ?CONFIG_LCD_SUPPORT_JL_M101_JD9365DA(=y| is not set)",
        "CONFIG_LCD_SUPPORT_JL_M101_JD9365DA=y" if jl_on else "# CONFIG_LCD_SUPPORT_JL_M101_JD9365DA is not set",
        text, count=1, flags=re.M)
    line = "CONFIG_LCD_SUPPORT_JL_HXR_ILI9881C=y" if hxr_on else "# CONFIG_LCD_SUPPORT_JL_HXR_ILI9881C is not set"
    if re.search(r"^#? ?CONFIG_LCD_SUPPORT_JL_HXR_ILI9881C", text, re.M):
        text = re.sub(
            r"^#? ?CONFIG_LCD_SUPPORT_JL_HXR_ILI9881C(=y| is not set)",
            line, text, count=1, flags=re.M)
    else:
        text = re.sub(
            r"^(# CONFIG_LCD_SUPPORT_JL_M101_JD9365DA is not set|CONFIG_LCD_SUPPORT_JL_M101_JD9365DA=y)\n",
            r"\g<0>" + line + "\n",
            text, count=1, flags=re.M)
    path.write_text(text, encoding="utf-8")

def rewrite_text_files(root: Path, repls):
    for p in root.rglob("*"):
        if not p.is_file() or p.is_symlink():
            continue
        if p.suffix.lower() in {".bin", ".bmp", ".png", ".jpg", ".so", ".a", ".o"}:
            continue
        try:
            data = p.read_bytes()
        except Exception:
            continue
        if b"\0" in data[:4096]:
            continue
        try:
            text = data.decode("utf-8")
        except UnicodeDecodeError:
            continue
        orig = text
        for a, b in repls:
            text = text.replace(a, b)
        if text != orig:
            p.write_text(text, encoding="utf-8")

def add_target_unsets(defconfig: Path, inserts):
    text = defconfig.read_text(encoding="utf-8")
    orig = text
    for after, line in inserts:
        if line in text or after not in text:
            continue
        text = text.replace(after, after + "\n" + line, 1)
    if text != orig:
        defconfig.write_text(text, encoding="utf-8")

# clone boards
rsync_tree(CHIP / "p1_emmc_JL_M101", CHIP / "p1_emmc_JL_HXR101")
rsync_tree(CHIP / "p1_nor_JL_M101", CHIP / "p1_nor_JL_HXR101")
rsync_tree(OWT / "h133-p1_emmc_JL_M101", OWT / "h133-p1_emmc_JL_HXR101")
rsync_tree(OWT / "h133-p1_nor_JL_M101", OWT / "h133-p1_nor_JL_HXR101")

for board in ("p1_emmc_JL_HXR101", "p1_nor_JL_HXR101"):
    patch_lcd(CHIP / board / "linux-5.4/board.dts", HXR_LINUX_LCD)
    patch_lcd(CHIP / board / "uboot-board.dts", HXR_UBOOT_LCD)
    set_kconfig(CHIP / board / "linux-5.4/config-5.4", jl_on=False, hxr_on=True)
    set_kconfig(CHIP / board / "openwrt/bsp_defconfig", jl_on=False, hxr_on=True)

for board, old, new in (
    ("p1_emmc_JL_HXR101", "h133-p1_emmc_JL_M101", "h133-p1_emmc_JL_HXR101"),
    ("p1_nor_JL_HXR101", "h133-p1_nor_JL_M101", "h133-p1_nor_JL_HXR101"),
):
    for rel in ("linux-5.4/config-5.4", "openwrt/bsp_defconfig"):
        p = CHIP / board / rel
        t = p.read_text(encoding="utf-8").replace(old, new)
        p.write_text(t, encoding="utf-8")

rewrite_text_files(OWT / "h133-p1_emmc_JL_HXR101", [
    ("h133-p1_emmc_JL_M101", "h133-p1_emmc_JL_HXR101"),
    ("p1_emmc_JL_M101", "p1_emmc_JL_HXR101"),
    ("TinaLinux-JL_M101", "TinaLinux-JL_HXR101"),
])
rewrite_text_files(OWT / "h133-p1_nor_JL_HXR101", [
    ("h133-p1_nor_JL_M101", "h133-p1_nor_JL_HXR101"),
    ("p1_nor_JL_M101", "p1_nor_JL_HXR101"),
    ("TinaLinux-JL_M101", "TinaLinux-JL_HXR101"),
])

emmc_mk = OWT / "h133-p1_emmc_JL_HXR101/Makefile"
nor_mk = OWT / "h133-p1_nor_JL_HXR101/Makefile"
emmc_mk.write_text(emmc_mk.read_text(encoding="utf-8").replace(
    "JL-M101 JD9365DA MIPI + eMMC 16G + RTL8733BU",
    "HXR10106B ILI9881C MIPI + eMMC 16G + RTL8733BU",
), encoding="utf-8")
nor_mk.write_text(nor_mk.read_text(encoding="utf-8").replace(
    "JL-M101 JD9365DA MIPI + RTL8733BU",
    "HXR10106B ILI9881C MIPI + RTL8733BU",
), encoding="utf-8")

for dc in (OWT / "h133-p1_emmc_JL_HXR101").glob("defconfig*"):
    add_target_unsets(dc, [
        ("CONFIG_TARGET_h133_p1_emmc_JL_HXR101=y", "# CONFIG_TARGET_h133_p1_emmc_JL_M101 is not set"),
        ("# CONFIG_TARGET_h133_p1_nor_JL_M101 is not set", "# CONFIG_TARGET_h133_p1_nor_JL_HXR101 is not set"),
    ])
for dc in (OWT / "h133-p1_nor_JL_HXR101").glob("defconfig*"):
    add_target_unsets(dc, [
        ("CONFIG_TARGET_h133_p1_nor_JL_HXR101=y", "# CONFIG_TARGET_h133_p1_nor_JL_M101 is not set"),
        ("# CONFIG_TARGET_h133_p1_emmc_JL_M101 is not set", "# CONFIG_TARGET_h133_p1_emmc_JL_HXR101 is not set"),
    ])

# sibling OpenWrt TARGET unsets + kernel LCD_SUPPORT unsets
for tgt in sorted(OWT.glob("h133-*")):
    if tgt.name in ("h133-p1_emmc_JL_HXR101", "h133-p1_nor_JL_HXR101"):
        continue
    for dc in tgt.glob("defconfig*"):
        text = dc.read_text(encoding="utf-8")
        orig = text
        pairs = [
            ("# CONFIG_TARGET_h133_p1_emmc_JL_M101 is not set", "# CONFIG_TARGET_h133_p1_emmc_JL_HXR101 is not set"),
            ("CONFIG_TARGET_h133_p1_emmc_JL_M101=y", "# CONFIG_TARGET_h133_p1_emmc_JL_HXR101 is not set"),
            ("# CONFIG_TARGET_h133_p1_nor_JL_M101 is not set", "# CONFIG_TARGET_h133_p1_nor_JL_HXR101 is not set"),
            ("CONFIG_TARGET_h133_p1_nor_JL_M101=y", "# CONFIG_TARGET_h133_p1_nor_JL_HXR101 is not set"),
        ]
        for after, line in pairs:
            if after in text and line not in text:
                text = text.replace(after, after + "\n" + line, 1)
        if text != orig:
            dc.write_text(text, encoding="utf-8")

skip = {"p1_emmc_JL_HXR101", "p1_nor_JL_HXR101"}
for board_dir in sorted(CHIP.iterdir()):
    if not board_dir.is_dir() or board_dir.name in skip:
        continue
    for rel in ("linux-5.4/config-5.4", "openwrt/bsp_defconfig"):
        p = board_dir / rel
        if not p.exists():
            continue
        text = p.read_text(encoding="utf-8")
        if "CONFIG_LCD_SUPPORT_JL_M101_JD9365DA" not in text:
            continue
        if "CONFIG_LCD_SUPPORT_JL_HXR_ILI9881C" in text:
            continue
        new = re.sub(
            r"^(# CONFIG_LCD_SUPPORT_JL_M101_JD9365DA is not set|CONFIG_LCD_SUPPORT_JL_M101_JD9365DA=y)\n",
            r"\g<0># CONFIG_LCD_SUPPORT_JL_HXR_ILI9881C is not set\n",
            text, count=1, flags=re.M)
        if new != text:
            p.write_text(new, encoding="utf-8")
            print(f"==> unset HXR {p.relative_to(CHIP)}")

print("==> boards/targets ready")
PY

echo "==> OK"
echo "next: ./tools/build_p1_emmc_JL_HXR101.sh kernel"
echo "      ./tools/build_p1_nor_JL_HXR101.sh kernel"
