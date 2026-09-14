---
project: H133
kind: log
---

# LVGL G2D 旋转（原厂 `smem_start` IOVA）

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-02 |
| 范围 | 翻页 + UI 旋转走 G2D（`use_phy_addr=1`，`laddr=smem_start`） |
| 基线 | `xia_yixian`（`e553f3a49`） |
| 远端 | `http://120.236.79.20:43000/xiayu/AI-KTV.git` 分支 `xia_g2d_rotate` |
| 提交 | `01f2f8f9d` → `37bf0adfb`（fd 弯路）→ `65aee7183` 改回 IOVA |
| 验证板 | 本地 lunch `p1_nor_ZS101`（**远端分支没有这块板**） |
| 补丁 | [patches/](./patches/) |
| 正文 | [开发记录.md](./开发记录.md) |
| 原理 | [H133-G2D-smem_start.md](../../H133-G2D-smem_start.md) |
| SDK 摘录 | [`docs/H133-LVGL-G2D旋转翻页.md`](../../../docs/H133-LVGL-G2D旋转翻页.md) |

## 一句话

旋转走 G2D；本板 `smem_start=0` 是合法 **IOVA**，跟原厂一样 `use_phy_addr=1`。不要导 dmabuf fd。

切页根因见 [切页撕裂](../切页撕裂/)。**只要翻页、不要 G2D** 见 [原厂翻页](../原厂翻页/)。

## 合入（产品定稿）

在 `xia_yixian` 上按顺序 `git am`：

```bash
cd H133-AI-Skills/开发记录/G2D旋转/patches
git am 0001-feat-LVGL-G2D-DIRECT-MODE-FBIOPAN.patch \
      0002-fix-IOMMU-G2D-dmabuf-fd.patch \
      0004-fix-G2D-smem_start-IOVA-not-dmabuf-fd.patch
```

已有远端：

```bash
git fetch http://120.236.79.20:43000/xiayu/AI-KTV.git xia_g2d_rotate
git cherry-pick 01f2f8f9d 37bf0adfb 65aee7183
```

**禁止**先合 [原厂翻页](../原厂翻页/) 的独立 `0001` 再合这里的 `0002`/`0004`。  
**禁止**停在 `0002`（fd 导出 + `close` 会打崩 mmap 的 ION）。

`0003` 是其它 lunch 开开关的**示例**（路径含 `<BOARD>`），**不要** `git apply`。p2 保持关。
