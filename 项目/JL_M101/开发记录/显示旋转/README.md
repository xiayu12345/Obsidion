---
project: JL_M101
kind: log
---

# 显示旋转（架构级）

HDMI / UI / 视频 **三路独立旋转**，跨板共用机制；板级只改旋钮取值，不改公共驱动逻辑。

| 文档 | 说明 |
|---|---|
| [20260825-三路旋转控制/](./20260825-三路旋转控制/) | **定稿**：三路入口、数据流、新板如何改 |

## 产品一句话

LCD 方向看 `disp_rotate`；HDMI 方向看 DTS `dual_display_rot`；视频贴 DE0 看 `VIDEO_WB_MIRROR_ROTATE`。三处互不影响。

```text
UI     setting.ini  disp_rotate          → sunxifb CPU 软转
HDMI   board.dts    dual_display_rot     → 内核 WB+G2D
视频   Makefile     VIDEO_WB_MIRROR_ROTATE → tlayer CPU 转（不读 ini）
      setting.ini  video_rotate          → TPlayerSetRotate（播放器 G2D）
```

新板改旋钮：[如何修改](./20260825-三路旋转控制/如何修改.md)（对照 [patches/](./20260825-三路旋转控制/patches/)）。

**已在树内**，无需对当前 SDK `git apply` 架构补丁。板级验证仍在各板目录。
