# LQ140 JD9366TS 原厂触摸 — 补丁

在 **SDK 根目录**执行。

| 步骤 | 内容 |
|---|---|
| 安装 `jdchipset` | 解压 `屏幕4/JD9366TP_JD9366TS_QZ_IIC_01.DE.zip` + `files/Makefile.jdchipset` + debug fortify |
| 清自写调试驱动 | 删 `jd9366ts.c`；去掉 Kconfig/Makefile/bsp 中的 `TOUCHSCREEN_JD9366TS` |
| `01-kernel-touchscreen-build.patch` | 挂接 `TOUCHSCREEN_JADARD_*`（无 JD9366TS 选项） |
| `02-board-dts-bsp.patch` | `ctp@68`→`jadard@68`，`panel-coords=<0 1920 0 1200>`，bsp 开 JADARD、关 GT9xx |
| `03-jdchipset-ic-id.patch` | 兼收 IC ID `0x9032` |
| `04-jdchipset-y-mirror.patch` | 交换 XY 后再做 Y 镜像（左上原点） |

```bash
bash apply.sh
bash apply.sh --check
source build/envsetup.sh
lunch 10
m kernel -j4 && p
```

说明：`02` 的「改前」侧仍写旧自写节点/`TOUCHSCREEN_JD9366TS=y`，便于从早期树迁移；定稿「改后」侧已无该配置项。
