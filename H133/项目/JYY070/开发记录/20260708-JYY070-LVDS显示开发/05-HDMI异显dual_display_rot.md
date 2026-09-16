---
project: JYY070
kind: log
date: 2026-07-08
---

# 05 — HDMI 异显 dual_display_rot

**上一步：** [04-app层与sunxifb统一路径.md](./04-app层与sunxifb统一路径.md)  
**下一步：** [06-编译与实机验证.md](./06-编译与实机验证.md)

---

## 1. 本步目标

JYY070 横屏（rot=0）插入 HDMI 后，副屏与 LVDS **同向** 显示；旋转角度由 DTS 配置，不再内核写死 rot270。

**补丁段：** `05-dual-display-rot`（合并补丁最后一段）

**前置：** 已完成 [04](./04-app层与sunxifb统一路径.md)（主屏 UI 稳定）

---

## 2. 主要变更

| 文件 | 说明 |
|---|---|
| `kernel/.../dev_disp.c` | G2D 旋转读 `dual_display_rot` DTS |
| `kernel/.../dev_disp.h` | 属性声明 |
| `device/.../board.dts` | `dual_display_rot = <0>`（JYY070 横屏） |

p1_nor MIPI 竖屏对照：`dual_display_rot = <3>`（rot270）。

---

## 3. 问题回顾

| 现象 | 根因 |
|---|---|
| HDMI 全绿 / 方向错 | 内核 dual display 写死 G2D rot270，横屏产品多转 270° |

LVDS 主屏由 sunxifb 负责；HDMI 走 **WB + G2D**，必须单独配旋转角。

---

## 4. 本步验收

插入 HDMI 后串口应出现：

```text
[DISP] dual display HDMI G2D rot0: 1024x600 full on ...
[DISP] dual display enabled: ... G2D rot0 ping-pong 1024x600 (dual_display_rot=0)
```

| 检查项 | JYY070 期望 | p1_nor 回归期望 |
|---|---|---|
| `dual_display_rot` | `0` | `3` |
| G2D log | `rot0` | `rot270` |
| HDMI 画面 | 与 LVDS 同向横屏 | 与 MIPI 竖屏逻辑一致 |

---

## 5. 深入阅读

原理、数据流、方案选型详见 bringup：

[03-HDMI双显旋转DTS可配开发记录.md](../../JYY070-7寸LVDS屏-bringup/03-HDMI双显旋转DTS可配开发记录.md)
