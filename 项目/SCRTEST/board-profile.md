# H133 p1_nor_SCRTEST 板级档案（屏幕测试 / ILI79600A）

> **2026-09-14 出图定稿**（基线 `p1_nor_JL_M101`）。触摸 DTS 已关。  
> 屏资料：`硬件资料/音乐骑士/新屏幕资料/13.36+79600  60HZ SPI 调试资料/`  
> 定稿笔记：[20260914-SCRTEST-ILI79600A-MIPI点亮定稿](../../开发记录/板件开发记录/SCRTEST/20260914-SCRTEST-ILI79600A-MIPI点亮定稿/README.md)

## 工程标识

| 项 | 值 |
|----|-----|
| 项目 | 音乐骑士（测屏工程） |
| 板级 | **p1_nor_SCRTEST**（NOR） |
| 屏 | 亿中 **01.YZ1.F134YKW7002**，13.36" **1200×1920 MIPI 4-lane**，IC **ILI79600A** |
| 驱动名 | `scrtest_ili79600a` |
| UI / fb0 | 物理 **1200×1920**；`disp_rotate=1`，`video_rotate=2` |
| 触摸 | TDDI SPI；本板 `ctp@40` **disabled** |
| WiFi | RTL8733BU |
| lunch | `h133-p1_nor_SCRTEST-tina` |
| 镜像 | `out/h133_linux_p1_nor_SCRTEST_uart0_nor.img` |
| 板级配置 | `device/config/chips/h133/configs/p1_nor_SCRTEST/` |
| OpenWrt target | `openwrt/target/h133/h133-p1_nor_SCRTEST/` |
| 编译 | `./tools/build_p1_nor_SCRTEST.sh [full\|kernel\|rootfs]` |
| 基线 | `p1_nor_JL_M101` |

## 板件隔绝

| 允许 | 禁止 |
|------|------|
| 只改本板 `configs/p1_nor_SCRTEST/`、`h133-p1_nor_SCRTEST/` | 改 JL_M101 / 其它板 DTS 迁就本屏 |
| 独立 `scrtest_ili79600a.c` | 改 `jl_m101_jd9365da.c` / `default_panel.c` / 公共 `disp_al.c` 分频 |

## 显示（2026-09-14 定稿）

| 项 | 值 |
|----|-----|
| `lcd_driver_name` | `scrtest_ili79600a` |
| 分辨率 | **1200×1920** |
| DSI | `lcd_if=4`，**4-lane** video；`dsi_gen_wr` |
| 厂家 porch | HSA2 HBP20 HFP20 / VSA2 VBP64 VFP270；PCLK 169 |
| Allwinner 定稿 | `hspw/hbp/ht=4/24/1244`，`vspw/vbp/vt=2/66/2256` |
| `lcd_dclk_freq` | **110**（实际像素钟 ≈165MHz，DSI 钉 150；约 59Hz） |
| RESET / PWM | PB11 / PB12 PWM0@50kHz `pol=1` |
| U-Boot | `disp_init_enable=0`（BootGUI 仍开屏） |
| 灌码 | `TEST_79600A_…DSC oFF`；**不做 DSI 读** |

## 编译

```bash
export PATH="/root/Work/H133-AIKTV/prebuilt/hostbuilt/make4.1/bin:$PATH"
./tools/build_p1_nor_SCRTEST.sh kernel
source build/envsetup.sh && p
```
