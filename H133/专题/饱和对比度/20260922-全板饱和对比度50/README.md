# 全板饱和度 / 对比度统一 50 / 50

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-22 |
| 范围 | H133 全部 lunch 板件 overlay `setting.ini` |
| 取值 | 饱和度 **50**（`color`），对比度 **50** |
| 做法 | 四个图像模式（standard / dynamic / mild / user）一起改；desk「恢复默认」宏对齐 |
| 补丁 | **无** |
| 正文 | [开发记录.md](./开发记录.md) |

## 一句话

原先多数板是饱和 90、对比 55（LQ140 eMMC 是 60 / 45）。现统一 50 / 50，与内核 CSC 默认和 `desk` 恢复默认一致。

## 板上命令

```bash
cat /sys/class/disp/disp/attr/enhance_saturation
cat /sys/class/disp/disp/attr/enhance_contrast
grep -E 'contrast|color' /mnt/UDISK/setting.ini /etc/setting.ini
```

重启后若仍不是 50，查 `/mnt/UDISK/setting.ini` 是否旧文件盖掉 `/etc`。
