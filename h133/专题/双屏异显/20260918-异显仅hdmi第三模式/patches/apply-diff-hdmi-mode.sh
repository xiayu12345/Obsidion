#!/usr/bin/env bash
# ④：在 ③ 上加 DIFF_HDMI（视频只贴 HDMI；DIFF 仍是 LCD+HDMI）
# 在 SDK 根目录执行，或任意路径执行本脚本。
#
# 用法:
#   apply-diff-hdmi-mode.sh           # 打补丁
#   apply-diff-hdmi-mode.sh --check   # dry-run
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

PATCH="$SCRIPT_DIR/01-libuapi-diff-hdmi-mode.patch"
if [[ ! -f "$PATCH" ]]; then
	echo "错误: 找不到 $PATCH" >&2
	exit 1
fi

cd "$SDK_ROOT"

if [[ "${1:-}" == "--check" ]]; then
	echo "==> dry-run: $PATCH"
	git apply --check "$PATCH"
	echo "OK: --check 通过"
	exit 0
fi

if [[ -n "${1:-}" ]]; then
	echo "用法: $0 [--check]" >&2
	exit 1
fi

echo "==> apply: $PATCH"
git apply "$PATCH"
echo "OK: 已应用 $PATCH"
echo "只重编 libuapi 再 pack，例："
echo "  rm -rf out/h133/<板名>/openwrt/build_dir/target/libuapi"
echo "  ./build.sh openwrt_rootfs && ./build.sh pack"
echo "板端: 停播 → disp_mode diff_hdmi → 再点播；get 时 video_screen=2"
echo "设置页「异屏」仍是 disp_mode diff（video_screen=3）"
