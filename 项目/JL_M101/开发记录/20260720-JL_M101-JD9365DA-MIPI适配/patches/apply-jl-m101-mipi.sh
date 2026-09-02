#!/bin/bash
# JL-M101 JD9365DA MIPI 适配 — phase1 补丁应用
# 在 H133 SDK 根目录执行，或设置 H133_SDK_ROOT
#
# Usage:
#   bash apply-jl-m101-mipi.sh          # 打合并补丁
#   bash apply-jl-m101-mipi.sh --check  # dry-run
#   bash apply-jl-m101-mipi.sh 01       # 只打 01-kernel-panel
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${H133_SDK_ROOT:-$(cd "$SCRIPT_DIR/../../../../.." && pwd)}"

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: 请在 SDK 根目录执行，或设置 H133_SDK_ROOT" >&2
	echo "  当前 ROOT=$ROOT" >&2
	exit 1
fi

cd "$ROOT"

pick_patch() {
	case "${1:-all}" in
	01) echo "$SCRIPT_DIR/01-kernel-panel.patch" ;;
	02) echo "$SCRIPT_DIR/02-board-tree.patch" ;;
	03) echo "$SCRIPT_DIR/03-shared-hooks.patch" ;;
	all|"") echo "$SCRIPT_DIR/jl-m101-mipi-phase1.patch" ;;
	*)
		echo "Usage: $0 [--check] [all|01|02|03]" >&2
		exit 1
		;;
	esac
}

MODE=apply
ARG=all
for a in "$@"; do
	case "$a" in
	--check) MODE=check ;;
	all|01|02|03) ARG=$a ;;
	*)
		echo "unknown arg: $a" >&2
		exit 1
		;;
	esac
done

PATCH="$(pick_patch "$ARG")"
if [ ! -f "$PATCH" ]; then
	echo "error: missing $PATCH" >&2
	exit 1
fi

if [ "$MODE" = check ]; then
	echo "==> patch --dry-run -p1 < $(basename "$PATCH")"
	patch -p1 --dry-run < "$PATCH"
	exit 0
fi

echo "==> patch -p1 < $(basename "$PATCH")"
if patch -p1 -N --forward < "$PATCH"; then
	echo "==> OK"
else
	echo "warn: 部分 hunk 已打过或上下文不匹配，请对照开发记录手工合并" >&2
fi

# bootlogo 不在补丁内
LOGO_DST="device/config/chips/h133/configs/p1_nor_JL_M101/bootlogo.bmp"
LOGO_SRC="device/config/chips/h133/configs/p1_nor_8733/bootlogo.bmp"
if [ ! -f "$LOGO_DST" ] && [ -f "$LOGO_SRC" ]; then
	cp -a "$LOGO_SRC" "$LOGO_DST"
	echo "==> copied bootlogo.bmp from p1_nor_8733"
fi

echo ""
echo "==> 编译:"
echo "    ./tools/build_p1_nor_JL_M101.sh kernel   # 先验证 panel"
echo "    ./tools/build_p1_nor_JL_M101.sh full"
echo ""
echo "==> 验收要点:"
echo "    lcd_driver_name=jl_m101_jd9365da；fb 800x1280；disp_rotate=3"
echo "    dmesg 有 panel/DSI；背光亮、无花屏；WiFi 仍 8733BU"
echo ""
echo "==> 重新生成补丁:"
echo "    bash $SCRIPT_DIR/gen-jl-m101-mipi-patch.sh"
