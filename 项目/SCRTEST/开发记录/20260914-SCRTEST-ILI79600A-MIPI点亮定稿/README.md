# 音乐骑士 SCRTEST ILI79600A MIPI 点亮定稿 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | **2026-09-14** |
| 板型 | **`p1_nor_SCRTEST`** |
| 基线 | **`p1_nor_JL_M101`** |
| 屏 | 亿中 **01.YZ1.F134YKW7002** / CSOT BPD361BT1，13.36" **1200×1920 MIPI 4-lane**，IC **ILI79600A** |
| panel | `scrtest_ili79600a` |
| 板级档案 | [board-profile-p1_nor_SCRTEST.md](../../../../skills/h133-display/board-profile-p1_nor_SCRTEST.md) |
| 镜像 | `out/h133_linux_p1_nor_SCRTEST_uart0_nor.img` |
| 定稿 MD5 | `72d77193aad40ea11914bbc48ab3be97`（20:13 包，dts 时钟 110） |

---

## 阅读顺序

| 步骤 | 文档 | 内容 |
|---|---|---|
| 0 | [00-总览与定稿.md](./00-总览与定稿.md) | 结论、原厂对照、时钟换算、隔绝 |
| 1 | [01-板件新建.md](./01-板件新建.md) | 从 JL_M101 克隆 |
| 2 | [02-panel与时序.md](./02-panel与时序.md) | 灌码、HSA、porch 公式 |
| 3 | [03-DTS与背光.md](./03-DTS与背光.md) | lcd0 定稿、PWM、旋转 |
| 4 | [04-实机调试与踩坑.md](./04-实机调试与踩坑.md) | 卡死、黑屏、dts×1.5、文档文件名 |
| 5 | [05-编译与验收.md](./05-编译与验收.md) | 编 U-Boot、验收 |

**建议：** 复盘时钟/黑屏 → **00 + 04**；干净树落地 → **补丁 + 05**。

---

## 补丁（定稿，相对干净基线）

路径：[patches/](./patches/)

| 文件 | 内容 |
|---|---|
| `01-kernel-uboot-panel.patch` | 内核+U-Boot `scrtest_ili79600a` + 注册 |
| `02-board-tree.patch` | `p1_nor_SCRTEST` + OpenWrt target + 编译脚本 |
| `03-shared-hooks.patch` | U-Boot defconfig、兄弟板 `not set`、libtmedia |
| `04-docs.patch` | 本定稿 + board-profile |
| `scrtest-ili79600a-display-final.patch` | 以上合并 |
| `apply-scrtest-ili79600a-display-final.sh` | 应用 |
| `gen-scrtest-ili79600a-display-final-patch.sh` | 从当前树重生成 |

**不含**公共 `disp_al.c`（分频保持原厂）。

```bash
bash H133-AI-Skills/开发记录/板件开发记录/SCRTEST/20260914-SCRTEST-ILI79600A-MIPI点亮定稿/patches/apply-scrtest-ili79600a-display-final.sh
./tools/build_p1_nor_SCRTEST.sh kernel
source build/envsetup.sh && p
```

`bootlogo.bmp` 不进补丁；apply 时从 `p1_nor_JL_M101` 复制。

---

*2026-09-14：MIPI 出图定稿；porch 尽量原厂；dts 时钟 110（实际像素钟约 165，约 59Hz）。*
