# tuopu-10.1-h133-tp-lvgl — 拓步 10.1 寸 TP 开发与 LVGL 坐标映射

> **产品型号**：`tuopu-10.1-h133-tp-lvgl`  
> **平台**：全志 H133，`h133-p1_nor`（NOR + UART0）  
> **触摸**：汇顶 GT9110（驱动 `gt9xxnew_ts`）  
> **显示**：MIPI 10.1 寸 800×1280（竖屏物理）+ HDMI（1080p，DE 缩放）  
> **应用**：LVGL 8 测试程序 `lv_tp_test`（唱吧 `lv_projector` 调试阶段关闭）  
> **SDK 路径**：`/home/wjz/Desktop/H133-03/H133-03`  
> **镜像**：`out/h133_linux_p1_nor_uart0_nor.img`

---

## 1. 文档目的与读者

本文记录 **从硬件到 LVGL 的完整触摸开发过程**，包括：

- 内核 GT9110 选型与设备树；
- `evdev` 输入与 `lv_drivers` 修复；
- **TP 坐标与 LVGL/双显的逻辑坐标统一**（1280×800 横屏）；
- 板上验证命令与常见故障。

相关专题文档：

| 文档 | 内容 |
|------|------|
| [GT9110-规格书要点与驱动对照.md](./硬件资料/GT9110-规格书要点与驱动对照.md) | 芯片 I2C 地址、复位时序、配置组 |
| [H133-双显-LVGL软转实践总结.md](./HDMI/H133-双显-LVGL软转实践总结.md) | MIPI 旋转 + HDMI 不旋转、split fb |
| [H133-TP驱动开发.md](./驱动/TP驱动/H133-TP驱动开发.md) | 早期 GSL 方案（本机已弃用） |
| [一体板调试流程点MD(1).md](./一体板调试流程点MD(1).md) | 一体板 MCU/音频等 |

---

## 2. 产品硬件概要（tuopu-10.1）

| 项目 | 规格 |
|------|------|
| 主控 | H133 |
| 液晶屏 | 10.1 寸，MIPI，物理分辨率 **800×1280**（竖屏） |
| 触摸 IC | **GT9110**，I2C 7 位地址 **0x14**（8 位写 0x28） |
| 触摸走线 | **TWI1**，SCL/SDA：**PG8 / PG9**；**INT：PG3**；**RST：PG2** |
| 外接显示 | **HDMI**，典型 1920×1080（16:9），由 DE 对 fb 内容缩放输出 |
| 目标 UI 逻辑坐标 | **1280×800 横屏**（与 GT911 上报范围一致） |

---

## 3. 整体数据流（最终方案）

```text
                    ┌─────────────────────────────────────┐
                    │  GT9110 @ I2C0x14 (TWI1)             │
                    │  内核 gt9xxnew_ts → /dev/input/eventN │
                    └──────────────────┬──────────────────┘
                                       │ ABS_MT 0~1279 × 0~799
                                       ▼
                    ┌─────────────────────────────────────┐
                    │  lv_drivers/evdev.c                  │
                    │  evdev_touch_init() → event3 等      │
                    │  evdev_read() 钳位到 hor×ver         │
                    └──────────────────┬──────────────────┘
                                       │ 1:1（无 SWAP/CALIBRATE 二次映射）
                                       ▼
                    ┌─────────────────────────────────────┐
                    │  LVGL lv_tp_test                      │
                    │  disp_drv: 1280×800, rotated=0         │
                    │  canvas 白底 + 8px 红点 + 中心坐标     │
                    └──────────────────┬──────────────────┘
                                       │ flush → rotatefbp
                                       ▼
                    ┌─────────────────────────────────────┐
                    │  sunxifb（sunxifb_init(90°)）          │
                    │  rotatefbp 1280×800                    │
                    │  ├─ page0 → HDMI（横屏，DE 缩放到 1080p）│
                    │  └─ page1 → MIPI（软旋转到竖屏面板）   │
                    └─────────────────────────────────────┘
```

**要点**：触摸与 LVGL 画布统一在 **1280×800**；**仅 sunxifb** 负责 MIPI 物理旋转；**禁止** `disp_drv.rotated=90` 与 sunxifb 再叠一层（否则触摸与画面错位）。

---

## 4. 内核与设备树（第一阶段）

### 4.1 驱动选型

| 项目 | 配置 |
|------|------|
| 启用 | `CONFIG_TOUCHSCREEN_GT9XXNEW_TS=y` |
| 关闭 | `CONFIG_TOUCHSCREEN_GSLX680NEW`（原 GSL @ 0x40 已不用） |
| 驱动目录 | `kernel/linux-5.4/drivers/input/touchscreen/gt9xxnew/` |
| 配置组 | `CTP_CFG_GROUP1`：800×1280，I2C 默认 **0x14** |

文件：`device/config/chips/h133/configs/p1_nor/openwrt/bsp_defconfig`

### 4.2 设备树节点

文件：`device/config/chips/h133/configs/p1_nor/linux-5.4/board.dts`

```dts
&twi1 {
	status = "okay";
	ctp@14 {
		compatible = "allwinner,goodix";
		reg = <0x14>;
		ctp_name = "gt9xxnew_ts";
		ctp_twi_id = <0x1>;
		ctp_twi_addr = <0x14>;
		ctp_screen_max_x = <0x320>;   /* 800 */
		ctp_screen_max_y = <0x500>;   /* 1280 */
		ctp_int_port = <&pio PG 3 GPIO_ACTIVE_HIGH>;
		ctp_wakeup = <&pio PG 2 GPIO_ACTIVE_HIGH>;
	};
};
```

### 4.3 板上内核验证

```sh
# I2C 已绑定应为 UU
i2cdetect -y 1

# 输入设备
cat /proc/bus/input/devices | grep -A6 gt9

# 原始坐标（先 killall lv_tp_test 避免占设备）
killall lv_tp_test 2>/dev/null
getevent /dev/input/event3
```

**正常示例**（单点）：

```text
0001 014a 00000001          # BTN_TOUCH down
0003 0035 0000042e          # ABS_MT_POSITION_X = 1070
0003 0036 0000022a          # ABS_MT_POSITION_Y = 554
```

即触摸芯片按约 **1280×800** 上报（与横屏逻辑一致）。

---

## 5. evdev 与 lv_drivers（第二阶段）

### 5.1 自动选择 GT9 节点

`platform/thirdparty/gui/lvgl-8/lv_drivers/indev/evdev.c` 中 `evdev_touch_init()`：

1. 优先 `/dev/input/touchscreen`（若存在）；
2. 扫描 `event0`…`event15`，按能力位判断触摸；
3. 名称含 `gt9xx` 得分最高，绑定对应 `eventN`。

启动 log：`evdev touch opened: /dev/input/event3`

### 5.2 修复：按路径打开设备

早期 `evdev_set_file(dev_name)` 忽略传入路径、固定打开不存在的 `/dev/input/touchscreen`，导致 init 失败。已改为 **使用扫描得到的真实路径**（如 `/dev/input/event3`）。

### 5.3 lv_drv_conf（tuopu-10.1 最终）

文件：`platform/thirdparty/gui/lvgl-8/lv_tp_test/src/lv_drv_conf.h`

```c
#define EVDEV_SWAP_AXES         0
#define EVDEV_CALIBRATE         0
```

触摸 raw 由 `evdev_read()` 按 `disp_drv.hor_res` / `ver_res` **钳位**，与 LVGL 1280×800 一致。

---

## 6. LVGL 应用 lv_tp_test（第三阶段）

### 6.1 包与源码

| 路径 | 说明 |
|------|------|
| `platform/thirdparty/gui/lvgl-8/lv_tp_test/src/main.c` | 测试 UI 主程序 |
| `openwrt/package/thirdparty/gui/lvgl-8/lv_tp_test/Makefile` | OpenWrt 包 |
| `openwrt/target/h133/h133-p1_nor/defconfig` | `CONFIG_PACKAGE_lv_tp_test=y`，`lv_projector` 关闭 |

已删除：`lv_touch_test`（旧触摸测试，易闪屏、坐标逻辑过时）。

### 6.2 功能行为

- 全屏 **白底**（canvas）；
- 手指按下并移动时 **实时** 画 **8px** 红色实心圆（约为初版 36px 的 1/5）；
- **屏幕正中** 显示 `(x, y)`；
- 单实例锁：`/tmp/lv_tp_test.lock`。

### 6.3 开机启动

文件：`openwrt/target/h133/h133-p1_nor/busybox-init-base-files/etc/init.d/rc.final`

```sh
sleep 5
lv_tp_test 1 &
```

参数 `1` = `LV_DISP_ROT_90`，交给 **sunxifb** 做 MIPI 输出旋转（非 LVGL `disp_drv.rotated`）。

---

## 7. 坐标映射（核心 — tuopu-10.1-h133-tp-lvgl）

### 7.1 问题复盘（为何曾「对不齐」）

曾出现现象：

- `getevent` 有坐标，但屏上红点偏到中间小矩形；
- HDMI 与 LCD 红点位置不一致；
- 点四角无法贴边。

**根因**：三套分辨率/旋转变换叠用：

| 层级 | 错误做法 | 结果 |
|------|----------|------|
| LVGL | `hor=800, ver=1280` + `disp_drv.rotated=90` | 触摸再被 LVGL 交换一次 |
| evdev | `CALIBRATE` 把 1280×800 压到 800×1280 | 与肉眼横屏不一致 |
| sunxifb | `sunxifb_init(90)` 软旋转出图 | 必要，但不应与上两项重复 |

### 7.2 正确映射（当前实现）

文件：`lv_tp_test/src/main.c`

```c
/* fb 物理 800×1280，输出旋转 90/270 时 LVGL 逻辑为横屏 */
static void lv_logical_size_from_fb(uint32_t fb_w, uint32_t fb_h,
                   uint32_t out_rot, uint32_t *lv_w, uint32_t *lv_h)
{
    if (out_rot == LV_DISP_ROT_90 || out_rot == LV_DISP_ROT_270) {
        *lv_w = fb_h;   /* 1280 */
        *lv_h = fb_w;   /* 800 */
    } else {
        *lv_w = fb_w;
        *lv_h = fb_h;
    }
}

/* display_init */
sunxifb_init(out_rotated);          /* 例如 90°：MIPI 旋转 + split fb */
disp_drv.hor_res = lv_w;            /* 1280 */
disp_drv.ver_res = lv_h;            /* 800 */
disp_drv.rotated = LV_DISP_ROT_NONE; /* 禁止 LVGL 再转触摸 */
```

| 坐标系 | 宽×高 | 说明 |
|--------|-------|------|
| GT911 / evdev raw | 1280×800 | `getevent` 的 ABS_MT |
| LVGL / canvas / 触摸 | **1280×800** | 与 raw 1:1 钳位 |
| fb 物理（MIPI 面板） | 800×1280 | `sunxifb_get_sizes` |
| sunxifb 输出旋转 | `init(1)` 或 `init(3)` | 仅影响送显，不改变 LVGL 逻辑坐标 |
| HDMI 显示 | 1280×800 内容 **缩放** 到 1080p | 逻辑位置与 LCD 一致，非 1080p 逐像素 1:1 |

### 7.3 HDMI 与「16:10」说明

- LVGL/TP 统一在 **1280×800（16:10）**；
- HDMI 多为 **1920×1080（16:9）**，DE 将 1280×800 **整体缩放**（可能留黑边），故 HDMI **像素** 与 TP **不是** 1:1，但 **逻辑坐标**（红点相对位置）应与 LCD 一致；
- 若需 HDMI 满屏无黑边，需改 DE/HDMI 时序或缩放策略（另案，见 [H133-双显-LVGL软转实践总结.md](./HDMI/H133-双显-LVGL软转实践总结.md)）。

### 7.4 闪屏与绘制优化

| 问题 | 处理 |
|------|------|
| 每点 `lv_obj_create` 导致双缓冲黑屏 | 改为 **单 canvas** 上 `lv_canvas_draw_rect` |
| 刷新过频 | 画点 33ms 节流、仅 invalidate 圆附近小区域 |
| `indev_drv` 在栈上 | 改为 **static** `indev_touch_drv` |

---

## 8. 双显（MIPI + HDMI）

依赖 **sunxifb 软旋转 + fb 拆页 + 内核 `FBIO_HDMI_SRC_FB0`**。

启动 log 应包含：

```text
sunxifb build: DOUBLE_BUFFER=on DIRECT_MODE=off
Turn on double buffering.
Turn on software rotate (G2D disabled).
Split fb: dirty sync HDMI page0 1280x800, MIPI page1 rotate
lv_tp_test: fb 800x1280 -> LVGL 1280x800, sunxifb_rot=1
```

OpenWrt 配置要求（`defconfig`）：

- `CONFIG_LVGL8_USE_SUNXIFB_DOUBLE_BUFFER=y`
- `CONFIG_LVGL8_USE_SUNXIFB_DIRECT_MODE` **关闭**

**仅改 rootfs 不够**：若内核无 split fb / HDMI clone，需 **full 编译**（含 `dev_fb.c`）。

---

## 9. 编译与烧录

### 9.1 脚本

```bash
export H133_SDK_ROOT=/path/to/H133-03
$H133_SDK_ROOT/../.cursor/skills/h133-build/scripts/build_p1_nor.sh rootfs   # 仅应用
$H133_SDK_ROOT/../.cursor/skills/h133-build/scripts/build_p1_nor.sh full      # DTS/内核/sunxifb 变更
```

### 9.2 产物

```text
out/h133_linux_p1_nor_uart0_nor.img
```

### 9.3 涉及文件清单（tuopu-10.1-h133-tp-lvgl）

| 类别 | 路径 |
|------|------|
| DTS | `device/config/chips/h133/configs/p1_nor/linux-5.4/board.dts` |
| 内核配置 | `device/config/chips/h133/configs/p1_nor/openwrt/bsp_defconfig` |
| GT9 驱动 | `kernel/linux-5.4/drivers/input/touchscreen/gt9xxnew/` |
| 显示 | `platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunxifb.c` |
| 触摸 | `platform/thirdparty/gui/lvgl-8/lv_drivers/indev/evdev.c` |
| 测试应用 | `platform/thirdparty/gui/lvgl-8/lv_tp_test/` |
| 开机 | `openwrt/target/h133/h133-p1_nor/busybox-init-base-files/etc/init.d/rc.final` |
| 包配置 | `openwrt/target/h133/h133-p1_nor/defconfig` |

---

## 10. 验收步骤（tuopu-10.1-h133-tp-lvgl）

### 10.1 串口

```sh
ps | grep lv_tp
# 应只有一个 lv_tp_test

# 不要频繁 killall 再手动起（易 fb 状态异常）；完整重启更可靠
```

### 10.2 触摸与画面对齐

1. 开机白底，正中 `(---, ---)`；
2. 点 **左上角** → 红点在角附近，坐标接近 `(0, 0)`；
3. 点 **右下角** → 接近 `(1279, 799)`；
4. 沿四边慢划一圈 → 红点应 **贴边**（不再缩在中间小块）；
5. **HDMI 与 LCD** 上红点 **相对位置** 一致。

### 10.3 方向不对时

```sh
killall lv_tp_test
lv_tp_test 3    # 试 270° 输出旋转（sunxifb）
```

若 X/Y 仍反，再在 `lv_drv_conf.h` 试 `EVDEV_SWAP_AXES 1`（需重新编译 rootfs）。

---

## 11. 故障速查

| 现象 | 可能原因 | 处理 |
|------|----------|------|
| 无 `gt9xxnew_ts` | I2C/供电/RST/INT | 查 `i2cdetect -y 1` 是否 0x14=UU |
| `evdev_touch_init failed` | 节点未生成或路径错误 | 查 eventN、`evdev_set_file` 修复是否编入 |
| 有 getevent 无红点 | `indev_drv` 栈失效 / 双重旋转 | 用当前 `main.c` static + `rotated=0` |
| 红点只在中间一块 | 800×1280 LVGL + 旋转未统一 | 确认 log：`LVGL 1280x800` |
| 点击黑屏闪 | 多对象 + 双缓冲 | 使用 canvas 方案 |
| HDMI 右侧黑边 | 1280×800 → 1080p 缩放 | 正常；要满屏改 DE |
| 无 `Split fb` log | 内核或 DOUBLE_BUFFER 未开 | full 编译 + 检查 defconfig |

---

## 12. 演进记录（简表）

| 阶段 | 内容 |
|------|------|
| v0 | GSL @ 0x40，与 GT911 硬件不符 |
| v1 | GT9110 @ 0x14，TWI1，800×1280 DTS |
| v2 | `lv_touch_test` + evdev 修路径；Segfault（栈上 disp_drv） |
| v3 | `lv_tp_test` canvas；仍 800×1280 LVGL + 旋转错位 |
| **v4（tuopu-10.1-h133-tp-lvgl）** | **1280×800 统一坐标**；sunxifb_rot=1；8px 实时画点；文档本文 |

---

## 13. 唱吧 UI 恢复与触摸接入（已实施）

测试程序 **`lv_tp_test`** 保留在 `platform/thirdparty/gui/lvgl-8/lv_tp_test/`（见该目录 `README.md`），**开机不再自动启动**。

### 13.1 当前开机

`rc.final`：

```sh
sleep 5
lv_projector 3 &
/usr/bin/lv_daemon.sh &
```

> **显示方向定稿**（拓步 10.1 寸）：`sunxifb_rot=3`，MIPI 上 LVGL 与视频同向。详见 [拓步H133-10.1寸-显示方向定稿.md](../HDMI&mipi&lvds/拓步H133-10.1寸-显示方向定稿.md)。

### 13.2 lv_projector 与 lv_tp_test 共用映射

| 项 | lv_tp_test | lv_projector |
|----|------------|----------------|
| LVGL 分辨率 | 1280×800 | 1280×800（`lv_logical_size_from_fb`） |
| `disp_drv.rotated` | `NONE` | `NONE`（`USE_SUNXIFB_SOFT_ROTATE` 时） |
| sunxifb | `init(3)` 量产定稿 | `LV_PROJECTOR_DISP_ROTATE=3` |
| evdev | SWAP=0, CALIB=0 | 同左（`lv_drv_conf.h`） |
| 触摸 init | 重试 50×200ms | `keypad_int()` 同逻辑 |

### 13.3 调试触摸坐标

`projector_config.h` 中设 `ENABLE_TP_DEBUG_OVERLAY 1` 可显示左上角坐标红点（调完改回 `0`）。

### 13.4 defconfig

```text
CONFIG_PACKAGE_lv_projector=y
CONFIG_PACKAGE_lv_tp_test=y    # 仅保留可选手动测试
```

---

## 14. 修订记录

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-06-01 | 1.0 | 初版：tuopu-10.1-h133-tp-lvgl 全流程与坐标映射定稿 |
| 2026-06-01 | 1.1 | 唱吧 lv_projector 恢复并接入 GT911 触摸；lv_tp_test 归档 |
| 2026-06-02 | 1.2 | 显示方向定稿：`sunxifb_rot=3`（MIPI LVGL 与视频同向），见 [显示方向定稿](../HDMI&mipi&lvds/拓步H133-10.1寸-显示方向定稿.md) |
