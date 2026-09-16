# H133 原厂：`smem_start=0` 与 G2D 工作原理

本文只描述 **H133-dz 原厂代码**（`kernel/linux-5.4`、`platform/thirdparty/gui`），不涉及其它工程或本地补丁副本。

结论先说：在 H133 上读到 `finfo.smem_start == 0` 是 **IOMMU + ION 下的预期结果**，不是 framebuffer 没分配。原厂 G2D 仍然可用，因为这里的「地址 0」是合法 **IOVA**，不是空指针。

---

## 1. 背景

### 1.1 `smem_start` 是什么

Linux fbdev 的 `fb_fix_screeninfo.smem_start` 传统含义是 **framebuffer 的 CPU 物理地址**。老平台没有 IOMMU，G2D / DE 直接用这个 PA 访问显存，因此：

- `smem_start == 0` 会被当成「没有有效 buffer」
- 用户态把 `0` 塞给 G2D 会写到空地址，blit 失败

H133 已经不是这条模型。

### 1.2 H133 相关配置

`device/config/chips/h133/configs/p2/openwrt/bsp_defconfig`（其它 h133 板级类似）：

```
CONFIG_ION=y
CONFIG_ION_SYSTEM_HEAP=y
CONFIG_ION_CMA_HEAP=y
CONFIG_SUNXI_IOMMU=y
```

开了 `CONFIG_SUNXI_IOMMU` 之后：

- framebuffer 从 **ION SYSTEM heap** 分配（按页，不必连续 CMA）
- DE、G2D 都带 IOMMU master
- 设备看到的地址是 **IOVA（DMA 地址）**，不是 CPU PA
- IOVA 可以从 `0` 起映射，所以 `smem_start` 完全可以是 `0`

---

## 2. 原厂修了什么

原厂没有在用户态给 `smem_start==0` 加特殊分支，而是改了 **地址语义**：

| 项目 | 老芯片（无 IOMMU） | H133 原厂（IOMMU） |
|---|---|---|
| fb 内存 | CMA / `disp_malloc` 连续物理页 | ION SYSTEM heap |
| `smem_start` 含义 | CPU 物理地址，**不能为 0** | ION `dma_addr`（IOVA），**可以为 0** |
| mmap | 用 `smem_start` remap | ION dmabuf `mmap` |
| G2D `use_phy_addr=1` | 硬件直访 PA | 把 `laddr` 当 IOVA，IOMMU 翻译 |
| 画布加速 buffer | ION 连续 PA | `sunxifb_mem_get_phyaddr()` 同样是 IOVA |

用户态原厂 LVGL 仍写：

```c
use_phy_addr = 1;
laddr[0]     = finfo.smem_start;   /* 可以是 0 */
```

在 H133 上这是正确用法。

---

## 3. 内核：framebuffer 怎么变成 IOVA 0

### 3.1 分配

`kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/dev_fb.c` → `fb_map_video_memory()`：

```c
#if defined(CONFIG_ION)
	g_fbi.mem[info->node] =
	    disp_ion_malloc(info->fix.smem_len, (u32 *)(&info->fix.smem_start));
	if (g_fbi.mem[info->node])
		info->screen_base = (char __iomem *)g_fbi.mem[info->node]->vaddr;
#endif
	g_fb_addr.fb_paddr = (uintptr_t) info->fix.smem_start;
```

`disp_ion_malloc()`（`dev_disp.c`）把 ION 的 DMA 地址写回 `smem_start`：

```c
#if IS_ENABLED(CONFIG_SUNXI_IOMMU)
	heap_id_mask = 1 << ION_HEAP_TYPE_SYSTEM;
#else
	heap_id_mask = 2; /* ION_HEAP_TYPE_DMA */
#endif

	/* ion_alloc → kernel map → disp_dma_map(fd) */
	*paddr = (u32)mem->p_item->dma_addr;
```

注意两点：

1. `dma_addr` 来自 `disp_dma_map()` → `sg_dma_address()`，这是 **DE 设备视角的 IOVA**。
2. 写回时强制转成 `u32`。`smem_start` 本身是 `unsigned long`（64 位），高 32 位保持注册时的 `0`。IOVA 落在 32 位内时，用户态看到的就是这个值；IOVA 正好是 `0` 时，用户态就是 `smem_start=0`。

注册时先把 `fix.smem_start` 置 `0x0`，unmap 时再清回 `0`。中间这段，`0` 表示「IOVA 起点」，不是「没分配」。

### 3.2 mmap：不依赖 `smem_start`

```c
static int sunxi_fb_mmap(struct fb_info *info, struct vm_area_struct *vma)
{
	if (off < info->fix.smem_len) {
#if defined(CONFIG_ION)
		return g_fbi.mem[info->node]->p_item->dmabuf->ops->mmap(
		    g_fbi.mem[info->node]->p_item->dmabuf, vma);
#else
		return dma_mmap_writecombine(..., info->fix.smem_start, ...);
#endif
	}
}
```

ION 路径用 dmabuf 做用户态映射。CPU 读写 framebuffer 只靠 `mmap` 出来的虚拟地址，和 `smem_start` 是否为 0 无关。

### 3.3 DE 上屏

图层地址同样用 `smem_start`：

```c
config.info.fb.addr[0] = (unsigned long long)info->fix.smem_start;
```

DE 也走 IOMMU（`DE_MASTOR_ID`）。`addr[0] == 0` 表示从 IOVA 0 取像素，能正常显示。

### 3.4 内核自带的 fb G2D 旋转

文件：`kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/fb_g2d_rot.c`  
开关：`CONFIG_SUNXI_DISP2_FB_HW_ROTATION_SUPPORT`  
脚本：`disp.disp_rotation_used` / `disp.degreeN`

创建时：

```c
fb_rot->info.src_image_h.laddr[0] = p_info->fix.smem_start;
fb_rot->info.src_image_h.use_phy_addr = 1;
/* dst 是 disp_malloc 出来的另一块 IOVA */
fb_rot->info.dst_image_h.use_phy_addr = 1;
```

每次 apply：

```c
inst->info.src_image_h.laddr[0] =
    inst->fb->fix.smem_start +
    inst->fb->fix.line_length * inst->fb->var.yoffset;
g2d_blit_h(&inst->info);
```

`smem_start=0` 时，源地址就是「IOVA 0 + 当前显示页偏移」，目标是独立旋转 buffer。这和用户态 LVGL 旋转是两套路径。

---

## 4. 内核 G2D：两种地址模式

设备节点：`/dev/g2d`  
用户态命令：`G2D_CMD_BITBLT_H` 等  
实现：`kernel/linux-5.4/drivers/char/sunxi_g2d/g2d_driver.c`

`g2d_image_enh` 关键字段（`g2d_driver_enh.h`）：

| 字段 | 含义 |
|---|---|
| `laddr[3]` / `haddr[3]` | 平面地址低 32 位 / 高 32 位 |
| `use_phy_addr` | 1：直接用 `laddr`；0：用 `fd` 做 dmabuf map |
| `fd` | dmabuf fd（仅 `use_phy_addr=0`） |
| `clip_rect` | 操作区域 |
| `format` | `G2D_FORMAT_ARGB8888` / `RGB565` / `RGB888` |

### 4.1 `use_phy_addr = 1`（原厂 LVGL 走这条）

`g2d_blit_h()` **不**调用 `g2d_dma_map()`，`laddr` 原样下给 G2D。  
H133 上 `laddr` 必须是 G2D 能认的 IOVA。`0` 合法，驱动不会因为「地址为 0」返回失败。

G2D 自己也有 IOMMU（`G2D_IOMMU_MASTER_ID`，出错时 `sunxi_reset_device_iommu()`）。

### 4.2 `use_phy_addr = 0`（原厂 LVGL 不用）

```c
if (!para->src_image_h.use_phy_addr) {
    g2d_dma_map(para->src_image_h.fd, src_item);
    g2d_set_info(&para->src_image_h, src_item); /* laddr = item->dma_addr */
}
```

`g2d_dma_map()`：`dma_buf_get(fd)` → attach 到 G2D 设备 → `sg_dma_address()`，得到 **G2D 自己的 IOVA**。  
旋转模块更严：任一侧 `use_phy_addr=0`，源和目标都按 fd map，不能一边 phy、一边 fd。

### 4.3 内核提供的查询 ioctl

`dev_fb.c` 自定义命令：

| ioctl | 值 | 作用 |
|---|---|---|
| `FBIO_CACHE_SYNC` | `0x4630` | cache 同步 |
| `FBIO_ENABLE_CACHE` | `0x4631` | 开关 fb cache |
| `FBIO_GET_IONFD` | `0x4632` | 取 ION/dmabuf fd |
| `FBIO_GET_PHY_ADDR` | `0x4633` | 取完整 `dma_addr`（`disp_get_phy_addr()`） |
| `FBIOGET_DMABUF` | `_IOR('F', 0x21, ...)` | 导出 dmabuf fd |
| `FBIO_RESET_FB` | `0x4634` | 按当前输出模式重置 fb |

Linux ≥ 4.12 的 `FBIOGET_DMABUF` 用 `g_fbi.mem[]->p_item->dmabuf`，**不读** `smem_start`。  
`< 4.12` 且非 ION 的 `sunxi_share_dma_buf()` 在 `smem_start==0` 时返回 `NULL`（H133 走 ION，不走这条）。

原厂 LVGL **没有**调用这些 ioctl 来「补救」`smem_start=0`，因为直接用 `smem_start` 当 IOVA 已经够用。

---

## 5. 用户态原厂 G2D（LVGL-8）

主文件：

- `platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunxifb.c`
- `platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunxig2d.c`
- `platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunximem.c`

LVGL-9 同一套语义，入口在 `platform/thirdparty/gui/lvgl-9/platform/`。

### 5.1 初始化

`sunxifb_init()`：

1. `open("/dev/fb0")`
2. `FBIOGET_FSCREENINFO` → `finfo.smem_start`（H133 上常为 `0`）
3. `mmap` 整段 `smem_len`（ION dmabuf，成功与否和 `smem_start` 无关）
4. 若 `USE_SUNXIFB_DOUBLE_BUFFER` 且页数 > 1：
   - `sunxifb_g2d_init()` → `open("/dev/g2d")`，按 bpp 设 `G2D_FORMAT_*`
   - `sunxifb_mem_init()` → 打开 ION adapter
5. 若 `USE_SUNXIFB_G2D_ROTATE`：ION 分配 `rotatefbp`，`rotatefbp_phy = sunxifb_mem_get_phyaddr()`

`sunxifb_mem_*` 只服务 ION 画布 / 旋转缓冲，**不**给 framebuffer 再查一遍物理地址。

### 5.2 `sunxifb_g2d_blit_to_fb()`

固定：

```c
info.src_image_h.laddr[0]      = src_buf;
info.src_image_h.use_phy_addr  = 1;
info.dst_image_h.laddr[0]      = dst_buf;
info.dst_image_h.use_phy_addr  = 1;
ioctl(g_g2dfd, G2D_CMD_BITBLT_H, &info);
```

没有 fd 参数，也不判断 `src_buf/dst_buf == 0`。`smem_start=0` 就按 IOVA 0 提交。

### 5.3 和 framebuffer 相关的三处调用

都在 `sunxifb_flush()` / `sunxifb_set_dbuf_en()`，且要开 `USE_SUNXIFB_DOUBLE_BUFFER`。

#### （1）G2D 旋转（`USE_SUNXIFB_G2D_ROTATE`）

LVGL 画在 ION `rotatefbp` 上，帧末旋到后台 fb 页：

```
src: rotatefbp_phy          （ION IOVA，一般非 0）
dst: finfo.smem_start       （fb IOVA，可以为 0）
     clip.y = fbindex * yres
```

ioctl 失败才 `sunxifb_soft_rotate()`。`smem_start=0` 本身不会触发失败。

#### （2）双缓冲页同步（开了 G2D、没开旋转）

前后台是同一块 fb，靠 clip 选页：

```
src/dst: 都是 finfo.smem_start（可为 0）
src clip.y = fbindex * yres
dst clip.y = nextindex * yres
```

失败才 `memcpy` 虚拟地址页。

#### （3）`sunxifb_set_dbuf_en(true)` 再开双缓冲

同样 `smem_start → smem_start` 拷一页。这里不看返回值。

### 5.4 不受 `smem_start` 影响的 G2D

`sunxifb_g2d_fill` / `blit` / `blend` / `scale` 的 buffer 来自 `sunxifb_mem_alloc()`，地址用 `sunxifb_mem_get_phyaddr()`。  
和 fb 的 `smem_start` 无关，`0` 或非 `0` 都不影响画布加速。

LVGL-9 在 32bpp flush 时，还会把 dirty 区从 ION `pixel_map` blit 到 `finfo.smem_start`（目标 IOVA 可为 0）。

---

## 6. 完整数据流（`smem_start=0`）

```
                    ion_alloc(SYSTEM heap)
                            │
              ┌─────────────┴─────────────┐
              ▼                           ▼
     disp_dma_map(DE)              mmap(dmabuf)
     dma_addr = 0 (IOVA)           CPU 虚拟地址 fbp
              │
              ├─ fix.smem_start = 0
              ├─ DE layer.addr[0] = 0     →  IOMMU → 上屏
              └─ G2D laddr = 0            →  IOMMU → blit/rotate
                            │
         用户态 sunxifb_g2d_blit_to_fb()
         use_phy_addr=1, laddr=smem_start
                            │
                    G2D_CMD_BITBLT_H
```

旋转时多一块 ION `rotatefbp`：

```
LVGL  →  rotatefbp (CPU VA)
      →  rotatefbp_phy (ION IOVA)
      →  G2D rotate
      →  fb IOVA 0 + yoffset
      →  FBIOPAN_DISPLAY
```

---

## 7. 原厂用户态为什么不用 fd

内核已经支持 dmabuf fd（`use_phy_addr=0`）。原厂 LVGL 仍走 IOVA，原因是：

1. `smem_start` 已经被写成 IOVA，`0` 可用，不必再导出 fd。
2. 旋转源是 ION，`sunxifb_mem_get_phyaddr()` 也能拿到 IOVA。
3. 双缓冲同步是同一块 buffer 的两个 clip，一个 IOVA 即可。

只有在这些情况才需要 fd / `FBIO_GET_PHY_ADDR`：

- 用户态看不到正确 IOVA（例如被 `FBINFO_HIDE_SMEM_START` 抹掉，而 H133 sunxi fb 的 `flags=0`，**没有**开 hide）
- 源、目标分属不同 IOMMU domain，不能共用一个 IOVA
- 64 位 IOVA 高 32 位非 0，而 `smem_start` 只回写了 `u32`

原厂当前产品路径不依赖上述兜底。

---

## 8. 和「地址 0 就失败」的误判对照

| 误判 | 原厂实际情况 |
|---|---|
| `smem_start=0` 表示没分配 | 已分配，IOVA 起点是 0 |
| G2D 不能 blit 到地址 0 | `use_phy_addr=1` + `laddr=0` 合法 |
| 必须用 dmabuf fd 才能加速 | 原厂 LVGL 不用 fd，G2D 可用 |
| mmap 会失败 | mmap 走 ION dmabuf，与 `smem_start` 无关 |
| 画布 fill/blit 也会坏 | 画布用独立 ION IOVA，不受影响 |
| 内核旋转会坏 | `fb_g2d_rot` 同样把 `smem_start` 当 IOVA |

真正会失败的情况是：G2D ioctl 参数非法（clip 越界、format 不支持、`/dev/g2d` 没开），或 ION/`rotatefbp_phy` 自己没拿到。那和 `smem_start` 是否为 0 无关。

---

## 9. 关键文件索引

| 路径 | 内容 |
|---|---|
| `device/config/chips/h133/configs/*/openwrt/bsp_defconfig` | `CONFIG_SUNXI_IOMMU` / `CONFIG_ION` |
| `kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/dev_fb.c` | fb 分配、mmap、ioctl、DE 图层地址 |
| `kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/dev_disp.c` | `disp_ion_malloc` / `disp_get_phy_addr` |
| `kernel/linux-5.4/drivers/video/fbdev/sunxi/disp2/disp/fb_g2d_rot.c` | 内核 fb G2D 旋转 |
| `kernel/linux-5.4/drivers/char/sunxi_g2d/g2d_driver.c` | `g2d_blit_h`、`g2d_dma_map`、`g2d_set_info` |
| `kernel/linux-5.4/drivers/char/sunxi_g2d/g2d_rcq/g2d.c` | G2D IOMMU reset |
| `platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunxifb.c` | flush、旋转、双缓冲同步 |
| `platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunxig2d.c` | 用户态 G2D 封装 |
| `platform/thirdparty/gui/lvgl-8/lv_drivers/display/sunximem.c` | ION 分配 / 取 IOVA / cache |
| `platform/thirdparty/gui/lvgl-9/platform/sunxifb.c` | LVGL-9 同语义 |
| `platform/thirdparty/gui/lvgl-9/platform/disp/sunxifb_port_linux_fbdev.c` | `*mem_phy = finfo.smem_start` |

---

## 10. 一句话

H133 原厂把 framebuffer 放进 ION + IOMMU，`smem_start` 从「CPU 物理地址」变成「设备 IOVA」。`0` 是合法起点。G2D / DE / 内核旋转都按 IOVA 用这块地址，所以 `smem_start=0` 时 G2D 仍然可用，用户态不必为 0 单独改路径。
