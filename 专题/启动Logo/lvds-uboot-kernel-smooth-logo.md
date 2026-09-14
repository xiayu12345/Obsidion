# 全志 H133 LVDS 开机 Logo 无缝显示机制

本文基于本仓库官方 disp2 / BootGUI 代码，说明：U-Boot 已经把 LVDS 屏幕点亮并显示 logo 后，内核如何避免“先闪一下黑屏，再重新出 logo”。

适用平台：全志 H133（sunxi disp2 + brandy-2.0 U-Boot 2018）。  
LVDS 在 disp 框架里走 **LCD 设备**（`DISP_OUTPUT_TYPE_LCD`），面板接口类型为 `LCD_IF_LVDS`。

---

## 1. 问题现象

正常期望：

```
上电 → U-Boot 显示 logo → 跳内核 → logo 一直在 → 应用接管 UI
```

异常现象：

```
U-Boot 显示 logo
        ↓
跳内核后 logo 消失 / 黑一下
        ↓
内核重新开屏，logo 再出来一次
```

根因不是“logo 画了两次”，而是 **硬件链路被内核重新初始化了一遍**：

1. U-Boot 已经打开 DE / TCON / LVDS PHY / 背光，并持续出图。
2. 内核如果走完整 `disp_lcd_enable()`，会再跑一遍 panel `open_flow`：
   - 重新上电
   - 复位面板
   - `sunxi_lcd_tcon_enable()` 重配 TCON/LVDS
   - 关背光再开背光
3. 或者内核先把 DE layer 切到一块还没画 logo 的空 framebuffer，画面会先黑一下。

官方解决办法叫 **smooth display（无缝显示）**：  
**硬件不断电、不关 TCON、不重开 LVDS；内核只接管软件状态，并在切 layer 前把 logo 拷进自己的 FB。**

---

## 2. 总体思路

| 阶段 | 做什么 | 不做什么 |
|------|--------|----------|
| U-Boot 显示 logo | 正常开 LVDS、画 logo | 跳内核前 **不要** `lcd_disable` / `tcon_disable` / 关背光 |
| 跳内核前 | 把显示状态和 FB 地址写进 DTB / cmdline | 不要释放 DE 时钟和 logo 内存 |
| 内核 disp 探测 | 解析 `boot_disp`，置 `boot_info.sync = 1` | 不要当冷启动重新 `open_flow` |
| 内核 FB 初始化 | 先把 U-Boot logo 拷到内核 FB，再切 DE layer | 不要先 `set_layer_config` 再拷图 |
| 内核软件接管 | `disp_lcd_sw_enable()` 认领时钟/regulator/GPIO/PWM | 不要 `disp_lcd_enable()` |

时序：

```
U-Boot
  boot_gui_init()
    disp_devices_open()     // 开 DE + TCON + LVDS + 背光
    fb_init()               // 画 bootlogo
        │
        │  跳内核前硬件保持运行
        │  save_disp_cmd()      → boot_disp / boot_fb0
        │  save_disp_cmdline()  → disp_reserve
        ▼
Kernel disp probe
  解析 boot_disp → boot_info.sync = 1
  bsp_disp_init()
  lcd_init()
  fb_init()
      Fb_map_kernel_logo() / Fb_copy_boot_fb()   // 先拷 logo
      mgr->set_layer_config()                    // 再切 layer
  start_process()
      start_work()
        bsp_disp_sync_with_hw()
          disp_lcd_sw_enable()                   // 只接管，不重开屏
```

---

## 3. U-Boot 侧：保持出图，只传递状态

### 3.1 入口

| 文件 | 作用 |
|------|------|
| `brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/bootGUI/boot_gui.c` | BootGUI 初始化、保存显示参数 |
| `brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/bootGUI/fb_con.c` | 写 `boot_fb0`、`disp_reserve` |
| `brandy/brandy-2.0/u-boot-2018/drivers/video/sunxi/bootGUI/video_hal.c` | 写 `boot_disp` / `boot_disp1` / `boot_disp2` |
| `brandy/brandy-2.0/u-boot-2018/board/sunxi/board_helper.c` | 更新 DTS 时调用 `save_disp_cmd()` |
| `brandy/brandy-2.0/u-boot-2018/board/sunxi/sunxi_bootargs.c` | cmdline 追加 `disp_reserve=` |

`boot_gui.c`：

```c
int save_disp_cmd(void)
{
    for (i = FB_ID_0; i < FRAMEBUFFER_NUM; ++i)
        fb_save_para(i);
}

int save_disp_cmdline(void)
{
    for (i = FB_ID_0; i < FRAMEBUFFER_NUM; ++i)
        fb_update_cmdline(i);
}

int boot_gui_init(void)
{
    disp_devices_open();   // 开显示设备
    fb_init();             // 显示 logo
}
```

跳内核前必须保证：

1. DE / TCON / LVDS / 背光仍然使能。
2. logo 所在物理内存没有被覆盖。
3. 上述三个参数已经写进 DTB / cmdline。

### 3.2 `boot_disp` 编码

`hal_save_boot_disp()`：

```c
disp_para0 = (((type << 8) | mode) << (screen_id * 16));
disp_para1 = (cs << 16) | (bits << 8) | format;
disp_para2 = eotf;

hal_save_int_to_kernel("boot_disp",  disp_para0);
hal_save_int_to_kernel("boot_disp1", disp_para1);
hal_save_int_to_kernel("boot_disp2", disp_para2);
```

`boot_disp` 位域：

```
screen0:
  [7:0]   mode
  [15:8]  type     // LVDS 为 DISP_OUTPUT_TYPE_LCD = 1

screen1:
  [23:16] mode
  [31:24] type
```

`boot_disp1` 位域：

```
[7:0]   format
[15:8]  bits
[31:16] cs
```

内核看到 `type != DISP_OUTPUT_TYPE_NONE` 就会置 `boot_info.sync = 1`。  
**如果 U-Boot 没写 `boot_disp`，内核会当成冷启动，重新跑完整开屏，必然闪一下。**

### 3.3 `boot_fb0`：U-Boot framebuffer 描述

`fb_save_para()` 写成字符串：

```
boot_fb0 = "<addr>,<width>,<height>,<bpp>,<stride>,<crop_l>,<crop_t>,<crop_r>,<crop_b>"
```

对应 `fb_con.c`：

```c
sprintf(fb_paras, "%p,%x,%x,%x,%x,%x,%x,%x,%x",
    fb->cv->base, fb->cv->width, fb->cv->height,
    fb->cv->bpp, fb->cv->stride,
    interest_rect->left, interest_rect->top,
    interest_rect->right, interest_rect->bottom);
hal_save_string_to_kernel("boot_fb0", fb_paras);
```

内核 `Fb_copy_boot_fb()` 按这个格式解析，把 U-Boot FB 逐行拷到内核 FB。

### 3.4 `disp_reserve`：保护 logo 内存

`fb_update_cmdline()`：

```c
size = align(width * bpp / 8) * height;
snprintf(disp_reserve, 80, "%d,0x%p", size, fb->cv->base);
hal_reserve_logo_mem(addr, size);
env_set("disp_reserve", disp_reserve);
```

`sunxi_bootargs.c` 再拼进内核 cmdline：

```
disp_reserve=<size>,0x<addr>
```

作用：

- 内核 memblock 把这块 RAM 保留下来。
- 内核在拷贝完成前不能把这块内存当普通内存分配。
- 否则会出现：U-Boot logo 还在 DE 上显示，但内容已经被内核踩掉，表现为花屏或闪一下。

### 3.5 可选：`fb_base`（BMP 原图）

如果 U-Boot 把 BMP 原图地址写到 disp 节点的 `fb_base`，内核会走 `Fb_map_kernel_logo()` 重新解码 BMP。  
没有 `fb_base` 时，退回到 `Fb_copy_boot_fb()` 直接拷 `boot_fb0` 对应的像素缓冲。

---

## 4. 内核侧：smooth display

### 4.1 解析 `boot_disp`

文件：`kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/dev_disp.c`

```c
value  = disp_boot_para_parse("boot_disp");
value1 = disp_boot_para_parse("boot_disp1");
value2 = disp_boot_para_parse("boot_disp2");

output_type = (value >> 8) & 0xff;   // disp0
output_mode =  value        & 0xff;

if (output_type != DISP_OUTPUT_TYPE_NONE) {
    para->boot_info.sync = 1;
    para->boot_info.disp = 0;
    para->boot_info.type = output_type;
    para->boot_info.mode = output_mode;
    ...
}

if (para->boot_info.sync == 1)
    __wrn("smooth display screen:%d type:%d mode:%d\n", ...);
```

`disp_bootloader_info`：

```c
struct disp_bootloader_info {
    int sync;   /* 1: 与 bootloader 无缝衔接 */
    int disp;
    int type;
    int mode;
    int format;
    int bits;
    int eotf;
    int cs;
    ...
};
```

调试时内核 log 必须能看到：

```
smooth display screen:0 type:1 mode:x
```

`type:1` 就是 `DISP_OUTPUT_TYPE_LCD`（含 LVDS）。

### 4.2 探测顺序（非常关键）

同一函数里的顺序是：

```c
bsp_disp_init(para);
lcd_init();
bsp_disp_open();          // 空操作，直接 return
fb_init(pdev);            // ① 先拷 logo，再切 layer
g_disp_drv.inited = true;
start_process();          // ② 再 schedule start_work → sw_enable
```

含义：

1. **硬件此时仍是 U-Boot 留下的状态**（TCON/LVDS 仍在出图）。
2. `fb_init()` 先把 logo 画进内核 FB，再把 DE layer 指过去。切过去时画面已经是同一张图。
3. `start_work()` 再调用 `bsp_disp_sync_with_hw()`，用 `sw_enable` 把软件状态标记为“已打开”。

如果把这两步反过来，或者 `fb_init` 时 FB 还是空的，就会闪黑。

### 4.3 `start_work()`：冷启动 vs 无缝

```c
if (g_disp_drv.para.boot_info.sync == 0) {
    /* 冷启动：完整 enable，会跑 open_flow，会闪 */
    disp_device_set_config(...);
} else {
    /* 无缝：只做软件接管 */
    if (bsp_disp_get_output_type(...) != boot_info.type)
        bsp_disp_sync_with_hw(&g_disp_drv.para);
}
```

`bsp_disp_sync_with_hw()`：

1. `disp_device_attached()` 把 LCD 绑到 manager。
2. 调用 `mgr->device->sw_enable()`，即 `disp_lcd_sw_enable()`。
3. **不调用** `disp_lcd_enable()`。

### 4.4 `disp_lcd_enable()` vs `disp_lcd_sw_enable()`

这是防闪的核心。

#### 完整开屏（会闪）

文件：`disp_lcd.c` → `disp_lcd_enable()`

典型 panel `open_flow`（`default_panel.c`，LVDS 也走这条）：

```c
LCD_OPEN_FUNC(sel, LCD_power_on, 30);
LCD_OPEN_FUNC(sel, LCD_panel_init, 50);
LCD_OPEN_FUNC(sel, sunxi_lcd_tcon_enable, 100);
LCD_OPEN_FUNC(sel, LCD_bl_open, 0);
```

对应硬件动作：

| 步骤 | 函数 | 后果 |
|------|------|------|
| 上电 | `LCD_power_on` / `sunxi_lcd_pin_cfg` | 电源和 pinmux 再配一遍 |
| 面板初始化 | `LCD_panel_init` | 部分屏会复位 |
| 开 TCON | `sunxi_lcd_tcon_enable` | **重配 TCON 时序和 LVDS PHY，画面中断** |
| 开背光 | `LCD_bl_open` | 若前面关过背光，就会先黑再亮 |

`disp_lcd_enable()` 还会：

- `mgr->enable()` 重新初始化 DE
- `lcd_clk_enable()` 配时钟
- `disp_al_lcd_cfg()` 重写 TCON 寄存器
- 逐条执行 `open_flow`

这就是“logo 先出来，闪一下，再出来”的直接原因。

#### 无缝接管（不闪）

`disp_lcd_sw_enable()` **故意不跑** `cfg_open_flow`，也不 `disp_al_lcd_cfg()`：

```c
static s32 disp_lcd_sw_enable(struct disp_device *lcd)
{
    mgr->sw_enable(mgr);          // DE 只做软件 enable，不复位流水线

#if !defined(CONFIG_COMMON_CLK_ENABLE_SYNCBOOT)
    lcd_clk_enable(lcd);         // 仅增加 clk 引用计数 / deassert reset
#endif

    /* 认领 regulator / gpio / pwm，不重新做 panel 时序 */
    disp_sys_power_enable(...);
    disp_sys_pwm_config(...);
    disp_sys_pwm_enable(...);

    lcdp->enabled = 1;
    lcdp->bl_need_enabled = 1;
    lcdp->bl_enabled = true;

    /* 只注册 IRQ，不重配 TCON */
    disp_sys_register_irq(...);
}
```

对比：

| 动作 | `disp_lcd_enable` | `disp_lcd_sw_enable` |
|------|-------------------|---------------------|
| `mgr->enable()` | 是 | 否，改 `mgr->sw_enable()` |
| `disp_al_lcd_cfg()` | 是 | **否** |
| `cfg_open_flow` | 是 | **否** |
| `sunxi_lcd_tcon_enable` | 是 | **否** |
| 背光关再开 | 是 | 否，只把 `bl_enabled` 置 true |
| `lcdp->enabled = 1` | 是 | 是 |

`mgr->sw_enable()`（`disp_mgr_sw_enable`）同样：

- 不复位 DE 模块
- 在没有 `CONFIG_COMMON_CLK_ENABLE_SYNCBOOT` 时只 `clk_prepare_enable`
- 注册 vsync IRQ、同步软件配置，让 DE 继续扫 U-Boot 已经配好的 layer

### 4.5 为什么要把 `enabled` 置 1

`disp_lcd_check_config_dirty()`：

```c
if (lcdp->enabled == 0 || mode_dirty)
    return DISP_NORMAL_UPDATE;
```

`DISP_NORMAL_UPDATE` 时上层会：

```c
if (mgr->device->is_enabled(mgr->device))
    mgr->device->disable(mgr->device);   // 关 TCON / 关背光
mgr->device->enable(mgr->device);        // 再完整 open_flow
```

所以 `sw_enable` 必须先把 `lcdp->enabled = 1`。  
否则后续任何 `set_config` 都会走“先关再开”，logo 必然闪。

LCD 没有 `DISP_SMOOTH_UPDATE` 路径（HDMI 才有 `smooth_enable`）。  
LCD/LVDS 的无缝完全依赖 **`sync=1` + `sw_enable`**。

---

## 5. Logo 如何从 U-Boot FB 接到内核 FB

文件：`kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/dev_fb.c`

### 5.1 调用点

`display_fb_request()`：

```c
config.enable = 1;
Fb_map_kernel_logo(sel, info);     // 必须在 set_layer_config 之前
...
config.info.fb.addr[0] = info->fix.smem_start;
mgr->set_layer_config(mgr, &config, 1);
```

顺序不能改：**先拷图，再切 layer。**

### 5.2 `Fb_map_kernel_logo()`

1. 读 `fb_base`（BMP 物理地址）。
2. 若地址为 0，转 `Fb_copy_boot_fb()`。
3. 校验 BMP 头 `'BM'`。
4. 把像素居中拷到内核 `info->screen_base`。

### 5.3 `Fb_copy_boot_fb()`

解析 `boot_fb0`：

```
addr, width, height, bpp, stride, crop_l, crop_t, crop_r, crop_b
```

然后：

1. `Fb_map_kernel_cache()` 映射 U-Boot FB。
2. 按 crop 裁剪。
3. 按 stride 逐行 memcpy 到内核 FB。
4. **要求 src_bpp == dst_bpp**，否则直接失败，内核 FB 保持空白，切 layer 就会闪黑。

### 5.4 切 layer 时硬件仍在出 U-Boot 那层

此时：

- TCON / LVDS 还在按 U-Boot 时序出图。
- DE 的 layer 地址从 U-Boot FB 换成内核 FB。
- 两块 buffer 内容已经是同一张 logo。

只要 DE 在 vsync 附近更新 shadow 寄存器，肉眼就是连续的。  
如果内核 FB 是全 0，就会看到“logo → 黑一下 → logo”。

---

## 6. LVDS 相关注意点

LVDS 没有单独的 output type，走 LCD：

```
boot_disp.type = DISP_OUTPUT_TYPE_LCD (1)
panel_info.lcd_if = LCD_IF_LVDS
```

`lcd_clk_enable()` 对 LVDS 额外处理：

```c
if (lcdp->panel_info.lcd_if == LCD_IF_LVDS) {
    reset_control_deassert(lcdp->rst_bus_lvds);
    clk_prepare_enable(lcdp->clk_lvds);
}
```

`sw_enable` 在未定义 `CONFIG_COMMON_CLK_ENABLE_SYNCBOOT` 时仍会调用 `lcd_clk_enable()`。

通常：

- `clk_prepare_enable()` 对已经打开的时钟只增加引用计数。
- `reset_control_deassert()` 若已经 deassert，一般是空操作。

但仍有两个风险：

1. 内核 CCF 在 disp 驱动 probe 前把 U-Boot 留下的时钟当 unused 关掉，logo 会先灭。
2. `lcd_clk_config()` 若重新配 PLL/分频，TCON 像素时钟会抖一下。

官方更稳的做法是打开 `CONFIG_COMMON_CLK_ENABLE_SYNCBOOT`，让 `sw_enable` 完全跳过 `lcd_clk_enable()` / `disp_mgr_clk_enable()`。  
本仓库当前配置里 **没有看到这个宏被打开**，因此 LVDS 无缝路径仍会走一遍 `clk_prepare_enable`。只要时钟框架没有先关掉这些时钟，一般不会闪。

---

## 7. 关键代码索引

### U-Boot

| 路径 | 说明 |
|------|------|
| `brandy/.../bootGUI/boot_gui.c` | `save_disp_cmd` / `save_disp_cmdline` / `boot_gui_init` |
| `brandy/.../bootGUI/fb_con.c` | `fb_save_para`、`fb_update_cmdline` |
| `brandy/.../bootGUI/video_hal.c` | `hal_save_boot_disp` |
| `brandy/.../board/sunxi/board_helper.c` | 更新 DTS 时保存 boot_disp |
| `brandy/.../board/sunxi/sunxi_bootargs.c` | cmdline 追加 `disp_reserve` |
| `brandy/.../logo_display/cmd_sunxi_bmp.c` | `sunxi_bmp_display("bootlogo.bmp")` |

### Kernel

| 路径 | 说明 |
|------|------|
| `disp2/disp/dev_disp.c` | 解析 `boot_disp`，`start_work`，探测顺序 |
| `disp2/disp/de/disp_display.c` | `bsp_disp_sync_with_hw` |
| `disp2/disp/de/disp_lcd.c` | `disp_lcd_enable` / `disp_lcd_sw_enable` / `check_config_dirty` |
| `disp2/disp/de/disp_manager.c` | `disp_mgr_sw_enable` |
| `disp2/disp/dev_fb.c` | `Fb_map_kernel_logo` / `Fb_copy_boot_fb` |
| `disp2/disp/lcd/default_panel.c` | 默认 `open_flow`（含 LVDS） |
| `disp2/disp/de/include.h` | `disp_bootloader_info`、`DISP_SMOOTH_UPDATE` |

---

## 8. 参数清单

| 参数 | 存放位置 | 用途 |
|------|---------|------|
| `boot_disp` | disp 设备树节点 u32 | 无缝开关 + 屏号/类型/mode |
| `boot_disp1` | 同上 | format / bits / cs |
| `boot_disp2` | 同上 | eotf |
| `boot_fb0` | 同上，字符串 | U-Boot FB 地址和几何 |
| `fb_base` | 同上，u32 | BMP 原图地址（可选） |
| `disp_reserve` | cmdline | 保留 logo 内存 |

`boot_info.sync` 判定：

```
boot_disp 的 type 字节 != 0  → sync = 1  → 无缝
boot_disp 为 0 或不存在     → sync = 0  → 完整开屏，会闪
```

---

## 9. 排障清单

按顺序核对。

### 9.1 内核有没有进入无缝

```
dmesg | grep -i "smooth display"
```

期望：

```
smooth display screen:0 type:1 mode:xxx
```

没有这行：`boot_disp` 没传到 disp 节点，内核走冷启动。

检查：

- U-Boot 是否 `CONFIG_BOOT_GUI`
- `save_disp_cmd()` 是否被调用
- 内核 `/proc/device-tree` 里 disp 节点是否有 `boot_disp`

### 9.2 `boot_fb0` / `disp_reserve` 是否有效

内核若打印：

```
no boot_fb0
Fb_map_kernel_logo failed
wrong para: src[...]
```

说明 logo 没拷成功。随后 `set_layer_config` 会把空 FB 送上 DE，表现为闪黑。

要求：

- `boot_fb0` 地址与 `disp_reserve` 地址一致
- bpp 与内核 FB 一致（常见 32bit）
- `disp_reserve` 大小覆盖整帧

### 9.3 是否误走了完整 `open_flow`

无缝时 **不应** 再看到 panel 的 power_on / tcon_enable / backlight 完整时序 delay。  
若 `disp_lcd_enable()` 被调用，说明：

- `boot_info.sync == 0`，或
- `lcdp->enabled` 仍为 0，`check_config_dirty` 返回 `DISP_NORMAL_UPDATE`

### 9.4 时钟是否被 CCF 关掉

跳内核后、disp probe 前，如果 DE/TCON/LVDS 时钟被 unused-clk 关掉，logo 会先灭。  
处理：

- 打开 `CONFIG_COMMON_CLK_ENABLE_SYNCBOOT`，或
- 保证这些时钟在 disp 驱动认领前不被 disable

### 9.5 不要在内核里再开一次屏

应用或 init 脚本不要在 logo 阶段调用：

- `DISP_LCD_ENABLE`
- panel `open_flow`
- 关背光再开背光

应用应等 UI 第一帧准备好后，再替换 layer 内容，而不是重新 enable LCD。

### 9.6 PWM 背光

`sw_enable` 会对 PWM 再 `config + set_polarity + enable`。  
若极性配反，会闪一下或常黑。无缝时 PWM 参数必须与 U-Boot 完全一致。

---

## 10. 和“闪一下”对应的代码路径对照

| 现象 | 路径 | 修复方向 |
|------|------|----------|
| logo 灭一下再亮，伴随背光闪 | 走了 `disp_lcd_enable` → `LCD_bl_open` | 保证 `boot_disp.sync=1`，走 `sw_enable` |
| logo 灭一下再亮，无背光动作 | `sunxi_lcd_tcon_enable` 重配 LVDS | 同上，禁止 `open_flow` |
| 先黑一下，再出同一张 logo | 先 `set_layer_config` 后拷图，或拷图失败 | 保持“先 `Fb_map_kernel_logo` 再切 layer” |
| 花屏一下再恢复 | `disp_reserve` 没生效，U-Boot FB 被踩 | 检查 cmdline `disp_reserve` |
| U-Boot logo 正常，进内核永久黑 | `sw_enable` 失败，或时钟被关掉且没再开 | 查 `lcd_clk_enable` / regulator |
| 进内核后又完整复位屏 | `check_config_dirty` 看到 `enabled==0` | `sw_enable` 必须成功置 `enabled=1` |

---

## 11. 实现检查表

U-Boot：

- [ ] BootGUI 已打开，开机能显示 logo
- [ ] 跳内核前不调用 LCD close_flow
- [ ] DTB disp 节点有 `boot_disp` / `boot_fb0`
- [ ] cmdline 有 `disp_reserve=<size>,0x<addr>`
- [ ] logo 内存在 `disp_reserve` 范围内

Kernel：

- [ ] 启动 log 有 `smooth display screen:0 type:1`
- [ ] `start_work` 走 `bsp_disp_sync_with_hw`，不走 `disp_device_set_config` 完整 enable
- [ ] `fb_init` 中先拷 logo 再 `set_layer_config`
- [ ] 未再次执行 panel `open_flow`
- [ ] LVDS 时钟在 probe 前未被 CCF 关闭

---

## 12. 一句话总结

官方防闪策略不是“内核再画一次 logo”，而是：

1. **U-Boot 把 LVDS 硬件链路一直开着**；
2. **用 `boot_disp` 告诉内核“屏已经在显示”**；
3. **内核用 `disp_lcd_sw_enable()` 只接管软件状态，绝不重跑 TCON/LVDS `open_flow`**；
4. **先把 U-Boot logo 拷进内核 FB，再切 DE layer**。

只要这四步不断，LVDS 从 U-Boot 到内核就不会出现“logo 出来 → 闪一下 → logo 再出来”。
