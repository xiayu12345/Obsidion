本目录是 H133-K1 / `p1_nor_XYC_K1` 把 GSL3670 换成 Betterlife BL3676 的触摸开发归档。2026-09-11 板件由 `p1_nor_JL_M101` 改名。

- 记录：`开发记录.md`（厂家驱动原样 + TWI1 DMA；协议解析不改 evdev；点穿改应用侧挡，liblvgl 不再 `EVIOCGRAB`）
- 补丁：`patches/`（从仓库根 `patch -p1`）
- 厂家资料：`AI-skiil/硬件资料/鑫宇宸/`（`betterlife_ts.7z`、BL3676 规格书、H133-K1 原理图）
- 同 SDK 对照：`AI-skiil/板件开发记录/XYC_K1/20260908-XYC_K1-BL3676触摸适配`

定稿要点：关 `BTL_DEBUG_SUPPORT`；IRQ 每次只读一次；节点 `betterlife_ts@2c`；本板 TWI1 用 DMA 通道 44；报点解析跟厂家源码，不要跟规格书时序图硬改。点穿：不要在 `evdev_set_file()` 里 `EVIOCGRAB`，不要 `wait_release` / 关桌面 fd。当前由 `hy_app` 全屏挡板和切页禁输入处理，见开发记录第 9 节。
