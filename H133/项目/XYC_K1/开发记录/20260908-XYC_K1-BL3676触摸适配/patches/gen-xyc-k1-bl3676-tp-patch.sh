#!/bin/bash
# 重新生成鑫宇宸 XYC_K1 BL3676 触摸补丁
# 在 SDK 根执行，或设置 H133_SDK_ROOT
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${H133_SDK_ROOT:-$(cd "$SCRIPT_DIR/../../../../../.." && pwd)}"
OUT_DIR="$SCRIPT_DIR"
DOC_DIR="H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-BL3676触摸适配"
DISPLAY_01="$ROOT/H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/patches/01-kernel-uboot-panel.patch"

cd "$ROOT"
if [ ! -f build/envsetup.sh ]; then
	echo "error: not SDK root: $ROOT" >&2
	exit 1
fi

python3 - "$DISPLAY_01" "$OUT_DIR/01-kernel-betterlife-ts.patch" <<'PY'
"""从 LVDS 01 里抽出 betterlife_ts / touchscreen Kconfig+Makefile。"""
import pathlib, re, sys

src = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
if not src.is_file():
    raise SystemExit(f"missing display 01 patch: {src}")

text = src.read_bytes().decode("latin-1")
files = re.split(r"(?=^diff --git )", text, flags=re.M)
keep = []
for f in files:
    if not f.strip():
        continue
    m = re.search(r"^diff --git a/(.+?) b/(.+)$", f, re.M)
    if not m:
        continue
    rel = m.group(2)
    if "betterlife_ts" in rel or rel.endswith("input/touchscreen/Kconfig") or rel.endswith("input/touchscreen/Makefile"):
        keep.append(f)
if not keep:
    raise SystemExit("no betterlife hunks in display 01")
out.write_bytes("".join(keep).encode("latin-1"))
PY

python3 - "$ROOT" "$OUT_DIR/02-board-dts-ctp.patch" <<'PY'
"""相对 JYY070 克隆态：只含本板 CTP / defconfig / symlink。"""
import pathlib, re, subprocess, tempfile, sys

root = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])
jyy = root / "device/config/chips/h133/configs/p1_nor_JYY070"
xyc = root / "device/config/chips/h133/configs/p1_nor_XYC_K1"

def uni(old, new, rel):
    with tempfile.TemporaryDirectory() as td:
        td = pathlib.Path(td)
        a, b = td / "a", td / "b"
        a.write_bytes(old.encode("latin-1"))
        b.write_bytes(new.encode("latin-1"))
        r = subprocess.run(["diff", "-u", str(a), str(b)], capture_output=True)
        d = r.stdout.decode("latin-1")
        if not d.strip():
            return ""
        d = d.replace(f"--- {a}", f"--- a/{rel}")
        d = d.replace(f"+++ {b}", f"+++ b/{rel}")
        d = re.sub(r"^(--- |\+\+\+ )(.+?)\t.*$", r"\1\2", d, flags=re.M)
        return f"diff --git a/{rel} b/{rel}\n" + d

def twi1_block(text):
    m = re.search(r"^&twi1 \{.*?\n\};\n", text, re.M | re.S)
    if not m:
        raise SystemExit("no &twi1 block")
    return m.group(0)

parts = []

rel_dts = "device/config/chips/h133/configs/p1_nor_XYC_K1/linux-5.4/board.dts"
old_dts = (jyy / "linux-5.4/board.dts").read_text(encoding="latin-1")
new_dts = (xyc / "linux-5.4/board.dts").read_text(encoding="latin-1")
# 只替换 &twi1，其余当 XYC 现状（补丁上下文取自 XYC 文件头尾）
old_one = new_dts.replace(twi1_block(new_dts), twi1_block(old_dts), 1)
p = uni(old_one, new_dts, rel_dts)
if p:
    parts.append(p)

rel_cfg = "device/config/chips/h133/configs/p1_nor_XYC_K1/openwrt/bsp_defconfig"
old_cfg = (jyy / "openwrt/bsp_defconfig").read_text(encoding="latin-1")
new_cfg = (xyc / "openwrt/bsp_defconfig").read_text(encoding="latin-1")
# 把 JYY 的触摸三行套进 XYC 全文，再 diff，避免把其它 defconfig 差异打进来
def swap_ts(cfg, flavor):
    if flavor == "jyy":
        return re.sub(
            r"# CONFIG_TOUCHSCREEN_GSLX680NEW is not set\n"
            r"# CONFIG_TOUCHSCREEN_GT9XXNEW_TS is not set\n"
            r"CONFIG_TOUCHSCREEN_BETTERLIFE_TS=y\n",
            "CONFIG_TOUCHSCREEN_GSLX680NEW=y\n"
            "# CONFIG_TOUCHSCREEN_GT9XXNEW_TS is not set\n",
            cfg,
            count=1,
        )
    return cfg

# 从 XYC 当前生成「仍是 GSL」的假旧文件
old_from_xyc = swap_ts(new_cfg, "jyy")
if old_from_xyc == new_cfg:
    raise SystemExit("bsp_defconfig BETTERLIFE 块未匹配，无法生成 02")
p = uni(old_from_xyc, new_cfg, rel_cfg)
if p:
    parts.append(p)

rel_sy = "openwrt/target/h133/h133-p1_nor_XYC_K1/busybox-init-base-files/usr/bin/input_symlink.sh"
old_sy = (root / "openwrt/target/h133/h133-p1_nor_JYY070/busybox-init-base-files/usr/bin/input_symlink.sh").read_text(encoding="latin-1")
new_sy = (root / rel_sy).read_text(encoding="latin-1")
# 只保留 betterlife 那一行差异
old_line_sy = new_sy.replace("*betterlife*|", "")
p = uni(old_line_sy, new_sy, rel_sy)
if p:
    parts.append(p)

if not parts:
    raise SystemExit("02-board-dts-ctp empty")
out.write_bytes("".join(parts).encode("latin-1"))
PY

trap 'git reset HEAD >/dev/null 2>&1 || true' EXIT

git add -f -- \
	"H133-AI-Skills/开发记录/板件开发记录/XYC_K1/README.md" \
	"$DOC_DIR/README.md" \
	"$DOC_DIR/00-总览.md" \
	"$DOC_DIR/01-硬件与驱动.md" \
	"$DOC_DIR/02-DTS与量程.md" \
	"$DOC_DIR/03-改动过程与踩坑.md" \
	"$DOC_DIR/04-编译与验收.md" \
	"$DOC_DIR/如何修改.md" \
	"$DOC_DIR/测试方法.md" \
	"$DOC_DIR/patches/README.md" \
	"$DOC_DIR/patches/apply-xyc-k1-bl3676-tp.sh" \
	"$DOC_DIR/patches/gen-xyc-k1-bl3676-tp-patch.sh"

# 交叉链接的显示/档案也进文档补丁
git add -f -- \
	"H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/README.md" \
	"H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/03-DTS与背光.md" \
	"H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/05-编译与验收.md" \
	"H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/patches/README.md" \
	"H133-AI-Skills/skills/h133-display/board-profile-p1_nor_XYC_K1.md" \
	"H133-AI-Skills/开发记录/板件与项目对照.md" \
	2>/dev/null || true

git diff --cached -- \
	"H133-AI-Skills/开发记录/板件开发记录/XYC_K1/README.md" \
	"H133-AI-Skills/开发记录/板件与项目对照.md" \
	"H133-AI-Skills/skills/h133-display/board-profile-p1_nor_XYC_K1.md" \
	"$DOC_DIR" \
	"H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/README.md" \
	"H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/03-DTS与背光.md" \
	"H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/05-编译与验收.md" \
	"H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/patches/README.md" \
	> "$OUT_DIR/03-docs.patch"

python3 - "$OUT_DIR/03-docs.patch" <<'PY'
import pathlib, sys
p = pathlib.Path(sys.argv[1])
text = p.read_bytes().decode("latin-1")
import re
files = re.split(r"(?=^diff --git )", text, flags=re.M)
keep = []
skip = (
    "01-kernel-betterlife-ts.patch",
    "02-board-dts-ctp.patch",
    "03-docs.patch",
    "xyc-k1-bl3676-tp.patch",
)
for f in files:
    if not f.strip():
        continue
    if any(s in f.split("\n", 3)[0] for s in skip):
        continue
    keep.append(f)
p.write_bytes("".join(keep).encode("latin-1"))
PY

cat "$OUT_DIR/01-kernel-betterlife-ts.patch" \
	"$OUT_DIR/02-board-dts-ctp.patch" \
	"$OUT_DIR/03-docs.patch" \
	> "$OUT_DIR/xyc-k1-bl3676-tp.patch"

git reset HEAD >/dev/null 2>&1 || true
chmod +x "$OUT_DIR/apply-xyc-k1-bl3676-tp.sh" "$OUT_DIR/gen-xyc-k1-bl3676-tp-patch.sh"

echo "==> $OUT_DIR/01-kernel-betterlife-ts.patch ($(grep -c '^diff --git' "$OUT_DIR/01-kernel-betterlife-ts.patch" || true) diffs)"
echo "==> $OUT_DIR/02-board-dts-ctp.patch ($(grep -c '^diff --git' "$OUT_DIR/02-board-dts-ctp.patch" || true) diffs)"
echo "==> $OUT_DIR/03-docs.patch ($(grep -c '^diff --git' "$OUT_DIR/03-docs.patch" || true) diffs)"
echo "==> $OUT_DIR/xyc-k1-bl3676-tp.patch ($(grep -c '^diff --git' "$OUT_DIR/xyc-k1-bl3676-tp.patch" || true) diffs, $(wc -l < "$OUT_DIR/xyc-k1-bl3676-tp.patch") lines)"
