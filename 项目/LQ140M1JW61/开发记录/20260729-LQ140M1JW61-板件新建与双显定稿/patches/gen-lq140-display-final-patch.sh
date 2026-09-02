#!/bin/bash
# 重新生成 LQ140M1JW61 显示定稿补丁（当前已出图树）
# 在 SDK 根执行，或设置 H133_SDK_ROOT
# 注意：只收录本专题相关文件，不含 p1_nor_4k/JL_M101 无关 DTS、不含 dev_disp.c
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# patches → 定稿目录 → LQ140M1JW61 → 开发记录 → H133-AI-Skills → SDK（5 级）
ROOT="${H133_SDK_ROOT:-$(cd "$SCRIPT_DIR/../../../../.." && pwd)}"
OUT_DIR="$SCRIPT_DIR"

cd "$ROOT"
if [ ! -f build/envsetup.sh ]; then
	echo "error: not SDK root: $ROOT" >&2
	exit 1
fi

stage_list() {
	local f
	while IFS= read -r f; do
		[ -z "$f" ] && continue
		[ -e "$f" ] || { echo "warn: missing $f" >&2; continue; }
		git add -f -- "$f"
	done
}

# --- stage code ---
stage_list <<'EOF'
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/lq140_mipi2edp.c
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/lq140_mipi2edp.h
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/Kconfig
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.c
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.h
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/Makefile
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/lq140_mipi2edp.c
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/lq140_mipi2edp.h
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/Kconfig
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.c
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.h
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/Makefile
brandy/brandy-2.0/u-boot-2018/configs/sun8iw20p1_auto_nor_defconfig
openwrt/package/allwinner/multimedia/tina_multimedia/libtmedia/Makefile
openwrt/.openwrt_targets
openwrt/target/h133/h133-p1_nor/defconfig
openwrt/target/h133/h133-p1_nor_8733/defconfig
openwrt/target/h133/h133-p1_nor_JYY070/defconfig
openwrt/target/h133/h133-p1_nor_JL_M101/defconfig
openwrt/target/h133/h133-p1_nor_4k/defconfig
device/config/chips/h133/configs/p1_nor/linux-5.4/config-5.4
device/config/chips/h133/configs/p1_nor_JYY070/linux-5.4/config-5.4
device/config/chips/h133/configs/p1_nor_JL_M101/linux-5.4/config-5.4
device/config/chips/h133/configs/p1_nor_4k/linux-5.4/config-5.4
tools/build_p1_nor_LQ140M1JW61.sh
EOF

# 板级整树（踢掉 bootlogo / 编译垃圾）
git add -f -- device/config/chips/h133/configs/p1_nor_LQ140M1JW61/
git add -f -- openwrt/target/h133/h133-p1_nor_LQ140M1JW61/
git restore --staged device/config/chips/h133/configs/p1_nor_LQ140M1JW61/bootlogo.bmp 2>/dev/null || true
git restore --staged brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/lq140_mipi2edp.su 2>/dev/null || true
# 勿把无关板 DTS 改动带进本专题
git restore --staged \
	device/config/chips/h133/configs/p1_nor_4k/linux-5.4/board.dts \
	device/config/chips/h133/configs/p1_nor_JL_M101/linux-5.4/board.dts \
	openwrt/target/h133/h133-p1_nor_4k/busybox-init-base-files/etc/setting.ini \
	2>/dev/null || true

# 文档（H133-AI-Skills 常被 gitignore，必须 -f）
DOC_DIR="H133-AI-Skills/开发记录/板件开发记录/LQ140M1JW61/20260729-LQ140M1JW61-板件新建与双显定稿"
git add -f -- \
	"H133-AI-Skills/skills/h133-display/board-profile-p1_nor_LQ140M1JW61.md" \
	"H133-AI-Skills/开发记录/README.md" \
	"H133-AI-Skills/开发记录/板件开发记录/LQ140M1JW61/README.md" \
	"$DOC_DIR/README.md" \
	"$DOC_DIR/00-总览与定稿.md" \
	"$DOC_DIR/01-板件新建.md" \
	"$DOC_DIR/02-panel与init.md" \
	"$DOC_DIR/03-DTS与双显.md" \
	"$DOC_DIR/04-实机调试与踩坑.md" \
	"$DOC_DIR/05-编译与验收.md" \
	"$DOC_DIR/patches/apply-lq140-display-final.sh" \
	"$DOC_DIR/patches/gen-lq140-display-final-patch.sh"

git diff --cached -- \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/lq140_mipi2edp.c \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/lq140_mipi2edp.h \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/Kconfig \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.c \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.h \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/Makefile \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/lq140_mipi2edp.c \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/lq140_mipi2edp.h \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/Kconfig \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.c \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.h \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/Makefile \
	brandy/brandy-2.0/u-boot-2018/configs/sun8iw20p1_auto_nor_defconfig \
	> "$OUT_DIR/01-kernel-uboot-panel.patch"

git diff --cached -- \
	device/config/chips/h133/configs/p1_nor_LQ140M1JW61/ \
	openwrt/target/h133/h133-p1_nor_LQ140M1JW61/ \
	tools/build_p1_nor_LQ140M1JW61.sh \
	> "$OUT_DIR/02-board-tree.patch"

git diff --cached -- \
	openwrt/package/allwinner/multimedia/tina_multimedia/libtmedia/Makefile \
	openwrt/.openwrt_targets \
	openwrt/target/h133/h133-p1_nor/defconfig \
	openwrt/target/h133/h133-p1_nor_8733/defconfig \
	openwrt/target/h133/h133-p1_nor_JYY070/defconfig \
	openwrt/target/h133/h133-p1_nor_JL_M101/defconfig \
	openwrt/target/h133/h133-p1_nor_4k/defconfig \
	device/config/chips/h133/configs/p1_nor/linux-5.4/config-5.4 \
	device/config/chips/h133/configs/p1_nor_JYY070/linux-5.4/config-5.4 \
	device/config/chips/h133/configs/p1_nor_JL_M101/linux-5.4/config-5.4 \
	device/config/chips/h133/configs/p1_nor_4k/linux-5.4/config-5.4 \
	> "$OUT_DIR/03-shared-hooks.patch"

git diff --cached -- \
	H133-AI-Skills/skills/h133-display/board-profile-p1_nor_LQ140M1JW61.md \
	H133-AI-Skills/开发记录/README.md \
	H133-AI-Skills/开发记录/板件开发记录/LQ140M1JW61/ \
	> "$OUT_DIR/04-docs.patch"

cat "$OUT_DIR/01-kernel-uboot-panel.patch" \
	"$OUT_DIR/02-board-tree.patch" \
	"$OUT_DIR/03-shared-hooks.patch" \
	"$OUT_DIR/04-docs.patch" \
	> "$OUT_DIR/lq140-display-final.patch"

git reset HEAD >/dev/null 2>&1 || true

echo "==> $OUT_DIR/01-kernel-uboot-panel.patch ($(grep -c '^diff --git' "$OUT_DIR/01-kernel-uboot-panel.patch" || true) diffs)"
echo "==> $OUT_DIR/02-board-tree.patch ($(grep -c '^diff --git' "$OUT_DIR/02-board-tree.patch" || true) diffs)"
echo "==> $OUT_DIR/03-shared-hooks.patch ($(grep -c '^diff --git' "$OUT_DIR/03-shared-hooks.patch" || true) diffs)"
echo "==> $OUT_DIR/04-docs.patch ($(grep -c '^diff --git' "$OUT_DIR/04-docs.patch" || true) diffs)"
echo "==> $OUT_DIR/lq140-display-final.patch ($(grep -c '^diff --git' "$OUT_DIR/lq140-display-final.patch" || true) diffs, $(wc -l < "$OUT_DIR/lq140-display-final.patch") lines)"
echo "    note: bootlogo.bmp / *.su / 无关板 DTS 不在补丁内"
echo "    note: 不含 dev_disp.c（定稿不保留驱动试验改动）"
