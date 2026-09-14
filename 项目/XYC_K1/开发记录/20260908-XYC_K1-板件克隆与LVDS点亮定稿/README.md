# 鑫宇宸 XYC_K1 板件新建与 LVDS 点亮定稿 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-08（克隆当天点亮） |
| 板型 | **`p1_nor_XYC_K1`** |
| 基线 | **`p1_nor_JYY070`** |
| 屏 | LTN141AT0-001，14.1" **1280×800 LVDS 1ch 6-bit** |
| panel | `xyc_k1_lvds` |
| 板级档案 | [board-profile-p1_nor_XYC_K1.md](../../../../skills/h133-display/board-profile-p1_nor_XYC_K1.md) |
| 镜像 | `out/h133_linux_p1_nor_XYC_K1_uart0_nor.img` |
| 定稿参考 MD5 | `bd312edc87f1506e507d5bae3b8277fc`（后续重编会变） |

---

## 阅读顺序

| 步骤 | 文档 | 内容 |
|---|---|---|
| 0 | [00-总览与定稿.md](./00-总览与定稿.md) | 结论、对照表、硬件要点、隔绝 |
| 1 | [01-板件新建.md](./01-板件新建.md) | 从 JYY070 克隆板级 / OpenWrt / 编译脚本 |
| 2 | [02-panel与时序.md](./02-panel与时序.md) | `xyc_k1_lvds`、open_flow、时序来源 |
| 3 | [03-DTS与背光.md](./03-DTS与背光.md) | lcd0、PB12 GPIO EN、pwm0、USB 脚 |
| 4 | [04-实机调试与踩坑.md](./04-实机调试与踩坑.md) | HDMI 全绿、PWM 崩机、背光不亮、**U-Boot 没进镜像** |
| 5 | [05-编译与验收.md](./05-编译与验收.md) | NOR U-Boot、验收清单 |

**建议：** 复盘或新开类似 LVDS → 先读 **00**；从零克隆 → **01**；排绿屏/灭灯 → **04**。

---

## 补丁（定稿，相对干净基线）

路径：[patches/](./patches/)

| 文件 | 内容 |
|---|---|
| `01-kernel-uboot-panel.patch` | 内核+U-Boot `xyc_k1_lvds` + 注册；**含** BL3676 `betterlife_ts`（专题见 [BL3676触摸适配](../20260908-XYC_K1-BL3676触摸适配/README.md)） |
| `02-board-tree.patch` | `p1_nor_XYC_K1` + OpenWrt target + 编译脚本 |
| `03-shared-hooks.patch` | U-Boot `sun8iw20p1(_nor)_defconfig` 打开本 panel |
| `04-docs.patch` | 本定稿文档 + board-profile |
| `xyc-k1-display-final.patch` | 以上合并（**干净树一键落地用这个**） |
| `apply-xyc-k1-display-final.sh` | 应用 |
| `gen-xyc-k1-display-final-patch.sh` | 从当前树重生成 |

```bash
# 干净 SDK 根目录
bash H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-板件克隆与LVDS点亮定稿/patches/apply-xyc-k1-display-final.sh

# 分段
bash …/patches/apply-xyc-k1-display-final.sh 01

# 重生成（已有出图树时）
bash …/patches/gen-xyc-k1-display-final-patch.sh
```

`bootlogo.bmp` 不进补丁；apply 时若缺失会从 `p1_nor_JYY070` 复制。

> 若树里**已经**有 XYC 板（当前出图树），再 apply 会报 already exists，属正常。

---

*2026-09-08：实机 LCD+HDMI 出图、背光常亮；文档定稿；final 补丁已生成。*
