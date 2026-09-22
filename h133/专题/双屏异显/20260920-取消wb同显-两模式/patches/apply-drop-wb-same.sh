#!/usr/bin/env bash
# ⑤：取消 WB 同显，只留两种贴屏（SAME=LCD+HDMI，DIFF=仅HDMI）
# 打在 ④ 之上。在 SDK 根目录执行，或任意路径执行本脚本。
#
# 用法:
#   apply-drop-wb-same.sh           # 打补丁
#   apply-drop-wb-same.sh --check   # dry-run
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
	"$SCRIPT_DIR/01-kernel-drop-wb-coupling.patch"
	"$SCRIPT_DIR/02-libuapi-two-modes.patch"
	"$SCRIPT_DIR/03-comment-cleanup.patch"
)

for p in "${PATCHES[@]}"; do
	if [[ ! -f "$p" ]]; then
		echo "错误: 找不到 $p" >&2
		exit 1
	fi
done

cd "$SDK_ROOT"

# 01/02 必须一起打：02 删掉的 sunxi_dual_display_set_hdmi_output() 是 01 删掉的 ioctl 的调用方
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
echo "动了内核，要整编（只编 libuapi 不够）："
echo "  ./build.sh && ./build.sh pack"
echo
echo "板端验收（须已插 HDMI、先停播）："
echo "  disp_mode get    # mode=same hdmi=1 video_screen=3，不再有 wb= / hdmi_out="
echo "  disp_mode diff   # 异屏：视频只上电视（video_screen=2）"
echo "  disp_mode same   # 同屏：LCD+HDMI 都有（video_screen=3）"
echo "开机串口不该再出现 [DISP] auto-enable dual display"
