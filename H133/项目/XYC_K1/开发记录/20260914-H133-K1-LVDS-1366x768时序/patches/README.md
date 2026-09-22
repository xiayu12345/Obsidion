# 补丁说明

相对 **已经是** `p1_nor_XYC_K1` / `xyc_k1_lvds` / **1280×800** 的工程（09-09 开屏定稿之后）。不要打在还没改成 K1 LVDS 的树上。

在 SDK 根目录：

```bash
bash AI-skiil/板件开发记录/XYC_K1/20260914-H133-K1-LVDS-1366x768时序/patches/apply.sh
```

或：

```bash
cd /root/Work/AI-tq
patch -p1 --forward < AI-skiil/板件开发记录/XYC_K1/20260914-H133-K1-LVDS-1366x768时序/patches/01-board-dts-1366x768.patch
patch -p1 --forward < AI-skiil/板件开发记录/XYC_K1/20260914-H133-K1-LVDS-1366x768时序/patches/02-setting-ini-1366x768.patch
```

当前 AI-tq 工作区已经合入这些改动，再 apply 会提示 already applied。

| 文件 | 作用 |
|---|---|
| [01-board-dts-1366x768.patch](./01-board-dts-1366x768.patch) | 内核 / U-Boot `lcd0` 时序 + `fb0` 改成 1366×768；旧 1280×800 用注释留底 |
| [02-setting-ini-1366x768.patch](./02-setting-ini-1366x768.patch) | `setting.ini` 全屏视频尺寸跟 FB；小窗坐标未改 |

**不改：** PWM（仍 50kHz / `used=1`）、LVDS 极性、开屏驱 `xyc_k1_lvds`、LCD-EN=PB10、触摸 `TP_MAX_*`。

打完后：

```bash
./tools/build_p1_nor_XYC_K1.sh kernel
# 改过 ini：重编 busybox-init-base-files 再 target/install，确认 squashfs 里 video_screen_w=1366
./build.sh pack
```
