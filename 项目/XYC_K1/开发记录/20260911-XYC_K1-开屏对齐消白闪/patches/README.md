# 补丁说明 — XYC_K1 开屏对齐消白闪

相对 [20260908 LVDS 点亮定稿](../../20260908-XYC_K1-板件克隆与LVDS点亮定稿/patches/) 的增量。

| 文件 | 说明 |
|---|---|
| `01-panel-open-flow.patch` | 内核+U-Boot `xyc_k1_lvds.c` |
| `02-board-dts-open.patch` | 本板 `board.dts` / `uboot-board.dts`（usb1 / lcd0 / pwm0） |
| `03-docs.patch` | 本专题文档 + 定稿/档案/索引修订 |
| `xyc-k1-open-flow-fix.patch` | 合并 |
| `apply-xyc-k1-open-flow-fix.sh` | `patch -p1` |
| `gen-xyc-k1-open-flow-fix-patch.sh` | 相对 09-08 `01`/`02` 补丁内容重生成 |

已含本改动的树再 apply 会冲突，属正常。
