# SCRTEST ILI79600A 点亮定稿 — 补丁

在 **SDK 根目录**执行。H133-AI-Skills 被 gitignore，文档补丁靠 `git add -f`。

| 文件 | 内容 |
|---|---|
| `01-kernel-uboot-panel.patch` | `scrtest_ili79600a` + 注册 |
| `02-board-tree.patch` | 板级树 + OpenWrt target + 编译脚本 |
| `03-shared-hooks.patch` | U-Boot defconfig、兄弟板 `not set`、libtmedia |
| `04-docs.patch` | 开发记录 + board-profile |
| `scrtest-ili79600a-display-final.patch` | 合并 |

**不含** `disp_al.c`。

```bash
bash apply-scrtest-ili79600a-display-final.sh
bash apply-scrtest-ili79600a-display-final.sh --check
bash apply-scrtest-ili79600a-display-final.sh 01
bash gen-scrtest-ili79600a-display-final-patch.sh
```

`bootlogo.bmp` 不进补丁；apply 时从 `p1_nor_JL_M101` 复制。
