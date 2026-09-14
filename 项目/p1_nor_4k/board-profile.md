# H133 p1_nor_4k 板级档案（纯 HDMI 1080p + RTL8733BU）

> 板件从 `p1_nor_8733` 分离。初版曾走 HDMI 4K；**当前显示基线为 1080p60，fb0=1920×1080（1:1）**。

## 工程标识

| 项 | 值 |
|----|-----|
| 板级 | **p1_nor_4k** |
| 显示 | **HDMI 1080p60**（`DISP_TV_MOD_1080P_60HZ` / mode **10**） |
| UI / fb0 | **1920×1080**（与输出 1:1；Guider 仍 1280×800，贴左上） |
| 触摸 | 默认关闭（无本板屏 TP） |
| WiFi | **RTL8733BU**（对齐 `p1_nor_8733`） |
| lunch | `h133-p1_nor_4k-tina` |
| 镜像 | `out/h133_linux_p1_nor_4k_uart0_nor.img` |
| 板级配置 | `device/config/chips/h133/configs/p1_nor_4k/` |
| OpenWrt target | `openwrt/target/h133/h133-p1_nor_4k/` |
| 工厂 ini | `…/busybox-init-base-files/etc/setting.ini` |
| 编译脚本 | `tools/build_p1_nor_4k.sh` |

## 板件隔绝

| 允许 | 禁止 |
|------|------|
| 只改 `configs/p1_nor_4k/**`、`h133-p1_nor_4k/**` | 改其它板 DTS 迁就本板显示 |
| `libtmedia` 按 target `-DVIDEO_WB_MIRROR_ROTATE=0` | 在共享 `.c` 里按板名写死 |

## 显示要点

| 项 | 值 |
|----|-----|
| `screen0_output_type` | HDMI（`3`） |
| `screen0_output_mode` | **`10`**（1080p60） |
| `fb0_width/height` | **1920×1080** |
| `lcd_used` | `0` |
| `disp_rotate` | `0` |
| `video_screen_w/h`（ini） | 1920×1080 |
| `cma`（板件基线） | `8M` |

### 说明（为何 fb=输出尺寸）

`fb0` 小于 HDMI 输出时，内核默认 `screen_win`=整屏 → DE VSU **拉伸铺满**。  
fb 与输出同为 1920×1080 则 1:1；业务 UI 仍按 1280×800 画在左上。详见 [20260724 开发记录](../../开发记录/板件开发记录/p1_nor_4k/20260724-p1_nor_4k-HDMI1080p-fb0对齐/开发记录.md)。

## 相关开发记录

- [HDMI 1080p + fb0 1:1（当前显示基线）](../../开发记录/板件开发记录/p1_nor_4k/20260724-p1_nor_4k-HDMI1080p-fb0对齐/开发记录.md)
- [板件新建与 HDMI4K 分离（历史）](../../开发记录/板件开发记录/p1_nor_4k/20260723-p1_nor_4k-板件新建与HDMI4K分离/)
- [CMA 与 lv_img_header（可选超 2047 硬解）](../../开发记录/板件开发记录/p1_nor_4k/CMA与lv_img_header-4K硬解/)
