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
	0001-sunxi-gpadc-optional-dual-key-groups.patch \
	0002-h133-k1-gpadc-20-key-map.patch
do
	echo "==> apply $p"
	patch -p1 --forward < "$DIR/$p"
done

echo "==> OK"
