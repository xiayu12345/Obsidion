# WiFi / 网络驱动开发

## 资料来源

| 文档 | 说明 |
|---|---|
| `H133-WiFi驱动开发.md` | WiFi bring-up 资料 |

## 当前线索

| 项目 | 状态 |
|---|---|
| WiFi manager | OpenWrt target 中可见相关包线索 |
| WiFi clock | PG11，`clk_fanout1` |
| 模组型号 | `[待确认]` |
| BT 是否启用 | `[待确认]` |

## 常用排查

```bash
adb shell ifconfig -a
adb shell logread | grep -i wifi
adb shell dmesg | grep -Ei 'wifi|wlan|sdio|mmc'
```

## 开发记录

### 待记录

- 模组型号：`[待填写]`
- 驱动路径：`[待填写]`
- 固件路径：`[待填写]`
- 联网验证：`[待填写]`
