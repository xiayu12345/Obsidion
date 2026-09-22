#!/bin/sh
set -e
ROOT="$(cd "$(dirname "$0")/../../../.." && pwd)"
cd "$ROOT"
DIR="$(cd "$(dirname "$0")" && pwd)"
patch -p1 < "$DIR/0001-jl-emmc-enable-snd-usb-audio.patch"
patch -p1 < "$DIR/0002-jl-emmc-usbc0-default-host.patch"
echo "applied: 0001 + 0002"
