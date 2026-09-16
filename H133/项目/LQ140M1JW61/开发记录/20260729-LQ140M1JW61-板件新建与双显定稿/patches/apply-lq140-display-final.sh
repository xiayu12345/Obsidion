#!/bin/bash
# LQ140M1JW61 显示定稿补丁应用
# 在 H133 SDK 根目录执行，或设置 H133_SDK_ROOT
#
# Usage:
#   bash apply-lq140-display-final.sh          # 打合并补丁
#   bash apply-lq140-display-final.sh --check  # dry-run
#   bash apply-lq140-display-final.sh 01       # 只打 panel
#   bash apply-lq140-display-final.sh 02|03|04
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
	01) echo "$SCRIPT_DIR/01-kernel-uboot-panel.patch" ;;
	02) echo "$SCRIPT_DIR/02-board-tree.patch" ;;
	03) echo "$SCRIPT_DIR/03-shared-hooks.patch" ;;
	04) echo "$SCRIPT_DIR/04-docs.patch" ;;
	all|"") echo "$SCRIPT_DIR/lq140-display-final.patch" ;;
	*)
		echo "Usage: $0 [--check] [all|01|02|03|04]" >&2
		exit 1
		;;
	esac
}

MODE=apply
ARG=all
for a in "$@"; do
	case "$a" in
	--check) MODE=check ;;
	all|01|02|03|04) ARG=$a ;;
	*)
		echo "Usage: $0 [--check] [all|01|02|03|04]" >&2
		exit 1
		;;
	esac
done

PATCH="$(pick_patch "$ARG")"
if [ ! -f "$PATCH" ]; then
	echo "error: missing $PATCH — 先跑 gen-lq140-display-final-patch.sh" >&2
	exit 1
fi

ensure_bootlogo() {
	local dst="device/config/chips/h133/configs/p1_nor_LQ140M1JW61/bootlogo.bmp"
	local src8733="device/config/chips/h133/configs/p1_nor_8733/bootlogo.bmp"
	local srcjyy="device/config/chips/h133/configs/p1_nor_JYY070/bootlogo.bmp"
	if [ -d "device/config/chips/h133/configs/p1_nor_LQ140M1JW61" ] && [ ! -f "$dst" ]; then
		if [ -f "$src8733" ]; then
			cp -a "$src8733" "$dst"
			echo "==> copied bootlogo.bmp from p1_nor_8733"
		elif [ -f "$srcjyy" ]; then
			cp -a "$srcjyy" "$dst"
			echo "==> copied bootlogo.bmp from p1_nor_JYY070"
		fi
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
echo "    编译: ./tools/build_p1_nor_LQ140M1JW61.sh full"
echo "    文档: H133-AI-Skills/开发记录/板件开发记录/LQ140M1JW61/20260729-LQ140M1JW61-板件新建与双显定稿/README.md"
