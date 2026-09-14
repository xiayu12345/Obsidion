#!/bin/bash
# ZS101 ILI9881C MIPI 显示点亮补丁（只含屏幕）
# 在 H133 SDK 根目录执行，或设置 H133_SDK_ROOT
#
# Usage:
#   bash apply-zs101-display.sh          # 打合并补丁
#   bash apply-zs101-display.sh --check  # dry-run
#   bash apply-zs101-display.sh 01       # 只打 panel
#   bash apply-zs101-display.sh 02|03
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# patches → 点亮目录 → ZS101 → 板件开发记录 → 开发记录 → H133-AI-Skills → SDK
ROOT="${H133_SDK_ROOT:-$(cd "$SCRIPT_DIR/../../../../../.." && pwd)}"

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: 请在 SDK 根目录执行，或设置 H133_SDK_ROOT" >&2
	echo "  当前 ROOT=$ROOT" >&2
	exit 1
fi

cd "$ROOT"

pick_patch() {
	case "${1:-all}" in
	01) echo "$SCRIPT_DIR/01-kernel-uboot-panel.patch" ;;
	02) echo "$SCRIPT_DIR/02-board-display.patch" ;;
	03) echo "$SCRIPT_DIR/03-shared-hooks.patch" ;;
	all|"") echo "$SCRIPT_DIR/zs101-display.patch" ;;
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
		echo "Usage: $0 [--check] [all|01|02|03]" >&2
		exit 1
		;;
	esac
done

PATCH="$(pick_patch "$ARG")"
if [ ! -f "$PATCH" ]; then
	echo "error: missing $PATCH — 先跑 gen-zs101-display-patch.sh" >&2
	exit 1
fi

ensure_bootlogo() {
	local dst="device/config/chips/h133/configs/p1_nor_ZS101/bootlogo.bmp"
	local src="device/config/chips/h133/configs/p1_nor_JL_M101/bootlogo.bmp"
	if [ -d "device/config/chips/h133/configs/p1_nor_ZS101" ] && [ ! -f "$dst" ] && [ -f "$src" ]; then
		cp -a "$src" "$dst"
		echo "==> copied bootlogo.bmp from p1_nor_JL_M101"
	fi
}

if [ "$MODE" = check ]; then
	echo "==> dry-run: $PATCH"
	git apply --check "$PATCH"
	echo "==> OK (check)"
	exit 0
fi

echo "==> apply: $PATCH"
git apply "$PATCH"
ensure_bootlogo
echo "==> done"
echo "    编译: ./tools/build_p1_nor_ZS101.sh full"
echo "    文档: H133-AI-Skills/开发记录/板件开发记录/ZS101/20260825-ZS101-ILI9881C-MIPI显示点亮/开发记录.md"
