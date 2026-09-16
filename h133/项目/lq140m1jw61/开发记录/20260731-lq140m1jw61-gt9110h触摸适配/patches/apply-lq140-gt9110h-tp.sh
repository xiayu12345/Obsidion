#!/usr/bin/env bash
# LQ140M1JW61 GT9110H：驱动 SEND_CFG=1 + GROUP8@1920×1080 + 板级 DTS
# Usage:
#   bash .../patches/apply-lq140-gt9110h-tp.sh
#   bash .../patches/apply-lq140-gt9110h-tp.sh --check
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_DRV="${SCRIPT_DIR}/01-gt9xx-driver.patch"
PATCH_DTS="${SCRIPT_DIR}/02-board-dts-ctp.patch"

find_sdk_root() {
	local d="$1"
	while [[ "$d" != "/" ]]; do
		if [[ -f "$d/build/envsetup.sh" && -d "$d/device/config" ]]; then
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
		echo "错误: 无法定位 SDK 根（需含 build/envsetup.sh）" >&2
		exit 1
	}
fi

CHECK_ONLY=0
if [[ "${1:-}" == "--check" ]]; then
	CHECK_ONLY=1
elif [[ $# -gt 0 ]]; then
	echo "用法: $0 [--check]" >&2
	exit 1
fi

cd "$SDK_ROOT"
echo "SDK 根: $SDK_ROOT"

apply_one() {
	local patch="$1"
	local label
	label="$(basename "$patch")"
	echo "==> $label"
	if [[ ! -f "$patch" ]]; then
		echo "错误: 缺少 $patch" >&2
		exit 1
	fi
	if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
		if [[ "$CHECK_ONLY" -eq 1 ]]; then
			if git apply --check "$patch" 2>/dev/null; then
				echo "    check OK"
			elif git apply --reverse --check "$patch" 2>/dev/null; then
				echo "    已落地（reverse check OK）"
			else
				echo "    警告: 无法 check，请人工对照" >&2
			fi
		else
			if git apply --check "$patch" 2>/dev/null; then
				git apply "$patch"
				echo "    applied"
			elif git apply --reverse --check "$patch" 2>/dev/null; then
				echo "    已存在，跳过"
			else
				echo "    警告: 无法应用，请人工对照开发记录" >&2
			fi
		fi
	else
		if [[ "$CHECK_ONLY" -eq 1 ]]; then
			patch -p1 --dry-run <"$patch"
		else
			patch -p1 <"$patch"
		fi
	fi
}

apply_one "$PATCH_DRV"
apply_one "$PATCH_DTS"
echo "完成。编译: ./tools/build_p1_nor_LQ140M1JW61.sh kernel"
