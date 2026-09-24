#!/bin/sh
# 从 p1_nor_JL_M101 复制出 p1_nor_ZS101。引脚、屏幕、触摸见同级另外三个目录。
set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$DIR/../../../../.." && pwd)

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: $ROOT is not AI-tq SDK root" >&2
	exit 1
fi

cd "$ROOT"

install_file() {
	src=$1
	dst=$2
	if [ -f "$dst" ]; then
		echo "==> keep $dst"
		return 0
	fi
	mkdir -p "$(dirname "$dst")"
	cp -a "$src" "$dst"
	echo "==> install $dst"
}

apply_patch() {
	p=$1
	if patch -p1 --forward --dry-run < "$DIR/$p" >/dev/null 2>&1; then
		echo "==> apply $p"
		patch -p1 --forward < "$DIR/$p"
	else
		echo "==> skip $p (already applied or context mismatch)"
	fi
}

install_file "$DIR/files/build_p1_nor_ZS101.sh" tools/build_p1_nor_ZS101.sh
chmod +x tools/build_p1_nor_ZS101.sh

apply_patch 01-pack-readme.patch
apply_patch 02-openwrt-stamp-built.patch

python3 - "$ROOT" <<'PY'
import shutil, sys
from pathlib import Path

ROOT = Path(sys.argv[1])
CHIP = ROOT / "device/config/chips/h133/configs"
OWT = ROOT / "openwrt/target/h133"
SRC = CHIP / "p1_nor_JL_M101"
DST = CHIP / "p1_nor_ZS101"
SRC_OWT = OWT / "h133-p1_nor_JL_M101"
DST_OWT = OWT / "h133-p1_nor_ZS101"

def copy_tree(src: Path, dst: Path):
    if dst.exists():
        print(f"==> keep {dst.relative_to(ROOT)}")
        return
    if not src.exists():
        raise SystemExit(f"missing {src}")
    shutil.copytree(src, dst, symlinks=True, copy_function=shutil.copy2)
    print(f"==> copy {src.name} -> {dst.name}")

def rewrite(root: Path):
    if not root.exists():
        return
    for p in root.rglob("*"):
        if not p.is_file() or p.is_symlink():
            continue
        if p.suffix.lower() in {".bin", ".bmp", ".png", ".jpg", ".so", ".a", ".o"}:
            continue
        data = p.read_bytes()
        if b"\0" in data[:4096]:
            continue
        try:
            text = data.decode("utf-8")
        except UnicodeDecodeError:
            continue
        new = text.replace("h133-p1_nor_JL_M101", "h133-p1_nor_ZS101")
        new = new.replace("p1_nor_JL_M101", "p1_nor_ZS101")
        if new != text:
            p.write_text(new, encoding="utf-8")

copy_tree(SRC, DST)
copy_tree(SRC_OWT, DST_OWT)
rewrite(DST)
rewrite(DST_OWT)

mk = DST_OWT / "Makefile"
if mk.exists():
    t = mk.read_text(encoding="utf-8")
    nt = t.replace(
        "JL-M101 JD9365DA MIPI + RTL8733BU",
        "ZS101 ILI9881C MIPI + GT928 + RTL8733BU",
    )
    if nt != t:
        mk.write_text(nt, encoding="utf-8")
        print("==> BOARDNAME")

for tgt in sorted(OWT.glob("h133-*")):
    if tgt.name == "h133-p1_nor_ZS101":
        continue
    for dc in tgt.glob("defconfig*"):
        text = dc.read_text(encoding="utf-8")
        line = "# CONFIG_TARGET_h133_p1_nor_ZS101 is not set"
        if line in text:
            continue
        for after in (
            "# CONFIG_TARGET_h133_p1_nor_JL_M101 is not set",
            "CONFIG_TARGET_h133_p1_nor_JL_M101=y",
        ):
            if after in text:
                dc.write_text(text.replace(after, after + "\n" + line, 1), encoding="utf-8")
                print(f"==> unset ZS {dc.relative_to(OWT)}")
                break

own = DST_OWT / "defconfig"
if own.exists():
    text = own.read_text(encoding="utf-8")
    line = "# CONFIG_TARGET_h133_p1_nor_JL_M101 is not set"
    if "CONFIG_TARGET_h133_p1_nor_ZS101=y" in text and line not in text:
        own.write_text(text.replace(
            "CONFIG_TARGET_h133_p1_nor_ZS101=y",
            "CONFIG_TARGET_h133_p1_nor_ZS101=y\n" + line,
            1,
        ), encoding="utf-8")

print("==> board ready")
PY

echo "==> OK"
echo "next: 引脚定义 → 屏幕 → 触摸"
