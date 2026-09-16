# XYC_K1 BL3676 触摸 — 补丁

在 **SDK 根目录**执行。相对 **XYC 板级仍是 JYY070 `ctp@40` GSL** 的树。H133-AI-Skills 被 gitignore，文档补丁靠 `git add -f`。

LVDS 定稿 `xyc-k1-display-final.patch` **已经含** 驱动和 DTS。当前出图树再 apply 会 already applied，属正常。

| 文件 | 内容 |
|---|---|
| `01-kernel-betterlife-ts.patch` | `betterlife_ts/` + `touchscreen/Kconfig` `Makefile` |
| `02-board-dts-ctp.patch` | 本板 `&twi1`、`bsp_defconfig`、`input_symlink.sh` |
| `03-docs.patch` | 开发记录 + 索引 |
| `xyc-k1-bl3676-tp.patch` | 合并 |

```bash
bash apply-xyc-k1-bl3676-tp.sh          # 打合并
bash apply-xyc-k1-bl3676-tp.sh --check
bash apply-xyc-k1-bl3676-tp.sh 01       # 分段
bash gen-xyc-k1-bl3676-tp-patch.sh     # 从当前树重生成
```

未改 U-Boot。
