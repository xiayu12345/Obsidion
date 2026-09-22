# 同显 / 异显切换（② 第一版）

| 项 | 内容 |
|---|---|
| 代次 | **② 第一版产品路径**（切换框架沿用至今） |
| 日期 | 2026-08-06 |
| 范围 | **架构级**（MIPI+HDMI 双屏板共用） |
| 验证板 | `p1_nor_JL_M101`（首验） |
| 异显画面 | **HDMI 有视频，LCD 没有**（LCD 只留 UI） |
| 做法 | WB 常开；`disp_mode` 只切 HDMI 上 WB 层；mask=**2** |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |
| 上一版 | [① 20260805-HDMI异显最小验证](../20260805-HDMI异显最小验证/)（TEMP，勿用） |
| 下一版 | [③ 20260915-异显视频双贴LCD-HDMI](../20260915-异显视频双贴LCD-HDMI/)（LCD 也要有视频） |
| 旁路 | [20260828-libuapi内核头对齐](../20260828-libuapi内核头对齐/) |

## 一句话

相对 ①：不再编译期拆 WB，改成管道常开、只显隐 HDMI 上的 WB 层。异显视频仍然**只贴 HDMI**。

要 LCD 也有视频，看 ③，不要在本目录把 mask 改回又改掉。

## 干净树落地（② 框架）

```bash
bash AI-skiil/专题开发记录/双屏异显/20260806-同异显切换/patches/apply-disp-mode.sh
```

板端：

```bash
disp_mode same
disp_mode diff
disp_mode get    # 第一版异显：video_screen=2
```
