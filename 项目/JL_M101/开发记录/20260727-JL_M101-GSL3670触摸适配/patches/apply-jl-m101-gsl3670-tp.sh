#!/usr/bin/env bash
# 在 SDK 根目录执行：将 JL_M101 显示定稿基线（gt911@5d）切到 GSL3670 触摸适配。
# 用法: ./H133-AI-Skills/开发记录/板件开发记录/JL_M101/20260727-JL_M101-GSL3670触摸适配/patches/apply-jl-m101-gsl3670-tp.sh [--check]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_FILE="${SCRIPT_DIR}/01-dts-config-gsl3670.patch"
FW_SRC="${SCRIPT_DIR}/files/gsl3670.bin"
PACK_SRC="${SCRIPT_DIR}/files/gsl_pack_firmware.py"

# 从 patches/ 向上找到含 device/config 与 tools/ 的 SDK 根
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
	echo "错误: 无法从脚本位置定位 SDK 根（需含 device/config 与 tools/）" >&2
	exit 1
}

FW_DST="${SDK_ROOT}/openwrt/target/h133/h133-p1_nor_JL_M101/busybox-init-base-files/lib/firmware/gsl_firmware/gsl3670.bin"
PACK_DST="${SDK_ROOT}/tools/gsl_pack_firmware.py"

CHECK_ONLY=0
if [[ "${1:-}" == "--check" ]]; then
	CHECK_ONLY=1
elif [[ $# -gt 0 ]]; then
	echo "用法: $0 [--check]" >&2
	exit 1
fi

cd "$SDK_ROOT"
echo "SDK 根: $SDK_ROOT"

apply_or_check_patch() {
	if command -v git >/dev/null 2>&1; then
		if [[ "$CHECK_ONLY" -eq 1 ]]; then
			git apply --check "$PATCH_FILE"
		else
			git apply "$PATCH_FILE"
		fi
	else
		if [[ "$CHECK_ONLY" -eq 1 ]]; then
			patch -p1 --dry-run < "$PATCH_FILE"
		else
			patch -p1 < "$PATCH_FILE"
		fi
	fi
}

if [[ ! -f "$PATCH_FILE" ]]; then
	echo "错误: 缺少补丁 $PATCH_FILE" >&2
	exit 1
fi
if [[ ! -f "$FW_SRC" ]]; then
	echo "错误: 缺少固件 $FW_SRC" >&2
	exit 1
fi

echo "==> 校验/应用 $PATCH_FILE"
apply_or_check_patch

if [[ "$CHECK_ONLY" -eq 1 ]]; then
	echo "==> --check: 跳过固件与 tools 复制"
	if [[ ! -f "$PACK_DST" && ! -f "$PACK_SRC" ]]; then
		echo "警告: 基线无 tools/gsl_pack_firmware.py，且 patches/files/ 也无副本" >&2
	fi
	echo "补丁可应用 (check OK)"
	exit 0
fi

echo "==> 复制 gsl3670.bin → $FW_DST"
mkdir -p "$(dirname "$FW_DST")"
cp -f "$FW_SRC" "$FW_DST"
md5sum "$FW_DST"

if [[ ! -f "$PACK_DST" ]]; then
	if [[ ! -f "$PACK_SRC" ]]; then
		echo "错误: 缺 tools/gsl_pack_firmware.py，且 patches/files/ 无副本" >&2
		exit 1
	fi
	echo "==> 复制 gsl_pack_firmware.py → $PACK_DST"
	cp -f "$PACK_SRC" "$PACK_DST"
	chmod +x "$PACK_DST"
else
	echo "==> tools/gsl_pack_firmware.py 已存在，跳过复制"
fi

cat << 'MSG'

完成。换固件后必须清 builtin 缓存并编 kernel，再打包：

  rm -rf out/h133/kernel/build/drivers/base/firmware_loader/builtin/gsl_firmware
  ./tools/build_p1_nor_JL_M101.sh kernel
  # lunch 后执行 p，或：./tools/build_p1_nor_JL_M101.sh full

MSG
