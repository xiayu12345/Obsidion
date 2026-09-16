---
project: LQ140M1JW61
kind: log
date: 2026-08-05
---

# 20260805 TEMP 补丁（历史对照，勿作产品默认）

这些补丁会**编译期关掉** `disp_dual_display_enable` 并死 `return` fb_clone，与正式方案「WB 常开」冲突。

**产品请用：**  
[../../20260806-同异显切换/patches/](../../20260806-同异显切换/patches/)

| 本目录文件 | 说明 |
|---|---|
| `01-kernel-skip-wb-and-fb-clone.patch` | TEMP 关 WB / clone |
| `02-tlayer-hdmi-only-fence-screen.patch` | 写死 `disp_screen=2` + fence（fence 思路已并入 20260806） |
| `hdmi-diff-display-temp.patch` | 合并 TEMP |
| `apply-hdmi-diff-temp.sh` | TEMP 一键 apply |
