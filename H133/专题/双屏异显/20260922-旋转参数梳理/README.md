# 双屏视频旋转参数梳理（重新设计前）

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-22 |
| 类型 | **现状梳理**（未改代码；给重新设计用） |
| 验证板举例 | `p1_nor_JL_M101`（其它板只改数值，分层不要混） |
| 前置 | [⑤ 20260920-取消WB同显-两模式](../20260920-取消WB同显-两模式/) |
| 状态 | 设计建议已落地，见 [20260922-按屏旋转框架](../20260922-按屏旋转框架/) |

---

## 一句话

名字都叫「旋转」，转的**不是同一张图**。取消 WB 后同显 HDMI 第一次直接吃解码图，`video_rotate` / TPlayer 那一档才会漏到电视上。重新设计前先把各档拆清楚。

---

## 1. 分层（谁被转）

```
触摸坐标          tp_rotate
UI 图层           disp_rotate
视频窗口坐标      disp_rotate（只换算小窗，不转像素）
解码图（共用）    video_rotate → TPlayerSetRotate   ★ LCD/HDMI 都会吃
LCD 视频像素      VIDEO_WB_MIRROR_ROTATE            ★ 只 per_screen[0]
HDMI 直贴         无独立旋钮                        ★ 就是解码图
HDMI 旧 WB        dts dual_display_rot              ★ 拍 LCD 整屏，现产品同显不用
```

同显 / 异显 **只决定贴哪路**（`disp_screen` 掩码 3/2/1），本身不旋转。

---

## 2. 参数一览

| 参数 | 档位 | JL_M101 | 转什么 | 不转什么 | 配置位置 |
|---|---|---|---|---|---|
| `disp_rotate` | 0/1/2/3 = 0/90/180/270° | **1（90°）** | LVGL UI；小窗逻辑坐标→竖屏 DE | 视频像素 | `setting.ini` `[display]` |
| `tp_rotate` | 同上 | **0** | 触摸坐标 | 任何画面 | 同上 |
| `video_rotate` | 同上 | **2（180°）** | 解码输出（一张共用图） | UI、触摸、LCD 那次 CPU90 | 同上；消费者是 TPlayer |
| `VIDEO_WB_MIRROR_ROTATE` | 编译宏，度 | **90** | 仅 LCD 视频 CPU `DispNvRotate90` | HDMI 直贴 | `libtmedia/Makefile` `-D` |
| `dual_display_rot` | dts 0..3 | **`<1>`（90°）** | WB：LCD 整屏→横屏 HDMI | 解码图、直贴 HDMI | `board.dts` |
| `/etc/disp_mirror_mode` | 0=同显 1=异显 | 运行时 | 下次建层贴哪些屏 | 旋转角 | `disp_dual.c` |

ini 路径（板级，会进 rootfs）：

- `openwrt/target/h133/h133-p1_nor_JL_M101/busybox-init-base-files/etc/setting.ini`
- `openwrt/target/h133/h133-p1_emmc_LQ140M1JW61/busybox-init-base-files/etc/setting.ini`（LQ140 同样 `disp_rotate=1`、`video_rotate=2`）

设备上优先 U 盘，否则 `/etc/setting.ini`（见 `lv_video_rect_config` 注释）。

---

## 3. 各档代码入口

### 3.1 `disp_rotate` — UI

- 读：`lv_video_rect_config` 键 `disp_rotate`  
  `platform/thirdparty/gui/lvgl-8/lv_drivers/lv_video_rect_config.h`
- 开机：`lv_orient_disp_rotate_boot()`  
  `platform/thirdparty/gui/lvgl-8/app_depend/desk_huiyin/src/main.c`
- 窗口换算：`lv_video_fit_to_de()` 按 `disp_rotate` 把逻辑小窗映到竖屏 DE（90/270 会 w/h 对调）

**不转视频像素。** 菜单正了，片子方向可以仍是歪的。

### 3.2 `tp_rotate` — 触摸

- 开机：`lv_orient_tp_rotate_boot()` → `evdev_set_tp_rotate()`  
  `lv_drivers/indev/evdev.c`

跟画面无关。手指和 UI 对不齐才动它。

### 3.3 `video_rotate` — 解码共用图

- 读：`lv_video_rect_config.rotate` ← ini `video_rotate`
- 用：`ktv_player_ui_tplayer_rotate_degree()` → `TPlayerSetRotate()`  
  `platform/thirdparty/gui/lvgl-8/lib/media_session/src/pro/ktv_player_ui.c`
- 实现：`XPLAYER_CMD_SET_ROTATE_DEGREE`  
  `platform/allwinner/multimedia/libtmedia/tplayer/tplayer.c`
- **异显特例：** `SUNXI_DISP_MODE_DIFF` 时 **丢掉 ini，强制 0°**。同显仍 `deg_map[cfg.rotate & 3]`。

这是同屏 HDMI 倒、异显 HDMI 正的根因：直贴 HDMI 没有自己的旋转，却吃这张共用图。

> `video_rotate=2` 不是「HDMI 转 180」，是「解码先转 180，谁贴这张图谁都带着」。

### 3.4 `VIDEO_WB_MIRROR_ROTATE` — 仅 LCD 视频

- 定义：`openwrt/package/allwinner/multimedia/tina_multimedia/libtmedia/Makefile`
  - `p1_nor` / `8733` / `JL_M101` / `JL_HXR101` → **90**
  - `JYY070` / `p1_nor_4k` → **0**
- 消费：`dualDispPreparePerScreen()`  
  `platform/allwinner/multimedia/libtmedia/tplayer/awsink/tlayer_ctrl.c`
  - `== 90`：`DispNvRotate90` → `per_screen[0]`（LCD）
  - `== 180/270`：**未实现**（直接 `return -1`，回落横屏）
  - HDMI：`per_screen[1] = landscape_rb`（解码图，**不跟 LCD 这次 90°**）
- 像素核：`DispNvRotate90` → `nv_rotage90()`  
  `platform/allwinner/display/libuapi/src/videoOutPort.c`  
  `yuv_rotate.c`（H133 linux-5.4 走 C 实现，不是 NEON 分支）

名字带 WB，取消 WB 后这条仍在给 MIPI 转视频。

### 3.5 `dual_display_rot` — 仅旧 WB

- dts：`device/config/chips/h133/configs/p1_nor_JL_M101/linux-5.4/board.dts`  
  `dual_display_rot = <1>; /* 90°：竖屏 DE0 → 横屏 HDMI */`
- 内核：`disp_dual_display_rot_degree()` ← `g_disp_drv.disp_init.dual_display_rot`  
  `kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/dev_disp.c`
- 产品现状（⑤）：开机不自动启 WB；同显 HDMI 由 tlayer 直贴。此参数 **空转**，除非再拉起 WB。

### 3.6 同/异显 — 只选屏

- `sunxi_disp_video_screen_mask()`：`platform/allwinner/display/libuapi/src/disp_dual.c`
  - 未插 HDMI → `1`（仅 LCD）
  - 异显已插 → `2`（仅 HDMI）
  - 同显已插 → `3`（LCD+HDMI）
- 贴屏：`videoOutPort.c` 按 `disp_screen` 循环；若 `per_screen_valid` 置位则每屏可用不同 buffer。

---

## 4. 这块板同屏实际叠加

```
原图
  → video_rotate 180°          （TPlayer，两路共用）
      ├─ LCD  +90°             → 270°，方向对（验证过的 DispNvRotate90）
      └─ HDMI 直贴             → 只剩 180°，倒
异显：TPlayer 强制 0，HDMI 原图，正
旧 WB 同显：不吃解码图，吃 LCD 整屏 + dual_display_rot，跟 LCD 走
```

记三个互不替代的量：

| 你要正的是 | 动哪个 | 别动哪个 |
|---|---|---|
| 菜单 / 点歌 UI | `disp_rotate` | `video_rotate` |
| 触摸 | `tp_rotate` | 上面那些 |
| LCD 里的片子 | `video_rotate` **加上** LCD 那次 90° | `disp_rotate` |
| HDMI 直贴的片子 | 其实就是 `video_rotate`（共用图） | LCD 的 90° 管不到它 |
| WB 电视镜像 | `dual_display_rot` | TPlayer |

---

## 5. 已否过的改法（重新设计时不要再走）

| 做法 | 结果 |
|---|---|
| 同显也 `TPlayerSetRotate(0)` | HDMI 正，LCD 倒（少了 180） |
| TPlayer 全 0 + LCD 改 270° CPU | 方向可凑，`nv_rotage270` 分块/重影/偏色 |
| HDMI 再对 LCD 的 90° 图转一次 90° | 能抵 180，但叠在未验证路径上，过重 |
| 改 ini `video_rotate` 当「只转 HDMI」 | 做不到，这一档没有分屏 |

冲突就一句：LCD 要 TPlayer **180**（再加 90=270），异显 / 同显直贴 HDMI / 旧 WB 效果都要 **原图（0）**。`TPlayerSetRotate` 只有一份，没法同时给。

---

## 6. 重新设计时建议的语义（**已落地**）

> 已按本节落地，见 [20260922-按屏旋转框架](../20260922-按屏旋转框架/)。下文保留作设计依据；实现细节以落地目录为准（含 270 绿边：G2D 须整帧 180）。

解码贴屏方向恒 0°。旋转按屏：`lcd_rot` / `hdmi_rot`。模式只改 mask。WB 与 tlayer HDMI **互斥**（不能同时写 DE1）。

```
解码  永远 0°
        │
        ├──────────────────────┐
        ▼                      ▼
   LCD（lcd_rot）          HDMI 二选一，禁止同时开
   这块板 270°                  │
        │              ┌────────┴────────┐
        │              ▼                 ▼
        │         ① tlayer 直贴        ② WB 抓 LCD
        │         hdmi_rot = 0         内核 dual_display_rot（G2D）
        │         同显 mask=3          拍的是 LCD 已经转完的屏
        │         异显 mask=2
        ▼
     屏上看着正 ──► WB 才可能正
```

| 旧参数 | 建议 |
|---|---|
| `disp_rotate` / `tp_rotate` / 窗口坐标 | **原样保留** |
| `disp_mirror_mode` | **原样保留**（只选屏） |
| `dual_display_rot` | **保留给 WB**，不要拿去转解码图 |
| `VIDEO_WB_MIRROR_ROTATE` | 实质就是 `lcd_rot`；TPlayer 不再加 180 时，JL 应变 **270**，不能继续 90 |
| `video_rotate` | **不要再进 TPlayer**。若改成 LCD 总转角，JL 对应 **3** 不是 **2**；与宏不能同时加 |
| HDMI 直贴角 | 无现成 ini；默认定 **0**，先不加键 |

旧 `video_rotate=2` + 宏 `90` 是凑 LCD 270° 的。新框架只留一档 LCD 角，两份一起留会转两次。

验收（互斥）：

1. WB 关、同显：LCD 正，HDMI 正  
2. WB 关、异显：LCD 无视频，HDMI 正  
3. 若再开 WB：tlayer 不贴 screen1，HDMI 为 LCD 镜像 + `dual_display_rot`

卡点：LCD 270° 必须达到现行 90° 核的画质；不过则 LCD 与 WB 一起挂。

---

## 7. 关键文件

| 文件 | 内容 |
|---|---|
| `openwrt/target/h133/h133-p1_nor_JL_M101/.../etc/setting.ini` | `disp_rotate` / `tp_rotate` / `video_rotate` |
| `lvgl-8/lv_drivers/lv_video_rect_config.h` | 键名、注释（仍写「仅 TPlayer」） |
| `lvgl-8/lib/media_session/src/pro/ktv_player_ui.c` | 异显强制 0，同显跟 ini |
| `libtmedia/tplayer/tplayer.c` | `TPlayerSetRotate` |
| `libtmedia/tplayer/awsink/tlayer_ctrl.c` | `dualDispPreparePerScreen` LCD 90 / HDMI 原图 |
| `openwrt/.../libtmedia/Makefile` | `VIDEO_WB_MIRROR_ROTATE` |
| `libuapi/src/videoOutPort.c` | `DispNvRotate90`；`per_screen_*` 贴屏 |
| `libuapi/src/disp_dual.c` | 模式 → mask |
| `libuapi/src/yuv_rotate.c` | `nv_rotage90` / `nv_rotage270` |
| `device/.../p1_nor_JL_M101/linux-5.4/board.dts` | `dual_display_rot` |
| `kernel/.../disp/dev_disp.c` | WB + G2D |
| [20260920-取消WB同显-两模式/](../20260920-取消WB同显-两模式/) | 取消 WB 后 SAME/DIFF 语义 |
