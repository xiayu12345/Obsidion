---
project: p1_nor_4k
kind: log
date: 2026-07-23
---

# p1_nor_4k 板件新建与 HDMI 4K 分离 — 文档索引

| 项 | 内容 |
|---|---|
| 日期 | 2026-07-23 |
| 板型 | **`p1_nor_4k`** |
| 基线 | **OpenWrt/WiFi：`p1_nor_8733`（RTL8733BU）**；**显示 DTS 源：`p1_nor`（8733 原软链到它）** |
| 显示（本文/初版） | **纯 HDMI 4K@30**（`mode=28`，`fb0=3840×2160`），无 LCD / 无辅屏 |
| 显示（当前基线） | 已改为 **1080p60 + fb0 1920×1080**，见 [../20260724-p1_nor_4k-HDMI1080p-fb0对齐/](../20260724-p1_nor_4k-HDMI1080p-fb0对齐/开发记录.md) |
| lunch | `h133-p1_nor_4k-tina` |
| 镜像 | `out/h133_linux_p1_nor_4k_uart0_nor.img` |
| 板级档案 | [board-profile-p1_nor_4k.md](../../../../skills/h133-display/board-profile-p1_nor_4k.md) |

---

## 阅读顺序

| 步骤 | 文档 | 内容 |
|---|---|---|
| 0 | [00-总览.md](./00-总览.md) | 基线、隔绝原则、与 CMA 专题关系 |
| 1 | [01-板件新建.md](./01-板件新建.md) | 克隆步骤、目录清单、公共挂钩 |
| 2 | [02-HDMI-4K-DTS与setting.md](./02-HDMI-4K-DTS与setting.md) | 显示关键值对照 |
| 3 | [03-编译与验收.md](./03-编译与验收.md) | 编译命令、验收清单 |

---

## 补丁

路径：[patches/](./patches/)

| 文件 | 内容 |
|---|---|
| `01-hdmi4k-dts-delta.patch` | `board.dts` / `uboot-board.dts`：相对 p1_nor 内容的 HDMI 4K 差异 |
| `02-openwrt-target-delta.patch` | 克隆并改名后的 `setting.ini` / `Makefile` / `hostname` |
| `03-build-script.patch` | 新增 `tools/build_p1_nor_4k.sh` |
| `04-shared-hooks.patch` | `.openwrt_targets`、`libtmedia`、兄弟板 `defconfig` not-set |
| `apply-p1_nor_4k-board.sh` | **干净树**：先克隆再打补丁 |

```bash
# 干净 SDK 根目录
bash H133-AI-Skills/开发记录/板件开发记录/p1_nor_4k/20260723-p1_nor_4k-板件新建与HDMI4K分离/patches/apply-p1_nor_4k-board.sh

# 当前树已有 p1_nor_4k 时再 apply 会报已存在/冲突，属正常
```

**不进本套补丁：**

- 整份 `linux-5.4/config-5.4`（从 p1_nor 实拷即可）
- `bootlogo.bmp`（apply 时从 8733 复制）
- CMA48 / `LV_SUPPORT_PICTURE_VIEWER` → 见 [../CMA与lv_img_header-4K硬解/](../CMA与lv_img_header-4K硬解/)

---

*2026-07-23：补齐板件分离开发记录与补丁（此前仅有 CMA/header 专题）。*
