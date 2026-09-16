# 通路 B：TSoundDeviceCreate 读 mode 对齐路由

| 项 | 内容 |
|---|---|
| 日期 | 2026-08-24 |
| 范围 | **libaudioroute / tplayer**（通路 B）；跨板型，非京龙专属 |
| 状态 | **已合入本树**（4K 已推 `libtplayer.so`） |
| 改动 | 只动 `platform/allwinner/multimedia/libtmedia/tplayer/awsink/tsound_ctrl.c` |
| 补丁 | [05-platform-tsound_ctrl-route-mode.patch](./20260822-libaudioroute-HDMI透传落地/patches/05-platform-tsound_ctrl-route-mode.patch) |
| 关联 | [音频路由架构.md](./音频路由架构.md)、[设置切换待修](./20260822-设置切换后播放器路由不同步.md) |

---

## 1. 现象

4K 切通路 B（`LIBAUDIOROUTE` + xml `OUT_HDMI_ARC`→sndi2s2）后，mode 已是 `hdmi`，播歌 **HDMI 无声**。

`TSoundDeviceCreate` 用 `OUT_DEFAULT` → 本进程 `current_device_type` 默认 `OUT_SPK` → 开 **sndowa**，电视没声。

---

## 2. 根因

desk 与 `media_sessiond` **各一份** `AudioManager`。desk 里 `adev_set` 到 32，播放器进程看不到。

官方透传覆盖只带了 `sunxi_passthough` / `direct_mode`，**没有**读 `/etc/audio_output.mode`。

**未打** `03-platform-tsound_ctrl.c.patch`（相对 H133-0820 的整文件大补丁，路径也对不上）。只合 05 这三处。

---

## 3. 改动

文件：`tsound_ctrl.c`（`#ifdef TPLAYER_AUDIO_API_LIBAUDIOROUTE`）

1. `routeModeFileToSndDevice()` / `syncAdevOutputRoute()`  
   读 `/etc/audio_output.mode`：`hdmi` → `OUT_HDMI_ARC` (32)，其它 → `OUT_SPK` (2)
2. `TSoundDeviceCreate`：**先** `syncAdevOutputRoute`，**再**注册 `handleAudioDeviceChange`，按 mode 建 port，**不用** `OUT_DEFAULT`
3. `openSoundDevice`：**禁止**再 sync。`adev_set_output_device` 会回调 `handleAudioDeviceChange` 抢 `sc->mutex`，与 `TSoundDeviceStart` 死锁 → 有 close 无 `pcm_open`

基线：官方透传覆盖后的 `tsound_ctrl.c`。打补丁：

```bash
patch -p1 < docs/开发记录/20260822-libaudioroute-HDMI透传落地/patches/05-platform-tsound_ctrl-route-mode.patch
```

本树已合入，再 apply 会提示 already applied。

---

## 4. 验收

冷启动 / 杀起 `media_sessiond` 后再播：

| 检查 | 预期 |
|------|------|
| `/etc/audio_output.mode` | `hdmi` |
| log | `snd_type = 32`、`card = 0`（sndi2s2）、`pcm_open` |
| PCM | HDMI 有声 |
| AC3 | `direct_mode` + 电视识别杜比 |

**不含**：运行中切 HDMI↔SPDIF 不重启仍跟切（须 `REOPEN_SOUND`，见设置切换待修）。
