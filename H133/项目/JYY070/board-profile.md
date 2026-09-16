# H133 p1_nor_JYY070 板级档案（JYY070 7" LVDS）

> **当前定稿（2026-07-17）**。板差异只进本板件目录；UI / 视频 / 触摸旋转分三路，勿混用。

## 工程标识

| 项 | 值 |
|----|-----|
| 板级 | **p1_nor_JYY070** |
| 屏 | JYY070BD35L27A1-50，7" **1024×600 LVDS** 横屏，`jyy070_lvds` |
| UI / fb0 | **1280×800**（DE0 VSU 缩放到 LVDS 1024×600） |
| 触摸 | **GSL1680**（内核映射到 1280×800） |
| WiFi | **RTL8733BU**（对齐 `p1_nor_8733`，不开 AIC8800） |
| lunch | `h133-p1_nor_JYY070-tina` |
| 镜像 | `out/h133_linux_p1_nor_JYY070_uart0_nor.img` |
| 板级配置 | `device/config/chips/h133/configs/p1_nor_JYY070/` |
| OpenWrt target | `openwrt/target/h133/h133-p1_nor_JYY070/` |
| 工厂 ini | `…/busybox-init-base-files/etc/setting.ini` |
| 音频默认 | **HDMI**（`sound_output=1`，`audio_output.mode=hdmi`，`asound`→`PlaybackHDMI`/`sndi2s2`）；SPDIF 仍可设置里切回 |

## 板件隔绝

| 允许 | 禁止 |
|------|------|
| 只改 `configs/p1_nor_JYY070/**`、`h133-p1_nor_JYY070/**` | 改 `p1_nor` / `p1_nor_8733` 的 DTS |
| panel 用独立 `jyy070_lvds.c` + 本板 bsp | 改公共 `default_panel.c` 迁就本屏 |
| 视频角用 `libtmedia` 按 target `-D` | 在共享 `.c` 里按板名写死行为 |

## 旋转与坐标（三路独立）

| 链路 | 控制入口 | JYY070 定稿 | 说明 |
|------|----------|-------------|------|
| **UI**（LVGL / sunxifb） | `setting.ini` → `[display] disp_rotate` | **`0`** | desk：`lv_orient_disp_rotate_boot` → `sunxifb_init`；优先 `/mnt/UDISK/setting.ini`，否则 `/etc/setting.ini` |
| **触摸**（evdev 软旋） | 同 ini → `tp_rotate` | **`0`** | 内核已 `ctp_revert_x/y=1` + `ctp_report_max 1280×800`；再设 `tp_rotate=2` 会 **180° 错位**（点左上→逻辑右下） |
| **视频**（TPlayer WB mirror） | `libtmedia/Makefile` → `VIDEO_WB_MIRROR_ROTATE` | **`0`** | 消费于 `tlayer_ctrl.c`；**不读** ini。`TPlayerSetRotate(0)` 管不了这条 |

兜底宏（**仅无有效 ini 时**）：`LV_ORIENT_DEFAULT_DISP=3`、`LV_ORIENT_DEFAULT_TP=2`、`LV_PROJECTOR_DISP_ROTATE=3`。有工厂 `/etc/setting.ini` 时以 ini 为准。

### 工厂 `[display]`（树内）

```ini
[display]
disp_rotate = 0
tp_rotate = 0
```

刷机后若触摸仍反：先查 UDISK 是否覆盖：

```bash
grep -E 'disp_rotate|tp_rotate' /mnt/UDISK/setting.ini /etc/setting.ini
# 有 /mnt/UDISK/setting.ini 则改 tp_rotate=0，或删掉该文件后重启 desk
```

### 视频宏（树内）

```makefile
# openwrt/package/.../tina_multimedia/libtmedia/Makefile
# p1_nor / p1_nor_8733 → 90；JYY070 → 0
ifeq ($(CONFIG_TARGET_h133_p1_nor_JYY070),y)
TARGET_CFLAGS+=-DVIDEO_WB_MIRROR_ROTATE=0
endif
```

### 触摸内核（本板 DTS）

| 属性 | 值 |
|------|-----|
| `ctp_screen_max_x/y` | 1024 / 600 |
| `ctp_report_max_x/y` | 1280 / 800 |
| `ctp_revert_x/y` | 1 / 1 |
| `ctp_exchange_x_y` | 0 |

## 与其它板

| 板 | 屏 | UI 软旋（典型） | 视频 WB | WiFi |
|----|----|-----------------|---------|------|
| `p1_nor` | MIPI 800×1280 | 多为 3（ini/兜底） | 90 | AIC8800 |
| `p1_nor_8733` | 同 p1_nor | 同左 | 90 | **8733BU** |
| **本板** | **LVDS 1024×600** | **`disp_rotate=0`** | **0** | **8733BU** |

## 编译

```bash
# 改 setting.ini / rootfs 应用：rootfs 即可
./tools/build_p1_nor_JYY070.sh rootfs

# 改内核 / DTS / panel：full 或 kernel 后再 rootfs
./tools/build_p1_nor_JYY070.sh full
# 或
source build/envsetup.sh && lunch h133-p1_nor_JYY070-tina
./build.sh kernel bootloader
cp -a out/h133/kernel/staging/{boot.img,uImage} out/h133/p1_nor_JYY070/openwrt/
m -j$(nproc) && p
```

切回其它板前必须重新 `lunch` 并重编对应 kernel。

## 相关开发记录

| 主题 | 文档 |
|------|------|
| 索引 | [开发记录/板件开发记录/JYY070](../../开发记录/板件开发记录/JYY070/README.md) |
| LVDS 显示 / DE 缩放 / HDMI 异显 | [20260708-JYY070-LVDS显示开发](../../开发记录/板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/README.md) |
| GSL1680 坐标映射 | [GSL触摸坐标映射](../../开发记录/GSL触摸坐标映射/README.md)（架构）；本板验证 [20260710](../../开发记录/板件开发记录/JYY070/20260710-JYY070-GSL1680触摸坐标内核映射/开发记录.md) |
| 视频 WB 旋转角 | [20260713-视频WB-mirror旋转](../../开发记录/板件开发记录/JYY070/20260713-JYY070-视频WB-mirror旋转/开发记录.md) |
| 8733BU WiFi | [20260713-8733BU-WiFi适配](../../开发记录/板件开发记录/JYY070/20260713-JYY070-8733BU-WiFi适配/开发记录.md) |
| 双板串编验证 | [20260714-双板串编验证](../../开发记录/板件开发记录/JYY070/20260714-双板串编验证/开发记录.md) |
| 默认 HDMI 音频 | [20260717-默认HDMI音频](../../开发记录/板件开发记录/JYY070/20260717-JYY070-默认HDMI音频/README.md) |

> 早期「LVGL 编译宏不旋转 / 应用层硬编码 rot=0」记录仍保留作历史；**树内当前以 ini `disp_rotate` + 本档案为准**。
