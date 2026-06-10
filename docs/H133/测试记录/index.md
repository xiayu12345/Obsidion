# H133 测试记录

## 测试记录索引

| 日期 | 测试项 | 版本/镜像 | 结果 | 记录 |
|---|---|---|---|---|
| `[待填写]` | `[待填写]` | `[待填写]` | `[待填写]` | `[待填写]` |

## 测试分类

| 分类 | 说明 |
|---|---|
| 硬件连通性测试 | 串口、ADB、USB、SD 卡、屏幕、触摸、HDMI、音频 |
| 系统启动测试 | U-Boot、Kernel、rootfs、服务启动 |
| 显示测试 | LCD、HDMI、双显、旋转、视频层和 UI 共存 |
| 应用测试 | `lv_projector` 页面、播放、输入、网络、稳定性 |
| 回归测试 | 修复问题后的复测记录 |

## 测试记录模板

```text
日期：
测试人：
硬件版本：
镜像版本：
应用版本：
测试环境：
测试项：
测试步骤：
预期结果：
实际结果：
结论：
遗留问题：
附件/日志：
```

## 常用测试命令

```bash
adb devices
adb shell dmesg | tail -100
adb shell logread -f
adb shell "cat /sys/class/disp/disp/attr/sys"
adb shell df -h
```
