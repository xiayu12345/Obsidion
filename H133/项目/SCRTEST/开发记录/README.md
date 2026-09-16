# SCRTEST ILI79600A MIPI — 文档索引

| 项 | 内容 |
|---|---|
| 项目 | 音乐骑士（测屏工程） |
| 板型 | `p1_nor_SCRTEST`（从 `p1_nor_JL_M101` 克隆） |
| 屏 | 亿中 **01.YZ1.F134YKW7002**，13.36" **1200×1920 MIPI**，IC **ILI79600A** |
| panel | `scrtest_ili79600a` |
| 状态 | **2026-09-14 出图定稿**（dts 时钟 110，实际约 165MHz / 59Hz）；触摸 disabled |
| 板级档案 | [board-profile-p1_nor_SCRTEST.md](../../../../skills/h133-display/board-profile-p1_nor_SCRTEST.md) |

## 阅读顺序

| 优先级 | 文档 | 内容 |
|---|---|---|
| **主** | [20260914-ILI79600A-MIPI点亮定稿/](./20260914-SCRTEST-ILI79600A-MIPI点亮定稿/README.md) | **板件新建 + 显示定稿 + final 补丁** |

定稿目录：`00 总览` → `01 板件新建` → `02 panel/时序` → `03 DTS` → `04 踩坑` → `05 编译验收`。

**干净树一键落地：**

```bash
bash H133-AI-Skills/开发记录/板件开发记录/SCRTEST/20260914-SCRTEST-ILI79600A-MIPI点亮定稿/patches/apply-scrtest-ili79600a-display-final.sh
./tools/build_p1_nor_SCRTEST.sh kernel
source build/envsetup.sh && p
```

## 硬件资料

`H133-AI-Skills/硬件资料/音乐骑士/新屏幕资料/13.36+79600  60HZ SPI 调试资料/`

LCD 手册：`h133-开发资料/Linux_CCU_开发指南.pdf`（标题是 Linux LCD）。

## 编译

```bash
export PATH="$PWD/prebuilt/hostbuilt/make4.1/bin:$PATH"
./tools/build_p1_nor_SCRTEST.sh kernel
./tools/build_p1_nor_SCRTEST.sh full
# 产物：out/h133_linux_p1_nor_SCRTEST_uart0_nor.img
```

禁止改兄弟板 DTS、改 `default_panel.c` / `jl_m101_jd9365da.c`、改公共 `disp_al.c` 分频。
