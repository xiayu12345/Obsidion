# H133 项目速览

> 本章节是 H133 固件工程的**总览入口**，适合新人上手或长期未接触后快速回忆。细节来自 Ubuntu 工程 `~/Workspace/HDMI_new/HDMI` 实测配置（板型 **p1_nor**）。

## 一句话

**全志 H133 + Tina Linux + LVGL 8.3 投影仪/KTV 一体机固件**，主应用 `lv_projector`，当前板型 SPI NOR 启动，MIPI 10.1 寸屏 + HDMI 双显输出。

## 速查卡片

| 项 | 值 |
|---|---|
| 芯片 | Allwinner H133（sun8iw20p1，Cortex-A7） |
| 板型 | **h133-p1_nor**（machine = p1） |
| Flash | SPI NOR，32MB（BY25FQ256ES 级） |
| 主应用 | `lv_projector` v8.3.2 |
| 固件版本前缀 | `H135-P1-`（`projector_config.h`） |
| 工程路径 | `/home/xiayu/Workspace/HDMI_new/HDMI` |
| 整包镜像 | `out/h133_linux_p1_nor_uart0_nor.img`（约 17MB） |
| 板端登录 | root / tina，SSH 22 |

## 子页面

| 页面 | 内容 |
|---|---|
| [[基本信息]] | 项目定位、功能清单、板型对照、路径约定 |
| [[硬件平台]] | 芯片、Flash 分区、显示/触摸/外设、引脚概要 |
| [[软件平台]] | 软件栈、功能开关、启动参数、rootfs 布局 |
| [[代码仓库]] | repo 多仓结构、关键路径、Git 与笔记库关系 |

## 30 秒上手

```bash
# 1. 连开发机
ssh h133-ubuntu
cd ~/Workspace/HDMI_new/HDMI

# 2. 编译打包
source build/envsetup.sh
m && p

# 3. 产物
ls -lh out/h133_linux_p1_nor_uart0_nor.img
```

改 DTS / 内核 / U-Boot 后须先 `./build.sh kernel bootloader`，再 `m && p`。

## 下一步读什么

| 目标 | 跳转 |
|---|---|
| 搭环境 | [[../开发环境/环境搭建]] |
| 编译烧录 | [[../常用命令速查/编译相关]]、[[../常用命令速查/烧录相关]] |
| 查引脚 | [[../引脚定义速查/index]] |
| 踩坑 | [[../踩坑记录/index]] |
| 驱动长文 | [[../开发记录/index]] |


## 自动补充 - 2026-06-10

本次自动分析依据 Ubuntu 工程：`/home/xiayu/Workspace/HDMI_new/HDMI`。

- 主控/平台：Allwinner H133，工程平台标识 `sun8iw20p1`，当前配置 `p1_nor`，启动/存储目标为 SPI NOR。
- 软件形态：Tina Linux / OpenWrt SDK，Linux kernel 5.4.61，业务应用以 `lv_projector` 为主。
- 工具链：`.buildconfig` 中为 `arm-linux-gnueabi`，OpenWrt defconfig 中另有 `arm-openwrt-linux-` 目标工具链配置。
- 需要确认：用户最初给出的 `/home/Workspace/HDMI_new/HDMI` 不存在，实际扫描路径为 `/home/xiayu/Workspace/HDMI_new/HDMI`。
