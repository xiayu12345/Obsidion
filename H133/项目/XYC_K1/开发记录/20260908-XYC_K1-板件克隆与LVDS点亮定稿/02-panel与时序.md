# 02 — Panel 驱动与时序

## 2.1 文件与注册

| 侧 | 路径 |
|---|---|
| 内核 | `kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/xyc_k1_lvds.c` |
| 内核头 | 同目录 `xyc_k1_lvds.h` |
| U-Boot | `brandy/.../disp/lcd/xyc_k1_lvds.c`（逻辑与内核一致） |

注册：`panels.c` / `panels.h` 在 `CONFIG_LCD_SUPPORT_XYC_K1_LVDS` 下加入 `panel_array`。  
**名字必须与 DTS `lcd_driver_name` 完全一致：** `"xyc_k1_lvds"`。

LVDS 无 DCS 灌码，`LCD_panel_init` 为空。

---

## 2.2 open_flow（定稿）

```text
pin_cfg → tcon_enable（200ms）→ sunxi_lcd_backlight_enable
```

| 做 | 不做 |
|---|---|
| `sunxi_lcd_pin_cfg` | **`panel_reset`**（无 `lcd_gpio_0` 时会踩 gpio0，TCON0 停 vsync → HDMI 全绿） |
| `tcon_enable` 后再开背光（AT13：valid data → 背光 ≥200ms） | `pwm_enable`（定稿不走 PWM） |
| `LCD_bl_open` → `sunxi_lcd_backlight_enable`（拉 `lcd_bl_en`） | 把 PB11 当 LVDS RST |

---

## 2.3 时序来源

屏型号 **LTN141AT0-001**（无单独规格书；同系列 AT01/AT02/AT13）。

AT13 typ：

| 项 | 规格 | 定稿 DTS |
|---|---|---|
| 分辨率 | 1280×800 | 1280×800 |
| 刷新 | 60Hz | 60Hz |
| fDCLK | 69.3MHz（68.3–70.3） | **69** |
| TH | 1416 | `lcd_ht=1416` |
| TV | 816 | `lcd_vt=816` |
| 接口 | LVDS 1ch 6-bit DE-only | `lvds_if=0` `colordepth=1` `frm=1` |

厂商原始 fex 曾用 dclk=67、ht=1380、vt=814，67 略低于规格下限；**定稿跟规格 typ**。极性未配（等画面再调）。
