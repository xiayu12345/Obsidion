# USB音频

内核 `SND_USB_AUDIO` + usbc0 Host，给 2.4G 空鼠麦（HID F24 + USB Audio）录音。  
首验在 `p1_emmc_JL_M101`，补丁改的是通用 `bsp_defconfig` / usbc0，其它板同样适用。

| 目录 | 说明 |
|------|------|
| [20260916-JL-eMMC-USB-Audio/](./20260916-JL-eMMC-USB-Audio/) | 开 USB Audio、usbc0 默认 Host；天猫 F24 麦录音流程 |
