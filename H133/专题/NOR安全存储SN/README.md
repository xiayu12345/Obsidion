---
project: H133
kind: peripheral
---

# NOR 安全存储 SN（snum）

全志 NOR 没有 `private` 分区，出厂 SN 写在 **SST**，key 名 **`snum`**。选一种烧录即可。

| | |
|---|---|
| 开发记录 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |
| sst_test | [sst_test/操作方法.md](./sst_test/操作方法.md) |
| libkey | [libkey/操作方法.md](./libkey/操作方法.md) |

ZS101 实际编 `sun8iw20p1_defconfig`，须 SST=64 + `SUNXI_SERIAL`。**PhoenixSuit 不要选全盘擦除。** 刷完用对应方法读，不要只看 cmdline。
