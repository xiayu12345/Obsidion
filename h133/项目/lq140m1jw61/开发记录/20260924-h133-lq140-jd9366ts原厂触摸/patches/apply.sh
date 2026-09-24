#!/bin/sh
# p1_nor_LQ140M1JW61 — Jadard JD9366TS 原厂触摸
# 在 SDK 根目录执行，或设置 H133_SDK_ROOT
set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT="${H133_SDK_ROOT:-$(CDPATH= cd -- "$DIR/../../../../.." && pwd)}"

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: 不是 SDK 根目录: $ROOT" >&2
	exit 1
fi

VENDOR_ZIP="$ROOT/AI-skiil/硬件资料/音乐骑士/屏幕4/JD9366TP_JD9366TS_QZ_IIC_01.DE.zip"
JD_DST="$ROOT/kernel/linux-5.4/drivers/input/touchscreen/jdchipset"

cd "$ROOT"

MODE=apply
for a in "$@"; do
	case "$a" in
	--check) MODE=check ;;
	*) echo "Usage: $0 [--check]" >&2; exit 1 ;;
	esac
done

install_jdchipset() {
	if [ -f "$JD_DST/jadard_common.c" ] && [ -f "$JD_DST/Makefile" ]; then
		if grep -q 'TOUCHSCREEN_JADARD_MODULE' "$JD_DST/Makefile" 2>/dev/null; then
			echo "==> keep $JD_DST"
			return 0
		fi
	fi
	if [ ! -f "$VENDOR_ZIP" ]; then
		echo "error: 缺少原厂包 $VENDOR_ZIP" >&2
		exit 1
	fi
	echo "==> extract jdchipset from vendor zip"
	TMP=$(mktemp -d)
	unzip -qo "$VENDOR_ZIP" -d "$TMP"
	rm -rf "$JD_DST"
	mkdir -p "$(dirname "$JD_DST")"
	mv "$TMP/jdchipset" "$JD_DST"
	rm -rf "$TMP"
	cp -a "$DIR/files/Makefile.jdchipset" "$JD_DST/Makefile"
	echo "==> installed $JD_DST"
}

fix_fortify_debug() {
	# 相对原厂 debug：copy_from_user 限长，避免 5.4 fortify 编译失败
	python3 - "$JD_DST/jadard_debug.c" <<'PY'
import re, sys
from pathlib import Path
p = Path(sys.argv[1])
t = p.read_text()
if 'min_t(size_t' in t and 'copy_from_user' in t:
    print('==> jadard_debug fortify already patched')
    raise SystemExit(0)
t2 = re.sub(
    r'copy_from_user\s*\(\s*(\w+)\s*,\s*(\w+)\s*,\s*len\s*-\s*1\s*\)',
    lambda m: f'copy_from_user({m.group(1)}, {m.group(2)}, min_t(size_t, (len ? len - 1 : 0), sizeof({m.group(1)}) - 1))',
    t,
)
t2 = re.sub(
    r'copy_from_user\s*\(\s*(\w+)\s*,\s*(\w+)\s*,\s*len\s*\)',
    lambda m: f'copy_from_user({m.group(1)}, {m.group(2)}, min_t(size_t, len, sizeof({m.group(1)}) - 1))',
    t2,
)
if t2 == t:
    print('==> warn: no copy_from_user pattern in jadard_debug.c', file=sys.stderr)
else:
    p.write_text(t2)
    print('==> patched jadard_debug.c fortify')
PY
}

apply_patch() {
	p=$1
	if [ "$MODE" = check ]; then
		if patch -p1 --forward --dry-run < "$DIR/$p" >/dev/null 2>&1; then
			echo "==> check OK $p"
		elif patch -p1 -R --dry-run < "$DIR/$p" >/dev/null 2>&1; then
			echo "==> already applied $p"
		else
			echo "==> check FAIL $p" >&2
			return 1
		fi
		return 0
	fi
	if patch -p1 --forward --dry-run < "$DIR/$p" >/dev/null 2>&1; then
		echo "==> apply $p"
		patch -p1 --forward < "$DIR/$p"
	elif patch -p1 -R --dry-run < "$DIR/$p" >/dev/null 2>&1; then
		echo "==> skip $p (already applied)"
	else
		echo "==> skip $p (context mismatch — 对照开发记录人工检查)" >&2
	fi
}

# 去掉曾用的自写调试驱动（源码 + 挂接残留）
remove_legacy_jd9366ts() {
	f="$ROOT/kernel/linux-5.4/drivers/input/touchscreen/jd9366ts.c"
	if [ -f "$f" ]; then
		echo "==> remove legacy jd9366ts.c"
		rm -f "$f"
	fi
	# 中间态曾把 JD9366TS 标成 legacy 留在 Kconfig/Makefile；定稿树不应再有
	kc="$ROOT/kernel/linux-5.4/drivers/input/touchscreen/Kconfig"
	mk="$ROOT/kernel/linux-5.4/drivers/input/touchscreen/Makefile"
	bsp="$ROOT/device/config/chips/h133/configs/p1_nor_LQ140M1JW61/openwrt/bsp_defconfig"
	if grep -q 'config TOUCHSCREEN_JD9366TS' "$kc" 2>/dev/null; then
		echo "==> strip TOUCHSCREEN_JD9366TS from Kconfig"
		python3 - "$kc" <<'PY'
import re, sys
from pathlib import Path
p = Path(sys.argv[1])
t = p.read_text()
t2 = re.sub(
    r'\nconfig TOUCHSCREEN_JD9366TS\n(?:\t.*\n)*?(?=\n(?:config |source |endif))',
    '\n',
    t,
    count=1,
)
if t2 != t:
    p.write_text(t2)
PY
	fi
	if grep -q 'TOUCHSCREEN_JD9366TS' "$mk" 2>/dev/null; then
		echo "==> strip jd9366ts.o from Makefile"
		sed -i '/TOUCHSCREEN_JD9366TS/d' "$mk"
	fi
	if grep -q 'TOUCHSCREEN_JD9366TS' "$bsp" 2>/dev/null; then
		echo "==> strip TOUCHSCREEN_JD9366TS from bsp_defconfig"
		sed -i '/TOUCHSCREEN_JD9366TS/d' "$bsp"
	fi
}

install_jdchipset
fix_fortify_debug
# 确保 Makefile 是 host 版
cp -a "$DIR/files/Makefile.jdchipset" "$JD_DST/Makefile"

remove_legacy_jd9366ts

apply_patch 01-kernel-touchscreen-build.patch
apply_patch 02-board-dts-bsp.patch
apply_patch 03-jdchipset-ic-id.patch
apply_patch 04-jdchipset-y-mirror.patch

echo "==> done"
echo "    source build/envsetup.sh && m kernel -j4 && p"
echo "    文档: AI-skiil/板件开发记录/LQ140M1JW61/20260924-H133-LQ140-JD9366TS原厂触摸/README.md"
