---
project: JL_M101
kind: log
date: 2026-07-22
---

# 02 — Panel 驱动与京龙 init

## 2.1 文件与注册

| 侧 | 路径 |
|---|---|
| 内核 | `kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/jl_m101_jd9365da.c` |
| 内核头 | 同目录 `jl_m101_jd9365da.h`（导出 `jl_m101_jd9365da_panel`） |
| U-Boot | `brandy/.../disp/lcd/jl_m101_jd9365da.c`（init 策略与内核一致） |

注册：`panels.c` / `panels.h` 在 `CONFIG_LCD_SUPPORT_JL_M101_JD9365DA` 下加入 `panel_array`。  
**名字必须与 DTS `lcd_driver_name` 完全一致：** `"jl_m101_jd9365da"`。

## 2.2 Init 来源

厂商文件（树内）：

`H133-AI-Skills/硬件资料/四川京龙/C-JD9365DA-H3_BOE10.1WXGA_IPS（B4TV101WXU-N91）_800x1280_FP7721BX2_column_20210830 (1)(1).txt`

要点：

- 表头 porch / `PLL_CLOCK=420`（MTK 口径；Allwinner 用 DTS `lcd_*` + `dclk`，不照搬 PLL）
- `{0x80,1,{0x03}}` → 四 lane
- `{REGFLAG_DELAY, ms, {}}` / `{REGFLAG_END_OF_TABLE,0x00,{}}`
- Sleep Out / Display On：`{0x11,1,{0x00}}`、`{0x29,1,{0x00}}`（厂商表如此；本驱动统一 `dsi_gen_wr`，不特判 DCS）

转换规则（工程内已落实）：

- `REGFLAG_DELAY` / `REGFLAG_END_OF_TABLE` 按 **cmd 字段**判断（`0xFC` / `0xFD`）
- 其余行：`dsi_gen_wr(sel, cmd, para, count)`
- **硬 reset 后直接发页命令，无 soft reset**

## 2.3 Reset 时序（vendor）

```text
LCD_nReset = 1; Delay 5ms;
LCD_nReset = 0; Delay 10ms;
LCD_nReset = 1; Delay 120ms;
→ 再发 init 表（表首另有 REGFLAG_DELAY 10）
```

代码（`LCD_power_on`）：

```c
sunxi_lcd_pin_cfg(sel, 1);
sunxi_lcd_delay_ms(50);
panel_reset(sel, 1);  sunxi_lcd_delay_ms(5);
panel_reset(sel, 0);  sunxi_lcd_delay_ms(10);
panel_reset(sel, 1);  sunxi_lcd_delay_ms(120);
```

`panel_reset` → `sunxi_lcd_gpio_set_value(sel, 0, val)`，对应 DTS **`lcd_gpio_0` = PB11**。

## 2.4 open_flow / close_flow（定稿）

```text
open:  power_on → panel_init → tcon_enable → bl_open
close: bl_close → tcon_disable → panel_exit → power_off
```

- `LCD_panel_init`：`dsi_clk_enable` → delay 20ms → 扫 init 表  
- `LCD_bl_open`：`sunxi_lcd_pwm_enable`（PWM 参数见 DTS）  
- `LCD_panel_exit`：DCS `0x28` / `0x10` 关显示进 sleep  

调通信阶段曾临时去掉 `bl_open`、用外部 VLED 供电；**出图定稿已恢复板载 PWM 背光**。

## 2.5 禁止项（踩过的坑）

| 禁止 | 原因 |
|---|---|
| 在 `panel_init` 里 `dsi_dcs_read` 探针 | 屏不回读时 DPHY 卡读态；后续 `dsi_gen_wr` 内 `while(dsi_inst_busy)` **无超时** → `panel_init` 挂死 |
| 改 `default_panel.c` 塞京龙码 | 污染其它板 |
| 把 `0x11/0x29` 盲改 DCS/GEN 当根因 | 实机证明非根因；根因在 RESET 电平 / 物理层 |

## 2.6 内核 / U-Boot 同步

- init 表、Reset、open_flow：**两侧保持一致**  
- 当前 U-Boot：`uboot-board.dts` 中 **`disp_init_enable=<0>`**，bootGUI 不抢先开屏，避免内核 **smooth display** 跳过 `cfg_open_flow`  
- 出图稳定后若要恢复 U-Boot logo：开 `disp_init_enable`，并确认 smooth 与灌码策略（见 [04](./04-实机调试与踩坑.md)）
