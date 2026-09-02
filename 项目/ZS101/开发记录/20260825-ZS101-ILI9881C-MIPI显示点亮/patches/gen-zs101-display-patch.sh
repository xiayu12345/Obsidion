#!/bin/bash
# 相对 qj/main 重生成 ZS101 屏幕补丁（不含音频/投屏）
# 在 SDK 根执行，或设置 H133_SDK_ROOT
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${H133_SDK_ROOT:-$(cd "$SCRIPT_DIR/../../../../../.." && pwd)}"
OUT_DIR="$SCRIPT_DIR"
BASE="${ZS101_PATCH_BASE:-qj/main}"

cd "$ROOT"
if [ ! -f build/envsetup.sh ]; then
	echo "error: not SDK root: $ROOT" >&2
	exit 1
fi

git rev-parse --verify "$BASE" >/dev/null

git diff "$BASE" -- \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/zs101_ili9881c.c \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/zs101_ili9881c.h \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/Kconfig \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.c \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.h \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/Makefile \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/zs101_ili9881c.c \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/zs101_ili9881c.h \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/Kconfig \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.c \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.h \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/Makefile \
	brandy/brandy-2.0/u-boot-2018/configs/sun8iw20p1_defconfig \
	brandy/brandy-2.0/u-boot-2018/configs/sun8iw20p1_nor_defconfig \
	> "$OUT_DIR/01-kernel-uboot-panel.patch"

git diff "$BASE" -- \
	device/config/chips/h133/configs/p1_nor_ZS101/linux-5.4/board.dts \
	device/config/chips/h133/configs/p1_nor_ZS101/uboot-board.dts \
	device/config/chips/h133/configs/p1_nor_ZS101/openwrt/bsp_defconfig \
	openwrt/target/h133/h133-p1_nor_ZS101/busybox-init-base-files/etc/setting.ini \
	tools/build_p1_nor_ZS101.sh \
	> "$OUT_DIR/02-board-display.patch"

git diff "$BASE" -- \
	openwrt/package/allwinner/multimedia/tina_multimedia/libtmedia/Makefile \
	openwrt/.openwrt_targets \
	> "$OUT_DIR/03-shared-hooks.patch"

cat "$OUT_DIR/01-kernel-uboot-panel.patch" \
	"$OUT_DIR/02-board-display.patch" \
	"$OUT_DIR/03-shared-hooks.patch" \
	> "$OUT_DIR/zs101-display.patch"

echo "==> $OUT_DIR/01-kernel-uboot-panel.patch ($(grep -c '^diff --git' "$OUT_DIR/01-kernel-uboot-panel.patch" || true) diffs)"
echo "==> $OUT_DIR/02-board-display.patch ($(grep -c '^diff --git' "$OUT_DIR/02-board-display.patch" || true) diffs)"
echo "==> $OUT_DIR/03-shared-hooks.patch ($(grep -c '^diff --git' "$OUT_DIR/03-shared-hooks.patch" || true) diffs)"
echo "==> $OUT_DIR/zs101-display.patch ($(grep -c '^diff --git' "$OUT_DIR/zs101-display.patch" || true) diffs, $(wc -l < "$OUT_DIR/zs101-display.patch") lines)"
echo "    base: $BASE"
echo "    note: 不含 tsound_ctrl / 投屏 / OpenWrt 整包；bootlogo 不进补丁"
