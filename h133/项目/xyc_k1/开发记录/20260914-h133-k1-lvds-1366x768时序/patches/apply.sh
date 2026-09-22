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
	01-board-dts-1366x768.patch \
	02-setting-ini-1366x768.patch
do
	echo "==> apply $p"
	patch -p1 --forward < "$DIR/$p"
done

echo "==> OK"
