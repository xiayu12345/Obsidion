---
project: LQ140M1JW61
kind: log
date: 2026-07-29
---

# 03 — DTS 与双显

## 1. lcd0（内核 `board.dts`）

| 项 | 值 |
|---|---|
| `lcd_used` | 1 |
| `lcd_driver_name` | `lq140_mipi2edp` |
| `lcd_if` | 4（DSI） |
| `lcd_x/y` | 1920 / 1080 |
| `lcd_dclk_freq` | **139**（实机定稿；**禁止**改 93「补偿」） |
| `lcd_hbp/ht/hspw` | 112 / 2080 / 32 |
| `lcd_vbp/vt/vspw` | 27 / 1110 / 5 |
| `lcd_dsi_lane` | 4 |
| `lcd_dsi_if` | 0（video） |
| PWM | `lcd_pwm_ch=0`，50kHz |

U-Boot `uboot-board.dts` 侧 lcd0 与上述对齐；**`disp_init_enable=0`**（调屏期关 U-Boot 开屏，避免 smooth）。

---

## 2. disp / 双显

| 项 | 值 | 说明 |
|---|---|---|
| `screen0_output_type` | 1（LCD） | 主屏 |
| `screen1` / HDMI | type/mode 按板（HDMI 1080p） | 副屏 |
| `fb0_width/height` | **1280 / 800** | UI/LVGL；**勿**改回与 lcd 同尺寸（双 1080p 压力） |
| `lcd_x/y`（lcd0） | **1920 / 1080** | 物理出屏；DE0 `screen_win` 据此放大 layer |
| `chn_cfg_mode` | **1** | 双显通道配置 |
| `dual_display_rot` | **0** | HDMI 抓帧不旋转 |

注释约定：UI 1280×800 → DE0 放大到 lcd 1080p；HDMI WB 跟 `mgr0` 设备分辨率（1080p），与 UI `disp_rotate=0` 对齐。

---

## 3. 旋转链路（全部为 0）

| 链路 | 定稿 |
|---|---|
| UI `disp_rotate` / desk `sunxifb_rot` | **0** |
| `tp_rotate` | **0** |
| `dual_display_rot` | **0** |
| `VIDEO_WB_MIRROR_ROTATE` | **0** |

验收日志应类似：

```text
[DISP] dual display enabled: 1920x1080 … (dual_display_rot=0)
[desk] fb 1280x800 -> LVGL 1280x800, sunxifb_rot=0 tp_rotate=0
```

→ **LCD：软件不旋转；UI 1280×800 由 DE0 放大到面板。HDMI：WB 仍为 DE0 出屏 1080p。**

---

## 4. env / CMA

| 文件 | 项 |
|---|---|
| `env.cfg` / `bsp/env.cfg` | `cma=8M` |

曾试 `16M`；**实机确认 `8M` 双显显示无问题，定稿保持 8M**。启动仍核对 cmdline / `cma: Reserved …` 与源一致即可。

---

## 5. 像素钟注意

- DTS **写 139**（真实 EDID 量级），U-Boot / 内核两份对齐。
- 勿因 `lcd_clk_config` 打印 `dclk real≈207` 就改成 93：实机 **93 显示差、139 显示好**。
- 完整踩坑（为何会想到 93、为何日志误导）见 `04` §5。
