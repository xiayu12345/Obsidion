#!/bin/bash
# p1_nor_4k 板件新建落地（干净树）
# 在 H133 SDK 根目录执行，或设置 H133_SDK_ROOT
#
# Usage:
#   bash apply-p1_nor_4k-board.sh           # 克隆(若无) + 打全部补丁
#   bash apply-p1_nor_4k-board.sh --check   # 仅检查补丁（不克隆）
#   bash apply-p1_nor_4k-board.sh 01|02|03|04
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${H133_SDK_ROOT:-$(cd "$SCRIPT_DIR/../../../../.." && pwd)}"

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: 请在 SDK 根目录执行，或设置 H133_SDK_ROOT" >&2
	echo "  当前 ROOT=$ROOT" >&2
	exit 1
fi

cd "$ROOT"
BASE=device/config/chips/h133/configs
OW=openwrt/target/h133

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

pick_patch() {
	case "$1" in
	01) echo "$SCRIPT_DIR/01-hdmi4k-dts-delta.patch" ;;
	02) echo "$SCRIPT_DIR/02-openwrt-target-delta.patch" ;;
	03) echo "$SCRIPT_DIR/03-build-script.patch" ;;
	04) echo "$SCRIPT_DIR/04-shared-hooks.patch" ;;
	*) echo "" ;;
	esac
}

clone_board_if_needed() {
	if [ -d "$BASE/p1_nor_4k" ] && [ -d "$OW/h133-p1_nor_4k" ]; then
		echo "==> board tree already exists, skip clone"
		return 0
	fi
	echo "==> clone from p1_nor_8733 + materialize DTS from p1_nor"
	[ -d "$BASE/p1_nor_8733" ] || { echo "error: missing $BASE/p1_nor_8733" >&2; exit 1; }
	[ -d "$BASE/p1_nor/linux-5.4" ] || { echo "error: missing $BASE/p1_nor/linux-5.4" >&2; exit 1; }

	if [ ! -d "$BASE/p1_nor_4k" ]; then
		cp -a "$BASE/p1_nor_8733" "$BASE/p1_nor_4k"
		rm -rf "$BASE/p1_nor_4k/linux-5.4"
		cp -a "$BASE/p1_nor/linux-5.4" "$BASE/p1_nor_4k/linux-5.4"
		# 拆其余软链为实文件（显示相关）
		for f in uboot-board.dts sys_config.fex sys_partition_nor.fex env.cfg; do
			if [ -L "$BASE/p1_nor_4k/$f" ]; then
				rm -f "$BASE/p1_nor_4k/$f"
				cp -a "$BASE/p1_nor/$f" "$BASE/p1_nor_4k/$f"
			fi
		done
		ln -sfn linux-5.4/board.dts "$BASE/p1_nor_4k/board.dts"
		if [ ! -f "$BASE/p1_nor_4k/bootlogo.bmp" ] && [ -f "$BASE/p1_nor_8733/bootlogo.bmp" ]; then
			cp -a "$BASE/p1_nor_8733/bootlogo.bmp" "$BASE/p1_nor_4k/bootlogo.bmp"
		fi
	fi

	if [ ! -d "$OW/h133-p1_nor_4k" ]; then
		cp -a "$OW/h133-p1_nor_8733" "$OW/h133-p1_nor_4k"
		# 路径内板名替换（保留 RTL8733BU 字样）
		find "$OW/h133-p1_nor_4k" -type f \( -name 'Makefile' -o -name 'vendorsetup.sh' -o -name 'defconfig' -o -name '*.mk' \) \
			-exec sed -i \
			-e 's/h133-p1_nor_8733/h133-p1_nor_4k/g' \
			-e 's/p1_nor_8733/p1_nor_4k/g' \
			{} +
	fi
}

apply_one() {
	local id=$1
	local patch
	patch="$(pick_patch "$id")"
	[ -n "$patch" ] && [ -f "$patch" ] || { echo "error: missing patch $id" >&2; exit 1; }
	if [ "$MODE" = check ]; then
		echo "==> dry-run: $(basename "$patch")"
		patch -p1 --dry-run <"$patch"
	else
		echo "==> apply: $(basename "$patch")"
		patch -p1 <"$patch"
	fi
}

if [ "$MODE" != check ]; then
	clone_board_if_needed
fi

if [ "$ARG" = all ]; then
	for id in 01 02 03 04; do
		apply_one "$id"
	done
else
	apply_one "$ARG"
fi

echo "==> done ($MODE)"
echo "    编译: ./tools/build_p1_nor_4k.sh full"
echo "    文档: H133-AI-Skills/开发记录/板件开发记录/p1_nor_4k/20260723-p1_nor_4k-板件新建与HDMI4K分离/README.md"
echo "    4K 硬解壁纸另见: ../CMA与lv_img_header-4K硬解/"
