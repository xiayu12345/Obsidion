---
project: p1_nor_4k
kind: log
date: 2026-07-24
---

# patches — p1_nor_4k HDMI 1080p fb0 对齐

| 文件 | 内容 |
|------|------|
| `01-fb0-1920x1080.patch` | `board.dts` / `uboot-board.dts`：`fb0` 1280×800 → **1920×1080** |

在已具备 1080p（`mode=10`）的 `p1_nor_4k` 树上：

```bash
cd <SDK根>
patch -p1 < H133-AI-Skills/开发记录/板件开发记录/p1_nor_4k/20260724-p1_nor_4k-HDMI1080p-fb0对齐/patches/01-fb0-1920x1080.patch
./tools/build_p1_nor_4k.sh kernel
# 再 pack 出镜像
```

说明见 [../开发记录.md](../开发记录.md)。
