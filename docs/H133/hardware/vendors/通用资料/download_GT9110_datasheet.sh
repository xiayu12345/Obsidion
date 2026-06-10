#!/bin/bash
# 下载汇顶 GT9110 规格书（Rev.02 2012-09-11，与 GT9110-Datasheet_20121205 同源）
# 用法: ./download_GT9110_datasheet.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="${SCRIPT_DIR}/GT9110-Datasheet_Rev02_20120911.pdf"
URL="https://dl.linux-sunxi.org/touchscreen/GT9110%20Datasheet.pdf"

echo "Downloading GT9110 datasheet..."
echo "  URL: ${URL}"
echo "  ->  ${OUT}"

if command -v curl >/dev/null 2>&1; then
	curl -fsSL --connect-timeout 30 --retry 3 -o "${OUT}" "${URL}"
elif command -v wget >/dev/null 2>&1; then
	wget -q --timeout=30 -O "${OUT}" "${URL}"
else
	echo "Error: need curl or wget" >&2
	exit 1
fi

if file "${OUT}" | grep -qi pdf; then
	ls -lh "${OUT}"
	echo "OK."
else
	echo "Warning: downloaded file may not be a valid PDF. Check manually." >&2
	file "${OUT}"
	exit 1
fi
