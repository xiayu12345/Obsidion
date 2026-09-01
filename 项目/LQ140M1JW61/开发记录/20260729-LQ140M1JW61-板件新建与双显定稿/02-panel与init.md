---
project: LQ140M1JW61
kind: log
date: 2026-07-29
---

# 02 — panel 与 init

## 1. 文件

| 侧 | 路径 |
|---|---|
| 内核 | `kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/lq140_mipi2edp.c/.h` |
| U-Boot | `brandy/.../disp/lcd/lq140_mipi2edp.c/.h` |
| 注册名 | `lq140_mipi2edp` ↔ DTS `lcd_driver_name` |

Kconfig 帮助文案：`Sharp LQ140M1JW61 1920x1080 eDP through QE01MIPI001-V01 (SoC MIPI)`。

---

## 2. open_flow（定稿）

```text
power_on → panel_init → tcon_enable → bl_open
```

要点：

- **RST=PB11**，**LCD-PWM=PB12/PWM0**；本板 **不控 BL-EN（PG15）**。
- `panel_init`：**不发 DCS**；打日志后 `sunxi_lcd_dsi_clk_enable` + 短延时。
- 日志可见：`lq140_mipi2edp: panel_init dsi_clk_enable (no DCS)`。

```c
/* 占位 init；有厂商表后再填，勿加 DSI 读命令。 */
pr_info("lq140_mipi2edp: panel_init dsi_clk_enable (no DCS)\n");
sunxi_lcd_dsi_clk_enable(sel);
```

桥片若后续提供完整 init 表：只增写命令，**禁止**加 DSI 读回（易卡死/超时）。

---

## 3. 与 JD9365 类 panel 的差异

| 项 | JD9365（JL_M101） | **LQ140 桥片** |
|---|---|---|
| 灌码 | 必须 DCS init | **通常无需 DCS** |
| 时钟 | tcon + DSI | **必须显式 `dsi_clk_enable` 再推 Video** |
| 分辨率 | 800×1280 | **1920×1080** |

---

## 4. 编入方式

与工程其它 panel 一致：`CONFIG_LCD_SUPPORT_LQ140_MIPI2EDP` **default y** 可同时编进内核；运行时靠本板 DTS 选名。兄弟板 `config-5.4` 写 `not set` 即可缩小无关板镜像体积（按板策略）。
