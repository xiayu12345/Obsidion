---
project: H133
kind: peripheral
---

# NOR SST / snum 补丁

在 **H133 SDK 根目录**按顺序合。当前 ZS101 出图树已合入。

| 文件 | 内容 |
|------|------|
| `0001-uboot-nor-sst-sunxi-serial.patch` | `SPINOR_SECURE_STORAGE_SIZE=64`（32KB SST 仓库，不是 SN 长度）+ `SUNXI_SERIAL=y` |
| `0002-uboot-bootargs-snum-null-tmpbuf512.patch` | `snum` 为空不拼 `androidboot.serialno`；`tmpbuf` 128→512 |
| `0003-libkey-sst_test-512.patch` | `sst_test` 读写截断 128/256→512 |
| `0004-zs101-enable-libkey-demo.patch` | ZS101 编 `libkey-demo`（`/usr/bin/sst_test`） |
| `apply-snum-sst.sh` | 四笔一起 `git apply` |

```bash
bash H133-AI-Skills/开发记录/NOR安全存储SN/patches/apply-snum-sst.sh
./tools/build_p1_nor_ZS101.sh full
```

`0004` **不含** G2D / DIRECT_MODE。其它 lunch 若也走 `sun8iw20p1_defconfig`，合 `0001`+`0002` 即可；要命令行写号再在该板 `defconfig` 开 `CONFIG_PACKAGE_libkey-demo=y`。

官方 `sun8iw20p1_nor_defconfig` 本来就有 SST=64 和 SERIAL，ZS101 的 `BoardConfig.mk` 指定的是 `sun8iw20p1_defconfig`，所以必须改这一份。
