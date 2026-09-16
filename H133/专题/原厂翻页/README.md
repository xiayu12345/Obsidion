---
project: H133
kind: log
---

# 原厂双页翻页（FBIOPAN）

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-01 |
| 范围 | **只要翻页**：去掉 `split_fb`，后台页 + `FBIOPAN` + DIRECT_MODE。G2D 开关仍关 |
| 基线 | `xia_yixian`（`e553f3a49`） |
| 验证 | 已 `git apply --check`；翻页 C 文件与远端 `01f2f8f9d` 的 `sunxifb`/`lv_port_disp` **字节相同** |
| 补丁 | [patches/0001-sunxifb-FBIOPAN-double-buffer.patch](./patches/0001-sunxifb-FBIOPAN-double-buffer.patch) |
| 正文 | [开发记录.md](./开发记录.md) |
| SDK 摘录 | [`docs/H133-LVGL-原厂翻页.md`](../../../docs/H133-LVGL-原厂翻页.md) |

## 一句话

按原厂：LVGL 画后台页，`FBIOPAN` 翻到那一页。不再把 MIPI 钉死在 page1。

切页为什么会撕见 [切页撕裂](../切页撕裂/)。要 **G2D** 不要用这份，用 [G2D旋转](../G2D旋转/) 的 `0001`+`0002`+`0004`（不要停在 `0002`）。

## 合入

在 `xia_yixian` 上：

```bash
git am H133-AI-Skills/开发记录/原厂翻页/patches/0001-sunxifb-FBIOPAN-double-buffer.patch
```

只动：`sunxifb.c/.h`、`lv_port_disp.c/.h`、`Config.in` 的 DIRECT_MODE 默认 y、三块板 **仅 `defconfig`** 开 DIRECT_MODE（`p1_nor` / `8733` / `JYY070`）。**不含** `sunxig2d`、`g2d_driver_enh.h`、G2D 开关、ota/qa。

**禁止**再叠 [G2D旋转](../G2D旋转/) 的 `0002`/`0004`（缺 `sunxig2d` / `libawion` / 结构体 116/236，对不上）。

换 lunch：公共 `sunxifb` 不用重做；新板自己开 `DIRECT_MODE`。`xia_yixian` 上只有上述三块 p1 + `p2`（p2 保持关）。ZS101 等板不在这条远端分支，合到有那些 lunch 的树后对照 [G2D旋转/patches/0003](../G2D旋转/patches/0003-example-other-board-defconfig.patch) 只开 DIRECT_MODE 即可。
