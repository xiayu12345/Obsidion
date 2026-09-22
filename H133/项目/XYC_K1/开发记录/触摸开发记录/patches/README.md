从仓库根目录 `patch -p1` 应用，基线是尚未合入触摸改动的工程（TWI1 仍是 GSL `ctp@40`）。补丁路径是 `p1_nor_XYC_K1`。`0006` 还要求工程里已有 `hy_app` launcher。

| 补丁 | 说明 |
|------|------|
| `0001-kernel-add-betterlife-BL3676-driver.patch` | 新增驱动。`betterlife-touch`、关调试 / ESD / debugfs，IRQ 每次只读一次 |
| `0002-kernel-enable-Betterlife-disable-GSL.patch` | 开 Betterlife、关 GSL（保留 `EXTRA_FIRMWARE` gsl 文件，无害） |
| `0003-board.dts-replace-GSL3670-with-BL3676.patch` | TWI1：`ctp@40` → `betterlife_ts@2c`，保留 DMA 通道 44 |
| `0004-userspace-recognize-betterlife-touch.patch` | `input_symlink.sh` 认 `*betterlife*`；**不改** evdev 协议解析 |
| `0005-evdev-O_CLOEXEC-and-fd-guard.patch` | `open` 加 `O_CLOEXEC`；`evdev_fd < 0` 回 REL；`liblvgl` `PKG_RELEASE` 5→7。**不再** `EVIOCGRAB` |
| `0006-app-side-touch-pierce-guard.patch` | `hy_app` 子应用返回全屏挡板；切页禁输入 100ms；`huiyin_ktv` 回桌面 `sleep(1)` |

工作树已经合过后再打会提示 already applied。`0003` 不要用整份 `board.dts` 的 diff。

旧文件 `0005-evdev-EVIOCGRAB-child-of-desk.patch` 已作废，不要再打。liblvgl 级 grab 会让 `hy_app` 再拉 `xyc_mix` 时报 `EVIOCGRAB: Device or resource busy`。
