---
project: JYY070
kind: log
---

# GSL 触摸坐标映射（架构级）

GSL 系列（GSL1680 / GSL3670 等）共用 `gslx680new/gslX680.c`。芯片量程与 UI/fb0 不一致时，在内核里按 DTS **线性缩放到 `ctp_report_max`**；板级只改本板 DTS，不改 LVGL。

| 文档 | 说明 |
|---|---|
| [20260710-GSL-ctp_report_max内核映射/](./20260710-GSL-ctp_report_max内核映射/) | **定稿**：驱动 `tp_map_to_report` + 可选 DTS；首验 JYY070 |

## 产品一句话

`ctp_screen_max` = 芯片物理量程（exchange/revert/裁剪用）。  
`ctp_report_max` = 报给应用的范围（对齐 LVGL）。两边相等则不缩放。

```bash
# 干净树（架构补丁：公共驱动；02 为 JYY070 示例 DTS）
bash H133-AI-Skills/开发记录/GSL触摸坐标映射/20260710-GSL-ctp_report_max内核映射/patches/apply-gsl-tp-report-map.sh
```

GT911 不走这条驱动。板级验证仍在各板目录（JYY070 / JL_M101）。
