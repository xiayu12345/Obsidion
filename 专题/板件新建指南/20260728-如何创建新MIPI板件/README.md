---
project: H133
kind: log
date: 2026-07-28
---

# 如何创建新的 MIPI 板件

| 项 | 内容 |
|---|---|
| 日期 | 2026-07-28 |
| 类型 | **通用操作指南**（非某一块屏的调试流水） |
| 推荐基线 | **`p1_nor_8733`**（MIPI 竖屏 UI + RTL8733BU） |
| 范本定稿 | [JL_M101 板件新建与 MIPI 显示定稿](../板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/README.md) |
| 范本板 | `p1_nor_JL_M101`（JD9365DA，800×1280，4-lane） |

下文用占位符：

| 占位 | 含义 | 范例 |
|---|---|---|
| `<BOARD>` | 板级目录名 | `p1_nor_FOO` |
| `<PANEL>` | `lcd_driver_name` / 驱动名 | `foo_jd9365da` |
| `<KCFG>` | Kconfig 宏后缀 | `FOO_JD9365DA` |

---

## 0. 一句话结论

从 **`p1_nor_8733` 整树克隆** → 拆 `linux-5.4` 软链 → **独立 panel + 本板 DTS**（`lcd_if=4`）→ OpenWrt target / 编译脚本挂钩 → 调屏期关 U-Boot 开屏 → 实机出图后再开 logo / 触摸。

**禁止**把新屏硬塞进共享 `p1_nor`，也禁止改 `default_panel.c`。

---

## 1. 开工前准备

| 资料 | 用途 |
|---|---|
| 模组规格书 | 分辨率、lane 数、VCC、RESET/背光脚 |
| 厂商 init txt / 参考驱动 | 灌码表、Reset 时序、porch |
| 主板/转接板原理图 | RESET/PWM/MIPI 走线、分压档、脚冲突 |
| UI 方向约定 | 竖屏 MIPI 通常对齐 8733：`disp_rotate=3`，`dual_display_rot=3`，`VIDEO_WB=90`（改法见 [显示旋转](../../显示旋转/README.md)） |

对照范本硬件要点：[JL_M101 00-总览](../板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/00-总览与定稿.md)

### 选基线

| 基线 | 何时选 |
|---|---|
| **`p1_nor_8733`** | 默认：同 MIPI 竖屏 UI + **8733BU** |
| `p1_nor` | 仅当你明确要 AIC8800，且接受 UI/视频与 8733 同框架 |
| `p1_nor_JYY070` | **不要**当 MIPI 基线（LVDS 横屏、`disp_rotate=0`） |

---

## 2. 克隆板级（device + OpenWrt + 脚本）

范本步骤详解：[JL_M101 01-板件新建](../板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/01-板件新建.md)

### 2.1 推荐命令（SDK 根目录）

```bash
BASE=device/config/chips/h133/configs
OW=openwrt/target/h133
BOARD=p1_nor_FOO          # ← 改成你的板名
SRC=p1_nor_8733

cp -a $BASE/$SRC $BASE/$BOARD

# 拆 linux-5.4 软链（8733 常指向 p1_nor）
rm -rf $BASE/$BOARD/linux-5.4
cp -a $BASE/p1_nor/linux-5.4 $BASE/$BOARD/linux-5.4
ln -sfn linux-5.4/board.dts $BASE/$BOARD/board.dts

# uboot-board.dts / env / fex 若仍是软链，一并拆成实文件再改
# （参考 p1_nor_4k / JL_M101 做法）

cp -a $OW/h133-$SRC $OW/h133-$BOARD
# 全文替换板名：h133-p1_nor_8733 → h133-$BOARD，p1_nor_8733 → $BOARD
# 注意：勿误伤字符串 RTL8733BU

cp tools/build_p1_nor_8733.sh tools/build_${BOARD}.sh
# 改脚本内 BOARD / LUNCH / DEFCONFIG 路径
```

### 2.2 必须落地的公共挂钩（最小）

| 文件 | 做什么 |
|---|---|
| `kernel/.../lcd/Kconfig` | `CONFIG_LCD_SUPPORT_<KCFG>` |
| `kernel/.../disp/Makefile` | 编入 `<PANEL>.o` |
| `kernel/.../lcd/panels.c` + `panels.h` | `#ifdef` 注册 |
| U-Boot 侧同上 | 同名 panel / Kconfig |
| **本板** `config-5.4` | `CONFIG_LCD_SUPPORT_<KCFG>=y` |
| **兄弟板** `config-5.4` | `# CONFIG_LCD_SUPPORT_<KCFG> is not set` |
| 兄弟板 OpenWrt `defconfig` | `# CONFIG_TARGET_h133_<BOARD> is not set` |
| `openwrt/.openwrt_targets`（若工程有） | 增加 lunch 名 |
| `libtmedia/Makefile` | 本 target → `VIDEO_WB_MIRROR_ROTATE`（竖屏 MIPI 通常 **90**） |

运行时选屏**只靠**本板 DTS `lcd_driver_name = "<PANEL>"`。

### 2.3 OpenWrt / 工厂 ini

| 项 | 竖屏 MIPI 典型（跟 8733） |
|---|---|
| `setting.ini` `disp_rotate` | **3** |
| `tp_rotate` | 按触摸方案（先跟基线，触摸另开记录） |
| WiFi | 继承 8733：`rtl8733bu-kmod`，**不开 AIC8800** |
| hostname | 可选改成带板名 |

---

## 3. 写独立 MIPI panel 驱动

范本：[JL_M101 02-panel与init](../板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/02-panel与init.md)

### 3.1 文件

| 侧 | 路径 |
|---|---|
| 内核 | `kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/<PANEL>.c` + `.h` |
| U-Boot | `brandy/.../disp/lcd/<PANEL>.c`（init / Reset / open_flow **与内核一致**） |

导出 `struct __lcd_panel`，名字与 DTS **完全一致**。

### 3.2 Init 转换要点

- 厂商表 → `dsi_gen_wr` / delay / end 标记（按工程现有约定）  
- **Reset 时序跟规格书**（常见：H→L→H 再延时再发码）  
- `panel_reset` → `lcd_gpio_0`（DTS 里的 RESET 脚）  
- open_flow 典型：`power_on → panel_init → tcon_enable → bl_open`

### 3.3 禁止项（JL_M101 踩过）

| 禁止 | 原因 |
|---|---|
| 在 `panel_init` 里 `dsi_dcs_read` 探针 | 屏不回读时 DPHY 卡死，后续写挂死 |
| 改 `default_panel.c` 塞新 init | 污染其它板 |
| 调屏期依赖 U-Boot smooth | 内核可能跳过 `cfg_open_flow`，新 init 不跑 |

调屏期：**U-Boot `disp_init_enable = <0>`**，让 Linux 自己灌码。

---

## 4. 本板 DTS（内核 + U-Boot 同步）

范本：[JL_M101 03-DTS与背光PWM](../板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/03-DTS与背光PWM.md)

### 4.1 lcd0 骨架（按屏改数字）

```dts
&lcd0 {
	lcd_used            = <1>;
	lcd_driver_name     = "<PANEL>";
	lcd_if              = <4>;          /* DSI */
	lcd_x               = <W>;          /* 如 800 */
	lcd_y               = <H>;          /* 如 1280 */
	lcd_dclk_freq       = <NN>;

	/* porch：按厂商 HSA/HBP/HFP、VSA/VBP/VFP 换算成 Allwinner hspw/hbp/ht、vspw/vbp/vt */
	lcd_hspw = <…>; lcd_hbp = <…>; lcd_ht = <…>;
	lcd_vspw = <…>; lcd_vbp = <…>; lcd_vt = <…>;

	lcd_dsi_if          = <0>;          /* video；勿一上来就 burst 当救命稻草 */
	lcd_dsi_lane        = <4>;          /* 或 2，跟模组 */
	lcd_dsi_format      = <0>;

	lcd_gpio_0          = <&pio Px N GPIO_ACTIVE_HIGH>; /* RESET */
	/* 背光：原理图是 PWM 就配 lcd_pwm_*；是 GPIO enable 才用 lcd_bl_en —— 不要混 */

	pinctrl-0 = <&dsi4lane_pins_a>;     /* lane 数要对 */
	pinctrl-1 = <&dsi4lane_pins_b>;
};
```

Porch 换算备忘（JL 范本）：

| Vendor | Allwinner |
|---|---|
| HSA, HBP, HFP | `hspw=HSA`，`hbp=HSA+HBP`，`ht=X+hbp+HFP` |
| VSA, VBP, VFP | `vspw=VSA`，`vbp=VSA+VBP`，`vt=Y+vbp+VFP` |

### 4.2 脚冲突（必查）

基线 DTS 里 `usbc0` 等节点可能占用 **RESET / 背光脚**。本板必须释放，并在注释写清原因。

### 4.3 背光

- 原理图写 **PWM → 恒流芯片 EN**：配 `lcd_pwm_used/ch/freq/pol`，并绑对应 `pwmN` pinctrl  
- 频率跟芯片资料（JL 转接板 PT4117 是 **50kHz**，不是随便 500Hz）  
- **禁止**把 PWM 脚再配成 `lcd_bl_en` GPIO

### 4.4 disp / fb

MIPI 竖屏跟 8733 时通常：

- `fb0_width/height` = 物理 `lcd_x/lcd_y`（如 800×1280）  
- 应用靠 `disp_rotate=3` 转成逻辑横屏 UI  

HDMI 异显：`dual_display_rot` 与 UI 策略对齐（竖屏 MIPI 常见与 rot 一致，见 8733/JL）。

---

## 5. 编译与验收

```bash
./tools/build_<BOARD>.sh kernel   # panel / DTS / bootloader
./tools/build_<BOARD>.sh full     # + rootfs + pack
# 产物：out/h133_linux_<BOARD>_uart0_nor.img
```

| 改动 | 编什么 |
|---|---|
| panel `.c` / 内核 DTS / config | `kernel` + pack |
| U-Boot panel / uboot-board | bootloader + pack（必要时清旧 `.o`） |
| `setting.ini` / 应用 | `rootfs` |

**禁止**在 WSL/x86 源码旁本地 `gcc -c` 试编（会污染交叉 `.o`）。

### 验收清单

- [ ] `dmesg` 见本 `<PANEL>: panel_init`，attached ok  
- [ ] **无**依赖 U-Boot smooth 跳过灌码（调屏期）  
- [ ] LCD 出图；分辨率 = `lcd_x×lcd_y`  
- [ ] 背光正常（PWM 或 bl_en）  
- [ ] desk 方向符合 `disp_rotate`  
- [ ] WiFi 仍为基线方案  
- [ ] 兄弟板 DTS **未被**本改动改坏（隔绝自检）

隔绝自检示例：

```bash
rg -n '<PANEL>|pwm.*本板脚' \
  device/config/chips/h133/configs/p1_nor/linux-5.4/board.dts \
  device/config/chips/h133/configs/p1_nor_8733/linux-5.4/board.dts \
  device/config/chips/h133/configs/p1_nor_JYY070/linux-5.4/board.dts
# 期望：无业务匹配（仅允许 config not-set）
```

---

## 6. 无图排查顺序（先硬件后软件）

完整踩坑时间线见：[JL_M101 04-实机调试](../板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/04-实机调试与踩坑.md)

| 优先级 | 查什么 |
|---|---|
| 1 | 屏 VCC / RESET **静态电压是否够 VIH**（分压档错误最常见） |
| 2 | RESET 是否有 **H→L→H 脉冲**（勿外部恒压灌 RESET） |
| 3 | 背光电源与 PWM/EN 是否真打开 |
| 4 | U-Boot 是否仍 `disp_init_enable=1` 导致 smooth 跳过内核 init |
| 5 | 是否加了 DSI 读探针把 DPHY 卡死 |
| 6 | USB/其它节点是否抢走 RESET/PWM 脚 |
| 7 | MIPI CK/DN 是否有 HS（示波器） |

已多次证明「只改 0x11/0x29 GEN↔DCS」或「盲切 burst」**往往不是根因**。

---

## 7. 出图后收尾

1. 写 `H133-AI-Skills/skills/h133-display/board-profile-<BOARD>.md`  
2. 在 `H133-AI-Skills/开发记录/<板型简写>/` 建本板定稿目录（可复制 JL_M101 文档结构）  
3. 需要时再开：触摸、U-Boot logo、gamma/dclk 微调  
4. 干净树可整理 `patches/` + `apply-*.sh`（参考 JL_M101 final）

---

## 8. 与现有记录的关系

| 文档 | 角色 |
|---|---|
| **本文** | 新开任意 MIPI 板的检查清单 |
| [JL_M101 定稿](../板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/) | 800×1280 JD9365DA **参数与补丁** |
| [JL_M101 phase1](../板件开发记录/JL_M101/20260720-JL_M101-JD9365DA-MIPI适配/) | 早期调试流水（干净树优先用定稿 final） |
| [p1_nor_4k 板件新建](../板件开发记录/p1_nor_4k/20260723-p1_nor_4k-板件新建与HDMI4K分离/01-板件新建.md) | 同套克隆手法（HDMI 板，无 LCD panel） |

---

*2026-07-28：据 JL_M101 / 8733 / 4k 板件新建经验整理。*
