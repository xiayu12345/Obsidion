#!/bin/bash
# 用法：在任意目录执行本脚本。要求 AI-tq 为 git 工作区。
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$DIR/../../../.." && pwd)"
if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: $ROOT is not AI-tq SDK root" >&2
	exit 1
fi
cd "$ROOT"
echo "==> apply in $ROOT"
for p in \
	01-kernel-uboot-lvds-panel.patch \
	02-board-dts-k1-lvds.patch \
	03-uboot-nor-boot1-size.patch \
	04-ui-rotate-landscape.patch \
	05-drop-lvds-io-polarity.patch
do
	echo "==> $p"
	git apply --check "$DIR/$p"
	git apply "$DIR/$p"
done
echo "==> OK"
