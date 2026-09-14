#!/bin/bash
# JYY070 LVDS 显示开发 — 阶段 1～5 补丁应用脚本
# 在 H133 SDK 根目录执行，或设置 H133_SDK_ROOT
#
# Usage:
#   bash apply-jyy070-lvds-display.sh          # 打合并补丁 phase1-5
#   bash apply-jyy070-lvds-display.sh --check  # 仅检查 patch 能否应用（dry-run）
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${H133_SDK_ROOT:-$(cd "$SCRIPT_DIR/../../../../.." && pwd)}"
PATCH="$SCRIPT_DIR/jyy070-lvds-display-phase1-5.patch"

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: 请在 SDK 根目录执行，或设置 H133_SDK_ROOT" >&2
	echo "  当前 ROOT=$ROOT" >&2
	exit 1
fi

if [ ! -f "$PATCH" ]; then
	echo "error: missing $PATCH" >&2
	exit 1
fi

cd "$ROOT"

if [ "${1:-}" = "--check" ]; then
	echo "==> patch --dry-run -p1 < $(basename "$PATCH")"
	patch -p1 --dry-run < "$PATCH"
	exit 0
fi

echo "==> patch -p1 < $(basename "$PATCH")"
if patch -p1 -N --forward < "$PATCH"; then
	echo "==> OK"
else
	echo "warn: 部分 hunk 已打过或上下文不匹配，请对照 README.md 分步文档手工合并" >&2
fi

echo ""
echo "==> 编译:"
echo "    ./tools/build_p1_nor_JYY070.sh full"
echo "    ./tools/build_p1_nor_JYY070.sh rootfs   # 仅 sunxifb/desk 变更"
echo ""
echo "==> 串口验收（统一路径）:"
echo "    必须有: [desk] fb 1280x800 -> LVGL 1280x800, sunxifb_rot=0"
echo "    必须有: [DISP] dual display ... G2D rot0 ... (dual_display_rot=0)"
echo "    必须无: rotate=0: draw ping-pong, LCD fixed page1  (旧 fix_lcd 路径)"
echo ""
echo "==> 重新生成补丁:"
echo "    bash $SCRIPT_DIR/gen-jyy070-lvds-display-patch.sh"
