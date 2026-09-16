---
project: p1_emmc_LQ140M1JW61
kind: log
---

# p1_emmc_LQ140M1JW61 — 文档索引

| 项 | 内容 |
|---|---|
| 板型 | `p1_emmc_LQ140M1JW61`（从 `p1_nor_LQ140M1JW61` 克隆，纯 eMMC） |
| 屏 | Sharp LQ140M1JW61 1920×1080 eDP（同 NOR 版 LQ140） |
| 存储 | 三星 **KLMAG1JETD-B041** 16GB eMMC 5.1 |
| 状态 | **2026-08-07 板型可出镜像；实机 eMMC 分区/读写已验** |
| 显示/触摸基线 | 见 [../LQ140M1JW61/](../LQ140M1JW61/README.md)（本板只换启动介质） |

---

## 阅读顺序

| 优先级 | 文档 | 内容 |
|---|---|---|
| **主** | [20260807-eMMC板型/](./20260807-p1_emmc_LQ140M1JW61-eMMC板型/README.md) | 原理图结论、与 NOR 差异、编译与烧录 |

## 编译

```bash
./tools/build_p1_emmc_LQ140M1JW61.sh full
# 产物：out/h133_linux_p1_emmc_LQ140M1JW61_uart0.img
```

烧录：Phoenix 烧 **eMMC**，勿与 `*_nor.img` 混用。
