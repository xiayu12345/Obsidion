# 音乐骑士 LQ140 / JD9366TS 原厂触摸

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-24（原厂合入 → XY 对调 → Y 镜像 → **删自写调试驱动**） |
| 板型 | **`p1_nor_LQ140M1JW61`** |
| 屏 | CSOT 13.36" BPD361BT1-1，1200×1920，LCD=`lq140_jd9366tp` |
| 触摸 | **Jadard JD9366TS**，仅原厂 **`jdchipset`**（QZ_IIC_01.DE） |
| 总线 | TWI1 PG8/PG9，I2C **0x68**，RST=PG2，INT=PG3 |
| 量程上报 | DTS `<0 1920 0 1200>` → 驱动交换 XY；再 Y 镜像 → getevent 约 **1920×1200**，左上原点 |
| 状态 | 四角顺序已验；自写 `jd9366ts.c` / `TOUCHSCREEN_JD9366TS` **已从树删除** |
| 定稿镜像 | `out/h133_linux_p1_nor_LQ140M1JW61_uart0_nor.img`，MD5 `bf248144000094f48bc7fff27b727630` |
| 资料 | `AI-skiil/硬件资料/音乐骑士/屏幕4/` |

---

## 一句话

本板触摸只走原厂 **`jdchipset`**。横屏 UI（`disp_rotate=3`）对调 `panel-coords` 交换 XY，并在交换分支做 **Y 镜像**；勿再合入自写 `jd9366ts`。

---

## 阅读顺序

| 步骤 | 文档 |
|------|------|
| 0 | [00-总览.md](./00-总览.md) |
| 1 | [01-硬件与原厂驱动.md](./01-硬件与原厂驱动.md) |
| 2 | [02-DTS与配置.md](./02-DTS与配置.md) |
| 3 | [03-改动与踩坑.md](./03-改动与踩坑.md) |
| 4 | [04-编译与验收.md](./04-编译与验收.md) |
| — | [如何修改.md](./如何修改.md) |
| — | [测试方法.md](./测试方法.md) |
| — | [patches/](./patches/) |

---

## 补丁

```bash
bash AI-skiil/板件开发记录/LQ140M1JW61/20260924-H133-LQ140-JD9366TS原厂触摸/patches/apply.sh
source build/envsetup.sh
lunch 10   # h133-p1_nor_LQ140M1JW61-tina
m kernel -j4   # 若 openwrt 假失败但已「compile Kernel successful」→ 直接 p
p
```

当前出图树若已合入，`apply.sh` 会跳过已存在项，并顺带清掉遗留 `jd9366ts.c`。
