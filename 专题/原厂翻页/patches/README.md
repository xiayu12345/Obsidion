---
project: H133
kind: log
---

# 原厂翻页补丁

相对 `xia_yixian`（`e553f3a49`）独立。已 `git apply --check`。

```bash
git am 0001-sunxifb-FBIOPAN-double-buffer.patch
```

只动：`sunxifb.c/.h`、`lv_port_disp.c/.h`、`Config.in` 的 DIRECT_MODE、`p1_nor` / `8733` / `JYY070` 的 **`defconfig`**（ota/qa 不动）。G2D 开关仍关。

`sunxifb.c/.h` 与远端 `01f2f8f9d` 字节相同，但 **没有** 那一笔里的 `sunxig2d` / `g2d_driver_enh.h` / G2D=y。

**不要**再叠 `../../G2D旋转/patches/0002-fix-IOMMU-G2D-dmabuf-fd.patch`。要翻页+G2D：用 G2D 目录的 `0001`+`0002`。
