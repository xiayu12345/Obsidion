# 取消 WB 同显，只留两种贴屏（⑤）

| 项 | 内容 |
|---|---|
| 代次 | **⑤ 当前**（替代 ④ 的三模式） |
| 日期 | 2026-09-20 |
| 范围 | **架构级**（内核 + libuapi；应用一行不改） |
| 验证板 | `p1_nor_JL_M101` |
| 镜像 | `out/h133_linux_p1_nor_JL_M101_uart0_nor.img` md5 `c5e57cba812e4595c714b67e4c6bbf6d` |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |
| 上一版 | [④ 20260918-异显仅HDMI第三模式](../20260918-异显仅HDMI第三模式/) |
| 用法 | [../使用与构建.md](../使用与构建.md) |

## 一句话

产品不再要 WB 同显。WB 管道**没有任何自动启动路径**了，两种模式只决定视频层贴哪块屏。
`SAME` / `DIFF` 的方法名、枚举值、设置页下拉都不动，但**含义搬了家**。

## 含义搬家（升级必读）

| 模式 | 设置页 | ④ 的 mask | **⑤ 的 mask** | ⑤ 的行为 |
|---|---|---|---|---|
| `SAME` | 同屏 | 1（视频 LCD，HDMI 是 WB 镜像） | **3** | 视频同时贴 LCD+HDMI |
| `DIFF` | 异屏 | 3（LCD+HDMI） | **2** | 视频只贴 HDMI，LCD 仅 UI |
| `DIFF_HDMI` | 未接 | 2 | **删除** | 语义并入 `DIFF` |

`/etc/disp_mirror_mode` 里存着 ④ 的 `2`（老 DIFF_HDMI）会自动迁成 `DIFF`，不用手工清。
未插 HDMI 仍强制 mask=`1`（视频回 LCD）。播中切仍 `-EBUSY`，切完要再起播。

## WB 现在是什么

保留为**独立功能**，但开机、HPD 插拔、模式切换三条路径都不碰它。只能手动拉：

```bash
# 仅排障，产品路径用不到
ioctl DISP_DUAL_DISPLAY_ENABLE (0x407)   # 拉起 WB，起来就是镜像到 HDMI
ioctl DISP_DUAL_DISPLAY_DISABLE (0x408)  # 拆掉
ioctl DISP_DUAL_DISPLAY_GET_EN (0x409)   # 查当前是否起着
```

这三个口用户态已无调用方，是**刻意整组留着**的（只删其一会让这组不成对）。

② 引入的「靠显隐 HDMI 上 WB 层来切同/异显」那一层已整个拆除，`SET_HDMI_OUT` / `GET_HDMI_OUT`
两个 ioctl 和 `sunxi_dual_display_*` 三个用户态接口都没了。

## 干净树落地（前提：树已是 ④）

```bash
bash AI-skiil/专题开发记录/双屏异显/20260920-取消WB同显-两模式/patches/apply-drop-wb-same.sh
./build.sh && ./build.sh pack        # 动了内核，要整编
```

板端（须已插 HDMI、先停播）：

```bash
disp_mode get     # mode=same hdmi=1 video_screen=3   ← 输出不再有 wb= / hdmi_out=
disp_mode diff    # 异屏：视频只上电视
disp_mode same    # 同屏：LCD+HDMI 都有
```

## ④ 遗留的两个问题：⑤ 上实测都没有了

不是单独去修的，是被本代的解耦顺带解决的。机制见 [开发记录 §6](./开发记录.md)：

- **异屏未插 HDMI 会回落 LCD。** ② 里 WB 被自动拉起会把 screen1 撑着，
  `DISP_GET_OUTPUT_TYPE` 就跟真实插拔脱钩；⑤ 拆掉这层耦合后 screen1 使能重新跟着
  HPD 走，查询自然准了。**不需要**再加 `DISP_HDMI_HPD_GET`。
- **同屏 HDMI 不倒。** `dualDispPreparePerScreen()` 给两块屏喂的是两份参数：
  `per_screen_*[0]`（LCD）是 CPU 旋转后的，`[1]`（HDMI）是原始横屏图，结构上不会倒。
