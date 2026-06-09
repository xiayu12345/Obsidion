---
title: "BUG-002：LVGL 内存重分配触发 Data Abort (os_realloc 越界读取)"
description: ""
updated: 1780371367062
created: 1780371330027
---

# BUG-002：LVGL 内存重分配触发 Data Abort (os_realloc 越界读取)

**状态**：已关闭  
**优先级**：P0（系统崩溃 / 核心组件）  
**记录日期**：2026-05-12  
**典型构建**：`RT-Thread 3.1.0` / SDK 3.0.76

---

## 1. 现象

- 设备在接收并处理 MQTT 下发的图片（`mqtt backend dispatch ws image to ui`），准备在 UI 上显示图片时，发生 **`data abort`**，随后系统 `shutdown`。
- 崩溃时的寄存器信息显示 `pc` 落在 `memcpy`，且源地址（`r1`/`r3`）越过了 `0x02040000`（PSRAM 物理内存边界）。
- 通过 `addr2line` 解析出的崩溃调用栈如下：
  `lv_timer_handler` -> `lv_draw_img` -> `decode_and_draw` -> `lv_mem_buf_get` -> `lv_mem_realloc` -> **`os_realloc`** -> **`memcpy`**。

---

## 2. 原因分析

根本原因在于 `beken378/rttos/mem_arch.c` 中的 `os_realloc` 实现存在严重缺陷：

```c
void *os_realloc(void *ptr, size_t size)
{
    void *tmp;
    tmp = (void *)rt_malloc(size);
    if(tmp)
    {
        os_memcpy(tmp, ptr, size); // <--- 致命错误：按照新分配的 size 拷贝旧数据
        rt_free(ptr);
    }
    return tmp;
}
```

1. **越界读取 (Out-of-bounds Read)**：当 LVGL 需要扩大内存块时（例如从较小的 buffer 扩大到 960 字节），传入的 `size` 参数是**新的更大尺寸**。
2. `os_memcpy` 错误地按照新尺寸 `size` 从旧指针 `ptr` 处拷贝数据，导致读取了超出旧内存块实际大小的数据。
3. **触发 Data Abort**：在本次崩溃中，旧内存块恰好分配在 PSRAM（`0x02000000` - `0x02040000`）的末尾附近。越界读取直接跨越了物理内存的最高边界 `0x02040000`，访问了未映射的非法地址，从而触发了硬件级别的 Data Abort。

---

## 3. 修复方法

RT-Thread 内核本身已经提供了完善的 `rt_realloc` 函数，它能够正确处理新旧内存块的大小，并在可能的情况下原地扩容，避免不必要的拷贝和越界问题。

将 `os_realloc` 的实现修改为直接调用 `rt_realloc`：

```c
void *os_realloc(void *ptr, size_t size)
{
    return (void *)rt_realloc(ptr, size);
}
```

这不仅解决了内存越界读取导致的 Data Abort 问题，还能提高 LVGL 图像解码时内存重新分配的运行效率。

---

## 4. 涉及模块与文件

| 模块 | 路径 |
|------|------|
| OS 内存适配层 | `beken378/rttos/mem_arch.c` |
| LVGL 内存管理 | `beken378/app/lvgl/src/misc/lv_mem.c` |

---

## 5. 变更记录

| 日期 | 说明 |
|------|------|
| 2026-05-12 | 分析并修复 `os_realloc` 越界读取导致的 Data Abort 问题，状态置为已关闭。 |
