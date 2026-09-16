# 鑫宇宸 XYC_K1 开屏对齐厂 fex · 消除开机白闪

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-11 |
| 板型 | **`p1_nor_XYC_K1`** |
| 基线 | [20260908 LVDS 点亮定稿](../20260908-XYC_K1-板件克隆与LVDS点亮定稿/README.md)（GPIO 背光版） |
| 对照 | 厂 fex 时序 + LCD-EN(PB10) → tcon → PWM0(PB12)。**不是**本仓 `p1_nor_JL_M101`（那是 10.1" MIPI） |
| 状态 | **实机：开机白闪消失；出图正常** |
| 镜像 | `out/h133_linux_p1_nor_XYC_K1_uart0_nor.img` |
| 参考 MD5 | `ede3de815ecffda771952502f2d195bf`（2026-09-11 10:57；后续重编会变） |

---

## 一句话

白闪不是翻页/G2D 补丁，是 U-Boot→内核开屏（09-08 用 GPIO 背光、无 PB10 EN）和厂 fex 开屏流不一致。改成 **LCD-EN(PB10) → tcon → PWM0(PB12)** 后不闪；**不要**在 H133 的 `de_lcd_sun50iw10.c` 里按 DTS 写 `lcd_lvds_io_polarity`（该文件只认 `LVDS_REVERT`，DTS 里写 `0x1f` 也不会生效；硬写会无图）。

---

## 阅读顺序

| 文档 | 内容 |
|---|---|
| [开发记录.md](./开发记录.md) | 结论、根因、改动表、极性坑、编译验收 |
| [patches/](./patches/) | 相对 09-08 定稿的增量补丁 |

---

## 补丁（相对 09-08 出图定稿）

| 文件 | 内容 |
|---|---|
| `01-panel-open-flow.patch` | 内核+U-Boot `xyc_k1_lvds.c` 开屏流 |
| `02-board-dts-open.patch` | `board.dts` / `uboot-board.dts`：厂 fex 时序、PB10 EN、PWM0 |
| `03-docs.patch` | 本专题 + 定稿/档案修订 + 索引 |
| `xyc-k1-open-flow-fix.patch` | 以上合并 |
| `apply-xyc-k1-open-flow-fix.sh` | 应用 |
| `gen-xyc-k1-open-flow-fix-patch.sh` | 从当前树重生成 |

```bash
# 须已有 09-08 XYC_K1 出图树（可再叠加 GPADC/触摸专题）
bash H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260911-XYC_K1-开屏对齐消白闪/patches/apply-xyc-k1-open-flow-fix.sh
export PATH="$PWD/prebuilt/hostbuilt/make4.1/bin:$PATH"
# 改了 U-Boot panel/dts：必须单独 uboot，禁止 kernel bootloader
./build.sh uboot
./tools/build_p1_nor_XYC_K1.sh kernel
source build/envsetup.sh && p
```

当前已含本改动的树不必再打。
