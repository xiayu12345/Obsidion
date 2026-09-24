# 补丁说明 — 引脚定义

只改 `p1_nor_ZS101` 内核 `board.dts` 里和 ZX30 冲突的脚。屏时序、触摸节点不在这里。

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/ZS101/20260924-H133-ZS101-引脚定义/patches/apply.sh
```

当前树已经合入。看到 `ZX30：USB VBUS` 会直接跳过。

下一份：[屏幕](../../20260924-H133-ZS101-屏幕/patches/)。
