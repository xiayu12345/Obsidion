# 饱和对比度

应用侧 PQ：`desk_huiyin` 读 `setting.ini` 的 `color` / `contrast`，写全志 enhance sysfs。  
不改内核。取值跨板共用，首验写在京龙 eMMC overlay，HXR 独立板件已从这份拷走。

| 目录 | 说明 |
|------|------|
| [20260918-H133-JL-eMMC-CSC饱和对比度/](./20260918-H133-JL-eMMC-CSC饱和对比度/) | 饱和 **90**、对比 **55**；重启后被 UDISK 旧 ini 覆盖的坑 |
