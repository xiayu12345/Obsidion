# 异显第三模式：仅 HDMI 视频（④）

| 项 | 内容 |
|---|---|
| 代次 | **④ 当前**（在 ③ 上扩充，不改 SAME/DIFF） |
| 日期 | 2026-09-18 |
| 范围 | **架构级**（只动 libuapi；设置页不接） |
| 验证板 | `p1_emmc_JL_M101` |
| 新增 | `SUNXI_DISP_MODE_DIFF_HDMI`：视频只上 HDMI，LCD 仅 UI |
| 设置页 | 「异屏」仍是 **③ DIFF**（LCD+HDMI 都有视频） |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |
| 上一版 | [③ 20260915-异显视频双贴LCD-HDMI](../20260915-异显视频双贴LCD-HDMI/) |
| 用法 | [../使用与构建.md](../使用与构建.md) |

## 一句话

③ 的 `diff` 仍是两路都有视频。④ 只**加** `diff_hdmi`（mask=2），`same` / `diff` 接口名和语义不动。设置页不改。

## 干净树落地（已是 ③）

```bash
bash AI-skiil/专题开发记录/双屏异显/20260918-异显仅HDMI第三模式/patches/apply-diff-hdmi-mode.sh
# 只重编 libuapi 再 pack
rm -rf out/h133/p1_emmc_JL_M101/openwrt/build_dir/target/libuapi
./build.sh openwrt_rootfs
./build.sh pack
```

板端（须已插 HDMI、先停播）：

```bash
disp_mode diff_hdmi
disp_mode get    # mode=diff_hdmi hdmi_out=0 video_screen=2
# 再点播：LCD 点歌窗空，视频只上电视
disp_mode diff   # 回到 ③：两路都有
```
