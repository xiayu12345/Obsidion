#!/bin/bash
# 在 SDK 根目录或本目录执行：重新生成 phase1-5 合并补丁
# 组成：01～03 + 04（不含 sunxifb.c）+ git diff sunxifb.c + 05 + 06-dts-hw-scale
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${H133_SDK_ROOT:-$(cd "$SCRIPT_DIR/../../../../.." && pwd)}"
BRINGUP="$ROOT/H133-AI-Skills/开发记录/板件开发记录/JYY070-7寸LVDS屏-bringup/patches"
UNIFIED="$(mktemp /tmp/sunxifb-unified-XXXX.patch)"
trap 'rm -f "$UNIFIED"' EXIT
OUT="$SCRIPT_DIR/jyy070-lvds-display-phase1-5.patch"

if [ ! -f "$ROOT/platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunxifb.c" ]; then
	echo "error: sunxifb.c not found under $ROOT" >&2
	exit 1
fi

# 1) 从 git 导出 sunxifb 统一路径补丁（相对 p1_nor 基线）
git -C "$ROOT" diff platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunxifb.c > "$UNIFIED"

# 2) 04 去掉 sunxifb.c（由统一路径补丁替代，勿含 fix_lcd_page）
awk 'BEGIN{p=1} /^diff --git.*sunxifb\.c/{p=0} /^diff --git/ && !/sunxifb\.c/{if(!p) p=1} p' \
	"$BRINGUP/04-app-sunxifb.patch" > /tmp/04-no-sunxifb.patch

# 3) 合并
: > "$OUT"
for p in 01-kernel-panel.patch 02-uboot-panel.patch 03-dts.patch; do
	cat "$BRINGUP/$p" >> "$OUT"
done
cat /tmp/04-no-sunxifb.patch >> "$OUT"
cat "$UNIFIED" >> "$OUT"
cat "$BRINGUP/05-dual-display-rot.patch" >> "$OUT"
cat "$SCRIPT_DIR/06-dts-hw-scale.patch" >> "$OUT"

echo "==> $UNIFIED ($(wc -l < "$UNIFIED") lines)"
echo "==> $OUT ($(grep -c '^diff ' "$OUT") hunks, $(wc -l < "$OUT") lines)"
echo "    sunxifb: unified rotatefbp+split_fb (NO fix_lcd_page)"
echo "    fb0: 1280x800 DE0 scale -> LVDS 1024x600 (06-dts-hw-scale)"
