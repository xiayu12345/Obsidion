# 补丁说明

相对已经有 `p1_nor_JL_M101`、且 `build/pack` 只给 NOR 京龙覆盖竖屏 logo 的树。

板级目录 `device/config/chips/h133/configs/p1_emmc_JL_M101/` 和 `openwrt/target/h133/h133-p1_emmc_JL_M101/` **不是补丁**，需要整树复制后再改存储（见上级 [开发记录.md](../开发记录.md)）。

在 SDK 根目录：

```bash
bash AI-skiil/板件开发记录/JL_M101/20260915-H133-JL-M101-eMMC/patches/apply.sh
```

或：

```bash
cd /root/Work/AI-tq
patch -p1 --forward < AI-skiil/板件开发记录/JL_M101/20260915-H133-JL-M101-eMMC/patches/01-pack-bootlogo-jl-emmc.patch
```

当前 AI-tq 工作区已经合入，再 apply 会提示 already applied。

| 文件 | 作用 |
|---|---|
| [01-pack-bootlogo-jl-emmc.patch](./01-pack-bootlogo-jl-emmc.patch) | OpenWrt pack 时 `p1_emmc_JL_M101` 也用板级 100×432 `bootlogo.bmp`，不要留 common 312×76 横图 |

**不改：** `jl_m101_jd9365da.c`、GSL、K1 板件、wolfssl/e2fsprogs 公共包。

打完后只需 pack：

```bash
source build/envsetup.sh
# 确认 LICHEE_BOARD=p1_emmc_JL_M101
p
# pack_out/boot-resource/bootlogo.bmp 应为 100×432
```
