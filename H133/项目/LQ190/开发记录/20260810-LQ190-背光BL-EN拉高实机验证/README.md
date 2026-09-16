---
project: LQ190
kind: log
date: 2026-08-10
---

# 20260810 — LQ190 背光 BL-EN 拉高实机验证

| 项 | 内容 |
|---|---|
| 日期 | 2026-08-10 |
| 板型 | `p1_nor_LQ190`（NOR） |
| 状态 | **已闭环**：烧录后 `LCD-BL-EN` 实机测得 **3.3V** |

---

## 1. 结论

TP-H10 原理图 **J9534 pin4 `LCD-BL-EN` = PG15**。原先 DTS 故意不配 `lcd_bl_en`（注释「本板不控」），开屏时 EN 不拉。  
本板 `&lcd0` 补上 `lcd_bl_en = PG15 ACTIVE_HIGH` 后，开背光时 EN 被拉到 **3.3V**（实机确认）。

---

## 2. 改动（仅本板）

| 文件 | 改动 |
|---|---|
| `device/.../p1_nor_LQ190/linux-5.4/board.dts` | `&lcd0` 增加 `lcd_bl_en = <&pio PG 15 GPIO_ACTIVE_HIGH>` |
| `device/.../p1_nor_LQ190/uboot-board.dts` | 同上 |

PWM 仍为：**PB12 = LCD-PWM → PWM0**（未改）。  
**未动** LQ140 / eMMC 等兄弟板。

---

## 3. 镜像与验证

```bash
./tools/build_p1_nor_LQ190.sh full
# 产物：out/h133_linux_p1_nor_LQ190_uart0_nor.img
```

| 项 | 结果 |
|---|---|
| 烧录介质 | NOR |
| 测点 | J9534 / TP132（`LCD-BL-EN`） |
| 结果 | 开屏后 **3.3V** |

---

## 4. 仍待确认（与背光/桥片相关）

本专题只验 BL-EN。出图/灌表/RST 见 [20260811 定稿](../20260811-LQ190-GM8775C-MIPI显示定稿/README.md)。
