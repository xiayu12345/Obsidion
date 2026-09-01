---
project: LQ140M1JW61
kind: log
date: 2026-08-06
---

# 同显 / 异显切换（定稿）

| 项 | 内容 |
|---|---|
| 日期 | 2026-08-06 |
| 范围 | **架构级**（MIPI+HDMI 双屏板共用） |
| 验证板 | `p1_nor_JL_M101`（首验） |
| 状态 | **定稿**：WB 常开，切模式只显隐 HDMI 上 WB 层 |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |
| 前置 | [20260805-HDMI异显最小验证](../20260805-HDMI异显最小验证/)（TEMP 对照，**勿用**） |
| 架构 | [LV_DS 中间件架构](../LV_DS-双屏异显中间件架构.md) |

## 一句话

WB 管道常开；`disp_mode same|diff` 只切 HDMI 上 WB 层 + 视频贴屏；播中拒切。

## 干净树落地

```bash
bash H133-AI-Skills/开发记录/双屏异显/20260806-同异显切换/patches/apply-disp-mode.sh
# 按目标板编译，例：
./tools/build_p1_nor_JL_M101.sh full
```

板端：

```bash
disp_mode same
disp_mode diff
disp_mode get
```
