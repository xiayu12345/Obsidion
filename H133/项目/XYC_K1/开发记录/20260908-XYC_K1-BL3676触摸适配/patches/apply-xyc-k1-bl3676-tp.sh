#!/bin/bash
# 鑫宇宸 XYC_K1 BL3676 触摸 — 补丁应用
# 在 H133 SDK 根目录执行，或设置 H133_SDK_ROOT
#
# Usage:
#   bash apply-xyc-k1-bl3676-tp.sh          # 打合并补丁
#   bash apply-xyc-k1-bl3676-tp.sh --check
#   bash apply-xyc-k1-bl3676-tp.sh 01|02|03
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${H133_SDK_ROOT:-$(cd "$SCRIPT_DIR/../../../../../.." && pwd)}"

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: 请在 SDK 根目录执行，或设置 H133_SDK_ROOT" >&2
	echo "  当前 ROOT=$ROOT" >&2
	exit 1
fi

if [ ! -f "$ROOT/device/config/chips/h133/configs/p1_nor_XYC_K1/linux-5.4/board.dts" ]; then
	echo "error: 没有 p1_nor_XYC_K1 板级树。先打 LVDS 定稿补丁（会连触摸一起带上）。" >&2
	exit 1
fi

cd "$ROOT"

pick_patch() {
	case "${1:-all}" in
	01) echo "$SCRIPT_DIR/01-kernel-betterlife-ts.patch" ;;
	02) echo "$SCRIPT_DIR/02-board-dts-ctp.patch" ;;
	03) echo "$SCRIPT_DIR/03-docs.patch" ;;
	all|"") echo "$SCRIPT_DIR/xyc-k1-bl3676-tp.patch" ;;
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
	echo "error: missing $PATCH — 先跑 gen-xyc-k1-bl3676-tp-patch.sh" >&2
	exit 1
fi

try_patch_check() {
	if patch -p1 --dry-run <"$PATCH" >/dev/null 2>&1; then
		echo "forward"
	elif patch -p1 --dry-run -R <"$PATCH" >/dev/null 2>&1; then
		echo "reverse"
	else
		echo "fail"
	fi
}

git_ok=0
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
	git_ok=1
fi

if [ "$MODE" = check ]; then
	echo "==> dry-run: $PATCH"
	if [ "$git_ok" = 1 ] && git apply --check "$PATCH" 2>/dev/null; then
		echo "==> OK (check)"
		exit 0
	fi
	if [ "$git_ok" = 1 ] && git apply --reverse --check "$PATCH" 2>/dev/null; then
		echo "==> 已落地（reverse check OK）"
		exit 0
	fi
	case "$(try_patch_check)" in
	forward) echo "==> OK (check)" ;;
	reverse) echo "==> 已落地（reverse check OK）" ;;
	*) echo "error: 无法 check，请人工对照开发记录" >&2; exit 1 ;;
	esac
	exit 0
fi

echo "==> apply: $PATCH"
if [ "$git_ok" = 1 ] && git apply --check "$PATCH" 2>/dev/null; then
	git apply "$PATCH"
	echo "==> done"
elif [ "$git_ok" = 1 ] && git apply --reverse --check "$PATCH" 2>/dev/null; then
	echo "==> 已存在，跳过"
elif [ "$(try_patch_check)" = reverse ]; then
	echo "==> 已存在，跳过"
elif [ "$(try_patch_check)" = forward ]; then
	patch -p1 <"$PATCH"
	echo "==> done"
else
	echo "error: 无法应用。当前出图树已含 BL3676 则属正常；否则对照开发记录。" >&2
	exit 1
fi

echo "    编译: export PATH=\"\$PWD/prebuilt/hostbuilt/make4.1/bin:\$PATH\""
echo "          ./tools/build_p1_nor_XYC_K1.sh kernel"
echo "          source build/envsetup.sh && p"
echo "    文档: H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-BL3676触摸适配/README.md"
