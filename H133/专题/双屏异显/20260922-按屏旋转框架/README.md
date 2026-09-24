# 按屏旋转框架（解码 0 + lcd_rot / hdmi_rot）

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-22 |
| 类型 | **落地**（相对 [旋转参数梳理](../20260922-旋转参数梳理/) 中的新框架建议） |
| 验证板 | `p1_nor_JL_M101`（lcd_rot=270）；`JL_HXR101` 同宏 |
| 镜像 | `out/h133_linux_p1_nor_JL_M101_uart0_nor.img` md5 `1f443c9fd651293044555b9e536e50f8`（含绿边修复） |
| 前置 | [⑤ 取消 WB 同显](../20260920-取消WB同显-两模式/)；[旋转参数梳理](../20260922-旋转参数梳理/) |
| 补丁 | [patches/](./patches/) |
| 状态 | **已合入工作区并板上过方向**；绿边已修进同包；横屏板（XYC 等）宏仍 0，不受影响 |

---

## 一句话

解码贴屏方向恒 **0°**。旋转只在分路：`lcd_rot`（宏 `VIDEO_WB_MIRROR_ROTATE`）转 LCD；HDMI 直贴原图（`hdmi_rot=0`）。同/异显只改 mask。

不做 DE0 合成后整屏转；不做直接 `nv_rotage270`。

---

## 路径

```
解码  TPlayer 恒 0°
        │
        ├─ LCD（screen0）  lcd_rot
        │     JL：270 = G2D 180（整帧）+ DispNvRotate90
        │     p1_nor / 8733：90（仅 CPU 90）
        │     JYY070 / 4k / XYC 等：0（宏未 -D 或显式 0）
        │
        └─ HDMI（screen1）  hdmi_rot = 0（原图）
              同显 mask=3 / 异显 mask=2 / 未插 HDMI mask=1
```

JL 270° **故意不调** `nv_rotage270`：板上已验证方向可对，但分块 / 重影 / 偏色。用 G2D 180 叠已验证的 `DispNvRotate90`，等价旧栈 `TPlayer 180 + CPU 90`，只是 180 挪进 LCD 分路，HDMI 不再跟着倒。

---

## 改了什么

| 位置 | 改动 |
|---|---|
| `ktv_player_ui.c` | `ktv_player_ui_tplayer_rotate_degree()` 恒返回 0；去掉异显特例与 `video_rotate`→TPlayer |
| `tlayer_ctrl.c` | `VIDEO_WB_MIRROR_ROTATE==270`：`mRotateExtraBufInfo` 做 G2D 180，再 `DispNvRotate90`；HDMI 仍原图；Release 释放 270 中缓 |
| `libtmedia/Makefile` | JL_M101 / JL_HXR101 → `-DVIDEO_WB_MIRROR_ROTATE=270`；p1_nor / 8733 仍 90；JYY070 / 4k 仍 0 |

未改：`disp_rotate` / `tp_rotate` / 小窗坐标 / SAME·DIFF 语义 / WB 自动启停。

`setting.ini` 的 `video_rotate` **键可留，但不再进 TPlayer**，勿当贴屏角。

宏名暂仍叫 `VIDEO_WB_MIRROR_ROTATE`，语义即 **lcd_rot**。

---

## 绿边（270 路径）

`DispNvRotate90` 把**源图底边**映到**目标左边**。首版 G2D 180 只按可见 `crop` clip（例如高 1080），decoder 对齐填充（如 1088）底边未写，仍是垃圾 UV；再经 90° 就成左边绿条。

**修法：** G2D 180 必须转**整帧**（含底/右对齐填充）；可见区仍用与 90° 路径同类的 crop 映射（`rotCropX = srcH - midCy - midCh` 等）。padding 经 180→90 后落到右边，由 `effW=crop_h` 裁掉。

只影响 `lcd_rot=270`。`90` / `0` 路径不动 → XYC 等横屏板默认 `0`，无此路径。

---

## 对其它板

| 板类 | `VIDEO_WB_MIRROR_ROTATE` | 影响 |
|---|---|---|
| JL_M101 / JL_HXR101 | **270** | 本框架目标板 |
| p1_nor / 8733 | 90 | 仍只走 `DispNvRotate90`（与改前同类） |
| JYY070 / 4k | 0 | 无 LCD 分路转 |
| XYC / 其它未列 target | 默认 **0**（Makefile 未 -D） | **不受本次改动影响**；TPlayer 恒 0 后若某横屏板以前靠 ini `video_rotate` 正图，需单独评估 |

---

## 验收

1. 同显（mask 3）：LCD 正，HDMI 正；LCD **无左边绿边**。
2. 异显（mask 2）：LCD 无视频，HDMI 正。
3. 未插 HDMI（mask 1）：LCD 正、无绿边。
4. 切歌分辨率变化：不崩（中缓重建逻辑与 90 路径同类）。

干净树（已是 ⑤）合入：

```bash
bash AI-skiil/专题开发记录/双屏异显/20260922-按屏旋转框架/patches/apply-per-screen-rot.sh
# 重编 libtmedia + media_session（ktv），再 pack
./build.sh && ./build.sh pack
```

---

## 明确不做

- DE0 / `disp_rotation_used` / 横屏 FB 合成后再转
- 直接启用 `nv_rotage270`
- 本次不扩 WB；若再开 WB，仍勿与 tlayer 同时写 DE1
