# ls_player_get_cur_time() 精度测试报告

| 项 | 值 |
|---|---|
| 生成时间 | 2026-06-15 00:16:54 |
| 测试文件 | /mnt/SDCARD/leishi_test/7279684.ts |
| 板端 | root@192.168.1.56 |
| 采样间隔 | 10 ms |
| 测试时长 | 60 s |
| 媒体总长 | 235034 ms |
| 结论 | **PASS** |

## 摘要

满足联调初筛: 单调性/漂移/抖动在可接受范围

## 核心指标

| 指标 | 数值 | 说明 |
|---|---|---|
| 样本数 | 6000 | CSV 行数 |
| Playing 样本 | 5487 | status=Playing |
| 稳态样本 | 5486 | 排除 seek/大跳变 |
| 稳态 drift cur/wall | 0.9952 | 理想≈1.0 |
| 平均绝对误差 | 0.27 ms | |delta_cur - delta_wall| |
| RMSE | 0.81 ms | 打分/歌词同步关键指标 |
| P95 绝对误差 | 1.00 ms | |
| P99 绝对误差 | 1.00 ms | |
| 回退步数 (delta<-20ms) | 0 | Playing 且非 seek 后 |
| 最大单步前进 | 21 ms | |
| 暂停期 cur 最大变化 | 0 ms | |
| Seek 收敛时间 | 122 ms | seek 到 50%% 后 |

## 测试方法

1. `ls_player_timebench` 播放 TS, 默认 10ms 采样 (~100Hz)
2. 第 25s 暂停 5s, 第 45s seek 到 50%
3. 对比 `delta_cur` 与 `delta_wall`, 统计单调性与 RMSE

## 原始 SUMMARY (板端)

```json
{
  "samples": 6000,
  "playing_samples": 5488,
  "interval_ms": 10,
  "total_ms": 235034,
  "wall_span_ms": 60000,
  "cur_span_ms": 132268,
  "drift_ratio": 2.204467,
  "avg_abs_err_ms": 0.293,
  "rmse_ms": 1.8,
  "backward_steps": 0,
  "max_forward_jump_ms": 129,
  "pause_cur_max_delta_ms": 67,
  "seek_settle_ms": 0
}
```

## 备注

- 雷石 spec 要求 `get_cur_time()` 高精度高频调用; 本报告为 H133/TPlayer 基线
- 正式联调前建议用雷石真实 MV + 歌词/打分模块复测
