# 取消 WB 同显、两模式贴屏 — 补丁

打在 **④** 之上（已有 `DIFF_HDMI`）。①〜④ 目录不要改。已合进树的不必再 apply。

| 文件 | 说明 |
|---|---|
| `01-kernel-drop-wb-coupling.patch` | `dev_disp.c` + `sunxi_display2.h`：停 WB 自动启动，拆 `SET_HDMI_OUT` 那一层，删无人调的 `FB_CLONE_ALLOW_GET` |
| `02-libuapi-two-modes.patch` | `disp_dual.c` / `disp_dual.h` / `disp_mode_cli.c`：两模式，删 WB 排障接口与已成空壳的 `mode_apply()` |
| `03-comment-cleanup.patch` | `tlayer_ctrl.c` / `media_session.c`：只改两行过期的 WB 注释，无逻辑变更 |
| `apply-drop-wb-same.sh` | 一键 apply 三份 |

```bash
bash AI-skiil/专题开发记录/双屏异显/20260920-取消WB同显-两模式/patches/apply-drop-wb-same.sh
# dry-run:
bash AI-skiil/专题开发记录/双屏异显/20260920-取消WB同显-两模式/patches/apply-drop-wb-same.sh --check
```

`01`/`02` 要一起打：`02` 删掉的 `sunxi_dual_display_set_hdmi_output()` 正是 `01` 删掉的
ioctl 的调用方，只打一边会留下悬空引用。`03` 只是注释，单独打也行。

**动了内核**，`./build.sh openwrt_rootfs` 不够，要 `./build.sh && ./build.sh pack` 整编。

应用侧（设置页、`ktv_player_ui`）不在本补丁里——这一代刻意一行逻辑没改，
`03` 碰到的 `tlayer_ctrl.c` / `media_session.c` 也只是注释。
