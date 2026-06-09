---
title: "prn_tune 串口调参命令说明"
description: ""
updated: 1780371367063
created: 1780371330028
---

# prn_tune 串口调参命令说明

在 RT-Thread Finsh（MSH）里通过调试串口输入，用于**运行时**调整热敏打印时序，无需反复烧录。  
命令实现在 `applications/Printer/thermal_printer.c`（需 **`RT_USING_FINSH`** 开启）。

---

## 使用条件

- 串口已连接，能看到 `msh />` 提示符。
- 打印机已完成 `Printer_init()` / `thermal_printer_init()`。
- **打印进行中**会拒绝修改（提示 `busy printing`），请等当前任务结束。

---

## 命令一览（与固件 `prn_tune help` 对齐）

```text
prn_tune show
prn_tune help

prn_tune preset cur5 | prev5 | L1 | L2 | L3 | L4 | L5

prn_tune set line <us> | igap <us> | motor <us> | steps <1..4>
prn_tune set clk <us> | latch <us>
prn_tune set heat <5c> <25c> <40c>
prn_tune set heatlim <min_us> <max_us>
prn_tune set dense <d300> <d220> <d140> <d80> <d30>
prn_tune set check <lines> | white <1..512> | yield <lines|0=off>
prn_tune set stop <c> | resume <c> | log <0..3>
prn_tune set strobe_guard <pre_us> <post_us>
prn_tune set linegap_thr <lte_sparse> <lte_mid> <gte_dense> <gte_vdense>
prn_tune set linegap_sparse_shift <n> | linegap_mid_shift <n>
prn_tune set linegap_dense_add <us> | linegap_vdense_add <us>
prn_tune set igap_sparse_shift <n>
prn_tune set gshape default | off | <13 ints>
```

---

## 常用命令清单（怎么敲）

快速对照：左边为**目的**，右边为可在串口**直接敲的一行示例**（数值可按实测改写）。

| 目的 | 命令示例 |
|------|----------|
| 帮助 | `prn_tune help` |
| 查看全部 | `prn_tune show` |
| 套用内置最快档 5 | `prn_tune preset cur5` |
| 套用内置档 1～4 | `prn_tune preset L1` … `prn_tune preset L4` |
| 套用文档「上一版」参数 | `prn_tune preset prev5` |
| 行间冷却（μs） | `prn_tune set line 10` |
| 组间间隔（μs） | `prn_tune set igap 1` |
| 电机步进间隔（μs） | `prn_tune set motor 650` |
| 每逻辑行走步数（1～4） | `prn_tune set steps 2` |
| 移位半周期 / 锁存脉宽（μs） | `prn_tune set clk 0`、`prn_tune set latch 0` |
| 加热夹紧上下限（μs） | `prn_tune set heatlim 760 1680` |
| 过温停打 / 恢复（℃） | `prn_tune set stop 75`、`prn_tune set resume 60` |
| 日志级别 0～3 | `prn_tune set log 1` |
| STROBE 前后保护（μs） | `prn_tune set strobe_guard 0 0` |
| 行尾 gap 与黑点阈值 | `prn_tune set linegap_thr 48 120 220 300` |
| 行尾 gap 右移位数 / 加码 | 见 `linegap_sparse_shift` 等 |
| 未加热组 gap 右移位数 | `prn_tune set igap_sparse_shift 1` |
| 分组加热塑形 | `prn_tune set gshape default` 或 `off` |
| 三根加热基准（5℃ / 25℃ / 40℃） | `prn_tune set heat 1080 940 820` |
| 多少行测一次温、刷新加热缓存 | `prn_tune set check 96` |
| 连续白行一次跳过最多几行 | `prn_tune set white 96` |
| 每多少行 `mdelay(1)`；关掉填 **0** | `prn_tune set yield 256` 或 `prn_tune set yield 0` |
| 高密度五档额外加热（黑点阈值见 `help`） | `prn_tune set dense 135 90 55 28 10` |

参数含义与 `打印数据` 目录下 README 参数表一致：`line` 对应 **`line_cooling`**，`motor` 对应 **`motor_step_us`**，`heat` 后三根依次为低温 / 中温 / 高温区的**基准加热时间**（微秒）。

---

## 子命令说明

| 命令 | 含义 |
|------|------|
| `prn_tune show` | 打印当前全部参数：速度档、`clk`/`latch`、冷却/组间/电机/每行走步、三根加热与 **heatlim**、停打/恢复温度、`log`、**strobe_guard**、测温周期、白行/yield、**dense**、**linegap** 阈值与移位/加码、**igap_sparse_shift**、**gshape** 表。 |
| `prn_tune preset cur5` | 等同 **`preset L5`**：内置 speed=5，并重置 bitmap 默认（白行/yield/dense）及 **高级默认**（heatlim、strobe、linegap、gshape 等）。 |
| `prn_tune preset L1` … `L5` | 调用 `apply_speed_profile(n)`：重写该档 clk/latch/heat/gap/motor/check，并重置 **bitmap 默认 + 高级默认**（见下）。 |
| `prn_tune preset prev5` | 文档「上一版 speed=5」时间与 dense/white/yield/check；末尾再套用 **高级默认**（与全新 cur5 一致）。 |
| `prn_tune set line <us>` | `line_cooling_us`（行间冷却，微秒）。 |
| `prn_tune set igap <us>` | `inter_group_us`（组间间隔，微秒）。 |
| `prn_tune set motor <us>` | `motor_step_us`（电机步进间隔；**0** 表示走内置加速表）。 |
| `prn_tune set steps <1..4>` | `motor_steps_per_line`。 |
| `prn_tune set clk <us>` | `clk_half_us`（移位每位前的延时；与 `cfg.clk_half_us` 同步）。 |
| `prn_tune set latch <us>` | `latch_us`（锁存脉宽；与 `cfg.latch_pulse_us` 同步）。 |
| `prn_tune set heat <5c> <25c> <40c>` | 低温/中温/高温区基准加热时间（微秒）。 |
| `prn_tune set heatlim <min> <max>` | `clamp_heat_us` 上下限；若 `min>max` 会自动交换。 |
| `prn_tune set check <lines>` | 每多少行做一次测温并刷新加热缓存；写 **0** 会被改成 **8**。 |
| `prn_tune set white <n>` | 连续白行一次最多跳过行数（**1～512**）。 |
| `prn_tune set yield <n>` | 每多少行执行一次 `rt_thread_mdelay(1)`；**0** 表示关闭该 yield。 |
| `prn_tune set dense …` | 行黑点个数超过阈值 **300 / 220 / 140 / 80 / 30** 时，分别额外增加的加热（微秒），共五个数。 |
| `prn_tune set stop / resume` | 头温停打阈值 / 恢复阈值（℃）。 |
| `prn_tune set log <0..3>` | `[prn]` 日志级别（与 `cfg.log_level` 同步）。 |
| `prn_tune set strobe_guard <pre> <post>` | STROBE 拉高前与拉低后的延时（μs）。 |
| `prn_tune set linegap_thr …` | 行尾 gap 与整行黑点比较的四阈值：`lte_sparse`、`lte_mid`、`gte_dense`、`gte_vdense`（默认 48/120/220/300）。 |
| `prn_tune set linegap_sparse_shift <n>` | 黑点 ≤ `lte_sparse` 时将行尾 gap 右移 `n` 位（0～7）；默认 **2**。 |
| `prn_tune set linegap_mid_shift <n>` | 黑点 ≤ `lte_mid` 时右移 `n` 位；默认 **1**。 |
| `prn_tune set linegap_dense_add <us>` | 黑点 ≥ `gte_dense` 时行尾 gap 加码；默认 **10**。 |
| `prn_tune set linegap_vdense_add <us>` | 黑点 ≥ `gte_vdense` 时加码；默认 **25**。 |
| `prn_tune set igap_sparse_shift <n>` | 未加热组：`group_gap` 右移 `n` 位；**0** 表示不缩小；默认 **1**（等同原先除以 2）。 |
| `prn_tune set gshape default` | 恢复内置分组塑形表（与原固件 8/16/28 减热与 56/70/82 加热一致）。 |
| `prn_tune set gshape off` | 关闭分组塑形（每组仅用该行基准加热 + clamp）。 |
| `prn_tune set gshape <13 ints>` | 顺序：`t8 s8 t16 s16 t28 s28 floor t82 a82 t70 a70 t56 a56`（与 `show` 最后一行格式一致）。 |

### 高级默认（执行 `preset L1`～`L5` / `cur5` 时重置）

含：`heatlim` 760/1680、`strobe_guard` 0/0、`linegap_thr` 48/120/220/300、`linegap_sparse_shift=2`、`linegap_mid_shift=1`、`linegap_dense_add=10`、`linegap_vdense_add=25`、`igap_sparse_shift=1`、**gshape 启用且为出厂表**。不含：`dense` / `white_run_max` / `yield`（这些仍由 `bitmap_tune_defaults_for_level` 按档位重置）。

---

## 行为说明（必读）

1. **`thermal_printer_set_speed_level(n)`** 与 **`prn_tune preset L1`～`L5`**  
   会按档位重写一整套 timing，并重置该档下的 **bitmap 默认调参**（白行/yield/dense）以及 **高级默认**（heatlim、strobe、linegap、gshape 等）。  
   改档后若要保留自定义高级项，请再执行一次对应的 `prn_tune set …`。

2. **文本打印 `thermal_printer_print_text()`**  
   为字迹浓度会**临时切到 speed 1**，打印结束后**恢复快照**（含本次扩展的全部 `prn_tune` 字段），不应再把你卡在档位 1。

3. **P36 长按 QR（`QR_code_printer`）**  
   **不**再强制切档位：二维码位图走你当前串口 `prn_tune`（及 `speed_level`）下的整表参数；仅 **`thermal_printer_print_text()`** 仍为字迹临时切 **speed 1**（内部快照恢复）。

4. **MQTT 云图打印**  
   不在「每张任务」里强制 `set_speed_level(5)`，避免覆盖你在串口改的 motor/igap 等。  
   `thermal_printer_init()` 末尾会套用内置 **L5**；MQTT 侧仅在打印机未就绪时重试 `Printer_init()`。

5. **参数仅存 RAM**  
   掉电/复位后丢失；需要默认开机策略可改 `main.c` 或做成 NV 配置（当前未做）。

---

## 使用示例（可复制到串口逐行执行）

以下均在 `msh />` 后输入；每条命令以回车结束，看到 `[prn_tune] ok` 或整表输出再继续。

### 示例 A：先看当前全局参数

```text
prn_tune show
```

### 示例 B：套用内置「当前仓库 speed=5」并确认

```text
prn_tune preset cur5
prn_tune show
```

### 示例 C：套用文档「上一版 speed=5」快照并确认

```text
prn_tune preset prev5
prn_tune show
```

### 示例 D：本版 / 上一版纸上测速对比（同一张云图各打一张）

先上一版参数，打图（MQTT 或本机流程），看纸上 **S/E/C**：

```text
prn_tune preset prev5
prn_tune show
```

再切回本版默认，**同一张图**再打一张对比：

```text
prn_tune preset cur5
prn_tune show
```

### 示例 E：在 cur5 基础上只改「行间冷却」和「电机步进」

```text
prn_tune preset cur5
prn_tune set line 12
prn_tune set motor 680
prn_tune show
```

### 示例 F：改三根加热基准（5℃ / 25℃ / 40℃ 对应档）

数值需三个连续参数：

```text
prn_tune preset cur5
prn_tune set heat 1120 980 860
prn_tune show
```

### 示例 G：测温周期、白行批量、周期性 yield

```text
prn_tune preset cur5
prn_tune set check 80
prn_tune set white 64
prn_tune set yield 128
prn_tune show
```

关闭 yield（追求极限吞吐时可试，注意其他线程饿死风险）：

```text
prn_tune set yield 0
prn_tune show
```

### 示例 H：高密度行额外加热（五档一起改）

顺序对应黑点阈值 **>300、>220、>140、>80、>30** 五档的增量（微秒）：

```text
prn_tune preset cur5
prn_tune set dense 170 115 70 38 14
prn_tune show
```

### 示例 I：组间间隔（与加热组之间的空隙有关）

```text
prn_tune preset cur5
prn_tune set igap 1
prn_tune show
```

### 示例 J：打印进行中无法改参

若提示 `busy printing`，等当前纸条打完或任务结束后再执行：

```text
prn_tune show
```

### 示例 K：MQTT 云图打印前后核对参数未被覆盖

调好自己的一组参数后：

```text
prn_tune set motor 650
prn_tune set line 10
prn_tune show
```

触发一次 MQTT 打印，任务结束后：

```text
prn_tune show
```

应仍为你设的 **motor / line**（除非你又执行了 `preset` 或 `thermal_printer_set_speed_level`）。

### 示例 L：P36 长按二维码前后

长按前先记下：

```text
prn_tune preset cur5
prn_tune set motor 650
prn_tune show
```

长按 P36 打完 QR + 文字后：

```text
prn_tune show
```

二维码位图与走纸使用**当前串口上的整表**，不会被 QR 流程强制改档；`motor`/`line` 等应与长按前一致（除非你又执行了 `preset` 或 `thermal_printer_set_speed_level`）。下方文字仍走 `print_text()` 的临时 speed 1，结束后不影响 RAM 里这组参数。

### 示例 M：查看内置帮助（与固件字符串一致）

```text
prn_tune help
```

---

## 常用流程示例（短总结）

**对比文档里的「本版 vs 上一版」speed=5：**

```text
prn_tune preset prev5
prn_tune show
```

→ 打测试图 → 再：

```text
prn_tune preset cur5
prn_tune show
```

→ 同图再打一版对比纸上 **C**。

**单项微调（示例）：**

```text
prn_tune preset cur5
prn_tune set line 12
prn_tune set motor 680
prn_tune show
```

---

## 串口输入注意

- 命令需**单独一行**；日志穿插时勿把 `temp_code:` 等粘进同一行，否则解析失败（会提示 `try: prn_tune help`）。
- 首字母不要漏：`prn_tune` 不是 `rn_tune`。

---

## 与打印数据文档的对应关系

- 组一 / 组二参数快照：[[项目/BK7252N-AI打印机/打印数据]] 及子目录 `01-…` / `02-…` 下的 [[项目/BK7252N-AI打印机/打印数据]]。
- `preset prev5` 与组一表一致；`preset cur5` 与当前仓库默认 speed=5 一致。

---

## 修订记录

| 日期 | 说明 |
|------|------|
| 2026-05-01 | 首版：汇总 Finsh 命令与行为说明，便于本地实时查阅。 |
| 2026-05-01 | 增补「使用示例」章节：A～M 逐步示例与 MQTT/QR 核对流程。 |
| 2026-05-01 | 增加「常用命令清单（怎么敲）」速查表，与终端说明一致。 |
| 2026-05-01 | 扩展 `prn_tune`：`preset L1`～`L5`、`clk`/`latch`/`steps`、`heatlim`、`stop`/`resume`/`log`、`strobe_guard`、`linegap_*`、`igap_sparse_shift`、`gshape`；`print_line` 全面参数化；`show`/`help` 同步。 |
