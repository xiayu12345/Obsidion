#!/bin/sh
set -e
ROOT="$(cd "$(dirname "$0")/../../../../.." && pwd)"
cd "$ROOT"
DIR="$(cd "$(dirname "$0")" && pwd)"

# 内核 / Host
patch -p1 < "$DIR/0001-jl-emmc-enable-snd-usb-audio.patch"
patch -p1 < "$DIR/0002-jl-emmc-usbc0-default-host.patch"

# 产品：USB 麦 + 独立 F24 PTT（可对已改工作区报 skip，属正常）
patch -p1 < "$DIR/0003-aas-capture-prefer-CaptureUSB.patch" || true
patch -p1 < "$DIR/0004-aas-f24-ptt-standalone.patch" || true
patch -p1 < "$DIR/0005-ai-audio-session-package-ptt.patch" || true
patch -p1 < "$DIR/0006-nor-JL-M101-asound-CaptureUSB.patch" || true

echo "applied: 0001..0006（见 patches/README.md）"
