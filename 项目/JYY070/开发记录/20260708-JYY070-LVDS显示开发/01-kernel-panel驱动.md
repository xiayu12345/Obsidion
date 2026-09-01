---
project: JYY070
kind: log
date: 2026-07-08
---

# 01 — Kernel Panel 驱动

**上一步：** [00-背景与路径统一.md](./00-背景与路径统一.md)  
**下一步：** [02-uboot-panel启动logo.md](./02-uboot-panel启动logo.md)

---

## 1. 本步目标

在内核 disp2 框架中注册 JYY070 LVDS panel 驱动，使 Linux 能按 1024×600 时序点亮屏。

**补丁段：** `01-kernel-panel`（合并补丁第一段）

---

## 2. 主要变更

| 文件 | 说明 |
|---|---|
| `kernel/.../lcd/jyy070_lvds.c` | panel 时序、上电序列 |
| `kernel/.../lcd/jyy070_lvds.h` | 屏参宏 |
| `kernel/.../lcd/panels.c` / `panels.h` | 注册 `jyy070_lvds` |
| `kernel/.../lcd/Kconfig` | `CONFIG_LCD_SUPPORT_JYY070_LVDS` |
| `kernel/.../disp/Makefile` | 编译 jyy070_lvds.o |
| `device/.../config-5.4` | 打开上述 Kconfig |

---

## 3. 验收

- 内核编译通过，无 panel 相关 link 错误
- 启动后 `dmesg` 可见 JYY070 / LVDS panel 加载（具体 log 见 bringup 01）

---

## 4. 深入阅读

硬件接线、时序表、寄存器细节见 bringup 主文档：

[01-LVDS显示驱动开发记录.md](../../JYY070-7寸LVDS屏-bringup/01-LVDS显示驱动开发记录.md) § 内核 panel 章节
