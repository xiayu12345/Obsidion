# 02 — Panel 驱动与时序

## 2.1 文件与注册

| 侧 | 路径 |
|---|---|
| 内核 | `kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/lcd/scrtest_ili79600a.c` |
| U-Boot | `brandy/.../disp/lcd/scrtest_ili79600a.c` |

名字必须与 DTS 完全一致：`"scrtest_ili79600a"`。

灌码：厂商 `TEST_79600A_…DSC oFF` REGISTER 表 → `dsi_gen_wr`（GENERIC）。**不做 DSI 读**。TDDI / `.ili` 不在本驱动。

RESET：`lcd_gpio_0=PB11`。背光：`pwm_enable` + `backlight_enable`（PWM0）。

---

## 2.2 Allwinner porch 公式

手册：`lcd_hbp = 实际 HBP + HSPW`，`lcd_ht = x + lcd_hbp + HFP`（V 同理）。

厂家 HSA=2 **不能**当 `lcd_hspw`。U-Boot `de_dsi.c`：

```text
dsi_hsa = hspw × 24 / 8 − 10 = hspw × 3 − 10
```

`hspw=2` → 负数回绕，卡在 `boot_gui_init`。定稿 **hspw=4**（最小合法），实际 HBP/HFP 仍是 20 → `hbp=24`、`ht=1244`。

垂直：VSA2 VBP64 VFP270 → `vspw=2 vbp=66 vt=2256`（与原厂一致）。

---

## 2.3 时钟（dts 不是实际像素钟）

见 [00](./00-总览与定稿.md) §3。定稿 dts **110** → 实际 ≈165MHz。  
全志 LCD 指南文件名是 `Linux_CCU_开发指南.pdf`（标题 Linux LCD）。`H13x开发文档` 是 I2S，帮不上 DSI。
