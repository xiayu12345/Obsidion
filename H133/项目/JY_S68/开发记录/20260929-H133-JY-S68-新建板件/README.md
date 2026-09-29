# H133 金运 S68 — 新建板件

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-29 |
| 工程 | `/root/Work/AI-tq` |
| 来源 | 整板复制 `p1_nor_JL_M101` |
| 板型 | NOR `p1_nor_JY_S68` / lunch `h133-p1_nor_JY_S68-tina` |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |

这一步只建板。触摸在同级目录。引脚和开屏还没改。

## 补丁

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/JY_S68/20260929-H133-JY-S68-新建板件/patches/apply.sh
```

下一份：[触摸](../20260929-H133-JY-S68-触摸/)。

## 编译

触摸补丁打完之后：

```bash
./tools/build_p1_nor_JY_S68.sh full
```
