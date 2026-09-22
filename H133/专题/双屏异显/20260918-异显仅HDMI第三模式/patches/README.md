# 异显第三模式 DIFF_HDMI — 补丁

打在 **③** 之上（异显 `DIFF` 已是 `video_screen=3`）。①/② 目录不要改。已合进树的不必再 apply。

| 文件 | 说明 |
|---|---|
| `01-libuapi-diff-hdmi-mode.patch` | 三文件：`disp_dual.c` / `disp_dual.h` / `disp_mode_cli.c` |
| `apply-diff-hdmi-mode.sh` | 一键 apply |

```bash
bash AI-skiil/专题开发记录/双屏异显/20260918-异显仅HDMI第三模式/patches/apply-diff-hdmi-mode.sh
# dry-run:
bash AI-skiil/专题开发记录/双屏异显/20260918-异显仅HDMI第三模式/patches/apply-diff-hdmi-mode.sh --check
```

只扩充 `DIFF_HDMI`。`SAME` / `DIFF`、内核、`tlayer`、设置页不在本补丁里。
