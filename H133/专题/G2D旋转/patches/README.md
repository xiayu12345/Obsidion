---
project: H133
kind: log
---

# G2D 旋转补丁（含翻页）

基线：`xia_yixian`（`e553f3a49`）。**按顺序三笔代码补丁**，不要跟「原厂翻页」那份混。

| 文件 | 对应提交 | 内容 |
|------|----------|------|
| `0001-feat-LVGL-G2D-DIRECT-MODE-FBIOPAN.patch` | `01f2f8f9d` | 翻页 + 开 G2D + `sunxig2d` / 116/236 / `libawion`；blit 走 `smem_start` |
| `0002-fix-IOMMU-G2D-dmabuf-fd.patch` | `37bf0adfb` | **弯路**：两边 dmabuf fd。不要停在这一笔 |
| `0003-example-other-board-defconfig.patch` | 无 | 其它 lunch 开开关的示例，路径含 `<BOARD>`，**勿 git apply** |
| `0004-fix-G2D-smem_start-IOVA-not-dmabuf-fd.patch` | `65aee7183` | 撤回 fd，改回原厂 `use_phy_addr=1` + `smem_start` IOVA |

```bash
git am 0001-feat-LVGL-G2D-DIRECT-MODE-FBIOPAN.patch \
      0002-fix-IOMMU-G2D-dmabuf-fd.patch \
      0004-fix-G2D-smem_start-IOVA-not-dmabuf-fd.patch
```

只合 `0002`，或先合 `../../原厂翻页/patches/0001-sunxifb-FBIOPAN-double-buffer.patch` 再合 `0002`/`0004` → `sunxig2d` / Makefile 对不上。

`0001` 会改 p1_nor / 8733 / JYY070 的 defconfig **和** ota/qa。ota 仍是 `CACHE=y`。p2 不要开。
