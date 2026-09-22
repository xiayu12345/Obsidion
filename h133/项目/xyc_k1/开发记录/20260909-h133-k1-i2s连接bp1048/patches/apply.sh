#!/bin/sh
set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$DIR/../../../.." && pwd)

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: $ROOT is not AI-tq SDK root" >&2
	exit 1
fi

cd "$ROOT"
for p in \
	0001-h133-k1-i2s1-dts.patch \
	0002-h133-k1-alsa-i2s-route.patch \
	0003-h133-k1-bp1048-uart.patch
do
	echo "==> apply $p"
	patch -p1 --forward < "$DIR/$p"
done
echo "==> OK"
