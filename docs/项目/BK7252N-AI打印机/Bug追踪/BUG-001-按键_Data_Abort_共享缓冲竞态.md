---
title: "BUG-001：按键极限操作触发 Data Abort / 意外重启"
description: ""
updated: 1780371367061
created: 1780371330027
---

# BUG-001：按键极限操作触发 Data Abort / 意外重启

**状态**：打开  
**优先级**：P0（可靠性 / 数据竞争）  
**记录日期**：2026-05-05  
**典型构建**：`RT-Thread 3.1.0` / SDK 3.0.76 / `rtthread.elf` 中 fault PC 曾落在 `memcpy`（约 `0x0011ad2e`，须与同版本 `.map` 核对）

---

## 1. 现象

- 设备在**反复极限按键操作**（快速切换桌面模式、secondary desktop、长按录音/松手停止、QR 预览、MQTT 收发图等）过程中，偶现 **`data abort`**，随后固件 **shutdown 并重启**。  
- 用户主观感受多为：**「一按按键相关流程就容易重启」**；不一定伴随堆用量单调涨至 100%。  
- 串口日志中常见前后文：  
  - `[audio_wait] wait image complete timeout, auto unlock task=…`  
  - `mqtt backend dispatch ws image to ui` / `mqtt backend print thread start`  
  - `[button] …` / `[ui] secondary desktop …`

---

## 2. 初步结论（架构层，非补丁说明）

本问题**首要怀疑并非「堆内存泄漏导致慢慢爆掉」**，而是：

1. **单块共享二进制接收缓冲区**（约 20KB，`MQTT_BINARY_SHARED_BUF_SIZE`）与 **零拷贝传递**：  
   - 打印线程 `mqtt_prn` 直接使用指向该缓冲的指针且不持有独立拷贝（当 `data == g_binary_shared_buf` 时）。  
   - UI 侧 `lv_desktop_request_show_ws_thermal_image` 通过 `lv_async_call` 仅传递**指针**，异步回调内再解码/适配预览。  
   - 下一趟 `result.start` / 收包会继续往**同一块物理缓冲**写入。

2. **多线程时间重叠**：打印线程、LVGL 异步回调、MQTT 收包写入可能在时间上交错；极限按键会**缩短会话间隔**，放大「上一趟消费者未结束、下一趟已覆盖缓冲区」的概率。

3. **`audio_wait` 超时**与云端**迟到**数据：超时后等待状态机会忽略部分迟到事件，但若其它路径仍假设 buffer / 界面状态有效，可能与「已离开 secondary / 已 teardown」交错，导致非法访问。

4. **现象与按键绑定**：按键是串联「录音上传 → MQTT → 二进制组装 → 打印 + UI 预览 → 超时解锁 → 下一轮」的触发器，故崩溃常出现在按键操作中。

fault 落在 **`memcpy`** 符合「目的/源地址无效或长度异常」类问题，与共享缓冲被覆盖或生命周期错乱一致。

---

## 3. 涉及模块与文件（便于 Code Review）

| 模块 | 路径 |
|------|------|
| 二进制接收 / 打印投递 | `applications/mqtt_backend/mqtt_backend_binary_rx.c` |
| MQTT 异步发布队列 | `applications/mqtt_backend/mqtt_backend_client.c` |
| 等待云端图像完成 / 超时 | `applications/audio/audio_result_wait.c` |
| WS 图预览异步 | `applications/pages/lv_example_meter.c`（`lv_desktop_request_show_ws_thermal_image` 等） |

---

## 4. 复现方向（软件准备好后验证）

- 保持 MQTT 在线，在 secondary desktop **快速多轮**：长按录音 → 松手 → 不等结果再次长按；或与 **QR 预览**、**离开/进入 secondary** 交错。  
- 观察是否在 **`audio_wait timeout`** 之后仍出现 **`dispatch ws image`** / 背靠背 **`result.start`** 时崩溃。  
- 使用**与设备一致**的 `rtthread.elf` 做 `addr2line`，确认 fault 是否仍在 `memcpy` 及调用栈上层归属。

---

## 5. 关闭标准（视为「彻底解决」）

满足下列条款可在本文件将状态改为 **已关闭**：

1. **缓冲区所有权清晰**：任一时刻对「整图结果」仅有单一写者，或读者持有独立快照直至用完释放；禁止在未同步的情况下让 MQTT 收包覆盖仍被打印/UI 使用的内存。  
2. **会话门禁**：新 `result.start` 收包前，须确认上一会话的打印/UI 异步已完成或已明确取消（或采用队列化的「任务描述符 + 独立缓冲」模型）。  
3. **超时与异步一致**：`audio_wait` 超时后，所有仍可能触摸该任务缓冲区的路径（MQTT 完成回调、LVGL async）行为已定义且无野指针。  
4. **压力测试**：文档化的极限按键脚本下 **连续运行 N 小时（建议 ≥2h）无 Data Abort**；必要时开启堆/栈水印辅助确认无异常碎片尖峰。  
5. 在本条文末记录：**修复 PR 或提交哈希**、**测试人 / 日期**。

---

## 6. 备注

- MQTT 异步发布队列深度固定（如 15），worker 会释放消息；该类设计**更易造成短暂排队**，而非无限堆涨，与「单次 fault」形态区分对待。  
- 若后续证明另有独立泄漏，应拆分为 **BUG-xxx** 新条，不在本条混杂。

---

## 7. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-05-05 | 初始录入：现象、架构原因、关闭标准 |
