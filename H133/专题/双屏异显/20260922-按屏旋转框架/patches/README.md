# 按屏旋转框架 — 补丁

打在 **⑤** 之上（已取消 WB 同显、两模式贴屏）。不动内核。已合进树的不必再 apply。

| 文件 | 说明 |
|---|---|
| `01-ktv-tplayer-rotate0.patch` | `ktv_player_ui.c`：TPlayer 旋转恒 0；去掉异显特例与 ini→TPlayer |
| `02-libtmedia-makefile-jl270.patch` | `libtmedia/Makefile`：JL_M101 / JL_HXR101 → `VIDEO_WB_MIRROR_ROTATE=270` |
| `03-tlayer-per-screen-270.patch` | `tlayer_ctrl.c`：270=G2D 整帧 180 + DispNvRotate90；绿边修复；HDMI 仍原图 |
| `apply-per-screen-rot.sh` | 一键 apply 三份 |

```bash
bash AI-skiil/专题开发记录/双屏异显/20260922-按屏旋转框架/patches/apply-per-screen-rot.sh
# dry-run:
bash AI-skiil/专题开发记录/双屏异显/20260922-按屏旋转框架/patches/apply-per-screen-rot.sh --check
```

三份建议一起打：`01` 去掉解码共用 180 后，JL 必须靠 `02`+`03` 在 LCD 分路补到 270，否则竖屏 LCD 会倒。

**不动内核**，但仍要重编 `libtmedia`（tplayer）与链了 `ktv_player_ui` 的 GUI/`media_session`，再 `./build.sh pack`。

横屏板（XYC 等）Makefile 未改宏；`03` 里 270 分支对它们是死代码。
