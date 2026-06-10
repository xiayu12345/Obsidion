# 显示 / HDMI / MIPI 驱动开发

## 资料来源

路径前缀：`H133开发文档-wjz/驱动/HDMI&mipi&lvds/`

| 文档 | 说明 |
|---|---|
| `H133-HDMI驱动原理.md` | HDMI 输出原理 |
| `H133-MIPI-HDMI双显开发记录.md` | MIPI + HDMI 双显方案演进 |
| `H133-DE显示引擎架构详解.md` | Display Engine 架构 |
| `H133-双显-LVGL软转实践总结.md` | LVGL 软旋转实践 |
| `H133-HDMI视频UI共存-问题复盘与原理.md` | 视频层与 UI 层叠关系 |
| `LV_DS-双屏异显中间件架构.md` | lv_ds 双屏异显中间件 |
| `H133-LCD驱动开发.md` | LCD 面板驱动 |
| `H133-LVDS驱动开发.md` | LVDS 面板驱动 |

## 当前关注点

| 项目 | 状态 |
|---|---|
| LCD 主屏 | `[待确认]` |
| HDMI 副屏 | 已启用，`hdmi_used=1` |
| 双显 layer 分配 | `[待确认]` |
| 视频与 UI 共存 | 已有问题复盘资料 |
| MIPI/LVDS 面板差异 | `[待确认]` |

## 关键配置

| 文件 | 用途 |
|---|---|
| `device/config/chips/h133/configs/p1_nor/sys_config.fex` | LCD、HDMI、显示相关板级配置 |
| `device/config/chips/h133/configs/p1_nor/board.dts` | Linux 设备树 |
| `kernel/linux-5.4/` | 显示驱动源码 |

## 开发记录

### 待记录

- 现象：`[待填写]`
- 修改文件：`[待填写]`
- 验证方法：`[待填写]`
- 结论：`[待填写]`
