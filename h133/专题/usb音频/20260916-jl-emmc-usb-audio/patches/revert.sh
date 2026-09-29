#!/bin/sh
# 回退产品接入改动（0006→0003）。不碰内核 0001/0002（USB Audio / usbc0 Host）。
set -e
ROOT="$(cd "$(dirname "$0")/../../../../.." && pwd)"
cd "$ROOT"
DIR="$(cd "$(dirname "$0")" && pwd)"

patch -p1 -R < "$DIR/0006-nor-JL-M101-asound-CaptureUSB.patch"
patch -p1 -R < "$DIR/0005-ai-audio-session-package-ptt.patch"
patch -p1 -R < "$DIR/0004-aas-f24-ptt-standalone.patch"
patch -p1 -R < "$DIR/0003-aas-capture-prefer-CaptureUSB.patch"

echo "reverted: 0006..0003（产品 F24/CaptureUSB）"
echo "若还要关内核 USB Audio / usbc0 Host："
echo "  patch -p1 -R < $DIR/0002-jl-emmc-usbc0-default-host.patch"
echo "  patch -p1 -R < $DIR/0001-jl-emmc-enable-snd-usb-audio.patch"
echo "  然后清 .config 重编对应板内核"
