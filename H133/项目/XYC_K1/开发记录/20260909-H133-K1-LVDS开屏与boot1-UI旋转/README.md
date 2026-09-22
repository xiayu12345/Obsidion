# H133-K1 LVDS 开屏 / NOR boot1 / UI 横屏 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-09；2026-09-11 去掉未生效的 LVDS 极性 |
| 工程 | `/root/Work/AI-tq`（lunch：`h133-p1_nor_XYC_K1-tina`） |
| 板型 | `p1_nor_XYC_K1`，硬件 **H133-K1**（`h133-k1-v0_0825`）；2026-09-11 由 `p1_nor_JL_M101` 改名 |
| 屏 | 厂 LVDS **1280×800**（单路 6bit NS）；开屏驱 `xyc_k1_lvds` / `CONFIG_LCD_SUPPORT_XYC_K1_LVDS` |
| 状态 | 已出镜像；UI 0°；boot1 已压进 NOR 上限；**不配** `lcd_lvds_io_polarity` |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |

## 一句话

K1 走 LVDS，不再发 MIPI init；时序抄厂 fex，背光按原理图 PB12/PWM0；NOR U-Boot 必须只留本屏否则 PhoenixSuit 烧 boot1 失败；横屏后 `disp_rotate=0`。H133 实际编的是 `de_lcd_sun50iw10.c`，dts 极性写了也不会进 TCON，已用 `05` 从补丁链路拿掉。

## 补丁顺序（干净树）

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/XYC_K1/20260909-H133-K1-LVDS开屏与boot1-UI旋转/patches/apply.sh
```

| 文件 | 内容 |
|---|---|
| `01-kernel-uboot-lvds-panel.patch` | 内核+U-Boot 开屏驱精简（09-09 曾改 `de_lcd.c` 写极性） |
| `02-board-dts-k1-lvds.patch` | `board.dts` / `uboot-board.dts`：LVDS 时序、LCD-EN=PB10、PWM0；09-09 含 `lcd_lvds_io_polarity=0x1f` |
| `03-uboot-nor-boot1-size.patch` | `sun8iw20p1_nor_defconfig` 关掉默认 y 屏驱，boot1 不超 logical |
| `04-ui-rotate-landscape.patch` | `setting.ini` + `LV_ORIENT_DEFAULT_*` 改为 0° / 1280×800 |
| `05-drop-lvds-io-polarity.patch` | **09-11**：去掉 dts 极性和 `de_lcd.c` 极性补丁 |

**不含** Betterlife TP、`bsp_defconfig`、`evdev.c`。

已打过 09-09 的 `01`–`04`、工作区 dts 里还有 `lcd_lvds_io_polarity` 时，只补打 `05`。干净树五张按序打完。

## 产物

`out/h133_linux_p1_nor_XYC_K1_uart0_nor.img`

| 日期 | md5 |
|---|---|
| 2026-09-09 12:06 | `90b6b33c47701fa5ecb0738306375794` |
| 2026-09-11 10:59（当前） | `63c68c109885e55e09779285d2974de2` |
