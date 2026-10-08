# HJ134A 屏幕 ↔ s10-h133 板子接线表

- 屏幕：`HJ134A-X5EI511-86J501-LCG03(9366TS)`（51pin FPC）
- 板子：`s10-h133-v1_0625`，LCD 座子 **CON5**（40pin FPC）
- 当前内容：**MIPI 通信脚** + **背光脚**

---

## 一、MIPI 接线

### 接线原则

1. 按 **P 接 P、N 接 N** 对接，不要把同一对的正负交叉。
2. 屏侧顺序是「先 P 后 N」，板侧 CON5 顺序是「先 N 后 P」，所以每一对内部两根线要对调。
3. 差分对之间的 GND 仍按顺序接。

### MIPI 接线顺序

| 屏脚 | 屏信号 | 极性说明 | 板子 CON5 | 板子网络 |
| ---: | --- | --- | ---: | --- |
| 10 | DOP_M | Lane0 P | 9 | MIPI-0P（DSI-D0P） |
| 11 | DON_M | Lane0 N | 8 | MIPI-0N（DSI-D0N） |
| 12 | GND | 地 | 10 | GND |
| 13 | D1P_M | Lane1 P | 12 | MIPI-1P（DSI-D1P） |
| 14 | D1N_M | Lane1 N | 11 | MIPI-1N（DSI-D1N） |
| 15 | GND | 地 | 13 | GND |
| 16 | CLKP_M | Clock P | 15 | MIPI-CKP（DSI-CKP） |
| 17 | CLKN_M | Clock N | 14 | MIPI-CKN（DSI-CKN） |
| 18 | GND | 地 | 16 | GND |
| 19 | D2P_M | Lane2 P | 18 | MIPI-2P（DSI-D2P） |
| 20 | D2N_M | Lane2 N | 17 | MIPI-2N（DSI-D2N） |
| 21 | GND | 地 | 19 | GND |
| 22 | D3P_M | Lane3 P | 21 | MIPI-3P（DSI-D3P） |
| 23 | D3N_M | Lane3 N | 20 | MIPI-3N（DSI-D3N） |
| 24 | GND | 地 | 22 | GND |

### 快速对照（按差分对）

| 差分对 | 屏脚 | 板子脚 |
| --- | --- | --- |
| Lane0 | 10→9（P），11→8（N） | CON5-9 / CON5-8 |
| Lane1 | 13→12（P），14→11（N） | CON5-12 / CON5-11 |
| Clock | 16→15（P），17→14（N） | CON5-15 / CON5-14 |
| Lane2 | 19→18（P），20→17（N） | CON5-18 / CON5-17 |
| Lane3 | 22→21（P），23→20（N） | CON5-21 / CON5-20 |

### 线序示意

```
屏 FPC:   10P 11N 12G | 13P 14N 15G | 16P 17N 18G | 19P 20N 21G | 22P 23N 24G
                 ↕  每对内部交叉(P/N)  ↕
板 CON5:   9P  8N 10G | 12P 11N 13G | 15P 14N 16G | 18P 17N 19G | 21P 20N 22G
```

---

## 二、背光接线

板子 CON5 的背光由 **PT4117B** 恒流驱动：`VLED+` / `VLED-`。

屏规格：LED 正向电压约 **24V typ / If=144mA**（21 颗白光）。

| 屏脚 | 屏信号 | 说明 | 板子 CON5 | 板子网络 |
| ---: | --- | --- | ---: | --- |
| 1 | LEDA | 背光阳极 | 39 或 40 | LED+（VLED+） |
| 2 | LEDA | 背光阳极 | 39 或 40 | LED+（VLED+） |
| 3 | NC | 不接 | — | — |
| 4 | LEDK | 背光阴极 | 32 或 33 | LED-（VLED-） |
| 5 | LEDK | 背光阴极 | 32 或 33 | LED-（VLED-） |
| 6 | LEDK | 背光阴极 | 32 或 33 | LED-（VLED-） |
| 7 | LEDK | 背光阴极 | 32 或 33 | LED-（VLED-） |
| 8 | LEDK | 背光阴极 | 32 或 33 | LED-（VLED-） |

### 推荐接法（并线）

| 功能 | 屏脚 | 板子 CON5 |
| --- | --- | --- |
| LED+（阳极） | 1、2 并在一起 | 39、40 并在一起 |
| LED-（阴极） | 4～8 并在一起 | 32、33 并在一起 |
| NC | 3 | 不接 |

```
屏:  LEDA(1,2)  --------------------→  CON5 LED+(39,40) = VLED+
屏:  LEDK(4,5,6,7,8)  --------------→  CON5 LED-(32,33) = VLED-
```

### 背光注意

1. **正负极不能接反**：LEDA → LED+，LEDK → LED-。
2. 屏侧多个 LEDA / LEDK 脚在模组内部通常已并联，飞线时同名脚并接即可。
3. 板子电流由 PT4117B 采样电阻设定（原理图 `RL6/RL7`）；对接本屏前建议确认恒流是否接近规格 **144mA**，避免过流。

---

## 备注

- 规格书功能栏里对 DOP_M / DON_M 的 Positive/Negative 文字有写反嫌疑；MIPI 接线以符号名 **P/N** 为准，与板子 `MIPI-xP/N` 同名对接。
- 电源（VSP/VSN/IOVCC）、复位、触摸脚尚未列入本表。
