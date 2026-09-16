---
project: H133
kind: peripheral
date: 2026-09-07
---

# 天猫 2.4G 空鼠（7045:2018）

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-07 |
| 验证板 | 京龙 `p1_nor_JL_M101`（gslX680） |
| 设备 | `Tmall.c0m 2.4G Wireless Air Mouse`，VID:PID **7045:2018** |
| 状态 | 实机已枚举；**补丁已写、源码已撤回，未合入、未刷机验采音** |
| 开发 | [开发记录.md](./开发记录.md) |
| 测试 | [测试方法.md](./测试方法.md) |
| 合入 | [如何修改.md](./如何修改.md) |
| 补丁 | [patches/usb-voice-tmall-7045-2018.patch](./patches/usb-voice-tmall-7045-2018.patch) |

## 一句话

语音键是键盘 **`KEY_F24`**（`event4` / `usb-kbd`）；麦是 USB Audio **iface 0/1**，当时内核没开 `SND_USB`，`arecord -l` 看不见。音量/Home 在 `event5`（Consumer Control），这次故意没接。
