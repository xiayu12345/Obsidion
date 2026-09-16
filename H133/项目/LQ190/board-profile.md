# H133 p1_nor_LQ190 板级档案

> **2026-08-12 定稿**：LQ190E1LX65 + GM8775C；主机 MIPI `dsi_gen_wr` 灌 RegList（**`0x13=0x63`**）；实机已出清晰系统 UI。  
> 详录：[开发记录/板件开发记录/LQ190/20260811-LQ190-GM8775C-MIPI显示定稿/](../../开发记录/板件开发记录/LQ190/20260811-LQ190-GM8775C-MIPI显示定稿/README.md)

## 工程标识

| 项 | 值 |
|----|-----|
| 板级 | **p1_nor_LQ190** |
| 屏 | Sharp **LQ190E1LX65** 1280×1024 双 LVDS + **GM8775C** MIPI→LVDS；驱动名 `lq190_mipi2edp` |
| UI | `disp_rotate=0`，`tp_rotate=0`；`fb0`=1280×1024（无 DE 放大） |
| 触摸 | **无**；`ctp@5d` disabled（CTP-RST=PG2 作桥片 RST） |
| WiFi | RTL8733BU（继承基线） |
| lunch | `h133-p1_nor_LQ190-tina` |
| 镜像 | `out/h133_linux_p1_nor_LQ190_uart0_nor.img` |
| 板级配置 | `device/config/chips/h133/configs/p1_nor_LQ190/` |
| OpenWrt target | `openwrt/target/h133/h133-p1_nor_LQ190/` |
| 编译 | `./tools/build_p1_nor_LQ190.sh [full\|kernel\|rootfs]` |

## 板件隔绝

| 允许 | 禁止 |
|------|------|
| 只改本板 `configs/` 与 `h133-p1_nor_LQ190/` | 改共享 `p1_nor` DTS 迁就本屏 |
| 独立 `lq190_mipi2edp.c` | 改 `default_panel.c` |
| 兄弟板 LQ190 `not set` | 把本屏时序塞进其它板 |

## 显示定稿

| 项 | 值 |
|----|-----|
| `lcd_driver_name` | `lq190_mipi2edp` |
| 分辨率 | **1280×1024** |
| `lcd_dclk_freq` | **108**（1688×1066×60） |
| porch | HFP194 / HSPW20 / HBP194 → `hbp=214` `ht=1688`；VFP19 / VSPW4 / VBP19 → `vbp=23` `vt=1066` |
| 桥片灌表 | 主机 MIPI：`0x27=0xAA` 解锁 → `dsi_gen_wr`；**`0x13=0x63`**（勿用 `0x53`，会发糊）；**`0x2A=0x01` 关 BIST**；LINE 交换保留（`14/18=34`） |
| 参考 txt | `硬件资料/鸿博芯业/1280x1024_20260811144404.txt`（与驱动同表） |
| 桥片 RST | **`lcd_gpio_0`=PG2**（CTP-RST） |
| `VIDEO_WB_MIRROR_ROTATE` / `dual_display_rot` | **0** |
| U-Boot | `disp_init_enable=1` |
| 背光 | **PB12=PWM0**；**PG15=`lcd_bl_en` ACTIVE_HIGH**（实机 3.3V） |
