# H133 京龙 JL-M101 eMMC 16G — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-15 |
| 工程 | `/root/Work/AI-tq`（lunch：`h133-p1_emmc_JL_M101-tina`） |
| 板型 | `p1_emmc_JL_M101`，屏同 NOR 京龙 **JL-M101**，存储改 eMMC 16G |
| 屏 | MIPI **800×1280**，开屏驱 `jl_m101_jd9365da`；触摸 GSL3670 |
| 状态 | 已出镜像；开机 logo 第二次 pack 起为竖图 100×432 |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |

## 一句话

整板复制 `p1_nor_JL_M101`，存储按音乐骑士 eMMC 改成 3.3V 4bit + GPT/`UDISK`；屏驱、UI、触摸不动。打包时必须把板级竖屏 `bootlogo.bmp` 盖过 common 横图。

这不是 K1。K1 是 `p1_nor_XYC_K1` / LVDS 横屏，见 [20260909](../20260909-H133-K1-LVDS开屏与boot1-UI旋转/) 和 [20260914](../20260914-H133-K1-LVDS-1366x768时序/)。

## 补丁

板件目录已在 SDK 里。`patches/` 只有 pack 脚本对京龙 eMMC 覆盖 logo 的那几行。当前工作区已合入。

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/JL_M101/20260915-H133-JL-M101-eMMC/patches/apply.sh
```

## 产物

`out/h133_linux_p1_emmc_JL_M101_uart0.img`

| 日期 | md5 | 说明 |
|---|---|---|
| 2026-09-15 10:55 | `d2a4f5510a069139fe6629f543ee1ae6` | 第一包；boot-resource 误用 312×76 横图 |
| 2026-09-15 14:51 | `fb6e54a36067b43b5479e74d887d15e4` | 竖图 100×432 已进 boot-resource |
