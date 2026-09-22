#!/bin/bash
# H133 p1_nor_JL_HXR101（NOR 京龙；屏驱 HXR10106B-28 / ILI9881C，触摸 GSL3670）
# Usage: build_p1_nor_JL_HXR101.sh [full|kernel|rootfs]

ROOT="${H133_SDK_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
BOARD=p1_nor_JL_HXR101
LUNCH=h133-p1_nor_JL_HXR101-tina
DEFCONFIG="$ROOT/openwrt/target/h133/h133-${BOARD}/defconfig"

cd "$ROOT" || exit 1

if [ ! -f "build/envsetup.sh" ]; then
	echo "error: not in H133 SDK root: $ROOT" >&2
	exit 1
fi

# Tina SDK 标记文件（部分环境缺失会导致 envsetup 失败）
[ -f build/.tinatopdir ] || touch build/.tinatopdir

ensure_board_config() {
	local cur
	cur=$(grep '^export LICHEE_BOARD=' .buildconfig 2>/dev/null | sed 's/.*=//')
	if [ "$cur" = "$BOARD" ]; then
		echo "==> .buildconfig already LICHEE_BOARD=$BOARD"
		return 0
	fi
	echo "==> autoconfig for $BOARD"
	./build.sh autoconfig -o openwrt -i h133 -b "$BOARD" -n nor || return 1
}

ensure_openwrt_defconfig() {
	local tgt
	tgt=$(grep '^CONFIG_TARGET_BOARD=' openwrt/openwrt/.config 2>/dev/null | sed 's/.*=\"\(.*\)\"/\1/')
	if [ "$tgt" = "h133-$BOARD" ] && [ -f openwrt/openwrt/.config ]; then
		return 0
	fi
	echo "==> install openwrt defconfig for h133-$BOARD"
	cp -a "$DEFCONFIG" openwrt/openwrt/.config
}

set +e
# shellcheck source=/dev/null
source build/envsetup.sh
_envsetup_ret=$?
set -e
if [ "$_envsetup_ret" -ne 0 ]; then
	echo "error: source build/envsetup.sh failed ($_envsetup_ret)" >&2
	exit 1
fi

ensure_board_config || exit 1
ensure_openwrt_defconfig || exit 1

# lunch 会再次跑 aw_patch 预检；内核树无独立 .git 时可能留下失败标记
rm -f "$ROOT/kernel/linux-5.4/.aw_patch_failed"

MODE="${1:-full}"
NPROC="$(nproc 2>/dev/null || echo 4)"

touch_disp_for_rebuild() {
	local d="$ROOT/kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2"
	touch "$d/disp/dev_disp.c" "$d/disp/dev_fb.c" "$d/hdmi2/hdmi_tx.c" 2>/dev/null || true
}

prepare_hxr_uboot_reconfig() {
	local u="$ROOT/brandy/brandy-2.0/u-boot-2018"
	# U-Boot 会按 defconfig md5 跳过配置刷新；这里强制丢弃旧屏驱配置。
	rm -f "$u/.config" "$u/u-boot.cfg" "$u/.tmp_defcofig.o.md5sum"
	rm -f "$ROOT/out/h133/kernel/build/.config"
}

verify_hxr_uboot_config() {
	local u="$ROOT/brandy/brandy-2.0/u-boot-2018"
	if ! grep -q '^CONFIG_LCD_SUPPORT_JL_HXR_ILI9881C=y' "$u/.config"; then
		echo "error: U-Boot LCD_SUPPORT_JL_HXR_ILI9881C is not enabled" >&2
		return 1
	fi
}

touch_lvgl_sunxifb_for_rebuild() {
	local f="$ROOT/platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunxifb.c"
	[ -f "$f" ] && touch "$f"
	rm -rf "$ROOT/out/h133/p1_nor_JL_HXR101/openwrt/build_dir/target/desk" 2>/dev/null || true
	rm -rf "$ROOT/out/h133/p1_nor_JL_HXR101/openwrt/build_dir/target/service_guardian" 2>/dev/null || true
}

sync_kernel_to_openwrt() {
	if [ -f "$ROOT/out/h133/kernel/staging/boot.img" ]; then
		mkdir -p "$ROOT/out/h133/$BOARD/openwrt"
		cp -a "$ROOT/out/h133/kernel/staging/boot.img" \
			"$ROOT/out/h133/kernel/staging/uImage" \
			"$ROOT/out/h133/$BOARD/openwrt/"
		echo "==> synced kernel staging -> out/h133/$BOARD/openwrt/"
	fi
}

case "$MODE" in
kernel)
	echo "==> ./build.sh kernel bootloader + ./build.sh uboot"
	touch_disp_for_rebuild
	prepare_hxr_uboot_reconfig
	rm -f "$ROOT/kernel/linux-5.4/.aw_patch_failed"
	./build.sh kernel bootloader
	./build.sh uboot
	verify_hxr_uboot_config
	sync_kernel_to_openwrt
	;;
rootfs)
	echo "==> m + p"
	touch_lvgl_sunxifb_for_rebuild
	m -j"${NPROC}"
	p
	;;
full)
	echo "==> ./build.sh kernel bootloader + ./build.sh uboot + m + p"
	touch_disp_for_rebuild
	prepare_hxr_uboot_reconfig
	rm -f "$ROOT/kernel/linux-5.4/.aw_patch_failed"
	./build.sh kernel bootloader
	./build.sh uboot
	verify_hxr_uboot_config
	sync_kernel_to_openwrt
	touch_lvgl_sunxifb_for_rebuild
	m -j"${NPROC}"
	p
	;;
*)
	echo "Usage: $0 [full|kernel|rootfs]" >&2
	exit 1
	;;
esac

IMG="$ROOT/out/h133_linux_${BOARD}_uart0_nor.img"
if [ -f "$IMG" ]; then
	echo "==> OK: $IMG"
	ls -la "$IMG"
	md5sum "$IMG" 2>/dev/null || true
else
	echo "==> note: image not found: $IMG"
fi
