---
project: JYY070
kind: log
date: 2026-07-08
---

# 03 — DTS 切换 LVDS

**上一步：** [02-uboot-panel启动logo.md](./02-uboot-panel启动logo.md)  
**下一步：** [04-app层与sunxifb统一路径.md](./04-app层与sunxifb统一路径.md)

---

## 1. 本步目标

将 `p1_nor_JYY070` 的显示节点从 MIPI 竖屏改为 LVDS 横屏，framebuffer 设为 **1024×600**。

**补丁段：** `03-dts`（合并补丁第三段）

---

## 2. 主要变更

| 文件 | 说明 |
|---|---|
| `device/.../linux-5.4/board.dts` | `&lcd0` 切 JYY070 LVDS；`&disp` fb0=1024×600 |
| `device/.../uboot-board.dts` | U-Boot 侧 panel / disp 与 Linux 一致 |

典型节点调整（示意）：

- `lcd0`：`lcd_driver_name = "jyy070_lvds"`
- `disp`：`fb0_width = <1024>`，`fb0_height = <600>`
- 关闭原 MIPI panel 相关引用

---

## 3. 验收

| 检查项 | 期望 |
|---|---|
| `/dev/fb0` 分辨率 | 1024×600 |
| 进 Linux 后 | 有 fbcon / 企鹅或背景，分辨率正确 |
| `cat /sys/class/graphics/fb0/virtual_size` | `1024,600` |

此步完成后 **硬件层已点亮**（fb0=1024×600 1:1）。若 UI 需 **1280×800 设计画布 + DE 缩放**，继续 [07-DE硬件缩放1280x800.md](./07-DE硬件缩放1280x800.md)。若 UI 仍异常（企鹅闪、无 desk），继续 [04](./04-app层与sunxifb统一路径.md)。

---

## 4. 深入阅读

[01-LVDS显示驱动开发记录.md](../../JYY070-7寸LVDS屏-bringup/01-LVDS显示驱动开发记录.md) § DTS / disp 章节
