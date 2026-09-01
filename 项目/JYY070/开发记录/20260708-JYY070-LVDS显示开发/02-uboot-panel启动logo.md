---
project: JYY070
kind: log
date: 2026-07-08
---

# 02 — U-Boot Panel / 启动 Logo

**上一步：** [01-kernel-panel驱动.md](./01-kernel-panel驱动.md)  
**下一步：** [03-DTS切换LVDS.md](./03-DTS切换LVDS.md)

---

## 1. 本步目标

U-Boot 阶段使用同一套 JYY070 LVDS panel，开机 logo 以 1024×600 正常显示。

**补丁段：** `02-uboot-panel`（合并补丁第二段）

---

## 2. 主要变更

| 文件 | 说明 |
|---|---|
| `brandy/.../lcd/jyy070_lvds.c` | 与内核 panel 逻辑对齐 |
| `brandy/.../lcd/panels.c` / `panels.h` | U-Boot panel 注册 |
| `brandy/.../lcd/Kconfig` | U-Boot Kconfig |
| `brandy/.../configs/sun8iw20p1_defconfig` | 启用 JYY070 panel |

---

## 3. 验收

- U-Boot 编译通过
- 上电后 **开机 logo 横屏 1024×600**，无竖条/花屏
- 若 logo 正常但进 Linux 后黑屏 → 检查 [03-DTS](./03-DTS切换LVDS.md)

---

## 4. 深入阅读

[01-LVDS显示驱动开发记录.md](../../JYY070-7寸LVDS屏-bringup/01-LVDS显示驱动开发记录.md) § U-Boot 章节
