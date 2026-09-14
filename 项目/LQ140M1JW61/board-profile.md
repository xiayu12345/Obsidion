# H133 p1_nor_LQ140M1JW61 板级档案（Sharp LQ140 14" 1080p）

> **定稿（2026-07-29）**：LCD + HDMI 双显正常，软件直出（rot=0）。  
> 详细笔记：[20260729-LQ140M1JW61-板件新建与双显定稿](../../开发记录/板件开发记录/LQ140M1JW61/20260729-LQ140M1JW61-板件新建与双显定稿/README.md)

## 工程标识

| 项 | 值 |
|----|-----|
| 板级 | **p1_nor_LQ140M1JW61** |
| 屏 | Sharp **LQ140M1JW61** 1920×1080 eDP，经 QE01MIPI001-V01，`lq140_mipi2edp` |
| UI / fb0 | **1920×1080**，`disp_rotate=0` |
| 副屏 | HDMI 1080p，`dual_display_rot=0` |
| WiFi | 继承克隆板（实机日志为 RTL8733BU） |
| lunch | `h133-p1_nor_LQ140M1JW61-tina` |
| 镜像 | `out/h133_linux_p1_nor_LQ140M1JW61_uart0_nor.img` |
| 板级配置 | `device/config/chips/h133/configs/p1_nor_LQ140M1JW61/` |
| OpenWrt target | `openwrt/target/h133/h133-p1_nor_LQ140M1JW61/` |
| 编译 | `./tools/build_p1_nor_LQ140M1JW61.sh [full\|kernel\|rootfs]` |

## 板件隔绝

| 允许 | 禁止 |
|------|------|
| 只改本板 `configs/` 与 `h133-p1_nor_LQ140M1JW61/` | 改共享 `p1_nor` DTS 迁就本屏 |
| 独立 `lq140_mipi2edp.c` | 改 `default_panel.c`；无对照地改 `dev_disp.c` |
| 兄弟板 LQ140 `not set` | 把本屏时序塞进其它板 |

## 显示定稿

| 项 | 值 |
|----|-----|
| `lcd_driver_name` | `lq140_mipi2edp` |
| 时序 | `dclk=139`，`hbp/ht/hspw=112/2080/32`，`vbp/vt/vspw=27/1110/5` |
| DSI | `lcd_if=4`，4-lane，video；init **仅 dsi_clk_enable** |
| RESET / PWM | PB11 / PB12=PWM0@50kHz |
| U-Boot | `disp_init_enable=0` |
| 双显 | `chn_cfg_mode=1`，`dual_display_rot=0`，`fb0=1920×1080` |

## 旋转与坐标

| 链路 | 定稿 |
|------|------|
| UI `disp_rotate` / `sunxifb_rot` | **0** |
| `tp_rotate` | **0** |
| `VIDEO_WB_MIRROR_ROTATE` | **0** |
| `dual_display_rot` | **0** |

## 与其它板

| 板 | 屏 | UI 软旋 | 视频 WB |
|----|----|---------|---------|
| JL_M101 / 8733 | 竖屏 MIPI | 3 | 90 |
| JYY070 | LVDS | 0 | 0 |
| **本板** | **横屏 1080p MIPI→eDP** | **0** | **0** |

## 编译

```bash
./tools/build_p1_nor_LQ140M1JW61.sh kernel
./tools/build_p1_nor_LQ140M1JW61.sh full
```
