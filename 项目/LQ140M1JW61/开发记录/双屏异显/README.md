---
project: LQ140M1JW61
kind: log
---

# 双屏异显（架构级）

MIPI（screen0）+ HDMI（screen1）的**同显 / 异显**能力，跨板型共用；板级只做验证与 DTS/旋转参数差异。

| 文档 | 说明 |
|---|---|
| [LV_DS-双屏异显中间件架构.md](./LV_DS-双屏异显中间件架构.md) | 中间件架构设计稿（待完整落地） |
| [20260806-同异显切换/](./20260806-同异显切换/) | **定稿**：WB 常开 + `SET_HDMI_OUT`；`disp_mode` |
| [20260805-HDMI异显最小验证/](./20260805-HDMI异显最小验证/) | 历史 TEMP 通路/fence 验证（**勿作产品默认**） |

## 产品一句话

同显：WB 镜像 UI+视频到 HDMI。  
异显：关掉 HDMI 上的 WB 层，视频直贴 DE1；LCD 只留 UI。

```bash
# 干净树（架构补丁，非某板专属）
bash H133-AI-Skills/开发记录/双屏异显/20260806-同异显切换/patches/apply-disp-mode.sh
# 再按目标板型编镜像，例如：
./tools/build_p1_nor_JL_M101.sh full
```

板端：`disp_mode same|diff|get`
