# H133 唱吧 UI：USB 鼠标与 GT911 触摸并存（lv_projector）

> **板型**：`h133-p1_nor`（拓步 10.1 寸一体板）  
> **应用**：`platform/thirdparty/gui/lvgl-8/lv_projector`（唱吧）  
> **触摸**：GT9110 → `gt9xxnew_ts` → `evdev_read`  
> **指针**：USB HID 鼠标 → `evdev_read_mouse` + 屏幕光标  
> **SDK**：`/home/wjz/Desktop/H133-03/H133-03`  
> **关联文档**：[tuopu-10.1-h133-tp-lvgl.md](./tuopu-10.1-h133-tp-lvgl.md)、[GT9110-规格书要点与驱动对照.md](../硬件资料/GT9110-规格书要点与驱动对照.md)

---

## 0. 最终方案一句话

**触摸与 USB 鼠标在 LVGL 里各注册一个 `LV_INDEV_TYPE_POINTER`，分别使用独立的 evdev 文件描述符（`evdev_fd` / `evdev_mouse_fd`），互不替换；鼠标支持约 500ms 轮询热插拔，光标在 `layer_top` 最上层显示。**

---

## 1. 架构总览

```text
┌─────────────────────────────────────────────────────────────┐
│  GT9110 (I2C)                    USB Optical Mouse (OHCI)   │
│  gt9xxnew_ts → /dev/input/event3   hid → /dev/input/eventN │
└────────────┬──────────────────────────────────┬───────────┘
             │ ABS_MT (0~1279 × 0~799)          │ REL_X/Y + BTN_LEFT
             ▼                                  ▼
┌────────────────────────────┐    ┌────────────────────────────┐
│ evdev_fd                   │    │ evdev_mouse_fd             │
│ evdev_touch_init()         │    │ evdev_mouse_init()         │
│ read_cb: evdev_read        │    │ read_cb: evdev_read_mouse   │
└────────────┬───────────────┘    └────────────┬───────────────┘
             │                                  │
             ▼                                  ▼
┌─────────────────────────────────────────────────────────────┐
│  LVGL 8（逻辑分辨率 1280×800，与 tuopu-10.1 一致）            │
│  · touch_indev  — 无屏幕光标，直接点控件                     │
│  · mouse_indev  — lv_indev_set_cursor 蓝点跟随               │
│  · 主循环 evdev_mouse_hotplug_poll() 约 500ms               │
└─────────────────────────────────────────────────────────────┘
```

| 输入 | 内核节点（示例） | LVGL indev | 是否有光标 |
|------|------------------|------------|------------|
| 触摸 | `event3`（`gt9xxnew_ts`） | `indev_touch_drv` | 否 |
| USB 鼠标 | `event4` 等（扫描获得） | `indev_mouse_drv` | 是（20×20 蓝点） |

**event 编号随插拔顺序变化**，应用通过能力扫描（`ABS_MT` / `REL+BTN_LEFT`）识别设备，不依赖写死 `event4`。

---

## 2. 内核配置（p1_nor）

文件：`device/config/chips/h133/configs/p1_nor/openwrt/bsp_defconfig`  
同步：`device/config/chips/h133/configs/p1_nor/linux-5.4/config-5.4`

| 配置项 | 说明 |
|--------|------|
| `CONFIG_INPUT_TOUCHSCREEN=y` | GT911 触摸 |
| `CONFIG_TOUCHSCREEN_GT9XXNEW_TS=y` | `gt9xxnew_ts` 驱动 |
| `CONFIG_USB_HID=y` | USB 鼠标 HID |
| `CONFIG_INPUT_MOUSE=y` | 鼠标 input 子系统 |
| `CONFIG_USB_EHCI_HCD` / `CONFIG_USB_OHCI_HCD` | USB Host（鼠标常接 OHCI 口） |

启动 log 正常时应出现：

```text
usbcore: registered new interface driver usbhid
input: gt9xxnew_ts as /devices/virtual/input/input3
input: USB Optical Mouse as ... input4
hid-generic ... Mouse [USB Optical Mouse]
```

仅改应用、未改内核时：鼠标已有 `event` 但唱吧不识别 → 刷 **rootfs** 即可；从未开过 `CONFIG_USB_HID` → 需 **full 镜像**（含 kernel）。

---

## 3. 应用配置（lv_drv_conf.h）

路径：`platform/thirdparty/gui/lvgl-8/lv_projector/src/lv_drv_conf.h`

```c
#define USE_EVDEV           1
#define USE_EVDEV_MOUSE     1      /* 与触摸并存，非二选一 */
#define EVDEV_SWAP_AXES     0
#define EVDEV_CALIBRATE     0
/* EVDEV_MOUSE_NAME 仅作优先尝试路径，热插拔会扫描 event0~15 */
#define EVDEV_MOUSE_NAME    "/dev/input/event4"
```

触摸坐标与 [tuopu-10.1-h133-tp-lvgl.md](./tuopu-10.1-h133-tp-lvgl.md) 一致：**1280×800，无二次 SWAP/CALIBRATE**。

---

## 4. 关键代码说明

### 4.1 触摸 / 鼠标 fd 分离（必改）

**问题**：旧版 `evdev_set_file()` 在 `USE_EVDEV_MOUSE=1` 时始终把 `evdev_fd` 打开为鼠标节点，导致触摸 indev 实际在读 `REL_X/Y`，表现为「鼠标能用、触摸失效」。

**修复**：`platform/thirdparty/gui/lvgl-8/lv_drivers/indev/evdev.c` 中 `evdev_set_file()` **始终** `open(path)`，`path` 由 `evdev_touch_init()` 传入（如 `/dev/input/event3`）。

| 变量 / 接口 | 用途 |
|-------------|------|
| `evdev_fd` | 仅 GT911 触摸，`evdev_read()` |
| `evdev_mouse_fd` | 仅 USB 鼠标，`evdev_read_mouse()` |

### 4.2 唱吧注册两个 pointer（main.c）

`keypad_int()` 顺序：

1. `evdev_touch_init()`（最多重试 50 次）→ 注册 `indev_touch_drv`  
2. **始终**注册 `indev_mouse_drv`（即使开机无鼠标）  
3. 若已有鼠标：`evdev_mouse_init()` → 打印 `USB mouse ok`  
4. 若无鼠标：打印 `USB mouse absent, hotplug polling enabled`  

### 4.3 鼠标光标层级

光标在 `karaoke_demo_open()`、`lv_app_launcher_init()` **之后** 创建（`lv_projector_mouse_cursor_init()`），并 `lv_obj_move_foreground()`，避免被 `g_kb_top_layer`、唱吧字幕层挡住。

### 4.4 USB 鼠标热插拔

| API | 文件 | 作用 |
|-----|------|------|
| `evdev_mouse_hotplug_poll()` | `evdev.c` | 约 500ms 由主循环调用；插入则 `evdev_mouse_init()`，拔出则 `evdev_mouse_close()` |
| `evdev_mouse_is_open()` | `evdev.c` | 查询 fd 是否有效 |
| `lv_projector_mouse_hotplug_handler()` | `main.c` | 插拔后显示/隐藏光标 |

主循环：`mouse_hotplug_cnt >= 15`（15×33ms）触发一次轮询。

串口 log：

```text
evdev mouse hotplug: plugged
evdev mouse hotplug: unplugged (/dev/input/event4)
```

---

## 5. 涉及文件清单

| 类型 | 路径 |
|------|------|
| evdev 驱动 | `platform/thirdparty/gui/lvgl-8/lv_drivers/indev/evdev.c` |
| evdev 头文件 | `platform/thirdparty/gui/lvgl-8/lv_drivers/indev/evdev.h` |
| 应用入口 | `platform/thirdparty/gui/lvgl-8/lv_projector/src/main.c` |
| LVGL 驱动配置 | `platform/thirdparty/gui/lvgl-8/lv_projector/src/lv_drv_conf.h` |
| 内核 defconfig | `device/config/chips/h133/configs/p1_nor/openwrt/bsp_defconfig` |
| 设备树（触摸） | `device/config/chips/h133/configs/p1_nor/linux-5.4/board.dts`（`gt9xxnew_ts`、`sdc0`） |

`lv_tp_test` 与 `lv_projector` **共用** `lv_drivers/indev/evdev.c`，改一处两边生效；`lv_tp_test` 默认 `USE_EVDEV_MOUSE=0`，仅测触摸。

---

## 6. 编译与烧录

```bash
# SDK 根目录
export H133_SDK_ROOT=/path/to/H133-03

# 仅应用 + rootfs（已含 USB_HID 的内核若之前刷过，可只刷本次 img）
bash .cursor/skills/h133-build/scripts/build_p1_nor.sh rootfs

# 首次启用 USB_HID 或改内核
bash .cursor/skills/h133-build/scripts/build_p1_nor.sh full
```

产物：`out/h133_linux_p1_nor_uart0_nor.img`

验证二进制：

```bash
strings out/h133/p1_nor/openwrt/staging_dir/target/root-h133-p1_nor/usr/bin/lv_projector | \
  grep -E 'GT911 touch ok|mouse absent|hotplug|mouse cursor'
```

---

## 7. 板上验证

### 7.1 设备节点

```bash
cat /proc/bus/input/devices
# 应有 gt9xxnew_ts → event3
# 应有 USB Optical Mouse → eventN，Handlers 含 mouse

ls -l /dev/input/event*
```

### 7.2 启动 log（lv_projector 段）

期望顺序类似：

```text
lv_projector: fb 800x1280 -> LVGL 1280x800, sunxifb_rot=1
evdev touch opened: /dev/input/event3
lv_projector: GT911 touch ok, LVGL 1280x800
lv_projector: USB mouse ok
# 或：lv_projector: USB mouse absent, hotplug polling enabled
...
lv_projector: USB mouse cursor on layer_top
```

**勿在 shell 里直接输入上述字符串**（那是程序 `printf`，不是命令）。

### 7.3 功能自测

| 步骤 | 预期 |
|------|------|
| 不插鼠标，手指点 UI | 触摸正常，无蓝点 |
| 启动后插入鼠标 | 约 0.5s 内 `hotplug: plugged`，出现蓝点，可点控件 |
| 拔出鼠标 | `hotplug: unplugged`，光标消失，**触摸仍正常** |
| 再插入 | 再次 `plugged`，鼠标恢复 |

```bash
# 动鼠标时看底层（将 N 换成实际 event 号）
getevent /dev/input/eventN
```

---

## 8. 常见问题

| 现象 | 原因 | 处理 |
|------|------|------|
| 触摸失效、鼠标正常 | 旧 `evdev_set_file` 把触摸绑到鼠标 fd | 刷含 fd 分离修复的 rootfs |
| 鼠标无反应、触摸正常 | 未开 `CONFIG_USB_HID` 或仅刷 boot 未刷 rootfs | `full` 编译并烧录整包 |
| 有 event 无 `USB mouse ok` | 仍是旧 `lv_projector` | `strings` 查 `hotplug polling` |
| 鼠标能用但看不见蓝点 | 光标被 `layer_top` 遮挡（旧版） | 刷含延后 `mouse_cursor_init` 的版本 |
| 启动后才插鼠标无效（旧版） | 仅开机 `evdev_mouse_init` 一次 | 刷含 `evdev_mouse_hotplug_poll` 的版本 |
| `SD mount wait timeout (2s)` | 旧 rootfs，与鼠标无关 | 见 [H133-Tina-SD卡调试经验.md](./H133-Tina-SD卡调试经验.md)，新包为 15s + reload |

---

## 9. 与 SD 卡大图、双显的关系

- **SD 图**：路径 `S:/mnt/SDCARD/*.png`，与输入无关；挂载时序见 SD 调试文档。  
- **双显 / 软旋转**：逻辑坐标仍为 1280×800，触摸与鼠标 clamp 均按 `hor_res`/`ver_res`，与 [tuopu-10.1-h133-tp-lvgl.md](./tuopu-10.1-h133-tp-lvgl.md) 一致。  
- **主循环**：`doubao_app_mgr_should_run_lvgl()` 为 0 时 LVGL 不 `task_handler`，触摸与鼠标都会停；若仅指针无响应，先确认豆包未 pause LVGL。

---

## 10. 版本记录

| 日期 | 说明 |
|------|------|
| 2026-06-01 | 初版：触摸+鼠标双 indev、fd 分离、光标置顶、USB 热插拔轮询、`CONFIG_USB_HID` |

---

*文档路径：`docs/驱动/H133-USB鼠标与GT911触摸并存-lvgl.md`*
