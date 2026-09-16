---
project: JL_M101
kind: log
date: 2026-07-27
---

# JL-M101 GSL3670 触摸适配 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | **2026-07-27** 报点 → **2026-07-28** 固件/四角 → **2026-08-03** `report_max` 对齐 LVGL |
| 板型 | `p1_nor_JL_M101` |
| 触摸 | 板载 **GSL3670**，I2C `0x40`，TWI1 PG8/PG9，INT=PG3，RST=PG2 |
| 固件源 | `kernel/.../gslx680new/GSL3670_JL_M101.h`（与其它板型 `.h` 同目录） |
| 运行 bin | `openwrt/.../gsl_firmware/gsl3670.bin`（芯片逻辑 **800×1280**） |
| 坐标 | `exchange=1`；`screen_max=report_max=1280×800`；`revert=0`；`tp_rotate=0` |
| bin md5 | `26c831f3d9884fecc5fdbd329d863a3e`（42227 字节） |
| startup | `0xb0=5a5a5a5a` (OK) |
| 镜像（08-03） | `out/h133_linux_p1_nor_JL_M101_uart0_nor.img` md5 `e8bb8718230399d5c2ed958d73f9a29b` |
| 基线 | 须先有 [20260722 显示定稿](../20260722-JL_M101-板件新建与MIPI显示定稿/)（原 ctp 为 gt911@5d） |

---

## 阅读

| 文档 | 内容 |
|---|---|
| [开发记录.md](./开发记录.md) | 结论、固件来源、A/B、坐标调校、踩坑、验收 |

## 补丁

路径：[patches/](./patches/)

| 文件 | 作用 |
|---|---|
| `01-dts-config-gsl3670.patch` | board.dts gt911→gsl3670（含坐标定稿）；`CONFIG_EXTRA_FIRMWARE`；新增 `tools/gsl_pack_firmware.py` |
| `files/gsl3670.bin` | 定稿固件副本（与 openwrt 同步） |
| `files/gsl_pack_firmware.py` | 从 `.h` 打包 Allwinner `gsl_firmware/*.bin` |
| `apply-jl-m101-gsl3670-tp.sh` | 一键落地 |

```bash
# SDK 根目录；须已落地 20260722 显示定稿
bash H133-AI-Skills/开发记录/板件开发记录/JL_M101/20260727-JL_M101-GSL3670触摸适配/patches/apply-jl-m101-gsl3670-tp.sh

rm -rf out/h133/kernel/build/drivers/base/firmware_loader/builtin/gsl_firmware
./tools/build_p1_nor_JL_M101.sh kernel
# 再打包镜像（lunch 后 p，或 full）
```

> 当前出图树若**已经是** GSL3670，再 `--check` / apply 会报已存在，属正常。

---

## 定稿路径

| 角色 | 路径 |
|---|---|
| 源 `.h` | `kernel/linux-5.4/drivers/input/touchscreen/gslx680new/GSL3670_JL_M101.h` |
| 打包工具 | `tools/gsl_pack_firmware.py` |
| 运行 / 内嵌 bin | `openwrt/target/h133/h133-p1_nor_JL_M101/busybox-init-base-files/lib/firmware/gsl_firmware/gsl3670.bin` |
| 补丁副本 bin | `patches/files/gsl3670.bin` |

**勿**把定稿 `.h` 放在 `H133-AI-Skills/硬件资料/`；原厂 set / 工具包仍可留在硬件资料作参考。

## 硬件 / 原厂资料（树内，仅参考）

- `H133-AI-Skills/硬件资料/四川京龙/conf_3670(3).set` — 项目 set（800×1280，残缺 FW）
- `H133-AI-Skills/硬件资料/四川京龙/1.5.3.31_STM32/` — MassProduct 工具包（默认 `GSL3670.h` 为 **480×800**）

---

*2026-07-28：四角对齐定稿；技术支持定稿 `.h` 后 `0xb0` 通过；源头放入 `gslx680new/`。*  
*2026-08-03：`report_max` 改为 **1280×800**（不再映回 fb 800×1280），对齐 `disp_rotate=3` 的 LVGL；勿改 `tp_rotate`。*
