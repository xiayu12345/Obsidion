# H133 开发记录

> 完整长篇文档在 Ubuntu 工程 `H133开发文档-wjz/`，此处只保留结构化入口。

## 分类入口

- [驱动开发](驱动开发/index.md)
- [应用开发](应用开发/index.md)

## 工程内精简笔记

| 日期 | 主题 | 分类 | 路径 |
|---|---|---|---|
| 2026-05-28 | G2D ABI + 顶层编译 | 驱动开发 / 显示链路 | `docs/debug-notes-g2d-abi-and-toplevel-build.md` |
| 2026-05-29 | SD 卡 DiskManager | 驱动开发 / 存储 | `docs/H133-Tina-SD卡调试经验.md` |

## 如何在 Ubuntu 浏览

```bash
ssh h133-ubuntu
cd ~/Workspace/HDMI_new/HDMI
ls "H133开发文档-wjz/驱动/"
ls "H133开发文档-wjz/应用开发/"
ls docs/
```

## 笔记维护约定

- **驱动 bring-up、DTS/FEX、内核、pinmux、显示/音频/触摸/WiFi/存储问题** → 写入 [驱动开发](驱动开发/index.md)
- **LVGL 业务、应用部署、rootfs、SFTP、应用层播放和 UI 流程** → 写入 [应用开发](应用开发/index.md)
- **确认根因后的问题复盘** → 写入 [踩坑记录](../踩坑记录/index.md)
- **流程变更** → 更新 [编译相关](../常用命令速查/编译相关.md) 或 [环境搭建](../开发环境/环境搭建.md)
- **引脚变更** → 更新 [引脚定义速查](../引脚定义速查/index.md)
