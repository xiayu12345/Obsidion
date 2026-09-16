---
project: JYY070
kind: log
date: 2026-07-10
---

# 补丁说明

| 文件 | 说明 |
|------|------|
| [01-kernel-gslx680-report-map.patch](./01-kernel-gslx680-report-map.patch) | 公共驱动 `gslX680.c` |
| [02-board-jyy070-dts.patch](./02-board-jyy070-dts.patch) | JYY070 `board.dts` 示例 |
| [gsl-tp-report-map.patch](./gsl-tp-report-map.patch) | 以上合并 |
| [apply-gsl-tp-report-map.sh](./apply-gsl-tp-report-map.sh) | 一键 apply |

```bash
bash H133-AI-Skills/开发记录/GSL触摸坐标映射/20260710-GSL-ctp_report_max内核映射/patches/apply-gsl-tp-report-map.sh
# dry-run:
bash …/apply-gsl-tp-report-map.sh --check
```
