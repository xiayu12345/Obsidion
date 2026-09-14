# 杜比 / libaudioroute 开发记录

与**板型无关**的杜比透传、HDMI 路由、播放器音频链路；板级 `defconfig` / `audio_configuration.xml` 仅在落地补丁里按板型区分。

| 文档 | 内容 | 状态 |
|------|------|------|
| [音频路由架构.md](./音频路由架构.md) | **双通路 / 双进程结构、数据流、优化 backlog** | 参照 |
| [20260822-libaudioroute-HDMI透传落地/](./20260822-libaudioroute-HDMI透传落地/README.md) | 透传链路、踩坑、补丁、JL_M101 首验 | **已验收** |
| [20260822-设置切换后播放器路由不同步.md](./20260822-设置切换后播放器路由不同步.md) | 设置 HDMI↔SPDIF 后 media_session 不跟切 | **待修** |
| [20260822-4K板libaudioroute移植指南.md](./20260822-4K板libaudioroute移植指南.md) | **h133-p1_nor_4k** 板级 / 4K_app 移植步骤与验收 | **待移植** |

参考原厂补丁包：[../h133-tina-5.0-support-passthrough/](../h133-tina-5.0-support-passthrough/)

京龙板件索引（显示/触摸等，**不含**杜比正文）：[`开发记录/板件开发记录/JL_M101/`](../../开发记录/板件开发记录/JL_M101/README.md)
