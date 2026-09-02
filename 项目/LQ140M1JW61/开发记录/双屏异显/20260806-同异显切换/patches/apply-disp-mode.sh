#!/usr/bin/env bash
# 双屏同/异显切换（架构级：WB 常开 + SET_HDMI_OUT）
# 在 SDK 根目录执行，或任意路径执行本脚本。
#
# 用法:
#   apply-disp-mode.sh              # 打合并补丁
#   apply-disp-mode.sh --check      # dry-run
#   apply-disp-mode.sh 01|02|03     # 只打分片
#   apply-disp-mode.sh --check 02
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
	01) echo "$SCRIPT_DIR/01-kernel-dual-hdmi-out.patch" ;;
	02) echo "$SCRIPT_DIR/02-libuapi-disp-mode.patch" ;;
	03) echo "$SCRIPT_DIR/03-tlayer-media-session.patch" ;;
	all|"") echo "$SCRIPT_DIR/disp-mode-same-diff.patch" ;;
	*)
		echo "用法: $0 [--check] [all|01|02|03]" >&2
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
		echo "用法: $0 [--check] [all|01|02|03]" >&2
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

if [[ "$MODE" == check ]]; then
	echo "==> dry-run: $PATCH"
	git apply --check "$PATCH"
	echo "OK: --check 通过"
	exit 0
fi

echo "==> apply: $PATCH"
git apply "$PATCH"
echo "OK: 已应用 $PATCH"
echo "编译建议（按目标板选用脚本）:"
echo "  ./tools/build_p1_nor_JL_M101.sh kernel   # 例：JL 验证板"
echo "  ./tools/build_p1_nor_JL_M101.sh rootfs"
echo "板端: disp_mode get|same|diff"
