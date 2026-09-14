# H133 p1_nor_JL_M101 板级档案（京龙 JL-M101 10.1" MIPI）

> **定稿（2026-07-22）**：实机已完整出图。从 `p1_nor_8733` 克隆；板差异只进本板件目录。  
> 详细笔记：[20260722-JL_M101-板件新建与MIPI显示定稿](../../开发记录/板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/README.md)  
> 触摸定稿：[20260727-JL_M101-GSL3670触摸适配](../../开发记录/板件开发记录/JL_M101/20260727-JL_M101-GSL3670触摸适配/README.md)（2026-07-28 四角坐标）  
> 同显/异显（架构级）：[双屏异显/](../../开发记录/双屏异显/README.md)（本板为首验）  
> phase1 补丁与调试流水：[20260720-JL_M101-JD9365DA-MIPI适配](../../开发记录/板件开发记录/JL_M101/20260720-JL_M101-JD9365DA-MIPI适配/开发记录.md)

## 工程标识

| 项 | 值 |
|----|-----|
| 板级 | **p1_nor_JL_M101** |
| 屏 | JL-M101B196-P21WX-M402632，10.1" **800×1280 MIPI 4-lane**，IC **JD9365DA-H3**，`jl_m101_jd9365da` |
| UI / fb0 | **800×1280**（与 `p1_nor_8733` 同） |
| 触摸 | **GSL3670**（见 [20260727 触摸适配](../../开发记录/板件开发记录/JL_M101/20260727-JL_M101-GSL3670触摸适配/README.md)） |
| WiFi | **RTL8733BU**（继承 8733，不开 AIC8800） |
| lunch | `h133-p1_nor_JL_M101-tina` |
| 镜像 | `out/h133_linux_p1_nor_JL_M101_uart0_nor.img` |
| 定稿 md5（参考） | `05a696f4b7672bc692c645cc3e8bb468`（重编会变） |
| 板级配置 | `device/config/chips/h133/configs/p1_nor_JL_M101/` |
| OpenWrt target | `openwrt/target/h133/h133-p1_nor_JL_M101/` |
| 编译 | `./tools/build_p1_nor_JL_M101.sh [full\|kernel\|rootfs]` |

## 板件隔绝

| 允许 | 禁止 |
|------|------|
| 只改 `configs/p1_nor_JL_M101/**`、`h133-p1_nor_JL_M101/**` | 改 `p1_nor` / `p1_nor_8733` / `JYY070` 的 DTS |
| panel 用独立 `jl_m101_jd9365da.c` | 改公共 `default_panel.c` 迁就本屏 |
| 兄弟板 config 写 JL `not set` | 把京龙 init 塞进共享板 DTS |

## 显示定稿（lcd0）

| 项 | 值 |
|----|-----|
| `lcd_driver_name` | `jl_m101_jd9365da` |
| 时序 | `hbp/ht/hspw=40/880/20`，`vbp/vt/vspw=24/1324/4`，`dclk=70` |
| DSI | `lcd_if=4`，`lane=4`，`dsi_if=0`（video） |
| RESET | `lcd_gpio_0=PB11`；转接板 **3.3V-RESET：R52=0R，R53=NC** |
| 背光 | `lcd_pwm_ch=0`（PB12=PWM0），`freq=50000`，`LCD_bl_open`；**勿** `lcd_bl_en=PB12` |
| U-Boot | `disp_init_enable=0`（避免 smooth 跳过内核灌码；logo 可后续再开） |

## 旋转与坐标（对齐 8733）

| 链路 | 定稿 | 说明 |
|------|------|------|
| **UI** `disp_rotate` | **3** | `/etc/setting.ini`；LVGL **1280×800** |
| **触摸** `tp_rotate` | **0** | DTS：`exchange=1`，`screen_max=report_max=1280×800`（对齐 LVGL；**勿**映回 fb 800×1280） |
| **视频** `VIDEO_WB_MIRROR_ROTATE` | **90** | `libtmedia` 已含本 target |

```ini
[display]
disp_rotate = 3
tp_rotate = 0
```

## 硬件资料

- `H133-AI-Skills/硬件资料/四川京龙/JL-M101B196-P21WX-M402632 规格书V1.0.pdf`
- `…/C-JD9365DA-H3_…_800x1280_…20210830 (1)(1).txt`（init）
- `…/s10-h133-v1_0625.pdf`（CON5 / R52·R53 / PT4117，PWM=50kHz）
- `…/TP-H10_H133 V2.0 2026.6.12.pdf`

## 与其它板

| 板 | 屏 | UI 软旋 | 视频 WB | WiFi |
|----|----|---------|---------|------|
| `p1_nor_8733` | MIPI 800×1280 `default_lcd` | 3 | 90 | 8733BU |
| **本板** | **同分辨率 + JD9365 init + PWM0 背光** | **3** | **90** | **8733BU** |
| `p1_nor_JYY070` | LVDS 1024×600 | 0 | 0 | 8733BU |

## 编译

```bash
./tools/build_p1_nor_JL_M101.sh kernel   # panel/DTS/uboot
./tools/build_p1_nor_JL_M101.sh full
```

切回其它板前必须重新 `lunch` 并重编对应 kernel。
