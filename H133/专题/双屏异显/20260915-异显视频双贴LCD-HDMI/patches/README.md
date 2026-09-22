# 异显播片两路都贴 — 补丁

干净树（仍是 20260806：异显 `video_screen=2`）才需要打。已合进树的不必再 apply。

| 文件 | 说明 |
|---|---|
| `01-libuapi-diff-video-screen-3.patch` | 三文件：`disp_dual.c` / `disp_dual.h` / `disp_mode_cli.c` |
| `apply-diff-video-both.sh` | 一键 apply |

```bash
bash AI-skiil/专题开发记录/双屏异显/20260915-异显视频双贴LCD-HDMI/patches/apply-diff-video-both.sh
# dry-run:
bash AI-skiil/专题开发记录/双屏异显/20260915-异显视频双贴LCD-HDMI/patches/apply-diff-video-both.sh --check
```

只动 libuapi 选屏。内核、`tlayer`、`scale_win` 不在本补丁里。
