---
project: p1_nor_4k
kind: log
date: 2026-07-23
---

# 02 — HDMI 4K DTS 与 setting.ini

## 2.1 显示关键值（相对 p1_nor / 8733）

| 项 | `p1_nor` / `8733` | `p1_nor_4k` |
|----|-------------------|-------------|
| `screen0_output_type` | LCD(`1`) | **HDMI(`3`)** |
| `screen0_output_mode` | `<4>` | **`<28>`** = `DISP_TV_MOD_3840_2160P_30HZ` |
| `fb0_width` / `fb0_height` | 800×1280 | **3840×2160** |
| `dev0_output_type` / `mode` | LCD | HDMI / **28** |
| `screen1` / `dev1` | 可作 HDMI 辅屏 | **全关** |
| `chn_cfg_mode` | 双显 | **单显 `0`** |
| `lcd_used` | `1` | **`0`** |
| CTP / 触摸 | 常开 | **关**（本板无屏触摸需求） |

内核与 U-Boot 两侧需一致：

- `device/.../p1_nor_4k/linux-5.4/board.dts`
- `device/.../p1_nor_4k/uboot-board.dts`

补丁：[patches/01-hdmi4k-dts-delta.patch](./patches/01-hdmi4k-dts-delta.patch)

## 2.2 setting.ini

路径：`openwrt/target/h133/h133-p1_nor_4k/busybox-init-base-files/etc/setting.ini`

| 项 | 8733 | 4k |
|----|------|-----|
| `disp_rotate` | `3` | **`0`** |
| `video_screen_w/h` | 800×1280 | **3840×2160** |
| `sun_video_screen_w/h` | 800×1280 | **3840×2160** |

补丁：[patches/02-openwrt-target-delta.patch](./patches/02-openwrt-target-delta.patch)

## 2.3 CMA / 分区（板件基线）

| 项 | 板件基线 |
|----|----------|
| `env.cfg` `cma=` | **`8M`**（与多数板相同） |
| `sys_partition_nor.fex` | rootfs=`34816`，rootfs_data=`16384` 扇区 |

硬解全屏 4K JPG 再叠 [CMA 专题补丁](../CMA与lv_img_header-4K硬解/)。
