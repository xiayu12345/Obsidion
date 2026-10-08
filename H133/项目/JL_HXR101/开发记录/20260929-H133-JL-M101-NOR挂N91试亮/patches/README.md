# 补丁说明

给**没有** `jl_hxr_n91` 源码的树用。对方只要有京龙 NOR（`p1_nor_JL_M101`，屏驱仍是 `jl_m101_jd9365da`），在 SDK 根目录执行：

```bash
bash AI-skiil/板件开发记录/JL_HXR101/20260929-H133-JL-M101-NOR挂N91试亮/patches/apply.sh
./tools/build_p1_nor_JL_M101.sh kernel
```

把整个 `20260929-H133-JL-M101-NOR挂N91试亮` 目录拷过去。只发 `01-*.patch` 不够，那份里面没有驱动。

`apply.sh` 会做这些事：

| 步骤 | 内容 |
|---|---|
| 装源码 | 内核、U-Boot 的 `jl_hxr_n91.c` / `.h`，来自 [files/](./files/) |
| 注册 | `Kconfig`、`Makefile`、`panels.c`、`panels.h`，挂在已有的 `JL_M101_JD9365DA` 后面 |
| 打开配置 | U-Boot `sun8iw20p1_defconfig`（以及 nor / auto_nor）、本板 `bsp_defconfig` 和 `config-5.4` 写上 `CONFIG_LCD_SUPPORT_JL_HXR_N91=y` |
| 改屏 | 本板内核和 U-Boot 设备树改成 `jl_hxr_n91`，`lcd_dclk_freq=47`，背光 15，N91 porch |

不改 eMMC M101，也不改两块 HXR 板。`JD9365DA` 的配置保持打开，`tools/build_p1_nor_JL_M101.sh` 里的 U-Boot 检查还能过。实际点哪块屏看 `lcd_driver_name`。

设备树按当前京龙 NOR 的 JD9365DA 段来替换（`dclk=70`，`vbp=24`，`vt=1324`）。这段如果已经被改过，脚本会停下来。

编完烧录，U-Boot 日志应出现 `jl_hxr_n91: panel_init`。

[01-p1_nor_JL_M101-jl_hxr_n91.patch](./01-p1_nor_JL_M101-jl_hxr_n91.patch) 只是设备树差异，方便看改了什么。入口是 `apply.sh`。
