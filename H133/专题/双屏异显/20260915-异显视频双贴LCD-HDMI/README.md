# 异显播片：LCD + HDMI 都有视频（③ 迭代）

| 项 | 内容 |
|---|---|
| 代次 | **③ 当前产品**（在 ② 上只改选屏） |
| 日期 | 2026-09-15 |
| 范围 | **架构级**（只动 libuapi 选屏） |
| 验证板 | `p1_emmc_JL_M101` |
| 异显画面 | **LCD 有视频，HDMI 也有视频** |
| 做法 | ② 的 WB / `SET_HDMI_OUT` 不动；mask **2→3** |
| 正文 | [开发记录.md](./开发记录.md) |
| 怎么改 | [如何修改.md](./如何修改.md) |
| 补丁 | [patches/](./patches/) |
| 上一版 | [② 20260806-同异显切换](../20260806-同异显切换/)（HDMI 有、LCD 没有） |
| 用法 | [../使用与构建.md](../使用与构建.md) |

## 一句话

② 已经能切同/异显，但异显把视频从 LCD 拿走了。③ 走全志 `disp_screen=3`，播片时两路都贴。HDMI 窗口仍跟 LCD 点歌窗等比，不是电视全屏。

## 干净树落地（还停在 ②）

```bash
bash AI-skiil/专题开发记录/双屏异显/20260915-异显视频双贴LCD-HDMI/patches/apply-diff-video-both.sh
# 只重编 libuapi 再 pack，例：
rm -rf out/h133/p1_emmc_JL_M101/openwrt/build_dir/target/libuapi
./build.sh openwrt_rootfs
./build.sh pack
```

板端（须已插 HDMI）：

```bash
# 停播后再切
disp_mode diff
disp_mode get    # ③：video_screen=3（② 是 2）
# 再点播：LCD 视频窗 + HDMI 等比窗口都有画面
```
