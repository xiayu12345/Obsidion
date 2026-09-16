---
project: ZS101
kind: log
date: 2026-08-27
---

# ZS101 GT928 触摸适配 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | **2026-08-27** |
| 板型 | `p1_nor_ZS101`（主板 ZX30-D618-H133） |
| 触摸 | **FXT101041 GT928** I2C 六线；客户 cfg 186B @ **1280×800**，校验 `CA` |
| 软件 | `ctp_name=gt928_fxt101041`→GROUP2；Allwinner `gt9xxnew`（`SEND_CFG=1` 已开） |
| 地址 / 脚位 | `0x5d`；TWI1 PG8/9、INT=PG3、RST=PG2 |
| 坐标 | `screen_max=report_max=1280×800`；`revert_y=1`；`revert_x=0`；`exchange=0`；`tp_rotate=0` |
| 状态 | **实机定稿** |
| 基线 | [20260825 显示点亮](../20260825-ZS101-ILI9881C-MIPI显示点亮/) |

---

## 阅读

| 文档 | 内容 |
|---|---|
| [开发记录.md](./开发记录.md) | 改动、踩坑、验收、镜像 md5 |

## 补丁

| 文件 | 作用 |
|---|---|
| `01-gt9xx-driver.patch` | GROUP2←FXT101041 cfg（186B）；`gt928_fxt101041`→sensor_id 1 |
| `02-board-dts-ctp.patch` | ZS101：GSL@40 禁用 → GT928@5d；`bsp_defconfig` 关 GSL 开 GT9XX |
| `apply-zs101-gt928-tp.sh` | 一键落地 |

```bash
# SDK 根目录；须已落地 20260825 显示点亮
bash H133-AI-Skills/开发记录/板件开发记录/ZS101/20260827-ZS101-GT928触摸适配/patches/apply-zs101-gt928-tp.sh
./tools/build_p1_nor_ZS101.sh kernel
# 再 pack（脚本 kernel 后 p，或 full）
```

当前出图树再 apply 会 already exists，属正常。

## 资料入口

- cfg：`硬件资料/纽曼/FXT101041_GT928_1080_VER00_Config_20260827_115020 - 副本.cfg`（文件名写 1080，**字节是 1280×800**）
- 规格书：`硬件资料/纽曼/FXT101041-MN-A1电容屏规格书.pdf`
- 原理图：`硬件资料/纽曼/zx30-d618-h133-v1_0730.pdf`（JP17 CTP 6P）
