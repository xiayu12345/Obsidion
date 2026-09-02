#!/usr/bin/env bash
# GSL ctp_report_max 内核映射（架构级：gslX680.c + 可选 JYY070 DTS 示例）
# 在 SDK 根目录执行，或任意路径执行本脚本。
#
# 用法:
#   apply-gsl-tp-report-map.sh              # 打合并补丁
#   apply-gsl-tp-report-map.sh --check      # dry-run
#   apply-gsl-tp-report-map.sh 01|02        # 只打分片
#   apply-gsl-tp-report-map.sh --check 01
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

find_sdk_root() {
	local d="$1"
	while [[ "$d" != "/" ]]; do
		if [[ -d "$d/device/config" && -d "$d/tools" ]]; then
			echo "$d"
			return 0
		fi
		d="$(dirname "$d")"
	done
	return 1
}

SDK_ROOT="${H133_SDK_ROOT:-}"
if [[ -z "$SDK_ROOT" ]]; then
	SDK_ROOT="$(find_sdk_root "$SCRIPT_DIR")" || {
		echo "错误: 无法定位 SDK 根（需含 device/config 与 tools/），或设置 H133_SDK_ROOT" >&2
		exit 1
	}
fi

pick_patch() {
	case "${1:-all}" in
	01) echo "$SCRIPT_DIR/01-kernel-gslx680-report-map.patch" ;;
	02) echo "$SCRIPT_DIR/02-board-jyy070-dts.patch" ;;
	all|"") echo "$SCRIPT_DIR/gsl-tp-report-map.patch" ;;
	*)
		echo "用法: $0 [--check] [all|01|02]" >&2
		exit 1
		;;
	esac
}

MODE=apply
ARG=all
for a in "$@"; do
	case "$a" in
	--check) MODE=check ;;
	all|01|02) ARG=$a ;;
	*)
		echo "用法: $0 [--check] [all|01|02]" >&2
		exit 1
		;;
	esac
done

PATCH="$(pick_patch "$ARG")"
if [[ ! -f "$PATCH" ]]; then
	echo "错误: 找不到 $PATCH" >&2
	exit 1
fi

cd "$SDK_ROOT"

apply_one() {
	local mode="$1"
	if command -v git >/dev/null && git -C "$SDK_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		if [[ "$mode" == check ]]; then
			git apply --check "$PATCH"
		else
			git apply "$PATCH"
		fi
	else
		if [[ "$mode" == check ]]; then
			patch -p1 --dry-run < "$PATCH"
		else
			patch -p1 < "$PATCH"
		fi
	fi
}

if [[ "$MODE" == check ]]; then
	echo "==> dry-run: $PATCH"
	apply_one check
	echo "OK: --check 通过"
	exit 0
fi

echo "==> apply: $PATCH"
apply_one apply
echo "OK: 已应用 $PATCH"
echo "编译建议（按目标板选用脚本）:"
echo "  ./tools/build_p1_nor_JYY070.sh kernel   # 例：首验板（需缩放）"
echo "  ./tools/build_p1_nor_JL_M101.sh kernel  # 恒等映射板只编 01 即可"
echo "文档: H133-AI-Skills/开发记录/GSL触摸坐标映射/"
