# 补丁说明 — 新建板件

相对已经有 `p1_nor_JL_M101` 的树。这一步只复制板件并改板号。

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/JY_S68/20260929-H133-JY-S68-新建板件/patches/apply.sh
```

当前 AI-tq 已经合入。再跑会保留已有 `p1_nor_JY_S68`，并跳过已经打上的 hunk。

| 文件 | 作用 |
|---|---|
| `apply.sh` | 复制板级目录和 OpenWrt target，改板号，安装编译脚本 |
| [01-pack-readme.patch](./01-pack-readme.patch) | `build/pack` 开机 logo、lunch 表 |
| [02-libtmedia-rotate.patch](./02-libtmedia-rotate.patch) | 视频旋转跟京龙一样，270° |
| [files/build_p1_nor_JY_S68.sh](./files/build_p1_nor_JY_S68.sh) | 安装到 `tools/` |

下一份：[触摸](../../20260929-H133-JY-S68-触摸/patches/)。
