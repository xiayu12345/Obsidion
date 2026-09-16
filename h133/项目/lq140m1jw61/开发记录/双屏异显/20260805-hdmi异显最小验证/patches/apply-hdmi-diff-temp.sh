#!/usr/bin/env bash
# TEMP：HDMI 异显最小验证（关 WB/clone + 视频直贴 screen1 + fence 跟屏）
# 历史对照，勿作产品默认。正式方案见 20260806-同异显切换。
# 用法: apply-hdmi-diff-temp.sh [--check]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_FILE="${SCRIPT_DIR}/hdmi-diff-display-temp.patch"

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

SDK_ROOT="$(find_sdk_root "$SCRIPT_DIR")" || {
	echo "错误: 无法定位 SDK 根（需含 device/config 与 tools/）" >&2
	exit 1
}

CHECK_ONLY=0
if [[ "${1:-}" == "--check" ]]; then
	CHECK_ONLY=1
elif [[ $# -gt 0 ]]; then
	echo "用法: $0 [--check]" >&2
	exit 1
fi

cd "$SDK_ROOT"
if [[ ! -f "$PATCH_FILE" ]]; then
	echo "错误: 找不到 $PATCH_FILE" >&2
	exit 1
fi

if [[ "$CHECK_ONLY" -eq 1 ]]; then
	git apply --check "$PATCH_FILE"
	echo "OK: --check 通过"
	exit 0
fi

git apply "$PATCH_FILE"
echo "OK: 已应用 $PATCH_FILE"
echo "编译: ./tools/build_p1_nor_JL_M101.sh kernel   # 含内核 TEMP"
echo "      ./tools/build_p1_nor_JL_M101.sh rootfs   # 含 libtmedia fence"
