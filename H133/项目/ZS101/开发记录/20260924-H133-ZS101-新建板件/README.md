# H133 纽曼 ZS101 — 新建板件

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-24 |
| 工程 | `/root/Work/AI-tq` |
| 来源 | 整板复制 `p1_nor_JL_M101` |
| 板型 | NOR `p1_nor_ZS101` / lunch `h133-p1_nor_ZS101-tina` |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |

这一步只建板。引脚、屏幕、触摸在同级另外三个目录。

## 补丁

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/ZS101/20260924-H133-ZS101-新建板件/patches/apply.sh
```

后面按顺序打：引脚定义 → 屏幕 → 触摸。

## 编译

四步都打完之后：

```bash
./tools/build_p1_nor_ZS101.sh full
```
