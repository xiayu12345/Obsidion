---
project: LQ190
kind: log
date: 2026-08-07
---

# 20260807 — 鸿博 LQ190E1LX65 资料梳理与待确认

| 项 | 内容 |
|---|---|
| 日期 | 2026-08-07 |
| 板型 | **`p1_nor_LQ190`（NOR，已确认不改 eMMC）** |
| 状态 | **历史资料梳理**；显示已在 [20260811 定稿](../20260811-LQ190-GM8775C-MIPI显示定稿/README.md) 闭环 |
| 资料目录 | `H133-AI-Skills/硬件资料/鸿博芯业/` |

---

## 1. 一句话结论

鸿博资料对应的是 **Sharp LQ190E1LX65（1280×1024 双 LVDS）+ GM8875C/GM8775C（MIPI→LVDS）**。  
本文为早期资料梳理；**出图已在 [20260811 定稿](../20260811-LQ190-GM8775C-MIPI显示定稿/README.md) 闭环**（主机 MIPI 灌表、`0x13=0x63`、RST=PG2、关 BIST）。

---

## 2. 硬件资料摘要

### 2.1 屏：LQ190E1LX65

| 项 | 值 | 来源 |
|---|---|---|
| 型号 | Sharp **LQ190E1LX65** | 规格书 PDF（LD-27X08A） |
| 尺寸 | 19.0" | 规格书 / Panelook |
| 分辨率 | **1280×1024（SXGA），5:4 横屏** | 同上 |
| 接口 | **LVDS 双通道 8-bit，30 pin** | 同上；实物丝印 RA*/RB* 双通道 |
| 屏供电 | 5.0V（Typ.） | Panelook |
| 刷新 | 60Hz（Typ.） | 同上 |
| 背光 | WLED + 驱动；板端 6P：**GND / GND / ADJ / EN / 12V / 12V** | 实物标注图 |

规格书 PDF（扫描件，难抽文本）：

`硬件资料/鸿博芯业/LQ190E1LX65_LD-27X08A_20151127_202407011157(1).pdf`

同类 Sharp SXGA（LQ190E1LX78）典型时序可作**初值参考**（非本屏定稿）：

| 项 | 参考值 |
|---|---|
| Pixel clock | ~108 MHz（VESA SXGA 60Hz） |
| HT / 有效 | 1688 / 1280（双 LVDS 时单通道常记 844） |
| VT / 有效 | 1066 / 1024 |

### 2.2 桥片：GM8875C（资料亦写 GM8775C）

| 项 | 内容 |
|---|---|
| 功能 | **MIPI-DSI 入 → LVDS 出**（Demo 可到 1920×1200） |
| 配置方式 | ① I2C 写寄存器 ② MIPI 短包 `DATA ID=0x23`（先写 `0x27=0xAA`）③ 板上 EEPROM 自举（I2C Master + EEPROM 0xA0） |
| I2C 地址 | 脚选：拉高 **0x5A**，拉低 **0x58**（7-bit 口径以手册/原理图为准） |
| 参考驱动 | `…/官方参考开发资料/gm8775.c`（Rockchip 侧 I2C probe 灌表） |
| 转接板规格 | `…/MIPI转LVDS转接板规格书.pdf`；原理图 `Sch/MIPI TO LVDS1920X1200-SCH_V3.0.pdf` |

### 2.3 RegList（桥片刷参表）是什么

路径：

`硬件资料/鸿博芯业/GM8875C 资料/官方参考开发资料/GM8775C_A1.1__IIC20190819/GM8775C_RegList20260729_210421.txt`

- 上位机按分辨率/porch 等生成的 **`寄存器地址,数值`** 列表（共 34 行）。
- 上电后写入 GM8875，桥片才按该表做 MIPI→LVDS。
- **注意**：该文件与官方示例 **1080p 灌表几乎相同**（`0x01~0x06` 一致），**不像已按 1280×1024 重导**；在确认「就是给本屏定稿」之前，**不要当 SXGA 最终表盲目灌入**。

---

## 3. 与现有工程对照

| 项 | 现有 `p1_nor_LQ190` | 资料应有 |
|---|---|---|
| 基线 | 自 `p1_nor_LQ140M1JW61` 克隆 | 可保留板级/WiFi/NOR 骨架 |
| 链路 | MIPI→**eDP**（`lq190_mipi2edp` 占位） | MIPI→**GM8875→LVDS** |
| `lcd_x/y` | 1920×1080 | **1280×1024** |
| `lcd_dclk_freq` | 139（LQ140） | 待定（初值可试 ~108） |
| panel init | 仅 `dsi_clk_enable`（无 DCS） | 视硬件：EEPROM 自举 / 主机灌 RegList |
| 存储 | NOR | **已确认：NOR** |
| 当前 lunch | 环境曾停在 `p1_emmc_LQ140M1JW61` | 确认后切 `p1_nor_LQ190` 再编 |

板级档案（脚手架说明，未按本专题更新）：

`H133-AI-Skills/skills/h133-display/board-profile-p1_nor_LQ190.md`

---

## 4. 拟改范围（确认后才执行）

1. **本板 DTS**（kernel + uboot）：分辨率/时序/`fb0`；仍 `lcd_if=4`（MIPI 进桥）。
2. **panel**：在现有 `lq190_mipi2edp` 上补灌参或改名 `mipi2lvds`（**改名需另确认**）；调屏期 U-Boot `disp_init_enable=0`。
3. **文档**：同步 `board-profile`、本目录定稿页。
4. **切板编译**：`./tools/build_p1_nor_LQ190.sh full` → `out/h133_linux_p1_nor_LQ190_uart0_nor.img`。

**禁止**：改兄弟板、共享 `p1_nor`、`generated/`、私自加对外 API。

---

## 5. 待用户确认清单

| # | 问题 | 状态 |
|---|---|---|
| 1 | 存储：NOR / eMMC | **已确认：NOR（`p1_nor_LQ190`）** |
| 2 | RegList：现成文件先用，还是按 1280×1024 重导 | **已闭环**：工具 MIPI 导出 + 主机 `dsi_gen_wr`（见 [20260811 定稿](../20260811-LQ190-GM8775C-MIPI显示定稿/README.md)） |
| 3 | GM8875：EEPROM 自举，还是主机灌（MIPI / I2C）；I2C 总线与地址 | **已闭环**：主机 MIPI 灌；转接板 IIC Slave **0x58**（上位机）；解锁 MIPI **`0x27=0xAA`** |
| 4 | 背光 EN/ADJ、桥片 EN/RST：是否跟 LQ140（PB11 RST、PB12 PWM0） | **已闭环**：BL-EN=PG15；PWM0=PB12；桥片 RST=**PG2（CTP-RST）**，非 PB11 |
| 5 | UI：`fb0` 直接 1280×1024，还是像 LQ140 做 DE 缩放；`disp_rotate` 是否仍为 0 | **已闭环**：`fb0`=1280×1024 直出，`disp_rotate=0` |

确认话术示例：

`确认执行：RegList先用，EEPROM自举，背光跟LQ140，fb0=1280x1024，disp_rotate=0`

---

## 6. 编译（确认并改完后再跑）

```bash
./tools/build_p1_nor_LQ190.sh kernel   # 或 full
# 产物：out/h133_linux_p1_nor_LQ190_uart0_nor.img
```
