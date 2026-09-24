# 补丁说明 — 屏幕

把 ZS 板的 `lcd0` 换成 `zs101_ili9881c`，桌面 `disp_rotate = 3`，视频层 90°。

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/ZS101/20260924-H133-ZS101-屏幕/patches/apply.sh
```

| 文件 | 作用 |
|---|---|
| `apply.sh` | 内核 / U-Boot `lcd0`、屏 Kconfig、`disp_rotate` |
| [01-libtmedia-rotate.patch](./01-libtmedia-rotate.patch) | ZS 视频层 `VIDEO_WB_MIRROR_ROTATE=90` |

屏驱 `zs101_ili9881c.c` 不在本补丁里。下一份：[触摸](../../20260924-H133-ZS101-触摸/patches/)。
