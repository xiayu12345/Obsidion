#!/usr/bin/env bash
# 按屏旋转：TPlayer 恒 0；JL lcd_rot=270（G2D 整帧 180 + DispNvRotate90）
# 打在 ⑤ 之上。在 SDK 根目录执行，或任意路径执行本脚本。
#
# 用法:
#   apply-per-screen-rot.sh           # 打补丁
#   apply-per-screen-rot.sh --check   # dry-run
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

PATCHES=(
	"$SCRIPT_DIR/01-ktv-tplayer-rotate0.patch"
	"$SCRIPT_DIR/02-libtmedia-makefile-jl270.patch"
	"$SCRIPT_DIR/03-tlayer-per-screen-270.patch"
)

for p in "${PATCHES[@]}"; do
	if [[ ! -f "$p" ]]; then
		echo "错误: 找不到 $p" >&2
		exit 1
	fi
done

cd "$SDK_ROOT"

if [[ "${1:-}" == "--check" ]]; then
	echo "==> dry-run"
	git apply --check "${PATCHES[@]}"
	echo "OK: --check 通过"
	exit 0
fi

if [[ -n "${1:-}" ]]; then
	echo "用法: $0 [--check]" >&2
	exit 1
fi

echo "==> apply"
git apply "${PATCHES[@]}"
echo "OK: 已应用 ${#PATCHES[@]} 份补丁"
echo
echo "不动内核，但要重编 libtmedia + media_session（ktv），再 pack："
echo "  ./build.sh && ./build.sh pack"
echo
echo "板端验收（JL 竖屏，须已插 HDMI）："
echo "  同显：LCD 正、无左边绿边；HDMI 正"
echo "  异显：LCD 无视频；HDMI 正"
echo "  setting.ini video_rotate 不再进 TPlayer，勿当贴屏角"
