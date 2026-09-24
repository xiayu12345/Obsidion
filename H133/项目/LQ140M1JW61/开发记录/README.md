---
project: LQ140M1JW61
kind: log
---

# LQ140M1JW61 — 文档索引

| 项 | 内容 |
|---|---|
| 板型 | `p1_nor_LQ140M1JW61` |
| 屏 | Sharp LQ140M1JW61 1920×1080 eDP，经 QE01MIPI001-V01（SoC MIPI） |
| panel | `lq140_mipi2edp` |
| 触摸 | **2026-09-24 改原厂 `jdchipset`（JD9366TS）**；此前 GT9110H 定稿仍保留作历史 |
| 状态 | **2026-07-29 LCD + HDMI 双显定稿**；**07-31 GT9110H**；**09-24 JD9366TS 原厂触摸** |
| 板级档案 | [board-profile-p1_nor_LQ140M1JW61.md](../../../../skills/h133-display/board-profile-p1_nor_LQ140M1JW61.md) |

纯 eMMC 变体见独立目录：[../p1_emmc_LQ140M1JW61/](../p1_emmc_LQ140M1JW61/README.md)。

---

## 阅读顺序

| 优先级 | 文档 | 内容 |
|---|---|---|
| **触摸（当前）** | [20260924-H133-LQ140-JD9366TS原厂触摸/](./20260924-H133-LQ140-JD9366TS原厂触摸/README.md) | 触摸改原厂 `jdchipset`（已移除自写 `jd9366ts.c`） |
| **主** | [20260729-板件新建与双显定稿/](./20260729-LQ140M1JW61-板件新建与双显定稿/README.md) | 板件新建 + 双显定稿 + final 补丁 |
| **触摸（历史）** | [20260731-GT9110H触摸适配/](./20260731-LQ140M1JW61-GT9110H触摸适配/README.md) | GT9110H 主机下发 1920×1080，实机 1:1 |
| 辅 | [20260729-双显排查.bak/](./20260729-LQ140M1JW61-双显LCD-HDMI排查.bak/) | 早期短记（以定稿为准） |
| 公共 BUG | [系统BUG修复/…DE1-linebuf…](../../系统BUG修复/20260730-HDMI同显-DE1-linebuf超宽1比1黑边/) | HDMI 1080p 同显 1:1 黑边根因（`de_rtmx` coarse） |

厂家资料：`AI-skiil/硬件资料/音乐骑士/屏幕4/`（本轮未同步硬件资料）。

**干净树一键落地（历史 GT9110H 路径）：**

```bash
bash H133-AI-Skills/开发记录/板件开发记录/LQ140M1JW61/20260729-LQ140M1JW61-板件新建与双显定稿/patches/apply-lq140-display-final.sh
bash H133-AI-Skills/开发记录/板件开发记录/LQ140M1JW61/20260731-LQ140M1JW61-GT9110H触摸适配/patches/apply-lq140-gt9110h-tp.sh
./tools/build_p1_nor_LQ140M1JW61.sh full
```

JD9366TS 原厂触摸见该条目 `patches/apply.sh`。

---

## 编译

```bash
./tools/build_p1_nor_LQ140M1JW61.sh kernel
./tools/build_p1_nor_LQ140M1JW61.sh full
# 产物：out/h133_linux_p1_nor_LQ140M1JW61_uart0_nor.img
```
