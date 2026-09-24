# H133 京龙 HXR10106B-28 独立板件 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-18 |
| 工程 | `/root/Work/AI-tq` |
| 对照 | `/root/Work/H133-AIKTV`：`p1_nor_JL_HXR101` + `jl_hxr_ili9881c` |
| 板型 | NOR `p1_nor_JL_HXR101`；eMMC `p1_emmc_JL_HXR101`。原 JL-M101 不动 |
| 屏 | MIPI **800×1280**，开屏驱 `jl_hxr_ili9881c`（`dclk=49`） |
| 触摸 | GSL3670，不变 |
| 状态 | 已出 eMMC / NOR 镜像 |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |

## 一句话

对照 AIKTV：独立板件 + 共用 `jl_hxr_ili9881c`，不要在 `p1_*_JL_M101` 上原地换屏。原京龙仍是 JD9365DA。

这不是 K1。K1 是 `p1_nor_XYC_K1` / LVDS 横屏。

## 补丁

板件目录已在 SDK 里。干净树（JL-M101 仍是 JD9365DA）按序 apply：

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/JL_HXR101/20260918-H133-JL-HXR101-新建板件/patches/apply.sh
```

说明见 [patches/README.md](./patches/README.md)。

## 编译

```bash
./tools/build_p1_emmc_JL_HXR101.sh kernel
./tools/build_p1_nor_JL_HXR101.sh kernel
```

## 产物

| 日期 | 文件 | md5 |
|---|---|---|
| 2026-09-18 11:54 | `out/h133_linux_p1_emmc_JL_HXR101_uart0.img` | `50bdd8e57fe63c3058d3637cd9f6ae1c` |
| 2026-09-18 11:56 | `out/h133_linux_p1_nor_JL_HXR101_uart0_nor.img` | `0476c6adc09e025de5514bfe97fa989b` |
