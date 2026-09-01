---
project: JL_M101
kind: log
---

# JL-M101 JD9365DA MIPI — 文档索引

| 项 | 内容 |
|---|---|
| 板型 | `p1_nor_JL_M101`（从 `p1_nor_8733` 克隆） |
| 屏 | JL-M101B196-P21WX-M402632，10.1" **800×1280 MIPI**，IC **JD9365DA-H3** |
| 状态 | **2026-07-22 实机已完整出图（定稿）** |
| 板级档案 | [board-profile-p1_nor_JL_M101.md](../../../skills/h133-display/board-profile-p1_nor_JL_M101.md) |

---

## 阅读顺序（推荐）

| 优先级 | 文档 | 内容 |
|---|---|---|
| **主** | [20260722-板件新建与MIPI显示定稿/](./20260722-JL_M101-板件新建与MIPI显示定稿/README.md) | **板件新建 + 显示开发定稿 + final 补丁** |
| **主** | [20260727-GSL3670触摸适配/](./20260727-JL_M101-GSL3670触摸适配/README.md) | **板载 GSL3670 TP 定稿**（`0xb0` OK；**2026-08-03** `report_max=1280×800` 对齐 LVGL） |
| 外 | [杜比播放/开发记录](../../../杜比播放/开发记录/README.md) | **HDMI 杜比透传**（首验本板，**2026-08-22**） |
| 辅 | [20260720-MIPI适配/开发记录.md](./20260720-JL_M101-JD9365DA-MIPI适配/开发记录.md) | phase1 调试流水 |
| 辅 | [20260720-…/patches/](./20260720-JL_M101-JD9365DA-MIPI适配/patches/) | phase1 早期补丁（干净树优先用 **final**） |

同显 / 异显（**架构级，非本板专属**）见：[双屏异显/](../../双屏异显/README.md)（首验板为本板）。  
GSL `ctp_report_max`（**架构级**）见：[GSL触摸坐标映射/](../../GSL触摸坐标映射/README.md)（本板恒等 1280×800，勿映回 fb）。

定稿目录内顺序：`00 总览` → `01 板件新建` → `02 panel/init` → `03 DTS/PWM` → `04 踩坑` → `05 编译验收`。

**干净树一键落地（推荐）：**

```bash
bash H133-AI-Skills/开发记录/板件开发记录/JL_M101/20260722-JL_M101-板件新建与MIPI显示定稿/patches/apply-jl-m101-display-final.sh
bash H133-AI-Skills/开发记录/板件开发记录/JL_M101/20260727-JL_M101-GSL3670触摸适配/patches/apply-jl-m101-gsl3670-tp.sh
bash H133-AI-Skills/开发记录/双屏异显/20260806-同异显切换/patches/apply-disp-mode.sh
rm -rf out/h133/kernel/build/drivers/base/firmware_loader/builtin/gsl_firmware
./tools/build_p1_nor_JL_M101.sh full
```

---

## 硬件资料（树内）

- `H133-AI-Skills/硬件资料/四川京龙/JL-M101B196-P21WX-M402632 规格书V1.0.pdf`
- `…/C-JD9365DA-H3_…_800x1280_…20210830 (1)(1).txt`
- `…/s10-h133-v1_0625.pdf`（转接板 CON5 / RESET 档 / PT4117）
- `…/TP-H10_H133 V2.0 2026.6.12.pdf`

---

## 编译

```bash
./tools/build_p1_nor_JL_M101.sh kernel
./tools/build_p1_nor_JL_M101.sh full
# 产物：out/h133_linux_p1_nor_JL_M101_uart0_nor.img
```
