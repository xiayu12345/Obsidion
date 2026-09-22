# H133 京龙 eMMC 饱和度 / 对比度（应用 PQ）

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-18 |
| 工程 | `/root/Work/AI-tq`（lunch：`h133-p1_emmc_JL_M101-tina`；HXR 屏请用 `p1_emmc_JL_HXR101`） |
| 板型 | 记录时写在 `p1_emmc_JL_M101` 的 overlay；HXR 独立板件已从这份 `setting.ini` 拷走 |
| 取值 | 饱和度 **90**（`color`），对比度 **55** |
| 做法 | `desk_huiyin` 启动调全志 sysfs；固化在 `setting.ini` |
| 补丁 | **无** |
| 正文 | [开发记录.md](./开发记录.md) |

## 一句话

不改内核、不开机脚本。`desk` 已有 PQ 接口，本板 `/etc/setting.ini` 已是实机调定的 90 / 55。重启后若变 50，查 `/mnt/UDISK/setting.ini` 是不是旧文件。

## 板上命令

```bash
cat /sys/class/disp/disp/attr/enhance_saturation
cat /sys/class/disp/disp/attr/enhance_contrast
echo 90 > /sys/class/disp/disp/attr/enhance_saturation
echo 55 > /sys/class/disp/disp/attr/enhance_contrast
grep -E 'contrast|color' /mnt/UDISK/setting.ini /etc/setting.ini
```
