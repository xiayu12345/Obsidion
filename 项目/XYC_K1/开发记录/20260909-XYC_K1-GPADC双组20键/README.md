# 鑫宇宸 XYC_K1 GPADC 双组 20 键

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-09 |
| 板型 | **`p1_nor_XYC_K1`** |
| 基线 | 已出图树（[20260908 LVDS 定稿](../20260908-XYC_K1-板件克隆与LVDS点亮定稿/README.md)） |
| 硬件 | 20 键全进 GPADC0；**PG18** 作组选 GPIO |
| 状态 | 内核按一次报一次；音效键尚未 `dsp_ipc_send`；LVGL 仍跳过 `sunxi-gpadc` |
| 镜像 | `out/h133_linux_p1_nor_XYC_K1_uart0_nor.img` |
| 参考 MD5 | `2464ef33f137ad6e46773cccbb420dbf`（2026-09-09 11:09；后续重编会变） |

---

## 一句话

20 键共用一根 ADC。驱动空闲时翻转 PG18 切两组；按下停扫。GPIO 高=前十音效（F1–F10），GPIO 低=后十界面键。京龙 5 键电压表不能用。

---

## 阅读顺序

| 步骤 | 文档 | 内容 |
|---|---|---|
| 0 | [00-总览.md](./00-总览.md) | 结论、键表、未做 |
| 1 | [01-硬件与组选.md](./01-硬件与组选.md) | J9536、PG18、厂商 LRADC 参考为何不能直接用 |
| 2 | [02-驱动与DTS.md](./02-驱动与DTS.md) | `sunxi_gpadc` mux、`&gpadc`、脚占用 |
| 3 | [03-改动过程与踩坑.md](./03-改动过程与踩坑.md) | 排查时间线、config-5.4 无效、重复 down |
| 4 | [04-编译与验收.md](./04-编译与验收.md) | 只编 kernel + pack；验收 |
| — | [如何修改.md](./如何修改.md) | 改电压 / 键码 / 极性 |
| — | [测试方法.md](./测试方法.md) | 读 ADC、dmesg、hexdump |

---

## 补丁（相对已出图树）

路径：[patches/](./patches/)

| 文件 | 内容 |
|---|---|
| `01-kernel-gpadc-mux.patch` | `sunxi_gpadc.c` / `.h`：DTS 有 `gpio_pin` 才启用组选 |
| `02-board-gpadc-keys.patch` | 本板 DTS：让出 PG18、10 档电压、`GPIO_SYSFS`（不含 I2S/PWM 等其它 WIP） |
| `03-docs.patch` | 本专题文档 + 索引 |
| `xyc-k1-gpadc-20key.patch` | 以上合并 |
| `apply-xyc-k1-gpadc-20key.sh` | 应用 |
| `gen-xyc-k1-gpadc-20key-patch.sh` | 从当前树重生成 |

```bash
# 须已有 XYC_K1 出图树
bash H133-AI-Skills/开发记录/板件开发记录/XYC_K1/20260909-XYC_K1-GPADC双组20键/patches/apply-xyc-k1-gpadc-20key.sh
export PATH="$PWD/prebuilt/hostbuilt/make4.1/bin:$PATH"
./tools/build_p1_nor_XYC_K1.sh kernel
source build/envsetup.sh && p
```

未改 U-Boot。当前已含本功能的树不必再打。
