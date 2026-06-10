# H133 开发记录

> 完整长篇文档在 Ubuntu 工程 `H133开发文档-wjz/`，此处为索引与摘要入口。

## 工程内精简笔记（docs/）

| 日期 | 主题 | 路径 |
|---|---|---|
| 2026-05-28 | G2D ABI + 顶层编译 | `docs/debug-notes-g2d-abi-and-toplevel-build.md` |
| 2026-05-29 | SD 卡 DiskManager | `docs/H133-Tina-SD卡调试经验.md` |

## 驱动开发记录

### 显示 / HDMI / MIPI

| 文档 | 说明 |
|---|---|
| H133-HDMI驱动原理.md | HDMI 输出原理 |
| H133-MIPI-HDMI双显开发记录.md | 双显方案演进 |
| H133-DE显示引擎架构详解.md | DE 架构 |
| H133-双显-LVGL软转实践总结.md | LVGL 软旋转 |
| H133-HDMI视频UI共存-问题复盘与原理.md | 视频与 UI 层叠 |
| LV_DS-双屏异显中间件架构.md | lv_ds 中间件 |
| H133-LCD驱动开发.md / H133-LVDS驱动开发.md | 面板驱动 |

路径前缀：`H133开发文档-wjz/驱动/HDMI&mipi&lvds/`

### 触摸 / 输入

| 文档 | 说明 |
|---|---|
| H133-GT9110触摸驱动开发过程.md | GT911  bring-up |
| H133-USB鼠标与GT911触摸并存-lvgl.md | 双输入源 |
| tuopu-10.1-h133-tp-lvgl...md | 10.1 寸 TP 坐标映射 |

路径前缀：`H133开发文档-wjz/驱动/TP驱动&鼠标&触摸/`

### 音频 / 网络 / 其他

| 文档 | 说明 |
|---|---|
| 拓步H133功放板驱动调试流程（UART + SPDIF）.md | 功放 |
| H133-WiFi驱动开发.md | WiFi |
| H133-44100单声道播放修复与ALSA路由方案.md | ALSA |
| H133-视频旋转-TPlayer路径说明.md | 视频旋转 |

## 基础资料 / 流程

| 文档 | 说明 |
|---|---|
| 工程编译方式.txt | m/p 命令速查 |
| lv_projector_烧录流程_123版.md | adb 快速刷应用 |
| H133-SFTP开发.md | OpenSSH 集成 |
| H133-rootfs空间与应用占用说明.md | 分区与体积 |

路径前缀：`H133开发文档-wjz/基础资料/`

## 如何在 Ubuntu 浏览

```bash
ssh h133-ubuntu
cd ~/Workspace/HDMI_new/HDMI
ls "H133开发文档-wjz/驱动/"
ls docs/
```

## 笔记维护约定

- **踩坑** → 确认根因后写入 [[踩坑记录/index]]
- **流程变更** → 更新 [[常用命令速查/编译相关]] 或 [[开发环境/环境搭建]]
- **引脚变更** → 更新 [[引脚定义速查/index]]
