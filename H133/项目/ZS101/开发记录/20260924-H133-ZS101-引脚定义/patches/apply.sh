#!/bin/sh
# ZX30 引脚。先跑新建板件。不改屏时序和触摸节点。
set -eu

DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$DIR/../../../../.." && pwd)

if [ ! -f "$ROOT/build/envsetup.sh" ]; then
	echo "error: $ROOT is not AI-tq SDK root" >&2
	exit 1
fi

python3 - "$ROOT" <<'PY'
import sys
from pathlib import Path

ROOT = Path(sys.argv[1])
path = ROOT / "device/config/chips/h133/configs/p1_nor_ZS101/linux-5.4/board.dts"
if not path.exists():
    raise SystemExit("missing p1_nor_ZS101, run 新建板件 first")

PIN_PAIRS = [
    (
        "\t\tgpio = <&pio PB 10 GPIO_ACTIVE_HIGH>;\n\t\tenable-active-high;",
        "\t\t/* ZX30：USB VBUS 由板上 SY6280 供电，PB10 无此网络 */",
    ),
    (
        '\tfunction = "clk_fanout1";',
        "\t/* ZX30：PG11 = I2S1-MCLK，不是 WiFi 32k */\n\tfunction = \"gpio_in\";",
    ),
    (
        '\tstatus = "okay";\n\t/* CTP on TP-H10: TWI1 @ PG8/PG9 — not twi2@PC0/1; old gt9xx/fts nodes removed */',
        '\t/* ZX30 原理图无 AC107，TWI2/PC0 未接这颗芯片 */\n\tstatus = "disabled";',
    ),
    (
        '''\t\twlan: wlan@0 {
\t\t\tcompatible    = "allwinner,sunxi-wlan";
\t\t\tpinctrl-0 = <&wlan_pins_a>;
\t\t\tpinctrl-names = "default";
\t\t\tclock-names = "32k-fanout1";
\t\t\tclocks = <&ccu CLK_FANOUT1_OUT>;
\t\t\twlan_busnum    = <0x1>;
\t\t\twlan_regon    = <&pio PG 17 GPIO_ACTIVE_HIGH>;
\t\t\twlan_hostwake  = <&pio PG 10 GPIO_ACTIVE_HIGH>;''',
        '''\t\t/* ZX30 为 USB WiFi。PG17=LCD-BL-EN，PG11=I2S1-MCLK，不用 SDIO 这组脚 */
\t\twlan: wlan@0 {
\t\t\tcompatible    = "allwinner,sunxi-wlan";
\t\t\twlan_busnum    = <0x1>;
\t\t\tstatus        = "disabled";''',
    ),
    (
        '''\t\tbt: bt@0 {
\t\t\tcompatible    = "allwinner,sunxi-bt";
\t\t\tpinctrl-0 = <&wlan_pins_a>;
\t\t\tpinctrl-names = "default";
\t\t\tclock-names = "32k-fanout1";
\t\t\tclocks = <&ccu CLK_FANOUT1_OUT>;''',
        '''\t\tbt: bt@0 {
\t\t\tcompatible    = "allwinner,sunxi-bt";
\t\t\tstatus        = "disabled";''',
    ),
    (
        '\t\t\tstatus        = "okay";\n\t\t};\n\t};\n\n\tbtlpm: btlpm@0 {\n\t\tcompatible  = "allwinner,sunxi-btlpm";\n\t\tuart_index  = <0x1>;\n\t\tbt_wake     = <&pio PG 16 GPIO_ACTIVE_HIGH>;\n\t\tbt_hostwake = <&pio PG 18 GPIO_ACTIVE_HIGH>;\n\t\tstatus      = "okay";',
        '\t\t};\n\t};\n\n\t/* PG16=DC_DET，PG18=SPDIF-OUT */\n\tbtlpm: btlpm@0 {\n\t\tcompatible  = "allwinner,sunxi-btlpm";\n\t\tuart_index  = <0x1>;\n\t\tstatus      = "disabled";',
    ),
    (
        '\trx-sync-en;\n\tstatus\t\t= "okay";',
        '\trx-sync-en;\n\t/* ZX30：I2S 座是 PG11–PG15，没有板载 AC107 */\n\tstatus\t\t= "disabled";',
    ),
]

text = path.read_text(encoding="utf-8")
if "ZX30：USB VBUS" in text:
    print(f"==> pins already ZS {path.relative_to(ROOT)}")
else:
    for a, b in PIN_PAIRS:
        if a not in text:
            raise SystemExit(f"pin snippet missing: {a.splitlines()[0]}")
        text = text.replace(a, b, 1)
    print(f"==> pins {path.relative_to(ROOT)}")

text2 = text.replace(
    '\tsoundcard-mach,capture-only;\n\tstatus\t\t= "okay";',
    '\tsoundcard-mach,capture-only;\n\tstatus\t\t= "disabled";',
    1,
)
if text2 != text:
    text = text2
    print("==> i2s1_mach disabled")
path.write_text(text, encoding="utf-8")
print("==> pins ready")
PY

echo "==> OK"
echo "next: 屏幕"
