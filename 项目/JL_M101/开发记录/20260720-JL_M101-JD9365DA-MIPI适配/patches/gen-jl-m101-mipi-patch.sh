#!/bin/bash
# 重新生成 JL-M101 MIPI phase1 补丁（在 SDK 根或本目录执行）
# 前提：树内已有本次改动（含未跟踪的新板级/panel）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${H133_SDK_ROOT:-$(cd "$SCRIPT_DIR/../../../../.." && pwd)}"
OUT_DIR="$SCRIPT_DIR"

cd "$ROOT"
if [ ! -f build/envsetup.sh ]; then
	echo "error: not SDK root: $ROOT" >&2
	exit 1
fi

PATHS=(
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_m101_jd9365da.c
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_m101_jd9365da.h
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/Kconfig
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.c
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.h
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/Makefile
	openwrt/package/allwinner/multimedia/tina_multimedia/libtmedia/Makefile
	openwrt/target/h133/h133-p1_nor/defconfig
	openwrt/target/h133/h133-p1_nor_8733/defconfig
	openwrt/target/h133/h133-p1_nor_JYY070/defconfig
	device/config/chips/h133/configs/p1_nor/linux-5.4/config-5.4
	device/config/chips/h133/configs/p1_nor_JYY070/linux-5.4/config-5.4
	tools/build_p1_nor_JL_M101.sh
	device/config/chips/h133/configs/p1_nor_JL_M101/
	openwrt/target/h133/h133-p1_nor_JL_M101/
)

git add -- "${PATHS[@]}"
# bootlogo.bmp 体积大且与 8733 相同，不进补丁；apply 时从 8733 拷
git restore --staged device/config/chips/h133/configs/p1_nor_JL_M101/bootlogo.bmp 2>/dev/null || true

git diff --cached -- \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_m101_jd9365da.c \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_m101_jd9365da.h \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/Kconfig \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.c \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.h \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/Makefile \
	> "$OUT_DIR/01-kernel-panel.patch"

git diff --cached -- \
	device/config/chips/h133/configs/p1_nor_JL_M101/ \
	openwrt/target/h133/h133-p1_nor_JL_M101/ \
	tools/build_p1_nor_JL_M101.sh \
	> "$OUT_DIR/02-board-tree.patch"

git diff --cached -- \
	openwrt/package/allwinner/multimedia/tina_multimedia/libtmedia/Makefile \
	openwrt/target/h133/h133-p1_nor/defconfig \
	openwrt/target/h133/h133-p1_nor_8733/defconfig \
	openwrt/target/h133/h133-p1_nor_JYY070/defconfig \
	device/config/chips/h133/configs/p1_nor/linux-5.4/config-5.4 \
	device/config/chips/h133/configs/p1_nor_JYY070/linux-5.4/config-5.4 \
	> "$OUT_DIR/03-shared-hooks.patch"

cat "$OUT_DIR/01-kernel-panel.patch" \
	"$OUT_DIR/02-board-tree.patch" \
	"$OUT_DIR/03-shared-hooks.patch" \
	> "$OUT_DIR/jl-m101-mipi-phase1.patch"

git reset HEAD -- "${PATHS[@]}" >/dev/null
git restore --staged device/config/chips/h133/configs/p1_nor_JL_M101/bootlogo.bmp 2>/dev/null || true

echo "==> $OUT_DIR/01-kernel-panel.patch ($(grep -c '^diff --git' "$OUT_DIR/01-kernel-panel.patch") diffs)"
echo "==> $OUT_DIR/02-board-tree.patch ($(grep -c '^diff --git' "$OUT_DIR/02-board-tree.patch") diffs)"
echo "==> $OUT_DIR/03-shared-hooks.patch ($(grep -c '^diff --git' "$OUT_DIR/03-shared-hooks.patch") diffs)"
echo "==> $OUT_DIR/jl-m101-mipi-phase1.patch ($(grep -c '^diff --git' "$OUT_DIR/jl-m101-mipi-phase1.patch") diffs, $(wc -l < "$OUT_DIR/jl-m101-mipi-phase1.patch") lines)"
echo "    note: bootlogo.bmp 不在补丁内，apply 时从 p1_nor_8733 复制"
