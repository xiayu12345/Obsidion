# 4K 板（h133-p1_nor_4k）libaudioroute / 杜比移植指南

| 项 | 内容 |
|---|---|
| 日期 | 2026-08-22 |
| 目标板型 | `h133-p1_nor_4k`（TP-H10，1920×1080，`4K_app`） |
| 参照首验 | [JL_M101 透传落地](./20260822-libaudioroute-HDMI透传落地/README.md) |
| 架构参照 | [音频路由架构.md](./音频路由架构.md) |
| 状态 | **待移植**（板级 + App 未改；平台层已与 JL 共用） |

---

## 1. 结论（先看这个）

4K 与 JL_M101 **硬件音频拓扑相同**（喇叭/光纤 = sndowa，HDMI = sndi2s2），`asound.conf` / `audio_route.sh` / `mcu_spdif_init.sh` **已对齐，不用重抄**。

移植只需三块：

1. **板级**：4K `defconfig` 开 `LIBAUDIOROUTE`；`audio_configuration.xml` 把 `OUT_HDMI_ARC` 改到 **sndi2s2**
2. **平台**：AIKTV 主干已含 JL 透传改动（`tsound_ctrl.c`、`AudioPortAlsaConfig.cpp`），**一般不用再 patch**
3. **App**：`4K_app/desk` 设置切路由时接 `ms_changba_reopen_sound_route()`（与 [设置切换待修](./20260822-设置切换后播放器路由不同步.md) 同方案）

**不能**继续用 4K 现网 `CONFIG_TR_AUDIO_API_ALSA_LIB`：ALSALIB 分支无 AC3/EAC3 透传，杜比必走 libaudioroute。

---

## 2. 4K 与 JL_M101 差异对照

| 项 | JL_M101（已验收） | 4K（当前） |
|---|---|---|
| OpenWrt 板目录 | `h133-p1_nor_JL_M101` | `h133-p1_nor_4k` |
| 编译脚本 | `tools/build_p1_nor_JL_M101.sh` | `tools/build_p1_nor_4k.sh` |
| GUI | `app/desk`、`app/sing_ktv` | **`4K_app/desk`、`4K_app/sing_ktv`** |
| 二进制 | `desk` / `sing_ktv` | **`4k-desk` / `4k-sing_ktv`** |
| `CONFIG_TR_AUDIO_API` | `LIBAUDIOROUTE=y` | **`ALSALIB=y`** |
| `OUT_HDMI_ARC`（xml） | sndi2s2 @ 48k/960 | **sndowa**（错误，须改） |
| `asound.conf` | PlaybackHDMI → sndi2s2 | **相同** |
| 启动音频 | mcu_spdif_init → audio_route auto | 相同 + **`4k-dspd`**（MCU 遥控，与路由无关） |
| media_session | 独立进程 + FIFO | **相同** |

---

## 3. 分层：改什么、不改什么

```
┌──────────────────────────────────────────────────────────┐
│ 平台 platform/（全板共用，JL 已合入）                      │
│  libtmedia/.../tsound_ctrl.c                             │
│  libaudioroute/AudioPortAlsaConfig.cpp                   │
│  → 4K 仅通过 defconfig 选 LIBAUDIOROUTE 编译分支          │
└──────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────┐
│ 板级 openwrt/target/h133/h133-p1_nor_4k/  【必改】        │
│  defconfig                                               │
│  busybox-init-base-files/etc/audio_configuration.xml     │
└──────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────┐
│ App 4K_app/desk/setting/core/desk_setting_param.c 【建议】 │
│  P_SOUND_OUT_MODE → REOPEN_SOUND                         │
└──────────────────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────┐
│ 可不动                                                    │
│  asound.conf / audio_route.sh / audio_output.mode        │
│  mcu_spdif_init.sh / rc.final 音频段                      │
│  4K_app/sing_ktv（只链 libms_client，无 tplayer 直连）     │
└──────────────────────────────────────────────────────────┘
```

---

## 4. 板级改动

### 4.1 defconfig

文件：`openwrt/target/h133/h133-p1_nor_4k/defconfig`

```diff
- CONFIG_TR_AUDIO_API_ALSA_LIB=y
- # CONFIG_TR_AUDIO_API_LIBAUDIOROUTE is not set
+ # CONFIG_TR_AUDIO_API_ALSA_LIB is not set
+ CONFIG_TR_AUDIO_API_LIBAUDIOROUTE=y
```

改完后同步 `openwrt/openwrt/.config`（或执行 `build_p1_nor_4k.sh` 时由脚本从板级 defconfig 覆盖）。

`4k-desk`、`media_session` 的 OpenWrt Makefile 已依赖 `+libaudioroute`，**无需改包依赖**。

### 4.2 audio_configuration.xml

文件：`openwrt/target/h133/h133-p1_nor_4k/busybox-init-base-files/etc/audio_configuration.xml`

将 `OUT_HDMI_ARC` 从 sndowa 改为 sndi2s2（与 JL patch `01-board-audio_configuration.xml.patch` 等价）：

```diff
     <snd_card_config
-        card_name="sndowa"
+        card_name="sndi2s2"
         device="0"
         channels="2"
-        rate="44100"
-        period_size="882"
+        rate="48000"
+        period_size="960"
         period_count="4"
         type="OUT_HDMI_ARC">
```

`OUT_SPK`、`OUT_OWA` 保持 **sndowa**；`IN_MIC`（sndi2s1）等采集配置不动。

### 4.3 无需改的板级文件

| 文件 | 说明 |
|------|------|
| `etc/asound.conf` | 已与 JL 一致：`PlaybackSPDIF`→sndowa，`PlaybackHDMI`→sndi2s2 |
| `usr/bin/audio_route.sh` | 写 `/etc/audio_output.mode` + 改 default pcm |
| `usr/bin/mcu_spdif_init.sh` | MCU 功放 SPDIF 初始化 |
| `etc/init.d/rc.final` | `mcu_spdif_init` → `audio_route.sh auto` → `media_sessiond` |

---

## 5. 平台层（确认即可）

JL 已落地的平台改动在 AIKTV 全板共用，4K 编译 `LIBAUDIOROUTE` 后自动生效：

| 文件 | 要点 |
|------|------|
| `tsound_ctrl.c` | `TSoundDeviceCreate` 读 `/etc/audio_output.mode`；透传 `sunxi_passthough` + `direct_mode`；禁止 `openSoundDevice` 内 sync（防死锁） |
| `AudioPortAlsaConfig.cpp` | `direct_mode=1` 时 `snd_pcm_writei` 直写，不经 amix |

若从**未合入 JL 改动的旧分支**移植，可参考 [patches/03、04](./20260822-libaudioroute-HDMI透传落地/patches/)（以 H133-0820 为基线）；**当前主干以源码为准**，勿重复 apply。

---

## 6. App 层：设置切换（建议与板级一并做）

4K 使用 **`4K_app/desk`**，与 HD `app/desk` **禁止互引源码**，须单独改。

文件：`platform/thirdparty/gui/lvgl-8/4K_app/desk/setting/core/desk_setting_param.c`

在 `P_SOUND_OUT_MODE` 分支，`audio_set_output_device` + `desk_setting_apply_audio_route` 之后：

```c
#include "ms_changba.h"

/* audio_route 成功后 */
(void)ms_changba_init();
ms_changba_reopen_sound_route();
```

原因见 [设置切换后播放器路由不同步](./20260822-设置切换后播放器路由不同步.md)：desk 与 `media_sessiond` 各一份 `AudioManager`，必须 FIFO 通知重建播放器。

`4K_app/sing_ktv` 经 `libms_client` 访问播放，**一般不用改**。

---

## 7. 与官方 SDK（H133-0820）的关系

SDK `lv_projector` 为**同进程** tplayer：`audio_set_output_device` → `handleAudioDeviceChange` 即时换 port。

AIKTV（含 4K）为 **desk + media_sessiond 跨进程**，SDK 的 callback 链**不能照搬**；4K 移植后仍须 `REOPEN_SOUND` + mode 文件。详见对话记录与 [音频路由架构.md](./音频路由架构.md) §2、§8。

---

## 8. 编译

```bash
./tools/build_p1_nor_4k.sh rootfs
# 产物：out/h133_linux_p1_nor_4k_*.img（以实际 out 文件名为准）
```

改 `defconfig` 后建议全量编 `libtmedia`、`media_session`、`4k-desk`、`4k-sing_ktv` 相关包（或直接 `rootfs`）。

**禁止**在 WSL/x86 上对 `desk/src` 等本地 `make` 产 `.o`（污染交叉编译）。

---

## 9. 验收清单

### 9.1 杜比 / 冷启动

1. 设置 → **HDMI/ARC**（或确认 `setting.ini` `sound_output=1`）
2. 播放 AC3/EAC3 样品（如 `ac3-5.1.mkv`）
3. log 关键字：`snd_type=32`、`pcm_open` **card:0**（sndi2s2）、`direct_mode`、`sunxi_passthough_open`
4. 电视识别杜比并有声

### 9.2 PCM

同设置下播 AAC/MP3 → HDMI PCM 正常。

### 9.3 运行中切换（接 REOPEN_SOUND 后）

| 步骤 | 预期 |
|------|------|
| HDMI 播 AC3 正常 | 基线 |
| 设置 → SPDIF → 播歌 | `card=2`（sndowa），喇叭有声 |
| 设置 → HDMI → **不重启** → 再播 AC3 | 电视有声；log 有 `REOPEN_SOUND` / `reopen sound route` |
| `aplay test.wav` | 与当前设置同物理口（`audio_route.sh show`） |

### 9.4 投屏 / 蓝牙（回归）

进 `lv_cast_test_pro` / `BluetoothPlayer` 时 desk 会 kill `media_sessiond`；退出后 guardian 应能拉回。行为应与改前一致，仅 KTV 路径走 libaudioroute。

---

## 10. 风险与注意

| 风险 | 说明 |
|------|------|
| 误绑 sndowa 给 HDMI | 透传比特流进 MCU，电视无声；必改 xml |
| 照搬 SDK「全 default」 | JL/4K 喇叭与 HDMI 分卡，不可合并 |
| 只改 defconfig 不接 REOPEN | 冷启动可能正常，**运行中切路由**仍不同步 |
| 改错 desk 树 | 4K 只改 `4K_app/desk`，HD 改 `app/desk` |
| `4k-dspd` | MCU 串口遥控，不参与 HDMI 杜比链路 |
| 平台补丁重复 apply | 以当前 AIKTV 源码为准，冲突则跳过 03/04 |

---

## 11. 移植步骤（推荐顺序）

1. 改 4K `defconfig` + `audio_configuration.xml`
2. `./tools/build_p1_nor_4k.sh rootfs` → 刷机 → **验收 §9.1、§9.2**
3. 改 `4K_app/desk_setting_param.c` 接 `REOPEN_SOUND` → 再编 `4k-desk` → **验收 §9.3**
4. 投屏/蓝牙抽测 **§9.4**
5. 在本文件顶部把状态改为 **已验收**，并记录镜像 md5

---

## 12. 相关文档

| 文档 | 用途 |
|------|------|
| [音频路由架构.md](./音频路由架构.md) | 双通路、双进程、PCM/透传数据流 |
| [20260822-libaudioroute-HDMI透传落地/](./20260822-libaudioroute-HDMI透传落地/README.md) | JL 首验、平台补丁说明 |
| [20260822-设置切换后播放器路由不同步.md](./20260822-设置切换后播放器路由不同步.md) | REOPEN_SOUND 根因与修法 |
