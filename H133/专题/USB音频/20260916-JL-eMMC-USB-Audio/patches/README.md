# patches

两份补丁，**所有板件同样打**（路径按当前板的 `device/.../configs/<board>/` 套用）：

| 文件 | 说明 |
|---|---|
| `0001-jl-emmc-enable-snd-usb-audio.patch` | 开 `SND_USB`/`SND_USB_AUDIO`（`bsp_defconfig` + `config-5.4`） |
| `0002-jl-emmc-usbc0-default-host.patch` | `usbc0` `usb_port_type` 0→1，开机默认 Host |

工作区已直接改好。从干净树重放（补丁内路径是首验板，其它板改对应目录同一处）：

```sh
cd /root/Work/AI-tq
./AI-skiil/专题开发记录/USB音频/20260916-JL-eMMC-USB-Audio/patches/apply.sh
rm -f out/h133/kernel/build/.config
./tools/build_<当前板件>.sh kernel
```
