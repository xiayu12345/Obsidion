#!/bin/bash
# 在 H133 SDK 根目录执行
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="${H133_SDK_ROOT:-$(cd "$HERE/../../../.." && pwd)}"
cd "$ROOT"
echo "==> SDK=$ROOT"
git apply --check \
  "$HERE/0001-uboot-nor-sst-sunxi-serial.patch" \
  "$HERE/0002-uboot-bootargs-snum-null-tmpbuf512.patch" \
  "$HERE/0003-libkey-sst_test-512.patch" \
  "$HERE/0004-zs101-enable-libkey-demo.patch"
git apply \
  "$HERE/0001-uboot-nor-sst-sunxi-serial.patch" \
  "$HERE/0002-uboot-bootargs-snum-null-tmpbuf512.patch" \
  "$HERE/0003-libkey-sst_test-512.patch" \
  "$HERE/0004-zs101-enable-libkey-demo.patch"
echo "==> applied. 然后: ./tools/build_p1_nor_ZS101.sh full"
