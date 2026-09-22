# patches

| 文件 | 说明 |
|---|---|
| `0001-jl-emmc-enable-snd-usb-audio.patch` | 开 `SND_USB`/`SND_USB_AUDIO`（改 `bsp_defconfig` + `config-5.4`） |
| `0002-jl-emmc-usbc0-default-host.patch` | `usbc0` `usb_port_type` 0→1，开机默认 Host（不必再 `cat .../usb_host`） |

工作区已直接改好。从干净树重放：

```sh
cd /root/Work/AI-tq
./AI-skiil/专题开发记录/USB音频/20260916-JL-eMMC-USB-Audio/patches/apply.sh
rm -f out/h133/kernel/build/.config   # 0001 后强制重新 defconfig
./tools/build_p1_emmc_JL_M101.sh kernel
# 0002 改 dts，需编进内核/打包（kernel 或 full 均可带上 dtb）
# 再 p 打镜像，或 ./tools/build_p1_emmc_JL_M101.sh full
```
