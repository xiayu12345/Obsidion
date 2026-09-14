# 鑫宇宸 XYC_K1 BL3676 触摸适配

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-08（与 LVDS 同日；2026-09-10 从显示记录拆出本专题） |
| 板型 | **`p1_nor_XYC_K1`** |
| 基线 | 已有板级树（[20260908 LVDS 定稿](../20260908-XYC_K1-板件克隆与LVDS点亮定稿/README.md)） |
| 触摸 | **BL3676** I2C `0x2C`，`betterlife_ts` |
| 坐标 | `TP_MAX=1280×800`；不交换、不翻转；`tp_rotate=0` |
| 状态 | **实机报点、四角方向已验** |
| 镜像 | 含在 LVDS 出图包 `out/h133_linux_p1_nor_XYC_K1_uart0_nor.img` |

---

## 一句话

鑫宇宸 K1 触摸不是 GSL。TWI1 挂 **BL3676**（`0x2C`，RST=PG2，INT=PG3），量程跟屏一样 1280×800。LVDS 定稿补丁里已经带上；本专题是独立检索入口和 CTP 子集补丁。

---

## 阅读顺序

| 步骤 | 文档 | 内容 |
|------|------|------|
| 0 | [00-总览.md](./00-总览.md) | 结论、对照、与显示补丁的关系 |
| 1 | [01-硬件与驱动.md](./01-硬件与驱动.md) | 原理图、原厂包、`betterlife_ts` |
| 2 | [02-DTS与量程.md](./02-DTS与量程.md) | 节点、`TP_MAX`、`twi_drv_used` |
| 3 | [03-改动过程与踩坑.md](./03-改动过程与踩坑.md) | 烧错镜像、量程裁点、DMA |
| 4 | [04-编译与验收.md](./04-编译与验收.md) | 只编 kernel；验收 |
| — | [如何修改.md](./如何修改.md) | 改地址 / 脚 / 量程 |
| — | [测试方法.md](./测试方法.md) | dmesg、`getevent`、四角 |

---

## 补丁（相对「XYC 板级仍是 JYY070 GSL」的树）

路径：[patches/](./patches/)

| 文件 | 内容 |
|------|------|
| `01-kernel-betterlife-ts.patch` | 内核 `betterlife_ts` + Kconfig/Makefile |
| `02-board-dts-ctp.patch` | 本板 DTS `ctp@40`→`betterlife_ts@2c`；关 GSL 开 BETTERLIFE；`input_symlink` |
| `03-docs.patch` | 本专题文档 + 索引 |
| `xyc-k1-bl3676-tp.patch` | 以上合并 |
| `apply-xyc-k1-bl3676-tp.sh` | 应用（已落地则跳过） |
| `gen-xyc-k1-bl3676-tp-patch.sh` | 从当前树重生成 |

**当前出图树不必再打**：LVDS `xyc-k1-display-final.patch` 已含驱动和 DTS。再 apply 会报已存在，属正常。

```bash
# 仅当板级还是 GSL@40、还没有 betterlife_ts 时
bash H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260908-XYC_K1-BL3676触摸适配/patches/apply-xyc-k1-bl3676-tp.sh
export PATH="$PWD/prebuilt/hostbuilt/make4.1/bin:$PATH"
./tools/build_p1_nor_XYC_K1.sh kernel
source build/envsetup.sh && p
```

未改 U-Boot。
