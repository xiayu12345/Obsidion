# 补丁说明

在 [20260918 独立板件](../../20260918-H133-JL-HXR101-新建板件/patches/) 已经合入、屏驱仍是群创码 `jl_hxr_ili9881c` 的树上，换成厂商 N91 发码 `jl_hxr_n91`。

不改 `p1_*_JL_M101`。09-28 曾临时在 NOR M101 上试屏，点亮后已退回 JD9365DA。

在 SDK 根目录：

```bash
bash AI-skiil/板件开发记录/JL_HXR101/20260928-H133-JL-HXR101-N91屏驱/patches/apply.sh
```

当前 AI-tq 工作区已经合入，再 apply 会 skip 已打过的 hunk，并重写 HXR 板的 lcd 为 N91。

| 文件 | 作用 |
|---|---|
| [files/](./files/) | kernel / U-Boot `jl_hxr_n91.{c,h}` |
| [01-register-jl_hxr_n91.patch](./01-register-jl_hxr_n91.patch) | 注册 `LCD_SUPPORT_JL_HXR_N91`；NOR / eMMC U-Boot defconfig 打开 |

`apply.sh` 另外把 `p1_nor_JL_HXR101`、`p1_emmc_JL_HXR101` 的 `lcd_driver_name` 改成 `jl_hxr_n91`，时序改成 N91 porch，`lcd_dclk_freq=47`，并在两块板的内核配置里打开 `CONFIG_LCD_SUPPORT_JL_HXR_N91`。

资料：`AI-skiil/硬件资料/四川京龙/HXR10106B28/`（与 `新建文件夹/` 同一份规格书和 `N91ILI9881最新版本.txt`）。

打完后：

```bash
./tools/build_p1_nor_JL_HXR101.sh kernel
./tools/build_p1_emmc_JL_HXR101.sh kernel
```
