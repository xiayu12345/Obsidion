# H133 踩坑记录

> 从 Ubuntu 工程 `docs/` 与 `H133开发文档-wjz/` 提炼的高频问题。

## BUG-001：G2D 用户态/内核 ABI 不一致

**现象**

```
[G2D] dma_buf_get failed, fd=255
ERROR: sunxifb_g2d_blend G2D_CMD_BLD_H failed: Operation not permitted
ion_alloc_vir2phy failed, no virtual address: 0x69798c
```

**根因**

用户态 `g2d_image_enh` 比内核多了一个 `g2d_size resize` 字段（8 字节），ioctl 传参偏移错位，`fd=255` 实为 `alpha=255` 被误读。

**修复**

1. 对齐 `g2d_driver_enh.h` 与 `kernel/.../g2d_driver.h`
2. 删除旧 build_dir：`out/h133/p1_nor/openwrt/build_dir/target/lv_projector/`
3. **在工程顶层** `m` 重编，勿在 `openwrt/openwrt/` 单独 make

**文档**：`docs/debug-notes-g2d-abi-and-toplevel-build.md`

---

## BUG-002：SD 卡识别但不挂载

**现象**

```
mmcblk0: p1 已出现
ls /mnt/SDCARD   # 空
cat /proc/mounts | grep mmc  # 无
```

手动 `mount -t vfat /dev/mmcblk0p1 /mnt/SDCARD` 成功。

**根因**

- hotplug/mdev/fstab 已禁用 SD 自动挂载（设计如此）
- `main.c` 中 **`system_init_early()` 被注释**，DiskManager 未初始化

**修复**

恢复 `main.c`：

```c
system_init_early();
wait_sd_mount_ready(KTV_SD_PROBE_MAX_SEC);
```

重编 `lv_projector` 并刷机。

**文档**：`docs/H133-Tina-SD卡调试经验.md`

---

## BUG-003：顶层目录编译铁律

**现象**

改了 G2D 头文件仍报错，或 toolchain/staging 路径异常。

**根因**

在 `openwrt/openwrt/` 子目录执行 `make`，`LICHEE_*` 环境变量为空。

**修复**

始终：

```bash
cd ~/Workspace/HDMI_new/HDMI
source build/envsetup.sh
m
```

---

## BUG-004：OpenWrt Build/Prepare 不覆盖旧源码

**现象**

源码已改对，板端行为仍旧。

**根因**

`build_dir/target/lv_projector/` 缓存旧文件，增量编译未更新。

**修复**

```bash
rm -rf out/h133/p1_nor/openwrt/build_dir/target/lv_projector/
m
```

---

## 更多专题踩坑

| 主题 | 文档位置（Ubuntu 工程） |
|---|---|
| MIPI+HDMI 双显 | `H133开发文档-wjz/驱动/HDMI&mipi&lvds/H133-MIPI-HDMI双显开发记录.md` |
| GT911+USB 鼠标并存 | `H133开发文档-wjz/驱动/TP驱动&鼠标&触摸/H133-USB鼠标与GT911触摸并存-lvgl.md` |
| 44100 单声道播放 | `H133开发文档-wjz/驱动/H133-44100单声道播放修复与ALSA路由方案.md` |
| LCD 背光不亮 | `H133开发文档-wjz/驱动/HDMI&mipi&lvds/H133-LCD背光亮度-硬件供电分析.md` |
| rootfs 空间不足 | `H133开发文档-wjz/基础资料/H133-rootfs空间与应用占用说明.md` |


## 自动补充 - 2026-06-10

### 待确认的坑：HDMI 双显 layer 初始化失败

来源：`docs/HDMI/video-hdmi-dual-display.patch`、`docs/临时日志每次刷新`。

现象线索：日志/补丁中出现 `disp_get_layer`、screen1 layer 初始化失败、HDMI video 跳过等信息。建议继续记录复现条件：LCD/HDMI 同时启用、视频播放路径、layer 分配参数、G2D/display ABI 是否一致。

### 待确认的坑：G2D/display ABI 与 OpenWrt build_dir 缓存

来源：`docs/debug-notes-g2d-abi-and-toplevel-build.md`。

线索：修改 package 源码后，OpenWrt `build_dir/target-*` 可能保留旧构建内容，导致现象和源码不一致。建议在相关包修改后记录清理命令和实际影响。

### 待确认的坑：DTS/U-Boot/kernel 改动不能只推应用验证

来源：构建结构和现有调试资料。

线索：设备树、pinmux、显示驱动、U-Boot 配置变更通常需要重建并重新打完整镜像；仅 `adb push /usr/bin/lv_projector` 只能验证应用层修改。

### 待确认的坑：pinmux 复用冲突

来源：`sys_config.fex`。

重点冲突：PC2-PC7 同时关联 SPI0/SPI NOR 与 SDC2；PB8/PB10/PB11/PB12 关联 UART0/TWI0/SPI1/LCD GPIO/USB VBUS/DMIC 等；PF0-PF5 关联 SDC0，同时与部分音频/调试功能有复用可能。
