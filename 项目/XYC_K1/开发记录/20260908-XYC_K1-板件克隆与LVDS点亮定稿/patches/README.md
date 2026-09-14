# XYC_K1 LVDS 点亮定稿 — 补丁

在 **SDK 根目录**执行。H133-AI-Skills 被 gitignore，文档补丁靠 `git add -f`。

| 文件 | 内容 |
|---|---|
| `01-kernel-uboot-panel.patch` | `xyc_k1_lvds` + BL3676（触摸专题另有子集补丁） |
| `02-board-tree.patch` | 板级树 + OpenWrt target + `tools/build_p1_nor_XYC_K1.sh` |
| `03-shared-hooks.patch` | U-Boot 两份 defconfig |
| `04-docs.patch` | 开发记录 + board-profile |
| `xyc-k1-display-final.patch` | 合并 |

```bash
bash apply-xyc-k1-display-final.sh          # 打合并
bash apply-xyc-k1-display-final.sh --check
bash apply-xyc-k1-display-final.sh 01       # 分段
bash gen-xyc-k1-display-final-patch.sh     # 从出图树重生成
```

`bootlogo.bmp` 不进补丁；apply 时从 `p1_nor_JYY070` 复制。
