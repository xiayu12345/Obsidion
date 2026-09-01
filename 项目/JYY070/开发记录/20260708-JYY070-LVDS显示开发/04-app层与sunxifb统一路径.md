---
project: JYY070
kind: log
date: 2026-07-08
---

# 04 — App 层与 sunxifb 统一路径

**上一步：** [03-DTS切换LVDS.md](./03-DTS切换LVDS.md)  
**下一步：** [05-HDMI异显dual_display_rot.md](./05-HDMI异显dual_display_rot.md)

**背景：** [00-背景与路径统一.md](./00-背景与路径统一.md) §2～3

---

## 1. 本步目标

1. JYY070 以 `lv_projector 0` / `sunxifb_rot=0` 启动 desk  
2. **sunxifb 与 p1_nor 同框架**：rot=0 也走 `rotatefbp + split_fb`（不用 fix_lcd）  
3. 改 sunxifb 后 lv_projector 能可靠重编

**补丁段：** `04`（无 sunxifb.c 段）+ 合并补丁内 `sunxifb.c` diff

---

## 2. App / 编译链（4a）

| 文件 | 说明 |
|---|---|
| `openwrt/.../lv_projector/Makefile` | `PKG_FILE_DEPENDS` 含 sunxifb.c，改驱动触发重编 |
| `openwrt/.../rc.final` | desk 启动，`lv_projector 0` |
| `openwrt/.../lv_daemon.sh` | 守护进程参数 |
| `platform/.../projector_config.h` | JYY070 显示旋转宏 |
| `H133-AI-Skills/.../build_p1_nor_jyy070.sh` | 板级编译脚本 |

---

## 3. sunxifb 关键改动（4b）

**文件：** `platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunxifb.c`

| 改动 | 说明 |
|---|---|
| 去掉 `if (rotated != LV_DISP_ROT_NONE)` | rot=0 也分配 `rotatefbp`、启用 `split_fb` |
| `case LV_DISP_ROT_NONE` | `SUNXIFB_ROT_0`，尺寸 = `vinfo.xres/yres` |
| `sunxifb_copy_area(dst, ...)` | HDMI / LCD 页共用脏区拷贝 |
| `soft_rotate_area` default | rot=0 拷贝到 **LCD dst** |
| `sunxifb_detach_fbcon()` | 启动时脱离 fbcon |
| **不含** `fix_lcd_page_en` | 与 bringup `04-app-sunxifb.patch` sunxifb 段 **互斥** |

### 与 p1_nor rot=3 对照

| 层级 | p1_nor | JYY070 |
|---|---|---|
| 框架 | rotatefbp + split_fb | **相同** |
| LCD 页 | 软转 270° | 直拷贝 |
| desk log | `sunxifb_rot=3` | `sunxifb_rot=0` |

---

## 4. 重新生成 sunxifb 补丁段

```bash
bash H133-AI-Skills/开发记录/板件开发记录/JYY070/20260708-JYY070-LVDS显示开发/patches/gen-jyy070-lvds-display-patch.sh
```

脚本从当前 `sunxifb.c` 的 `git diff` 生成 4b 段并写入 phase1-5 合并补丁。

---

## 5. 本步验收

| 必须出现 | 含义 |
|---|---|
| `[desk] fb 1024x600 -> LVGL 1024x600, sunxifb_rot=0` | rot=0 横屏 |
| `[desk] started` | UI 进程正常 |

| 必须不出现 | 含义 |
|---|---|
| `rotate=0: draw ping-pong, LCD fixed page1` | 旧 fix_lcd 路径 |
| `fix_lcd_page` | 旧 fix_lcd 路径 |

debug 开（`-DLV_SUNXIFB_DEBUG=1`）可选看到：

```text
Turn on software rotate path (rot=0).
Split fb: dirty sync HDMI page0 1024x600, MIPI page1 copy
```

完整编译与串口 checklist 见 [06-编译与实机验证.md](./06-编译与实机验证.md)。
