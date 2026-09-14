---
project: JYY070
kind: log
date: 2026-07-10
---

# GSL `ctp_report_max` 内核映射（定稿）

| 项 | 内容 |
|---|---|
| 日期 | **2026-07-10** 落地；**2026-08-25** 从 JYY070 板件记录拆为架构级 |
| 范围 | **架构级**（`gslx680new/gslX680.c`，所有 GSL 板共用） |
| 首验板 | `p1_nor_JYY070`（芯片 1024×600 → UI 1280×800） |
| 状态 | **定稿**：DTS 可选；未配则与 `ctp_screen_max` 1:1 |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |

## 一句话

exchange/revert/裁剪之后，按 `ctp_report_max` 线性放大或缩小再 `input_report_abs`。

## 干净树落地

```bash
bash H133-AI-Skills/开发记录/GSL触摸坐标映射/20260710-GSL-ctp_report_max内核映射/patches/apply-gsl-tp-report-map.sh
# 再按目标板编内核，例：
./tools/build_p1_nor_JYY070.sh kernel
```

本树已合入时 apply 会 already applied，属正常。
