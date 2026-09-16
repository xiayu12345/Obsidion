#!/bin/bash
# 在 H133 SDK 根目录执行。默认不要打；试用才跑。
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="${H133_SDK_ROOT:-$(cd "$HERE/../../../../.." && pwd)}"
PATCH="$HERE/usb-voice-tmall-7045-2018.patch"
cd "$ROOT"
echo "==> SDK=$ROOT"
patch -p1 < "$PATCH"
echo "==> applied. 然后: ./tools/build_p1_nor_JL_M101.sh full"
echo "==> 撤回: patch -p1 -R < $PATCH"
