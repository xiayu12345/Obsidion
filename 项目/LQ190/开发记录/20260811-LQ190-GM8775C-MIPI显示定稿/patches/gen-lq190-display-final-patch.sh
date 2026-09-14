#!/bin/bash
# 重新生成 LQ190 + GM8775C MIPI 显示定稿补丁（当前已出图树）
# 在 SDK 根执行，或设置 H133_SDK_ROOT
#
# 基线：引入 p1_nor_LQ190 之前的提交（50f4e3d80^），补丁含板件新建 + 出图定稿。
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_DIR="$SCRIPT_DIR"
# 向上找 build/envsetup.sh；也可 export H133_SDK_ROOT
if [ -n "${H133_SDK_ROOT:-}" ]; then
	ROOT="$H133_SDK_ROOT"
else
	ROOT="$SCRIPT_DIR"
	while [ "$ROOT" != "/" ] && [ ! -f "$ROOT/build/envsetup.sh" ]; do
		ROOT="$(dirname "$ROOT")"
	done
fi
if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: 找不到 SDK 根（需含 build/envsetup.sh），请设置 H133_SDK_ROOT" >&2
	exit 1
fi
# 首次纳入 LQ190 板树的提交；其父为无 LQ190 干净基线
LQ190_INTRO="${LQ190_INTRO_COMMIT:-50f4e3d80}"
BASE="$(git -C "$ROOT" rev-parse "${LQ190_INTRO}^")"

cd "$ROOT"

echo "==> BASE (pre-LQ190)=$BASE"
echo "==> OUT=$OUT_DIR"

# --- 01 panel：kernel + uboot 驱动/注册/defconfig ---
# 注意：工作区 sun8iw20p1_auto_nor_defconfig 若误删 JL/LQ140/LQ190，改用 HEAD（已入库）相对 BASE
git diff "$BASE" -- \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/lq190_mipi2edp.c \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/lq190_mipi2edp.h \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/Kconfig \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.c \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.h \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/Makefile \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/lq190_mipi2edp.c \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/lq190_mipi2edp.h \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/Kconfig \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.c \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.h \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/Makefile \
	brandy/brandy-2.0/u-boot-2018/configs/sun8iw20p1_defconfig \
	brandy/brandy-2.0/u-boot-2018/configs/sun8iw20p1_nor_defconfig \
	> "$OUT_DIR/01-kernel-uboot-panel.patch"

git diff "$BASE" HEAD -- \
	brandy/brandy-2.0/u-boot-2018/configs/sun8iw20p1_auto_nor_defconfig \
	>> "$OUT_DIR/01-kernel-uboot-panel.patch"

# --- 02 板级整树（踢掉 bootlogo / 编译残留 .su）---
git add -f -- device/config/chips/h133/configs/p1_nor_LQ190/
git add -f -- openwrt/target/h133/h133-p1_nor_LQ190/
git add -f -- tools/build_p1_nor_LQ190.sh
git restore --staged device/config/chips/h133/configs/p1_nor_LQ190/bootlogo.bmp 2>/dev/null || true
git restore --staged \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/lq190_mipi2edp.su \
	2>/dev/null || true

git diff --cached "$BASE" -- \
	device/config/chips/h133/configs/p1_nor_LQ190/ \
	openwrt/target/h133/h133-p1_nor_LQ190/ \
	tools/build_p1_nor_LQ190.sh \
	> "$OUT_DIR/02-board-tree.patch"

git reset HEAD >/dev/null 2>&1 || true

# --- 03 兄弟板隔离（仅含 LQ190 not-set 的干净增量；跳过整板新建的 emmc 等）---
git diff "$BASE" -- \
	openwrt/target/h133/h133-p1_nor/defconfig \
	openwrt/target/h133/h133-p1_nor_8733/defconfig \
	openwrt/target/h133/h133-p1_nor_JYY070/defconfig \
	openwrt/target/h133/h133-p1_nor_LQ140M1JW61/defconfig \
	device/config/chips/h133/configs/p1_nor/linux-5.4/config-5.4 \
	device/config/chips/h133/configs/p1_nor_JYY070/linux-5.4/config-5.4 \
	device/config/chips/h133/configs/p1_nor_JL_M101/linux-5.4/config-5.4 \
	device/config/chips/h133/configs/p1_nor_LQ140M1JW61/linux-5.4/config-5.4 \
	device/config/chips/h133/configs/p1_nor_4k/linux-5.4/config-5.4 \
	device/config/chips/h133/configs/p1_nor_8733/linux-5.4/config-5.4 \
	> "$OUT_DIR/03-shared-hooks.patch"

# --- 04 文档（H133-AI-Skills 可能被 ignore，必须 -N / add -f）---
DOC_ROOT="H133-AI-Skills/开发记录/板件开发记录/LQ190"
DOC_FINAL="$DOC_ROOT/20260811-LQ190-GM8775C-MIPI显示定稿"
git add -f -- \
	"H133-AI-Skills/skills/h133-display/board-profile-p1_nor_LQ190.md" \
	"$DOC_ROOT/README.md" \
	"$DOC_ROOT/20260807-鸿博LQ190E1LX65-资料梳理与待确认/README.md" \
	"$DOC_ROOT/20260810-LQ190-背光BL-EN拉高实机验证/README.md" \
	"$DOC_FINAL/README.md" \
	"$DOC_FINAL/patches/apply-lq190-display-final.sh" \
	"$DOC_FINAL/patches/gen-lq190-display-final-patch.sh" \
	"H133-AI-Skills/开发记录/板件开发记录/README.md" \
	2>/dev/null || true

git diff --cached "$BASE" -- \
	H133-AI-Skills/skills/h133-display/board-profile-p1_nor_LQ190.md \
	H133-AI-Skills/开发记录/板件开发记录/LQ190/ \
	H133-AI-Skills/开发记录/板件开发记录/README.md \
	> "$OUT_DIR/04-docs.patch" || true

# 04 里不要塞入巨大 .patch 本体（避免自引用膨胀）；若 staged 到了则重做一次排除
git reset HEAD >/dev/null 2>&1 || true
git add -f -- \
	"H133-AI-Skills/skills/h133-display/board-profile-p1_nor_LQ190.md" \
	"$DOC_ROOT/README.md" \
	"$DOC_ROOT/20260807-鸿博LQ190E1LX65-资料梳理与待确认/README.md" \
	"$DOC_ROOT/20260810-LQ190-背光BL-EN拉高实机验证/README.md" \
	"$DOC_FINAL/README.md" \
	"$DOC_FINAL/patches/apply-lq190-display-final.sh" \
	"$DOC_FINAL/patches/gen-lq190-display-final-patch.sh" \
	"H133-AI-Skills/开发记录/板件开发记录/README.md"

git diff --cached "$BASE" -- \
	H133-AI-Skills/skills/h133-display/board-profile-p1_nor_LQ190.md \
	"$DOC_ROOT/README.md" \
	"$DOC_ROOT/20260807-鸿博LQ190E1LX65-资料梳理与待确认/README.md" \
	"$DOC_ROOT/20260810-LQ190-背光BL-EN拉高实机验证/README.md" \
	"$DOC_FINAL/README.md" \
	"$DOC_FINAL/patches/apply-lq190-display-final.sh" \
	"$DOC_FINAL/patches/gen-lq190-display-final-patch.sh" \
	H133-AI-Skills/开发记录/板件开发记录/README.md \
	> "$OUT_DIR/04-docs.patch"

git reset HEAD >/dev/null 2>&1 || true

cat "$OUT_DIR/01-kernel-uboot-panel.patch" \
	"$OUT_DIR/02-board-tree.patch" \
	"$OUT_DIR/03-shared-hooks.patch" \
	"$OUT_DIR/04-docs.patch" \
	> "$OUT_DIR/lq190-display-final.patch"

echo "==> $OUT_DIR/01-kernel-uboot-panel.patch ($(grep -c '^diff --git' "$OUT_DIR/01-kernel-uboot-panel.patch" || true) diffs)"
echo "==> $OUT_DIR/02-board-tree.patch ($(grep -c '^diff --git' "$OUT_DIR/02-board-tree.patch" || true) diffs)"
echo "==> $OUT_DIR/03-shared-hooks.patch ($(grep -c '^diff --git' "$OUT_DIR/03-shared-hooks.patch" || true) diffs)"
echo "==> $OUT_DIR/04-docs.patch ($(grep -c '^diff --git' "$OUT_DIR/04-docs.patch" || true) diffs)"
echo "==> $OUT_DIR/lq190-display-final.patch ($(grep -c '^diff --git' "$OUT_DIR/lq190-display-final.patch" || true) diffs, $(wc -l < "$OUT_DIR/lq190-display-final.patch") lines)"
echo "    note: bootlogo.bmp 不在补丁内，apply 时从 p1_nor_LQ140M1JW61 复制"
echo "    note: 基线为 ${LQ190_INTRO}^；含 MIPI 灌表定稿（0x27 解锁 / 0x13=0x63 / 交换保留 / BIST off / RST=PG2）"
