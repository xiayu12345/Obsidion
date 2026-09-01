---
project: ZS101
kind: log
date: 2026-08-17
---

# 20260817 — 纽曼 ZS101NI4042 资料梳理

| 项 | 内容 |
|---|---|
| 日期 | 2026-08-17 |
| 板型 | **`p1_nor_ZS101`（NOR，已确认）** |
| 基线 | **`p1_nor_JL_M101`（已确认）** |
| 状态 | **板件已克隆**（2026-08-17）；**点亮见 [20260825](../20260825-ZS101-ILI9881C-MIPI显示点亮/)** |
| 资料目录 | `H133-AI-Skills/硬件资料/纽曼/` |

---

## 1. 一句话结论

纽曼屏是 **中深 ZS101NI4042J4H8II-B：10.1" 800×1280 MIPI 4-lane + ILI9881C**，直连 SoC DSI，不是桥片。  
规格书扫描方向是 **横 800 / 竖 1280**（模组外形 143×228.6，竖条），和京龙 JL_M101 同类。  
产品横屏 UI → **`disp_rotate=3`**；HDMI 同理 **`dual_display_rot=3`**（缺省已是 3）、**`VIDEO_WB_MIRROR_ROTATE=90`**。

---

## 2. 硬件资料摘要

### 2.1 屏：ZS101NI4042J4H8II-B

| 项 | 值 | 来源 |
|---|---|---|
| 型号 | 中深 **ZS101NI4042J4H8II-B**（Innolux T2 10.1"） | 规格书封面 |
| 尺寸 | 10.1"；外形 **143×228.6×2.5 mm**；AA 135.36×216.58 | 规格书 §1 / 模组图 |
| 分辨率 | **800(RGB)×1280** | 页脚 / §1 Number of Dots |
| 接口 | **MIPI 4-lane**（pin8–21：D0/D1/CK/D2/D3） | §5 |
| IC | **ILI9881C**（规格书未写型号；init `0xFF,0x98,0x81`） | 厂商 `.c` 文件名 |
| 供电 | VCI **3.3V** typ；RST 2.8–3.6V typ 3.3V | §3 / §5 pin5 |
| 背光 | LED+/LED−，**12V / 180mA**（4S8P）；屏上 PWM0 脚 **NC** | §3.1 / pin27、31–32、39–40 |
| 视角 | Full View（IPS） | §1 |

规格书：`硬件资料/纽曼/ZS101NI4042J4H8II-B.pdf`

### 2.2 时序（规格书 §6.1，Rev 1.2）

| Vendor | 值 | Allwinner |
|---|---|---|
| HSA / HBP / HFP / X | 16 / 60 / 60 / 800 | `hspw=16` `hbp=76` `ht=936` |
| VSA / VBP / VFP / Y | 4 / 10 / 10 / 1280 | `vspw=4` `vbp=14` `vt=1304` |
| 校验 | HT=936、VT=1304 | 与表一致 |
| dclk | 规格书无像素钟 | 60Hz 估算 **73 MHz**（`936×1304×60`） |
| DSI | 4-lane video，non-burst + sync pulses | `lcd_if=4` `lane=4` `dsi_if=0` |

### 2.3 Init

`硬件资料/纽曼/新代码02群创10.1(T2)+ILI9881C-0D_2P_20190920.c`

- 页切换 `DCS_Long_Write_3P(0xFF,0x98,0x81,page)` → ILI9881
- `SSD_LANE(4,0)`；收尾 `0x11` delay 120ms、`0x29` delay 20ms
- `SSD_MODE(0,1)`：video non-burst sync pulses + HS
- 文件头 `Set_POWER(1.8/2.8/5V)` 是点屏夹具，H133 上不用
- 注释写过 `HX8394D`，与 `0xFF 0x98 0x81` 不符，以 ILI9881C 为准

树内已有 Allwinner 样例 `ili9881c.c`（init 不同，无板启用、Kconfig 甚至无条目）。**一屏一驱动**：新建 `zs101_ili9881c`，不改该样例。

### 2.4 主板

`硬件资料/纽曼/纽曼h133主板：ZX30-D618-H133.rar`（RAR5，当前环境未解开）。  
RESET/PWM 克隆期先继承京龙 s10：**PB11=RST、PB12=PWM0@50kHz**；原理图解开后复核。

触摸：当时无 TP 资料。定稿见 [20260827 GT928](../20260827-ZS101-GT928触摸适配/)。

---

## 3. 旋转（规格书，非抄京龙习惯）

规格书把 **800 标成 Horizontal Display、1280 标成 Vertical Display Area**，模组图短边 143 / 长边 228.6。  
结论：**面板原生竖屏 800×1280**（和 LQ140/LQ190 那种原生横屏不同）。

产品要横屏 UI / 横屏 HDMI，必须软旋：

| 链路 | 值 | 理由 |
|---|---|---|
| `fb0` | **800×1280** | 跟物理 `lcd_x/y`，不做 DE 把 fb 转成 1280×800 |
| UI `disp_rotate` | **3**（270°） | LVGL 逻辑 **1280×800** |
| HDMI `dual_display_rot` | **3** | WB 抓竖屏 DE0 → 横屏 HDMI；属性缺省已是 3 |
| 视频 `VIDEO_WB_MIRROR_ROTATE` | **90** | 与 8733 / JL_M101 竖屏 MIPI 一致 |
| `tp_rotate` | **0** | 触摸定稿见 [20260827 GT928](../20260827-ZS101-GT928触摸适配/)（`revert_y=1`，仍 `tp_rotate=0`） |

HDMI 本身是横屏输出（基线 `screen1` 1080p），要旋的是 **从竖屏主显镜像过去的那帧**，不是把 HDMI 时序改成 800×1280。

---

## 4. 与基线对照

| 项 | `p1_nor_JL_M101` | 本板应有 |
|---|---|---|
| 分辨率 / lane | 800×1280 / 4 | **同**（porch/dclk/init 不同） |
| panel | `jl_m101_jd9365da` | **`zs101_ili9881c`** |
| `disp_rotate` / WB / HDMI rot | 3 / 90 / 缺省 3 | **同**（规格书原生竖屏） |
| RESET / PWM | PB11 / PB12 PWM0 | 克隆先继承；主板 rar 后复核 |
| WiFi | RTL8733BU | 继承 |
| 存储 | NOR | **NOR** |

---

## 5. 克隆已落地（2026-08-17）

从 `p1_nor_JL_M101` 克隆 `p1_nor_ZS101`：独立 `zs101_ili9881c`、本板 DTS 时序/`dclk=73`、`disp_rotate=3`、`dual_display_rot=3`、WB=90、调屏期 U-Boot `disp_init_enable=0`。CTP 先 disabled。

编译：`./tools/build_p1_nor_ZS101.sh kernel`（或 `full`）。

**禁止**：改兄弟板 DTS、改 `default_panel.c` / 现有 `ili9881c.c`、改 `generated/`。点亮见 [20260825](../20260825-ZS101-ILI9881C-MIPI显示点亮/)。

---

## 6. 已确认 / 仍待

| # | 问题 | 状态 |
|---|---|---|
| 1 | 存储 | **NOR（`p1_nor_ZS101`）** |
| 2 | 基线 | **`p1_nor_JL_M101`** |
| 3 | UI / HDMI 旋转 | **规格书原生竖屏 → rot=3 / dual_display_rot=3 / WB=90** |
| 4 | RESET / 背光脚 | 克隆先跟京龙 PB11/PB12；主板 rar 未解 |
| 5 | 触摸 | 无资料，本阶段不做（CTP disabled） |
