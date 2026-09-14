# 播放器底层适配接口技术文档

为了让本项目的 KTV 核心业务（如播放列表管理、打分同步、原伴唱切换等）能在新项目中无缝运行，**底层开发人员必须实现一套标准的播放器包装接口 (Wrapper API)**。

本项目的业务代码是通过调用 `ls_player.h` 中定义的标准接口来控制底层多媒体引擎的。底层可以使用任何播放器（如 TPlayer, GStreamer, mpv 或 Android MediaPlayer），只需将它们的能力映射到以下接口即可。

---

## 1. 核心状态与速度枚举定义
底层在回调状态变化或控制速度时，必须严格遵守以下枚举定义：

### 1.1 播放器状态 (`eLsPlayerStatus`)
```c
enum {
    eLsPlayerStatusStop = 0,    // 已停止
    eLsPlayerStatusPrepare = 1, // 准备中（加载 URL/解析流）
    eLsPlayerStatusPlaying = 2, // 播放中
    eLsPlayerStatusPause = 3,   // 暂停中
    eLsPlayerStatusSeeking = 4, // 正在 Seek
    eLsPlayerStatusSpeed = 5,   // 正在快进快退
    eLsPlayerStatusComplete = 6,// 播放自然结束
    eLsPlayerStatusError = 7,   // 发生错误
    eLsPlayerStatusMax,
};
```

### 1.2 播放速度 (`eLsPlayerSpeed`)
```c
enum {
    eLsPlayerSpeedFastForward16 = 0,
    eLsPlayerSpeedFastForward8,
    eLsPlayerSpeedFastForward4,
    eLsPlayerSpeedFastForward2,
    eLsPlayerSpeedNormal,
    eLsPlayerSpeedFastBackward2,
    eLsPlayerSpeedFastBackward4,
    eLsPlayerSpeedFastBackward8,
    eLsPlayerSpeedFastBackward16,
    eLsPlayerSpeedMax,
};
```

---

## 2. 底层需实现的完整 C 接口规范

以下是 `ls_player.h` 要求的**全部**函数原型。为保证项目平滑移植，请务必将其完整实现（如果某些硬件不支持特定功能，可实现为空函数并返回默认值）。

### 2.1 生命周期与基础控制
| 接口名 | 描述 |
| :--- | :--- |
| `bool ls_player_create(void);` | 初始化您的底层播放引擎组件。成功返回 `true`。 |
| `void ls_player_release(void);` | 销毁并释放所有播放器底层资源。 |
| `void ls_player_handle(void);` | 播放器内部状态泵（如果底层需要轮询驱动则实现；否则可留空）。 |
| `bool ls_player_set_screen_region(int x, int y, int w, int h);` | 设置视频画面的渲染区域坐标。 |
| `bool ls_player_set_looping(bool loop);` | 设置当前媒体是否循环播放。 |
| `bool ls_player_set_hold_last_picture(bool hold);`| 设置播放结束后是否保留最后一帧画面。 |
| `int ls_player_auto_switch_control(int soundcard, int flag);` | 控制底层声卡或输出通道的自动切换逻辑。 |

### 2.2 事件回调注册
| 接口名 | 描述 |
| :--- | :--- |
| `bool ls_player_set_status_change_cb(fun_ls_player_status_change cb);` | 注册状态变化回调：`void (*)(uint32_t cur, uint32_t old)`。 |
| `bool ls_player_set_buffer_status_cb(fun_ls_player_buffer_status cb);` | 注册缓冲状态回调：`void (*)(bool no_data)`。当网络卡顿或恢复时触发。 |

### 2.3 播放动作控制
| 接口名 | 描述 |
| :--- | :--- |
| `bool ls_player_play_url(const char *url);` | 传入网络地址或本地路径并触发 Prepare。 |
| `bool ls_player_play_audio_url(const char *url);` | 仅播放音频资源。 |
| `bool ls_player_play(void);` | 从暂停状态恢复播放。 |
| `bool ls_player_pause(void);` | 暂停播放。 |
| `bool ls_player_stop(void);` | 停止播放，释放媒体句柄。 |
| `bool ls_player_seek(int time_ms);` | 跳转到指定时间（毫秒）。 |
| `bool ls_player_speed(uint32_t speed);` | 变速播放（传入 `eLsPlayerSpeed` 枚举）。 |

### 2.4 KTV 专属音轨与音量控制
这些接口是 KTV 业务的核心，底层引擎**必须支持多音轨切换或声道静音**。
| 接口名 | 描述 |
| :--- | :--- |
| `int ls_player_get_audio_track(void);` | 获取当前正在使用的音频轨道索引。 |
| `bool ls_player_set_audio_track(int track_index);` | 切换音轨（MP4内置双音轨，常用于原伴唱切换）。 |
| `bool ls_player_set_channel_mode(int mode);` | 切换声道（单音轨左右声道分离，0:立体声 1:左声道 2:右声道）。 |
| `bool ls_player_set_volume(int volume);` | 设置系统或引擎混音音量 (0~100)。 |

### 2.5 状态与参数查询
其中 `get_cur_time()` 会被打分和歌词引擎高频调用，必须保证高效精准。
| 接口名 | 描述 |
| :--- | :--- |
| `uint32_t ls_player_get_total_time(void);` | 获取媒体总时长（毫秒）。 |
| `uint32_t ls_player_get_cur_time(void);` | 获取当前播放进度时间戳（毫秒）。**精度要求极高**。 |
| `uint32_t ls_player_get_status(void);` | 获取底层当前状态（返回 `eLsPlayerStatus`）。 |
| `const char *ls_player_get_url(void);` | 获取当前正在播放的媒体路径。 |
| `bool ls_player_is_no_data(void);` | 当前是否处于无数据缓冲状态。 |
| `uint32_t ls_player_get_video_width(void);` | 获取视频资源的原始宽度。 |
| `uint32_t ls_player_get_video_height(void);`| 获取视频资源的原始高度。 |

---

## 3. 核心业务层调用时序说明
1. **启动应用**：调用 `ls_player_create()` 并注册各类回调事件。
2. **点歌播放**：
   - 调用 `ls_player_play_url(url)`。
   - 底层进入 `Prepare` 状态，加载成功后自动进入 `Playing`，并触发 `status_change_cb`。
3. **播放中途**：
   - KTV 打分线程高频调用 `ls_player_get_cur_time()` 寻卡音高并同步歌词。
   - 用户喊出“切换原唱”：业务层调用 `ls_player_set_audio_track()` 或 `ls_player_set_channel_mode()`。
4. **切歌/播放结束**：
   - 歌曲自然结束，底层触发 `Complete` 状态回调。
   - 业务层收到信号，调用 `ls_player_stop()` 清理当前流，紧接着传入下一首的 URL。
