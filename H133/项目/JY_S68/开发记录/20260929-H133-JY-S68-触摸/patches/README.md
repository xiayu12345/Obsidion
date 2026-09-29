# 补丁说明 — 触摸

把金运板的触摸从京龙脚位改到 S68 原理图。先打新建板件。

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/JY_S68/20260929-H133-JY-S68-触摸/patches/apply.sh
```

| 文件 | 作用 |
|---|---|
| `apply.sh` | 改 `board.dts` 的 TWI2 / 中断 / 复位，换固件名 |
| [files/gsl3670_jys68.bin](./files/gsl3670_jys68.bin) | 由 `QD101T41A01-K.h` 打出来的固件 |
| [files/GSL3670_JY_S68.h](./files/GSL3670_JY_S68.h) | 装进 `gslx680new/` 的配置头 |

当前树已经合入。再跑会跳过已改过的节点。
