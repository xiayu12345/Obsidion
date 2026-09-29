# patches

## 内核 / Host（各板相同）

| 文件 | 说明 |
|---|---|
| `0001-jl-emmc-enable-snd-usb-audio.patch` | 开 `SND_USB`/`SND_USB_AUDIO` |
| `0002-jl-emmc-usbc0-default-host.patch` | `usbc0` 默认 Host |

## 产品接入：F24 PTT + USB 麦（`p1_nor_JL_M101`）

| 文件 | 说明 |
|---|---|
| `0003-aas-capture-prefer-CaptureUSB.patch` | `aas_capture.c`：有 USB 则 `CaptureUSB`，跳过 MCU |
| `0004-aas-f24-ptt-standalone.patch` | 新增独立进程 `ptt/aas_f24_ptt.c` + Makefile |
| `0005-ai-audio-session-package-ptt.patch` | 包装编/装 ptt，`S84`；安装 `libaas_client.so.1` 符号链接（过 ipk 依赖检查） |
| `0006-nor-JL-M101-asound-CaptureUSB.patch` | **仅** NOR JL_M101 `asound.conf` 增加 `pcm.CaptureUSB` |

### 源码落盘位置（与补丁一致）

| 路径 | 来源 |
|---|---|
| `platform/.../lib/ai_audio_session/src/aas_capture.c` | 0003 |
| `platform/.../lib/ai_audio_session/ptt/*` | 0004 |
| `openwrt/package/.../ai_audio_session/Makefile` + `files/aas_f24_ptt.init` | 0005 |
| `openwrt/target/h133/h133-p1_nor_JL_M101/.../etc/asound.conf` | 0006 |

### 覆盖范围（回退用）

产品相关**仅**下面 4 个路径，无 desk/键盘钩子残留：

| 路径 | 补丁 |
|---|---|
| `.../ai_audio_session/src/aas_capture.c` | 0003 |
| `.../ai_audio_session/ptt/*`（整目录新增） | 0004 |
| `openwrt/package/.../ai_audio_session/Makefile` + `files/aas_f24_ptt.init` | 0005 |
| `.../h133-p1_nor_JL_M101/.../asound.conf` | 0006 |

2026-09-29 已对 0003～0006 做 **反向→正向 round-trip**，与工作区一致。

### 已知：开机自启未过（非补丁缺口）

S83/S84 已随 0005 打进镜像，但 busybox-init 板上电后进程常不在；手动 start 后 F24 采音正常。  
记录见上级 [`开发记录.md` §7.5](../开发记录.md)、[`接入方案-F24与USB麦.md` §7.1](../接入方案-F24与USB麦.md)。后续再改 init，暂不扩补丁。

### 施加 / 回退

```sh
cd /root/Work/AI-tq

# 施加（干净树；已改过的文件可能 skip）
./AI-skiil/专题开发记录/USB音频/20260916-JL-eMMC-USB-Audio/patches/apply.sh

# 只回退产品（F24 + CaptureUSB），保留内核 USB Audio / Host
./AI-skiil/专题开发记录/USB音频/20260916-JL-eMMC-USB-Audio/patches/revert.sh

# 若连内核能力也要撤：
#   patch -p1 -R < .../patches/0002-jl-emmc-usbc0-default-host.patch
#   patch -p1 -R < .../patches/0001-jl-emmc-enable-snd-usb-audio.patch
#   rm -f out/h133/kernel/build/.config && ./tools/build_<板件>.sh kernel
```

产品回退后需重编 `ai_audio_session` 并打包 NOR rootfs（清旧 ipk/build_dir 再 `m`/`p`）。