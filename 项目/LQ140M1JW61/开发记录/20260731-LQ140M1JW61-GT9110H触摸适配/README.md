---
project: LQ140M1JW61
kind: log
date: 2026-07-31
---

# LQ140M1JW61 GT9110H 触摸适配 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | **2026-07-31** |
| 板型 | `p1_nor_LQ140M1JW61`（主板 TP-H10 V2.0） |
| 触摸 | **GT9110H** I2C 六线；主机下发 `1401598@1920×1080`（186B）→ 1:1 |
| 软件 | `ctp_name=gt9110h_lq140`→GROUP8；`SEND_CFG=1`（原版：版本&lt;155 才写） |
| 地址 / 脚位 | `0x5d`；TWI1 PG8/9、INT=PG3、RST=PG2 |
| `screen_max` | **1920×1080**（fb0） |
| 状态 | **实机定稿** |
| 基线 | [20260729 显示定稿](../20260729-LQ140M1JW61-板件新建与双显定稿/) |

---

## 阅读

| 文档 | 内容 |
|---|---|
| [开发记录.md](./开发记录.md) | 改动、踩坑、验收、镜像 md5 |

## 补丁

| 文件 | 作用 |
|---|---|
| `01-gt9xx-driver.patch` | `SEND_CFG=1`；GROUP8←1401598@1920×1080（186B）；`gt9110h_lq140`→id7；写 `cfg_len` |
| `02-board-dts-ctp.patch` | LQ DTS：ctp 名 + screen_max |
| `apply-lq140-gt9110h-tp.sh` | 一键落地 |

```bash
bash H133-AI-Skills/开发记录/板件开发记录/LQ140M1JW61/20260731-LQ140M1JW61-GT9110H触摸适配/patches/apply-lq140-gt9110h-tp.sh
./tools/build_p1_nor_LQ140M1JW61.sh kernel
```

## 资料入口

- 主板：`硬件资料/TP-H10_H133 V2.0 2026.6.12.pdf`
- 模组：`硬件资料/音乐骑士/触摸资料/`（`1401598*.cfg` + 编程指南）
- 经验：`TP驱动&鼠标&触摸/乐大海10.1寸TPC3386-GT911触摸驱动开发.md`
