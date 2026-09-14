---
project: LQ190
kind: log
date: 2026-08-11
---

# 20260811 — LQ190 + GM8775C MIPI 显示定稿

| 项 | 内容 |
|---|---|
| 日期 | 2026-08-11（出图）；**2026-08-12 灌表修订（消糊）** |
| 板型 | **`p1_nor_LQ190`（NOR）** |
| 状态 | **实机显示已正常、清晰**（主机 MIPI 灌表 + DSI 出图） |
| 板级档案 | [board-profile-p1_nor_LQ190.md](../../../../skills/h133-display/board-profile-p1_nor_LQ190.md) |

---

## 1. 一句话结论

Sharp **LQ190E1LX65**（1280×1024 双 LVDS）经转接板 **GM8775C** 接 H133 MIPI；主机用 **`dsi_gen_wr`** 灌表（**`0x27=0xAA` 解锁**，**`0x13=0x63`**，**LINE 交换保留**，**`0x2A=0x01` 关 BIST**）；桥片 RST 走 **PG2（CTP-RST）**，本板 **不开触摸**。

---

## 2. 硬件要点

| 项 | 定稿 |
|---|---|
| 屏 | LQ190E1LX65，1280×1024，双 LVDS 8bit VESA |
| 桥片 | GM8775C / 资料亦写 GM8875C；转接板 **IIC_TYPE=Slave**，地址 **0x58** |
| 主机→桥 | MIPI FPC 4-lane；**CTP-SDA/SCK→桥 IIC**；**CTP-RST→桥 RST** |
| 转接板 LCD_RST | 原理图电阻 **NC**，主控 **PB11 打不到桥片** |
| 背光 | PB12=PWM0；PG15=`lcd_bl_en`（已验 3.3V） |
| 触摸 | **无**；`ctp@5d` 必须 `disabled`（否则 GT911 失败会拉 PG2 冲掉桥片表） |

工具资料：`硬件资料/鸿博芯业/转接板资料/`、`1280x1024_*.txt`（与驱动 `gm8775_reglist[]` 对齐）。

---

## 3. 软件定稿

| 项 | 值 |
|---|---|
| panel | `lq190_mipi2edp`（kernel + uboot 同表） |
| 灌表 | `dsi_clk_enable` → `dsi_gen_wr` 扫表（对齐 JL_M101 写法；**禁止 DSI 读**） |
| 解锁 | MIPI：**`0x27=0xAA`**（IIC 工具里是 `0x00=0xAA`，勿混用） |
| **关键寄存器** | **`0x13=0x63`**（**禁止**用 `0x53`：实机会发糊） |
| BIST | **`0x2A=0x01`**（`0x5D`/`0x3D` 等为测试图打开态） |
| LINE 交换 | LINK0/1 均保留实机可用映射（**`0x14/18=0x34`** 等；勿改回工具偶发直通） |
| 时序 DTS | 1280×1024，`dclk=108`；HFP194/HSW20/HBP194 → `hbp=214` `ht=1688`；VFP19/VSW4/VBP19 → `vbp=23` `vt=1066` |
| UI | `disp_rotate=0`；`fb0`=1280×1024 直出；Guider 页仍 1280×800 |
| `disp_init_enable` | **1** |
| 桥片 RST | **`lcd_gpio_0`=PG2** |

关键路径：

- `kernel/.../lcd/lq190_mipi2edp.c`
- `brandy/.../lcd/lq190_mipi2edp.c`
- `device/config/chips/h133/configs/p1_nor_LQ190/{linux-5.4/board.dts,uboot-board.dts}`

参考灌表（与驱动一致）：

- `H133-AI-Skills/硬件资料/鸿博芯业/1280x1024_20260811144404.txt`
- `H133-AI-Skills/硬件资料/鸿博芯业/1280x1024_2024.txt`

---

## 4. 踩坑（根因级）

| 现象 | 根因 | 处理 |
|---|---|---|
| 软件 open 成功但无图 | 桥片 RST 接 **CTP-RST=PG2**，旧代码拉 PB11 无效；内核 CTP 探失败又 **Process reset** 清表；smooth 不再 `panel_init` | `lcd_gpio_0=PG2`；`ctp` disabled |
| MIPI 灌了仍像没配 | IIC 解锁 `0x00=0xAA` 不能当 MIPI 首条；MIPI 必须 **`0x27=0xAA`** | 按工具 MIPI 导出 |
| 开机全是黑白棋盘 | 上位机 BIST 未关（`0x2A` 非 `0x01`），内部测试图盖住视频 | 表末 **`0x2A=0x01`**；灌前关工具测试模式 |
| **UI/字发糊、边缘发虚** | 灌表 **`0x13=0x53`** 不对（20260811 初稿） | **改为 `0x13=0x63`**（2026-08-12 实机确认消糊） |
| 调屏时 CH341 灌不上 | 主机 DSI/RST 抢桥片 | 临时 BL-only / `lcd_used` 关显；灌完再恢复出图路径 |

说明：JL_M101 的 `dsi_gen_wr` 写法可参考，但 **JD9365 是真 MIPI 屏**，GM8775 是桥片，RST/解锁/BIST/`0x13` 约束不同。

---

## 5. 验收

- [x] U-Boot 有 `panel_init dsi_gen_wr (0x13=0x63, swap keep, BIST off)`，`LCD open finish`
- [x] 背光亮，系统 UI 正常（非彩条/棋盘格）
- [x] **画面清晰，无整体发糊**（`0x13=0x63`）
- [x] 无 GTP/`0x5d` 复位风暴
- [ ] `setting.ini` 视频窗坐标仍残留竖屏 800×1280 克隆值（不影响本次出图；后续可按 1280×1024 改）
- [ ] UI 仍为 Guider 1280×800 资源嵌在 1280×1024；低 PPI 下点阵观感与桥片发糊不同，勿混为一谈

---

## 6. 编译

```bash
./tools/build_p1_nor_LQ190.sh kernel   # 或 full
# 产物：out/h133_linux_p1_nor_LQ190_uart0_nor.img
```

| 镜像说明 | md5（以当次 `md5sum` 为准） |
|---|---|
| 2026-08-11 初稿出图（`0x13=0x53`，可糊） | `ba6b9a14144a46cf9544711873f6b601` |
| **2026-08-12 定稿清晰（`0x13=0x63`）** | **`2ab2ac2697d27072dba4fa7e064427f9`** |

---

## 7. 补丁（定稿，相对无 LQ190 干净基线）

路径：[patches/](./patches/)

| 文件 | 内容 |
|---|---|
| `01-kernel-uboot-panel.patch` | 内核+U-Boot `lq190_mipi2edp`（MIPI 灌表）+ 注册 + defconfig |
| `02-board-tree.patch` | `p1_nor_LQ190` + OpenWrt target + `build_p1_nor_LQ190.sh`（含 1280×1024 / RST=PG2 / CTP off） |
| `03-shared-hooks.patch` | 兄弟板 `LQ190` not-set |
| `04-docs.patch` | 本定稿文档 + board-profile + LQ190 索引 |
| `lq190-display-final.patch` | 以上合并（**干净树一键落地用这个**） |
| `apply-lq190-display-final.sh` | 应用 |
| `gen-lq190-display-final-patch.sh` | 从当前树重生成 |

```bash
# 干净 SDK 根目录
bash H133-AI-Skills/开发记录/板件开发记录/LQ190/20260811-LQ190-GM8775C-MIPI显示定稿/patches/apply-lq190-display-final.sh

# 分段 / dry-run
bash …/patches/apply-lq190-display-final.sh 01
bash …/patches/apply-lq190-display-final.sh --check

# 重生成（已有出图树时；须含 0x13=0x63）
bash …/patches/gen-lq190-display-final-patch.sh
```

`bootlogo.bmp` 不进补丁；apply 时若缺失会从 `p1_nor_LQ140M1JW61` 复制。

> 若树里**已经**有 LQ190 板（当前出图树），`--check` / 再 apply 会报 already exists，属正常。

---

*2026-08-11：实机出图；文档与 final 补丁同步。*  
*2026-08-12：确认 `0x13=0x63` 消糊；灌表 txt / 文档 / board-profile 修订为当前定稿；驱动内旧表备份已删除。*
