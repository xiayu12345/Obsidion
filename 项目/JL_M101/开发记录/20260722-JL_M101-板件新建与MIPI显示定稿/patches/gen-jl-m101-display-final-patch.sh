#!/bin/bash
# 重新生成 JL-M101 MIPI 显示定稿补丁（当前已出图树）
# 在 SDK 根执行，或设置 H133_SDK_ROOT
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# patches → 定稿目录 → JL_M101 → 开发记录 → H133-AI-Skills → SDK（5 级）
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
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_m101_jd9365da.c
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_m101_jd9365da.h
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/Kconfig
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.c
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.h
kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/Makefile
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/jl_m101_jd9365da.c
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/jl_m101_jd9365da.h
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/Kconfig
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.c
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.h
brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/Makefile
openwrt/package/allwinner/multimedia/tina_multimedia/libtmedia/Makefile
openwrt/target/h133/h133-p1_nor/defconfig
openwrt/target/h133/h133-p1_nor_8733/defconfig
openwrt/target/h133/h133-p1_nor_JYY070/defconfig
device/config/chips/h133/configs/p1_nor/linux-5.4/config-5.4
device/config/chips/h133/configs/p1_nor_JYY070/linux-5.4/config-5.4
tools/build_p1_nor_JL_M101.sh
EOF

# 板级整树（再踢掉 bootlogo）
git add -f -- device/config/chips/h133/configs/p1_nor_JL_M101/
git add -f -- openwrt/target/h133/h133-p1_nor_JL_M101/
git restore --staged device/config/chips/h133/configs/p1_nor_JL_M101/bootlogo.bmp 2>/dev/null || true

# 文档（H133-AI-Skills 被 gitignore，必须 -f）
DOC_DIR1="H133-AI-Skills/开发记录/板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿"
DOC_DIR2="H133-AI-Skills/开发记录/板件开发记录/JL_M101/20260720-JL_M101-JD9365DA-MIPI适配"
git add -f -- \
	"H133-AI-Skills/skills/h133-display/board-profile-p1_nor_JL_M101.md" \
	"H133-AI-Skills/开发记录/README.md" \
	"H133-AI-Skills/开发记录/板件开发记录/JL_M101/README.md" \
	"$DOC_DIR1/README.md" \
	"$DOC_DIR1/00-总览与定稿.md" \
	"$DOC_DIR1/01-板件新建.md" \
	"$DOC_DIR1/02-panel与init.md" \
	"$DOC_DIR1/03-DTS与背光PWM.md" \
	"$DOC_DIR1/04-实机调试与踩坑.md" \
	"$DOC_DIR1/05-编译与验收.md" \
	"$DOC_DIR1/patches/apply-jl-m101-display-final.sh" \
	"$DOC_DIR1/patches/gen-jl-m101-display-final-patch.sh" \
	"$DOC_DIR2/开发记录.md"

git diff --cached -- \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_m101_jd9365da.c \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_m101_jd9365da.h \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/Kconfig \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.c \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/panels.h \
	kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/Makefile \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/jl_m101_jd9365da.c \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/jl_m101_jd9365da.h \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/Kconfig \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.c \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/lcd/panels.h \
	brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/disp2/disp/Makefile \
	> "$OUT_DIR/01-kernel-uboot-panel.patch"

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

git diff --cached -- \
	H133-AI-Skills/skills/h133-display/board-profile-p1_nor_JL_M101.md \
	H133-AI-Skills/开发记录/README.md \
	H133-AI-Skills/开发记录/板件开发记录/JL_M101/ \
	> "$OUT_DIR/04-docs.patch"

cat "$OUT_DIR/01-kernel-uboot-panel.patch" \
	"$OUT_DIR/02-board-tree.patch" \
	"$OUT_DIR/03-shared-hooks.patch" \
	"$OUT_DIR/04-docs.patch" \
	> "$OUT_DIR/jl-m101-display-final.patch"

git reset HEAD >/dev/null 2>&1 || true

echo "==> $OUT_DIR/01-kernel-uboot-panel.patch ($(grep -c '^diff --git' "$OUT_DIR/01-kernel-uboot-panel.patch" || true) diffs)"
echo "==> $OUT_DIR/02-board-tree.patch ($(grep -c '^diff --git' "$OUT_DIR/02-board-tree.patch" || true) diffs)"
echo "==> $OUT_DIR/03-shared-hooks.patch ($(grep -c '^diff --git' "$OUT_DIR/03-shared-hooks.patch" || true) diffs)"
echo "==> $OUT_DIR/04-docs.patch ($(grep -c '^diff --git' "$OUT_DIR/04-docs.patch" || true) diffs)"
echo "==> $OUT_DIR/jl-m101-display-final.patch ($(grep -c '^diff --git' "$OUT_DIR/jl-m101-display-final.patch" || true) diffs, $(wc -l < "$OUT_DIR/jl-m101-display-final.patch") lines)"
echo "    note: bootlogo.bmp 不在补丁内，apply 时从 p1_nor_8733 复制"
echo "    note: 相对干净基线；含 PWM0/bl_open 出图定稿"
