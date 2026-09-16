# H133 p1_nor_ZS101 板级档案（纽曼 / 中深 ZS101 10.1" MIPI）

> **2026-08-25 实机已点亮**；**2026-08-27 GT928 触摸定稿**。  
> 显示：[开发记录/板件开发记录/ZS101/20260825-ZS101-ILI9881C-MIPI显示点亮/](../../开发记录/板件开发记录/ZS101/20260825-ZS101-ILI9881C-MIPI显示点亮/README.md)  
> 触摸：[20260827 GT928](../../开发记录/板件开发记录/ZS101/20260827-ZS101-GT928触摸适配/README.md)  
> 资料：[20260817 梳理](../../开发记录/板件开发记录/ZS101/20260817-纽曼ZS101-资料梳理与待确认/README.md)

## 工程标识

| 项 | 值 |
|----|-----|
| 项目 | **纽曼** |
| 板级 | **p1_nor_ZS101**（NOR） |
| 屏 | 中深 **ZS101NI4042J4H8II-B** 10.1" **800×1280 MIPI 4-lane**，IC **ILI9881C**；驱动名 `zs101_ili9881c` |
| UI | 物理 `fb0`=800×1280；`disp_rotate=3` → LVGL **1280×800** |
| HDMI | `dual_display_rot=3`（竖屏 DE0 → 横屏 HDMI）；`VIDEO_WB_MIRROR_ROTATE=90` |
| 触摸 | **FXT101041 GT928** I2C `0x5d`，TWI1 PG8/9，INT=PG3，RST=PG2；`ctp_name=gt928_fxt101041`→GROUP2；`revert_y=1`；量程 1280×800 |
| WiFi | RTL8733BU（继承基线） |
| lunch | `h133-p1_nor_ZS101-tina` |
| 镜像 | `out/h133_linux_p1_nor_ZS101_uart0_nor.img` |
| 板级配置 | `device/config/chips/h133/configs/p1_nor_ZS101/` |
| OpenWrt target | `openwrt/target/h133/h133-p1_nor_ZS101/` |
| 编译 | `./tools/build_p1_nor_ZS101.sh [full\|kernel\|rootfs]` |

## 板件隔绝

| 允许 | 禁止 |
|------|------|
| 只改本板 `configs/` 与 `h133-p1_nor_ZS101/` | 改共享 `p1_nor` / JL_M101 DTS 迁就本屏 |
| 独立 `zs101_ili9881c.c` | 改 `default_panel.c` 或现有 `ili9881c.c` |
| 兄弟板 ZS101 `not set` | 把本屏 init/时序塞进其它板 |

## 显示（2026-08-25 实机点亮）

| 项 | 值 |
|----|-----|
| `lcd_driver_name` | `zs101_ili9881c` |
| 分辨率 | **800×1280** |
| `lcd_dclk_freq` | **73**（规格书无钟；`936×1304×60`） |
| porch | HSA16/HBP60/HFP60 → `hspw=16` `hbp=76` `ht=936`；VSA4/VBP10/VFP10 → `vspw=4` `vbp=14` `vt=1304` |
| DSI | `lcd_if=4`，4-lane，`dsi_if=0`（video non-burst） |
| RESET / PWM | **PB11 RST、PB12 PWM0@50kHz**（继承京龙；主板 rar 未解） |
| U-Boot | 调屏期 `disp_init_enable=0` |

## 旋转依据

规格书 §6.1：Horizontal=800、Vertical=1280；模组 143×228.6 竖条。原生竖屏，产品横屏必须软旋（同 JL_M101，不是抄习惯）。

## 硬件资料

- `H133-AI-Skills/硬件资料/纽曼/ZS101NI4042J4H8II-B.pdf`
- `…/新代码02群创10.1(T2)+ILI9881C-0D_2P_20190920.c`
- `…/纽曼h133主板：ZX30-D618-H133.rar`（未解）
