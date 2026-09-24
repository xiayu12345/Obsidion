# 补丁说明

相对已经有 `p1_nor_JL_M101` / `p1_emmc_JL_M101`（屏驱仍是 `jl_m101_jd9365da`）、且 `build/pack` 只给这两块京龙板覆盖竖屏 logo 的树。

板级目录 `p1_{emmc,nor}_JL_HXR101/` 和 OpenWrt target **不是 unified diff**：`apply.sh` 从对应 JL 板整树复制后再改 lcd / `LCD_SUPPORT` / 固件路径。和 [20260915 eMMC](../../20260915-H133-JL-M101-eMMC/patches/README.md) 一样。

在 SDK 根目录：

```bash
bash AI-skiil/板件开发记录/JL_HXR101/20260918-H133-JL-HXR101-新建板件/patches/apply.sh
```

当前 AI-tq 工作区已经合入，再 apply 会 skip 已打过的 hunk、keep 已有板件。

| 文件 | 作用 |
|---|---|
| [files/](./files/) | kernel/U-Boot `jl_hxr_ili9881c.{c,h}`；`tools/build_p1_{emmc,nor}_JL_HXR101.sh` |
| [01-kernel-uboot-hxr-panel.patch](./01-kernel-uboot-hxr-panel.patch) | 注册 `LCD_SUPPORT_JL_HXR_ILI9881C`；eMMC/NOR U-Boot defconfig 打开 |
| [02-pack-libtmedia-readme.patch](./02-pack-libtmedia-readme.patch) | pack 覆盖 HXR 竖屏 logo；NOR HXR `VIDEO_WB_MIRROR_ROTATE=90`；lunch 表 |

`apply.sh` 另外会：复制板件和 OpenWrt target、把 lcd 改成 AIKTV 时序（`dclk=49`）、给其它板 `LCD_SUPPORT_JL_HXR` / `CONFIG_TARGET_*_JL_HXR101` 写 `is not set`。

**不改：** `jl_m101_jd9365da.c`、ILI9881C 屏驱、GSL 固件内容、K1。

打完后：

```bash
./tools/build_p1_emmc_JL_HXR101.sh kernel
./tools/build_p1_nor_JL_HXR101.sh kernel
```
