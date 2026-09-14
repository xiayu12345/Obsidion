---
project: H133
kind: log
date: 2026-07-28
---

# 如何创建新的 LVDS 板件

| 项 | 内容 |
|---|---|
| 日期 | 2026-07-28 |
| 类型 | **通用操作指南**（非某一块屏的调试流水） |
| 推荐基线 | **`p1_nor_8733`**（WiFi/包选型）再切 LVDS；显示框架对齐 `p1_nor` 异显路径 |
| 范本定稿 | [JYY070 LVDS 显示开发](../板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/README.md) |
| 范本板 | `p1_nor_JYY070`（1024×600 LVDS；UI fb0=1280×800 + DE 缩放） |
| 板级档案 | [board-profile-p1_nor_JYY070.md](../../../skills/h133-display/board-profile-p1_nor_JYY070.md) |

下文占位符：

| 占位 | 含义 | 范例 |
|---|---|---|
| `<BOARD>` | 板级目录名 | `p1_nor_BAR` |
| `<PANEL>` | `lcd_driver_name` | `bar_lvds` |
| `<KCFG>` | Kconfig 后缀 | `BAR_LVDS` |
| `Wp×Hp` | 物理屏分辨率 | 1024×600 |
| `Wf×Hf` | fb0 / UI 画布 | 可与物理相同，或更大（走 DE 缩放） |

---

## 0. 一句话结论

克隆独立板级 → **独立 LVDS panel**（`lcd_if=3`）→ DTS 切 LVDS 时序与 fb0 → **应用层继续走 `rotatefbp + split_fb`**（横屏通常 `disp_rotate=0`）→ 若 UI 设计分辨率 ≠ 物理屏，用 **DE0 VSU 缩放**，不要再写 `fix_lcd` 旁路。

**禁止**改共享 `p1_nor` DTS 迁就本屏；**禁止**复活已废弃的 `fix_lcd_page` 路径。

---

## 1. MIPI 板 vs LVDS 板（先选对路）

| 项 | MIPI 新板 | **LVDS 新板（本文）** |
|---|---|---|
| `lcd_if` | **4**（DSI） | **3**（LVDS） |
| 驱动重点 | 厂商 **init 灌码** + Reset/DSI | **时序 / LVDS 模式 / 上电** |
| UI 旋转典型 | 竖屏 `disp_rotate=3` | 横屏 **`disp_rotate=0`** |
| 视频 WB | 常 **90** | 常 **0** |
| `dual_display_rot` | 常与竖屏策略一致 | 常 **0** |
| 特有风险 | DSI 读探针、RESET 分压、smooth | fb/UI 尺寸不一致、异显绿屏方向 |

MIPI 流程见：[如何创建新MIPI板件](../20260728-如何创建新MIPI板件/README.md)

---

## 2. 开工前准备

| 资料 | 用途 |
|---|---|
| 模组规格书 | `Wp×Hp`、LVDS single/dual、6/8bit、NS/JEIDA、porch、dclk |
| 原理图 | LVDS 差分、背光 EN/PWM、电源时序 |
| UI 约定 | 是否必须 1280×800 画布（JYY070 是）；还是 fb=物理分辨率即可 |
| 触摸 | 报点坐标系要对齐 **fb0**（有缩放时用 `ctp_report_max`，见 [GSL触摸坐标映射](../../GSL触摸坐标映射/README.md)） |

### 选基线

| 基线 | 用途 |
|---|---|
| **`p1_nor_8733`** | 克隆板树 / OpenWrt / **8733BU**（推荐） |
| `p1_nor_JYY070` | **对照**：LVDS DTS、`jyy070_lvds`、DE 缩放、`setting.ini` |
| `p1_nor` | 异显 / sunxifb 框架对照（勿直接在其 DTS 上改业务） |

---

## 3. 克隆板级（与 MIPI 相同套路）

克隆命令骨架与 [MIPI 指南 §2](../20260728-如何创建新MIPI板件/README.md) / [JL_M101 01](../板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/01-板件新建.md) 相同，把 `BOARD` 换成你的 LVDS 板名即可。

要点再强调：

1. `cp -a p1_nor_8733 → <BOARD>`  
2. **拆** `linux-5.4`（及 uboot/fex 若软链）为实目录  
3. `cp -a h133-p1_nor_8733 → h133-<BOARD>`，改 defconfig / vendorsetup / lunch  
4. `tools/build_<BOARD>.sh`  
5. panel Kconfig / panels.c / 兄弟板 `not set` / `libtmedia` 挂钩  

### LVDS 板工厂 ini / 视频宏（横屏典型）

| 项 | JYY070 定稿 | 新板默认建议 |
|---|---|---|
| `disp_rotate` | **0** | 横屏 LVDS → **0** |
| `tp_rotate` | **0**（内核已做映射时勿再软旋 180） | 跟触摸方案，单独验证 |
| `VIDEO_WB_MIRROR_ROTATE` | **0** | 横屏 → **0** |
| `dual_display_rot` | **0** | 与 HDMI 异显方向一起验 |

三路旋转**独立**（UI / 触摸 / 视频），勿混用一个宏。详见 JYY070 board-profile。

---

## 4. 写独立 LVDS panel 驱动

范本：[01-kernel-panel](../板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/01-kernel-panel驱动.md)、[02-uboot-panel](../板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/02-uboot-panel启动logo.md)

| 侧 | 路径 |
|---|---|
| 内核 | `kernel/.../lcd/<PANEL>.c` + `.h` |
| U-Boot | `brandy/.../lcd/<PANEL>.c`（logo 需要则同步） |

相对 MIPI：

- 通常**没有**大段 DSI init 表；重点是 `LCD_cfg_panel_info` 填时序、`open_flow` 上电/背光顺序  
- 名字必须等于 DTS `lcd_driver_name`  
- 本板 `config-5.4`：`CONFIG_LCD_SUPPORT_<KCFG>=y`；可关掉无关 MIPI panel（按需）

---

## 5. DTS：MIPI → LVDS

范本：[03-DTS切换LVDS](../板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/03-DTS切换LVDS.md)

### 5.1 lcd0 骨架

```dts
&lcd0 {
	lcd_used            = <1>;
	lcd_driver_name     = "<PANEL>";
	lcd_if              = <3>;          /* LVDS（注释：0 hv / 3 lvds / 4 dsi） */
	lcd_x               = <Wp>;
	lcd_y               = <Hp>;
	lcd_dclk_freq       = <NN>;

	lcd_hspw = <…>; lcd_hbp = <…>; lcd_ht = <…>;
	lcd_vspw = <…>; lcd_vbp = <…>; lcd_vt = <…>;

	lcd_lvds_if         = <0>;          /* 0:single  1:dual */
	lcd_lvds_colordepth = <0>;          /* 0:8bit  1:6bit —— 跟屏 */
	lcd_lvds_mode       = <0>;          /* 0:NS  1:JEIDA —— 跟屏 */

	/* 背光 / 电源 GPIO：按原理图；PWM 则配 lcd_pwm_* */
	/* pinctrl：LVDS 脚组，不要再绑 dsi4lane */
};
```

内核与 **uboot-board.dts** 的 lcd0 / disp **同步**（logo 策略可单独关 `disp_init_enable`）。

### 5.2 disp / fb0：两条路线

**路线 A — fb = 物理分辨率（先点亮）**

```dts
fb0_width  = <Wp>;
fb0_height = <Hp>;
```

验收：`/dev/fb0` = `Wp×Hp`，有 fbcon/企鹅即可。适合新屏 bring-up 第一步。

**路线 B — UI 画布更大，DE 硬件缩放（JYY070 定稿）**

范本：[07-DE硬件缩放](../板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/07-DE硬件缩放1280x800.md)

```dts
/* lcd0 仍写物理 Wp×Hp */
fb0_width  = <Wf>;   /* 如 1280 */
fb0_height = <Hf>;   /* 如 800 */
```

数据流：

```text
LVGL / desk（Wf×Hf）→ fb0（Wf×Hf）→ DE0 VSU → LVDS 物理 Wp×Hp
```

- **不要**依赖注释里的 `fb0_scaler_mode_enable`（内核无对应实现）  
- crop ≠ frame 时 DE 自动缩放  
- 触摸 `ctp_report_max` 应对齐 **Wf×Hf**（JYY070：1280×800；机制见 [GSL触摸坐标映射](../../GSL触摸坐标映射/README.md)）

### 5.3 HDMI 异显

范本：[05-dual_display_rot](../板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/05-HDMI异显dual_display_rot.md)

横屏 LVDS：`dual_display_rot = <0>`。内核写死 G2D 旋转会导致 HDMI 全绿/方向错——必须可配，且本板显式写 0。三路改法：[显示旋转](../../显示旋转/README.md)。

---

## 6. 应用层：统一 sunxifb 路径

范本：[00-背景与路径统一](../板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/00-背景与路径统一.md)、[04-app层](../板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/04-app层与sunxifb统一路径.md)

| 要求 | 说明 |
|---|---|
| 框架 | **`rotatefbp + split_fb`**，与 `p1_nor` 同构 |
| `disp_rotate=0` | LCD 页走 **直拷贝**（`SUNXIFB_ROT_0`），不是 fix_lcd |
| `disp_rotate=3` | 仅当该 LVDS 板仍要竖屏软转时才用（少见） |
| 废弃 | `fix_lcd_page` / 旧 bringup `04-app-sunxifb` 旁路补丁 **勿混打** |

改 sunxifb 后必须重编对应 app 包（如 `lv_projector` / desk），只烧内核不够。

---

## 7. 编译与验收

```bash
./tools/build_<BOARD>.sh kernel
./tools/build_<BOARD>.sh full
# 产物：out/h133_linux_<BOARD>_uart0_nor.img
```

| 阶段 | 期望 |
|---|---|
| panel + DTS 路线 A | fb0=`Wp×Hp`，屏亮、分辨率对 |
| DE 缩放路线 B | `fbset` 为 `Wf×Hf`；`sys` 里 crop=画布、frame=物理 |
| desk | log：`fb WfxHf -> LVGL …`，`sunxifb_rot=0`（横屏） |
| HDMI 异显 | 方向正确，无全绿 |
| WiFi | 仍 8733BU（若基线如此） |
| 隔绝 | 未改 `p1_nor` / `8733` / `JL_M101` 业务 DTS |

隔绝自检：

```bash
rg -n '<PANEL>' device/config/chips/h133/configs/p1_nor{,_8733,_JL_M101}/linux-5.4/board.dts
# 期望：无匹配
```

更多串口验收项见：[06-编译与实机验证](../板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/06-编译与实机验证.md)

---

## 8. 常见坑

| 现象 | 优先查 |
|---|---|
| 屏不亮 / 花屏 | `lcd_lvds_mode` NS/JEIDA、6/8bit、lane single/dual、时序 |
| 企鹅闪 / desk 无图 | 是否误走 fix_lcd；`disp_rotate` 与 sunxifb 分支是否匹配 |
| HDMI 绿/歪 | `dual_display_rot` |
| 改了 sunxifb 无效 | 未重编 lv_projector/desk |
| 触摸整体反了 | `tp_rotate` 与内核 `ctp_revert_*` **叠乘** |
| 视频小窗方向错 | `VIDEO_WB_MIRROR_ROTATE`（不读 ini） |
| UI 糊 / 比例怪 | fb 与 `lcd_x/y` 是否故意缩放；勿只改一个 |

---

## 9. 推荐实施顺序

```text
1. 克隆板级 + 公共挂钩 + build 脚本
2. 独立 <PANEL>.c（内核；U-Boot 可后补）
3. DTS 切 LVDS，fb0=物理分辨率 → 确认硬件出图
4. setting.ini disp_rotate=0；确认 sunxifb 统一路径
5. （可选）fb0 提到 UI 画布 + DE 缩放
6. dual_display_rot / 视频 WB / 触摸坐标系
7. board-profile + 本板开发记录目录 + 补丁归档
```

---

## 10. 与现有记录的关系

| 文档 | 角色 |
|---|---|
| **本文** | 新开任意 LVDS 板的检查清单 |
| [JYY070 LVDS 显示开发](../板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/) | 1024×600 + DE 缩放 + 异显 **定稿步骤与补丁** |
| [JYY070 板级索引](../板件开发记录/JYY070/README.md) | WiFi / 触摸 / 音频等后续项 |
| [如何创建新MIPI板件](../20260728-如何创建新MIPI板件/README.md) | 对照：克隆套路相同，显示接口不同 |

---

*2026-07-28：据 JYY070 LVDS 定稿 + 板件隔绝实践整理。*
