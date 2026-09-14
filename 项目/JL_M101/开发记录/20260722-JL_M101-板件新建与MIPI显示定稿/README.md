---
project: JL_M101
kind: log
date: 2026-07-22
---

# JL-M101 板件新建与 MIPI 显示定稿 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | 2026-07-20 起；**定稿 2026-07-22（实机已完整出图）** |
| 板型 | **`p1_nor_JL_M101`** |
| 基线 | **`p1_nor_8733`**（MIPI 竖屏 UI + RTL8733BU） |
| 屏 | JL-M101B196-P21WX-M402632，10.1" **800×1280 MIPI 4-lane**，IC **JD9365DA-H3** |
| panel | `jl_m101_jd9365da` |
| 板级档案 | [board-profile-p1_nor_JL_M101.md](../../../../skills/h133-display/board-profile-p1_nor_JL_M101.md) |
| 镜像 | `out/h133_linux_p1_nor_JL_M101_uart0_nor.img` |
| 阶段 1 补丁（初版落地） | [../20260720-JL_M101-JD9365DA-MIPI适配/](../20260720-JL_M101-JD9365DA-MIPI适配/) |

---

## 阅读顺序

| 步骤 | 文档 | 内容 |
|---|---|---|
| 0 | [00-总览与定稿.md](./00-总览与定稿.md) | 结论、对照表、硬件要点、与其它板隔离 |
| 1 | [01-板件新建.md](./01-板件新建.md) | 从 8733 克隆板级 / OpenWrt / 编译脚本 / 公共挂钩 |
| 2 | [02-panel与init.md](./02-panel与init.md) | `jl_m101_jd9365da`、京龙 init、Reset 时序、open_flow |
| 3 | [03-DTS与背光PWM.md](./03-DTS与背光PWM.md) | lcd0 时序、PB11/PB12、PWM0@50kHz、USB 脚冲突 |
| 4 | [04-实机调试与踩坑.md](./04-实机调试与踩坑.md) | smooth、DSI 读探针、RESET 分压、出图路径 |
| 5 | [05-编译与验收.md](./05-编译与验收.md) | 编译命令、验收清单、回归 |

**建议：** 复盘或新开类似屏 → 先读 **00**；从零克隆新板 → **01**；只查 init/PWM → **02/03**；排无图 → **04**。

---

## 补丁（定稿，相对干净基线）

路径：[patches/](./patches/)

| 文件 | 内容 |
|---|---|
| `01-kernel-uboot-panel.patch` | 内核+U-Boot `jl_m101_jd9365da`（含 `LCD_bl_open`）+ 注册 |
| `02-board-tree.patch` | `p1_nor_JL_M101` + OpenWrt target + 编译脚本（含 PWM0@50kHz） |
| `03-shared-hooks.patch` | 兄弟板 not-set、libtmedia |
| `04-docs.patch` | 本定稿文档 + board-profile |
| `jl-m101-display-final.patch` | 以上合并（**干净树一键落地用这个**） |
| `apply-jl-m101-display-final.sh` | 应用 |
| `gen-jl-m101-display-final-patch.sh` | 从当前树重生成 |

```bash
# 干净 SDK 根目录
bash H133-AI-Skills/开发记录/板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/patches/apply-jl-m101-display-final.sh

# 分段
bash …/patches/apply-jl-m101-display-final.sh 01

# 重生成（已有出图树时）
bash …/patches/gen-jl-m101-display-final-patch.sh
```

`bootlogo.bmp` 不进补丁；apply 时若缺失会从 `p1_nor_8733` 复制。

> 若树里**已经**有 JL 板（当前出图树），`--check` / 再 apply 会报 already exists，属正常。

phase1 旧补丁仍在 [../20260720-…/patches/](../20260720-JL_M101-JD9365DA-MIPI适配/patches/)；**新开干净树请用本目录 final 补丁**，勿先打 phase1 再打 final（会冲突）。

---

## 与 20260720 目录的关系

| 目录 | 角色 |
|---|---|
| `20260720-…-MIPI适配/` | phase1 早期补丁与调试流水 |
| **本目录 `20260722-…定稿/`** | **出图定稿文档 + final 补丁** |

---

*2026-07-22：实机完整显示；文档定稿；final 补丁已生成。*
