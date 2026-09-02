#!/bin/bash
# =============================================================================
# 个人验证脚本（不是 SDK tools，不要当工程构建入口）
#
# 用途：改了公共代码后，串编 p1_nor_8733 + p1_nor_JYY070，确认两板 UI 各自正确。
# 可整份拷走（本目录任意放），用环境变量 / 参数指向 SDK 即可。
#
# UI 档（编前临时切，默认可编完还原 8733 档）：
#   8733/p1_nor : DISP_ROTATE=3，小窗竖屏，SCREEN 800×1280
#   JYY070      : DISP_ROTATE=0，小窗 (278,113,479×237)，SCREEN 1024×600
#
# Usage:
#   export H133_SDK_ROOT=/path/to/H133-AIKTV   # 可选；也可 --sdk-root
#   ./verify_build_8733_then_JYY070.sh
#   ./verify_build_8733_then_JYY070.sh --sdk-root /path/to/H133-AIKTV
#   ./verify_build_8733_then_JYY070.sh --leave-jyy-ui
#   ./verify_build_8733_then_JYY070.sh --only 8733|jyy070
#   ./verify_build_8733_then_JYY070.sh --ui-only 8733|jyy070
# =============================================================================

# 不用 set -u：Tina envsetup/lunch 会读未定义的 $1
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT=""
LOG="${BUILD_LOG:-/tmp/verify_build_8733_then_JYY070.log}"
LEAVE_JYY_UI=0
ONLY=""
UI_ONLY=""
NPROC="$(nproc 2>/dev/null || echo 4)"

GUI_PKGS=(
	desk sing_ktv media_session mix_station bt_player live_player ai_mv liyuan_opera
)

resolve_sdk_root() {
	if [ -n "${ROOT}" ]; then
		:
	elif [ -n "${H133_SDK_ROOT:-}" ]; then
		ROOT="$H133_SDK_ROOT"
	elif [ -f ./build/envsetup.sh ]; then
		ROOT="$(pwd)"
	elif [ -f "$SCRIPT_DIR/../../../../build/envsetup.sh" ]; then
		# 仍放在本仓库 H133-AI-Skills/开发记录/板件开发记录/JYY070/... 时
		ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"
	else
		echo "error: 找不到 SDK。请设置 H133_SDK_ROOT 或传 --sdk-root" >&2
		exit 1
	fi
	ROOT="$(cd "$ROOT" && pwd)"
}

usage() {
	sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
	exit 1
}

while [ $# -gt 0 ]; do
	case "$1" in
	--sdk-root)
		ROOT="${2:-}"; shift 2 ;;
	--leave-jyy-ui) LEAVE_JYY_UI=1; shift ;;
	--only)
		ONLY="${2:-}"; shift 2 ;;
	--ui-only)
		UI_ONLY="${2:-}"; shift 2 ;;
	-h|--help) usage ;;
	*) echo "unknown arg: $1" >&2; usage ;;
	esac
done

resolve_sdk_root
cd "$ROOT"
[ -f build/envsetup.sh ] || { echo "error: not SDK root: $ROOT" >&2; exit 1; }
[ -f build/.tinatopdir ] || touch build/.tinatopdir

log() { echo "$*" | tee -a "$LOG"; }

# ---- UI 档位：p1nor（8733） / jyy070 ----
apply_ui_profile() {
	local profile="$1"
	python3 - "$ROOT" "$profile" <<'PY'
import re, sys
from pathlib import Path

root = Path(sys.argv[1])
profile = sys.argv[2]
assert profile in ("p1nor", "jyy070"), profile

rotate = 3 if profile == "p1nor" else 0
if profile == "p1nor":
    sk_small = (330, 360, 320, 570)
    ms_small = (330, 330, 320, 600)
    screen = (800, 1280)
else:
    sk_small = (278, 113, 479, 237)
    ms_small = (278, 113, 479, 237)
    screen = (1024, 600)

rotate_files = [
    "platform/thirdparty/gui/lvgl-8/app/desk/src/projector_port/include/projector_config.h",
    "platform/thirdparty/gui/lvgl-8/app/sing_ktv/src/include/projector_config.h",
    "platform/thirdparty/gui/lvgl-8/app/liyuan_opera/src/include/projector_config.h",
    "platform/thirdparty/gui/lvgl-8/app/MixStation/src/main.c",
    "platform/thirdparty/gui/lvgl-8/app/LiveStreamPlayer/src/main.c",
    "platform/thirdparty/gui/lvgl-8/app/BluetoothPlayer/src/main.c",
    "platform/thirdparty/gui/lvgl-8/app/ai_mv/src/main.c",
]

def set_rotate(text: str) -> str:
    return re.sub(
        r"(#define\s+LV_PROJECTOR_DISP_ROTATE\s+)\d+",
        rf"\g<1>{rotate}",
        text,
        count=1,
    )

def set_small(text: str, rect) -> str:
    x, y, w, h = rect
    text = re.sub(r"(#define\s+KTV_PLAYER_SMALL_RECT_X\s+\()\d+(\))", rf"\g<1>{x}\2", text, count=1)
    text = re.sub(r"(#define\s+KTV_PLAYER_SMALL_RECT_Y\s+\()\d+(\))", rf"\g<1>{y}\2", text, count=1)
    text = re.sub(r"(#define\s+KTV_PLAYER_SMALL_RECT_W\s+\()\d+(\))", rf"\g<1>{w}\2", text, count=1)
    text = re.sub(r"(#define\s+KTV_PLAYER_SMALL_RECT_H\s+\()\d+(\))", rf"\g<1>{h}\2", text, count=1)
    return text

def set_screen(text: str) -> str:
    w, h = screen
    text = re.sub(r"(#define\s+KTV_PLAYER_SCREEN_WIDTH\s+\()\d+(\))", rf"\g<1>{w}\2", text, count=1)
    text = re.sub(r"(#define\s+KTV_PLAYER_SCREEN_HEIGHT\s+\()\d+(\))", rf"\g<1>{h}\2", text, count=1)
    return text

RIGHT_P1 = """int ktv_player_ui_set_right_rect(void)
{
    return ktv_player_ui_apply_rect(115,
                                    KTV_PLAYER_SMALL_RECT_Y,
                                    570,
                                    1280 - KTV_PLAYER_SMALL_RECT_Y);
}"""
RIGHT_JYY = """int ktv_player_ui_set_right_rect(void)
{
    return ktv_player_ui_apply_rect(115,
                                    KTV_PLAYER_SMALL_RECT_Y,
                                    570,
                                    600 - KTV_PLAYER_SMALL_RECT_Y);
}"""

FULL_SK_P1 = """int ktv_player_ui_set_full_rect(void)
{
    uint32_t w = 0;
    uint32_t h = 0;

    sunxifb_get_sizes(&w, &h);
    if (w == 0 || h == 0)
    {
        return ktv_player_ui_apply_rect(0,
                                        0,
                                        KTV_PLAYER_SCREEN_WIDTH,
                                        KTV_PLAYER_SCREEN_HEIGHT);
    }

    return ktv_player_ui_apply_rect(0, 0, (int)w, (int)h);
}"""

FULL_SK_JYY = """int ktv_player_ui_set_full_rect(void)
{
    /* 视频 layer 用 DE 屏坐标，切勿用 FB 1280×800 */
    return ktv_player_ui_apply_rect(0, 0, 1024, 600);
}"""

FULL_MS_P1 = """int ktv_player_ui_set_full_rect(void)
{
    return ktv_player_ui_apply_rect(0,
                                    0,
                                    KTV_PLAYER_SCREEN_WIDTH,
                                    KTV_PLAYER_SCREEN_HEIGHT);
}"""

FULL_MS_JYY = FULL_MS_P1

def replace_func(text: str, name: str, new_body: str) -> str:
    m = re.search(rf"int\s+{re.escape(name)}\s*\(void\)\s*\{{", text)
    if not m:
        raise SystemExit(f"function not found: {name}")
    start = m.start()
    i = text.find("{", m.start())
    depth = 0
    j = i
    while j < len(text):
        if text[j] == "{":
            depth += 1
        elif text[j] == "}":
            depth -= 1
            if depth == 0:
                j += 1
                break
        j += 1
    return text[:start] + new_body + text[j:]

changed = []
for rel in rotate_files:
    p = root / rel
    old = p.read_text(encoding="utf-8", errors="surrogateescape")
    new = set_rotate(old)
    if new != old:
        p.write_text(new, encoding="utf-8", errors="surrogateescape")
        changed.append(rel)

sk_ui = root / "platform/thirdparty/gui/lvgl-8/app/sing_ktv/src/generated/ktv_player/core/ktv_player_ui.c"
ms_ui = root / "platform/thirdparty/gui/lvgl-8/lib/media_session/src/pro/ktv_player_ui.c"
ms_h = root / "platform/thirdparty/gui/lvgl-8/lib/media_session/src/pro/ktv_player_common.h"
sk_h = root / "platform/thirdparty/gui/lvgl-8/app/sing_ktv/src/generated/ktv_player/core/ktv_player_common.h"

for p, rect in ((sk_ui, sk_small), (ms_ui, ms_small)):
    old = p.read_text(encoding="utf-8", errors="surrogateescape")
    new = set_small(old, rect)
    if p == sk_ui:
        new = replace_func(new, "ktv_player_ui_set_right_rect", RIGHT_JYY if profile == "jyy070" else RIGHT_P1)
        new = replace_func(new, "ktv_player_ui_set_full_rect", FULL_SK_JYY if profile == "jyy070" else FULL_SK_P1)
        if profile == "p1nor" and "sunxifb.h" not in new:
            new = new.replace(
                '#include "ms_changba.h"\n',
                '#include "ms_changba.h"\n#include "lv_drivers/display/sunxifb.h"\n',
                1,
            )
    else:
        new = replace_func(new, "ktv_player_ui_set_right_rect", RIGHT_JYY if profile == "jyy070" else RIGHT_P1)
        new = replace_func(new, "ktv_player_ui_set_full_rect", FULL_MS_JYY if profile == "jyy070" else FULL_MS_P1)
    if new != old:
        p.write_text(new, encoding="utf-8", errors="surrogateescape")
        changed.append(str(p.relative_to(root)))

for p in (ms_h, sk_h):
    if not p.exists():
        continue
    old = p.read_text(encoding="utf-8", errors="surrogateescape")
    new = set_screen(old)
    if new != old:
        p.write_text(new, encoding="utf-8", errors="surrogateescape")
        changed.append(str(p.relative_to(root)))

print(f"UI profile={profile} rotate={rotate} screen={screen[0]}x{screen[1]}")
print(f"changed: {len(changed)} files")
for c in changed:
    print(f"  - {c}")
PY
}

verify_ui_profile() {
	local profile="$1"
	local want_rot want_sw
	if [ "$profile" = "p1nor" ]; then
		want_rot=3
		want_sw=800
	else
		want_rot=0
		want_sw=1024
	fi
	local rot sw
	rot=$(sed -n 's/.*#define[[:space:]][[:space:]]*LV_PROJECTOR_DISP_ROTATE[[:space:]][[:space:]]*\([0-9][0-9]*\).*/\1/p' \
		platform/thirdparty/gui/lvgl-8/app/desk/src/projector_port/include/projector_config.h | head -1)
	sw=$(sed -n 's/.*#define[[:space:]][[:space:]]*KTV_PLAYER_SCREEN_WIDTH[[:space:]][[:space:]]*(\([0-9][0-9]*\)).*/\1/p' \
		platform/thirdparty/gui/lvgl-8/lib/media_session/src/pro/ktv_player_common.h | head -1)
	[ "$rot" = "$want_rot" ] || { log "error: UI rotate=$rot want=$want_rot"; return 1; }
	[ "$sw" = "$want_sw" ] || { log "error: SCREEN_WIDTH=$sw want=$want_sw"; return 1; }
	log "==> UI verify ok: profile=$profile rotate=$rot SCREEN_W=$sw"
}

purge_gui_out() {
	local board="$1"
	local p
	for p in "${GUI_PKGS[@]}"; do
		rm -rf "$ROOT/out/h133/${board}/openwrt/build_dir/target/${p}" \
			"$ROOT/out/h133/${board}/openwrt/build_dir/target/${p}"-* 2>/dev/null || true
	done
	rm -rf "$ROOT/out/h133/${board}/openwrt/build_dir/target/libtmedia"* 2>/dev/null || true
}

ensure_lunch() {
	local board="$1"
	local lunch="h133-${board}-tina"
	local defconfig="$ROOT/openwrt/target/h133/h133-${board}/defconfig"
	local cur tgt

	cur=$(grep '^export LICHEE_BOARD=' .buildconfig 2>/dev/null | sed 's/.*=//' || true)
	if [ "$cur" != "$board" ]; then
		log "==> autoconfig $board"
		./build.sh autoconfig -o openwrt -i h133 -b "$board" -n nor
	fi

	# shellcheck source=/dev/null
	source build/envsetup.sh
	lunch "$lunch"

	tgt=$(grep '^CONFIG_TARGET_BOARD=' openwrt/openwrt/.config 2>/dev/null | sed 's/.*=\"\(.*\)\"/\1/' || true)
	if [ "$tgt" != "h133-$board" ]; then
		log "==> install openwrt defconfig h133-$board"
		cp -a "$defconfig" openwrt/openwrt/.config
	fi

	rm -f "$ROOT/kernel/linux-5.4/.aw_patch_failed"
	log "==> LICHEE_BOARD=$(grep LICHEE_BOARD= .buildconfig | cut -d= -f2)"
}

build_one() {
	local board="$1"
	local profile="$2"
	local img="$ROOT/out/h133_linux_${board}_uart0_nor.img"

	log ""
	log "======== build $board (UI=$profile) ========"
	apply_ui_profile "$profile"
	verify_ui_profile "$profile"

	ensure_lunch "$board"
	purge_gui_out "$board"

	touch "$ROOT/kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/dev_disp.c" \
		"$ROOT/platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunxifb.c" 2>/dev/null || true

	log "==> build.sh kernel bootloader"
	./build.sh kernel bootloader

	mkdir -p "$ROOT/out/h133/${board}/openwrt"
	cp -a "$ROOT/out/h133/kernel/staging/boot.img" \
		"$ROOT/out/h133/kernel/staging/uImage" \
		"$ROOT/out/h133/${board}/openwrt/" 2>/dev/null || true

	log "==> m -j${NPROC} && p"
	m -j"${NPROC}"
	p

	[ -f "$img" ] || { log "error: missing $img"; return 1; }
	log "==> OK: $img"
	ls -la "$img" | tee -a "$LOG"
	md5sum "$img" | tee -a "$LOG"
}

# ---- main ----
: >"$LOG"
log "=== start $(date) === root=$ROOT (verify script, not SDK tools)"

if [ -n "$UI_ONLY" ]; then
	case "$UI_ONLY" in
	8733|p1_nor_8733|p1nor) apply_ui_profile p1nor; verify_ui_profile p1nor ;;
	jyy070|JYY070|p1_nor_JYY070) apply_ui_profile jyy070; verify_ui_profile jyy070 ;;
	*) echo "bad --ui-only $UI_ONLY" >&2; exit 1 ;;
	esac
	log "=== done (ui-only) $(date) ==="
	exit 0
fi

set +e
# shellcheck source=/dev/null
source build/envsetup.sh
_env=$?
set -e
[ "$_env" -eq 0 ] || { echo "error: envsetup failed" >&2; exit 1; }

do_8733=1
do_jyy=1
case "${ONLY}" in
"") ;;
8733|p1_nor_8733) do_jyy=0 ;;
jyy070|JYY070|p1_nor_JYY070) do_8733=0 ;;
*) echo "bad --only $ONLY" >&2; exit 1 ;;
esac

# build_one 内部会再 source/lunch；此处不再带 set -u
set +e
if [ "$do_8733" -eq 1 ]; then
	build_one p1_nor_8733 p1nor || { log "error: p1_nor_8733 build failed"; exit 1; }
fi
if [ "$do_jyy" -eq 1 ]; then
	build_one p1_nor_JYY070 jyy070 || { log "error: p1_nor_JYY070 build failed"; exit 1; }
fi
set -e

if [ "$LEAVE_JYY_UI" -eq 0 ]; then
	log "==> restore UI profile p1nor (8733 baseline)"
	apply_ui_profile p1nor
	verify_ui_profile p1nor
else
	log "==> leave UI at jyy070 (--leave-jyy-ui)"
fi

log "=== done $(date) ==="
log "images:"
log "  $ROOT/out/h133_linux_p1_nor_8733_uart0_nor.img"
log "  $ROOT/out/h133_linux_p1_nor_JYY070_uart0_nor.img"
