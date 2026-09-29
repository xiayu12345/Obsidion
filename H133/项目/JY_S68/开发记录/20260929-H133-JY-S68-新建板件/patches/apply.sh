#!/bin/sh
# 从 p1_nor_JL_M101 复制出 p1_nor_JY_S68。触摸见同级目录。
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

install_file "$DIR/files/build_p1_nor_JY_S68.sh" tools/build_p1_nor_JY_S68.sh
chmod +x tools/build_p1_nor_JY_S68.sh

apply_patch 01-pack-readme.patch
apply_patch 02-libtmedia-rotate.patch

python3 - "$ROOT" <<'PY'
import shutil, sys
from pathlib import Path

ROOT = Path(sys.argv[1])
CHIP = ROOT / "device/config/chips/h133/configs"
OWT = ROOT / "openwrt/target/h133"
SRC = CHIP / "p1_nor_JL_M101"
DST = CHIP / "p1_nor_JY_S68"
SRC_OWT = OWT / "h133-p1_nor_JL_M101"
DST_OWT = OWT / "h133-p1_nor_JY_S68"

def copy_tree(src: Path, dst: Path) -> bool:
    if dst.exists():
        print(f"==> keep {dst.relative_to(ROOT)}")
        return False
    if not src.exists():
        raise SystemExit(f"missing {src}")
    shutil.copytree(src, dst, symlinks=True, copy_function=shutil.copy2)
    print(f"==> copy {src.name} -> {dst.name}")
    return True

def rewrite(root: Path):
    n = 0
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
        new = text.replace("h133-p1_nor_JL_M101", "h133-p1_nor_JY_S68")
        new = new.replace("p1_nor_JL_M101", "p1_nor_JY_S68")
        if new != text:
            p.write_text(new, encoding="utf-8")
            n += 1
    print(f"==> rewrite {n} files under {root.relative_to(ROOT)}")

copied_chip = copy_tree(SRC, DST)
copied_owt = copy_tree(SRC_OWT, DST_OWT)
if copied_chip:
    rewrite(DST)
if copied_owt:
    rewrite(DST_OWT)
    mk = DST_OWT / "Makefile"
    t = mk.read_text(encoding="utf-8")
    nt = t.replace(
        "JL-M101 JD9365DA MIPI + RTL8733BU",
        "金运 S68，克隆京龙 NOR / JD9365DA MIPI + RTL8733BU",
    )
    if nt != t:
        mk.write_text(nt, encoding="utf-8")
        print("==> BOARDNAME")
    host = DST_OWT / "busybox-init-base-files/etc/hostname"
    if host.exists() and host.read_text(encoding="utf-8").strip() == "TinaLinux-JL_M101":
        host.write_text("TinaLinux-JY_S68\n", encoding="utf-8")
        print("==> hostname")
    own = DST_OWT / "defconfig"
    text = own.read_text(encoding="utf-8")
    line = "# CONFIG_TARGET_h133_p1_nor_JL_M101 is not set"
    y = "CONFIG_TARGET_h133_p1_nor_JY_S68=y"
    if y in text and line not in text:
        own.write_text(text.replace(y, y + "\n" + line, 1), encoding="utf-8")
        print("==> own defconfig unsets JL")
    # 源板上若已经有「不选中金运」，复制后会变成自己关掉自己
    text = own.read_text(encoding="utf-8")
    self_off = "# CONFIG_TARGET_h133_p1_nor_JY_S68 is not set\n"
    if y in text and self_off in text:
        own.write_text(text.replace(self_off, "", 1), encoding="utf-8")
        print("==> drop self unset")

for tgt in sorted(OWT.glob("h133-*")):
    if tgt.name == "h133-p1_nor_JY_S68":
        continue
    for dc in tgt.glob("defconfig*"):
        text = dc.read_text(encoding="utf-8")
        line = "# CONFIG_TARGET_h133_p1_nor_JY_S68 is not set"
        if line in text:
            continue
        for after in (
            "# CONFIG_TARGET_h133_p1_nor_JL_M101 is not set",
            "CONFIG_TARGET_h133_p1_nor_JL_M101=y",
        ):
            if after in text:
                dc.write_text(text.replace(after, after + "\n" + line, 1), encoding="utf-8")
                print(f"==> unset JY {dc.relative_to(OWT)}")
                break

print("==> board ready")
PY

echo "==> OK"
echo "next: 触摸"
