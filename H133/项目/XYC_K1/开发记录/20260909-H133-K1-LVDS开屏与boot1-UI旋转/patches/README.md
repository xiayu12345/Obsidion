# 补丁说明

相对当前工程 `p1_nor_XYC_K1` / `xyc_k1_lvds` 的 git diff。汇音基线里这块板还叫 `p1_nor_JL_M101`、屏驱还叫 `jl_m101_jd9365da`；要在干净汇音树上打这些补丁，须先完成板件改名和屏驱改名。当前 AI-tq 工作区已经改过。

在 SDK 根目录按序 apply：

```bash
bash AI-skiil/板件开发记录/XYC_K1/20260909-H133-K1-LVDS开屏与boot1-UI旋转/patches/apply.sh
```

或：

```bash
git apply --check AI-skiil/板件开发记录/XYC_K1/20260909-H133-K1-LVDS开屏与boot1-UI旋转/patches/0*.patch
git apply AI-skiil/板件开发记录/XYC_K1/20260909-H133-K1-LVDS开屏与boot1-UI旋转/patches/0*.patch
```

当前 AI-tq 工作区若已经改过这些文件，再 apply 会冲突，以工作区为准。

| 文件 | 作用 |
|---|---|
| [01-kernel-uboot-lvds-panel.patch](./01-kernel-uboot-lvds-panel.patch) | 开屏驱收成电源/PWM helper；09-09 曾改 `de_lcd.c` 写 TCON 极性 |
| [02-board-dts-k1-lvds.patch](./02-board-dts-k1-lvds.patch) | 板级 dts（含 PB10 LCD-EN）；09-09 含 `lcd_lvds_io_polarity=0x1f` |
| [03-uboot-nor-boot1-size.patch](./03-uboot-nor-boot1-size.patch) | NOR U-Boot 体积 |
| [04-ui-rotate-landscape.patch](./04-ui-rotate-landscape.patch) | UI / 视频窗 0° |
| [05-drop-lvds-io-polarity.patch](./05-drop-lvds-io-polarity.patch) | **09-11**：去掉 dts 极性和 `de_lcd.c` 极性补丁 |

H133 编的是 `de_lcd_sun50iw10.c`，不读 dts 极性，且 `LVDS_REVERT` 未开。板上不配 `lcd_lvds_io_polarity` 也能亮，所以用 `05` 清掉。

已打过 09-09 `01`–`04` 的树只补 `05`。干净树五张按序打完即当前定稿。不要再打 `disp_rotate=2`。

打完后：`./tools/build_p1_nor_XYC_K1.sh kernel`，再编 rootfs + `pack`。改 ini 后确认 squashfs 里 `/etc/setting.ini` 的 `disp_rotate = 0`。
