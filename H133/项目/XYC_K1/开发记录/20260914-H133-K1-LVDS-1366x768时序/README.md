# H133-K1 LVDS 1366×768 时序 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-14 |
| 工程 | `/root/Work/AI-tq`（lunch：`h133-p1_nor_XYC_K1-tina`） |
| 板型 | `p1_nor_XYC_K1`，硬件 **H133-K1** |
| 屏 | 厂 LVDS **1366×768**（单路 6bit NS）；开屏驱仍是 `xyc_k1_lvds` |
| 状态 | 已点亮；PWM / 线序沿用 1280×800 那套 |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |

## 一句话

K1 换 1366×768 LVDS，只改 dts 时序和 FB 尺寸。厂参数里的 `hbp=40/hspw=48` 按全志规则写成 `hbp=88`；PWM 和 LVDS 极性都不动。

## 补丁顺序（1280×800 基线树）

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/XYC_K1/20260914-H133-K1-LVDS-1366x768时序/patches/apply.sh
```

| 文件 | 内容 |
|---|---|
| `01-board-dts-1366x768.patch` | `board.dts` / `uboot-board.dts` 时序 + fb0 |
| `02-setting-ini-1366x768.patch` | `setting.ini` 全屏视频 1366×768 |

前序：09-09 LVDS 开屏 `01`–`05` 必须已经打过。

## 产物

`out/h133_linux_p1_nor_XYC_K1_uart0_nor.img`

| 日期 | md5 |
|---|---|
| 2026-09-14（点亮） | `adef8d0a735663e24e7e760139499fea` |
