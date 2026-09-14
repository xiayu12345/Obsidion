---
project: p1_nor_4k
kind: log
date: 2026-07-23
---

# patches — p1_nor_4k 板件新建

## 用法

```bash
# SDK 根目录
bash apply-p1_nor_4k-board.sh           # 无板则克隆 + 打 01～04
bash apply-p1_nor_4k-board.sh --check   # 仅 dry-run（树须已含待改文件）
bash apply-p1_nor_4k-board.sh 01        # 只打某一段
```

## 文件

| 补丁 | 前提 | 作用 |
|------|------|------|
| `01-hdmi4k-dts-delta.patch` | 已有 `p1_nor_4k` 且 DTS 仍接近 p1_nor | HDMI 4K |
| `02-openwrt-target-delta.patch` | 已从 8733 克隆并改名 target | setting / BOARDNAME / hostname |
| `03-build-script.patch` | 无 `tools/build_p1_nor_4k.sh` | 新增编译脚本 |
| `04-shared-hooks.patch` | 干净共享挂钩 | lunch / libtmedia / 兄弟 not-set |

当前工程树**已经**含本板时：不必再 apply；补丁供干净树复现或对照。

CMA / 13-bit header **不在此目录**，见 `../../CMA与lv_img_header-4K硬解/`。
