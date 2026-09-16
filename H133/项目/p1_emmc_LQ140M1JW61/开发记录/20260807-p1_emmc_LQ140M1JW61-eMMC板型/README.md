---
project: p1_emmc_LQ140M1JW61
kind: log
date: 2026-08-07
---

# p1_emmc_LQ140M1JW61 — 纯 eMMC 板型

| 项 | 内容 |
|---|---|
| 日期 | 2026-08-07 |
| 基线 | `p1_nor_LQ140M1JW61`（LQ140 屏 / 触摸 / WiFi / 应用） |
| 存储 | 三星 **KLMAG1JETD-B041** 16GB eMMC 5.1（原理图仍画 NOR，实板 NOR 已拆、eMMC 已装） |

## 原理图结论（s10-h133-v1_0625 P09）

- SPI FLASH 与 eMMC **二选一**（同 PC2–PC7）
- eMMC：**4bit** SDC2；`VCC-EMMC=3.3V`，`VCCQ=VCC-PC=3.3V` → **不开** `sdc_io_1v8` / HS400
- RST：`eMMC-RST` 经 0R 接 `AP-RESET`

## 与 NOR 差异

| | NOR (`p1_nor_LQ140…`) | eMMC（本板） |
|---|---|---|
| `storage_type` | 3 | **2** |
| 分区 | `sys_partition_nor.fex` | `sys_partition.fex` + UDISK |
| flash | `nor` / `boot0_spinor` | **default** / `boot0_sdcard` |
| bootcmd | `setargs_nor` | **`setargs_mmc`** |
| root | squashfs mtd | **squashfs `/dev/mmcblk0p5`**（沿用 LQ140 OpenWrt squashfs 产物） |
| 镜像名 | `*_uart0_nor.img` | **`*_uart0.img`** |

## 编译

```bash
./tools/build_p1_emmc_LQ140M1JW61.sh full
```

产物：`out/h133_linux_p1_emmc_LQ140M1JW61_uart0.img`  
烧录：Phoenix 烧 **eMMC**，勿与 NOR 镜像混用。

## 不影响

其它 `p1_nor_*` 板级与镜像路径未改。
