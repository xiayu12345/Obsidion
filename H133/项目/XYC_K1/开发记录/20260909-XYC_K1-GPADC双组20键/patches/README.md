# XYC_K1 GPADC 双组 20 键 — 补丁

在 **SDK 根目录**执行。相对 **已出图的 XYC_K1 树**（LVDS 定稿之后）。H133-AI-Skills 被 gitignore，文档补丁靠 `git add -f`。

| 文件 | 内容 |
|---|---|
| `01-kernel-gpadc-mux.patch` | `sunxi_gpadc.c` / `.h` |
| `02-board-gpadc-keys.patch` | 相对 LVDS 定稿：只含 owa/btlpm/`&gpadc`/`GPIO_SYSFS`，不含 I2S/PWM 等其它 WIP |
| `03-docs.patch` | 开发记录 + 索引 |
| `xyc-k1-gpadc-20key.patch` | 合并 |

```bash
bash apply-xyc-k1-gpadc-20key.sh          # 打合并
bash apply-xyc-k1-gpadc-20key.sh --check
bash apply-xyc-k1-gpadc-20key.sh 01       # 分段
bash gen-xyc-k1-gpadc-20key-patch.sh     # 从当前树重生成
```

未改 U-Boot。当前已含本功能的树再 apply 会报 already applied，属正常。
