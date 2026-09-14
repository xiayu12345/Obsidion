# 功放 MCU V2.13 主控制页 API 对照表

> 版本：V2.13  
> 设计原则：外部调用者不暴露 `amp_mcu_t *`，不手动 `open/close`，全部接口内部单例懒加载。  
> 默认 UART：`/dev/ttyS1`，如需修改，在第一次命令前调用 `amp_mcu_set_uart_dev("/dev/ttyS1")`。

---

## 1. 按钮 / 基础控制函数表

| 功能分类 | 按钮 / 控件 | 对外调用函数 | 参数 / 枚举 | 协议 Data0 | 协议 Data1 | 说明 |
|---|---|---|---|---:|---:|---|
| 输入源 | 蓝牙 | `amp_mcu_select_input(AMP_MCU_INPUT_BLUETOOTH)` | 蓝牙模式 | `0x02` | `0x01` | 切换 BT |
| 输入源 | 安卓 / LineIn | `amp_mcu_select_input(AMP_MCU_INPUT_ANDROID)` | 安卓 LineIn | `0x02` | `0x02` | 切换安卓 LineIn |
| 输入源 | 同轴 | `amp_mcu_select_input(AMP_MCU_INPUT_COAXIAL)` | 同轴 | `0x02` | `0x03` | 切换同轴 |
| 输入源 | AUX | `amp_mcu_select_input(AMP_MCU_INPUT_AUX)` | AUX | `0x02` | `0x1F` | 切换 AUX |
| 输入源 | 光纤 | `amp_mcu_select_input(AMP_MCU_INPUT_OPTICAL)` | 光纤 | `0x02` | `0x60` | V2.13 新增 |
| 输入源 | ARC | `amp_mcu_select_input(AMP_MCU_INPUT_ARC)` | ARC | `0x02` | `0x61` | V2.13 新增 |
| 输入源 | 话筒输入 | `amp_mcu_select_input(AMP_MCU_INPUT_MIC)` | 话筒 | `0x02` | `0x0C` | 输入选择话筒 |
| 输入源 | 吉他输入 | `amp_mcu_select_input(AMP_MCU_INPUT_GUITAR)` | 吉他 | `0x02` | `0x0D` | 输入选择吉他 |
| 播放控制 | 上一曲 | `amp_mcu_prev()` | 无 | `0x02` | `0x04` | 上一曲 |
| 播放控制 | 下一曲 | `amp_mcu_next()` | 无 | `0x02` | `0x05` | 下一曲 |
| 播放控制 | 暂停 | `amp_mcu_pause()` | 无 | `0x02` | `0x06` | 暂停 |
| 播放控制 | 播放 | `amp_mcu_play()` | 无 | `0x02` | `0x07` | 播放 |
| 播放控制 | 播放 / 暂停切换 | `amp_mcu_play_pause()` | 无 | `0x02` | `0x12` | Toggle |
| 静音 | 静音开 | `amp_mcu_mute(true)` | `true` | `0x02` | `0x08` | 静音开 |
| 静音 | 静音关 | `amp_mcu_mute(false)` | `false` | `0x02` | `0x09` | 静音关 |
| 监听 | 监听开 | `amp_mcu_monitor(true)` | `true` | `0x02` | `0x13` | 监听打开 |
| 监听 | 监听关 | `amp_mcu_monitor(false)` | `false` | `0x02` | `0x14` | 监听关闭 |
| 话筒优先 | 话筒优先开 | `amp_mcu_mic_priority(true)` | `true` | `0x02` | `0x10` | 话筒优先开 |
| 话筒优先 | 话筒优先关 | `amp_mcu_mic_priority(false)` | `false` | `0x02` | `0x11` | 话筒优先关 |
| 内录 | 音频输入内录开 | `amp_mcu_audio_record(true)` | `true` | `0x02` | `0x0A` | DACX / 直播相关 |
| 内录 | 音频输入内录关 | `amp_mcu_audio_record(false)` | `false` | `0x02` | `0x0B` | DACX / 直播相关 |
| 直播 | 切换到直播界面 | `amp_mcu_enter_live_page()` | 无 | `0x02` | `0x0E` | 功放常开 |
| 混响模式 | 传统模式 | `amp_mcu_set_reverb_mode(AMP_MCU_REVERB_TRADITIONAL)` | 传统模式 | `0x02` | `0x19` | 混响模式 |
| 混响模式 | 专业模式 | `amp_mcu_set_reverb_mode(AMP_MCU_REVERB_PROFESSIONAL)` | 专业模式 | `0x02` | `0x1A` | 混响模式 |
| 原伴唱 | 原唱 | `amp_mcu_set_vocal_mode(AMP_MCU_VOCAL_ORIGINAL)` | 原唱 | `0x02` | `0x1D` | 原唱 |
| 原伴唱 | 伴唱 | `amp_mcu_set_vocal_mode(AMP_MCU_VOCAL_ACCOMPANIMENT)` | 伴唱 | `0x02` | `0x1E` | 伴唱 |

---

## 2. 话筒音效函数表

| 按钮 | 对外调用函数 | 参数 / 枚举 | 协议 Data0 | 协议 Data1 | 说明 |
|---|---|---|---:|---:|---|
| 演唱 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_SINGING)` | 演唱 | `0x02` | `0x21` | Mic 音效 |
| 主持 / 主播 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_HOST)` | 主持 | `0x02` | `0x22` | Mic 音效 |
| KTV / K歌 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_KTV)` | KTV | `0x02` | `0x23` | Mic 音效 |
| 会议 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_MEETING)` | 会议 | `0x02` | `0x24` | Mic 音效 |
| 原声 / 原音 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_ORIGINAL)` | 原声 | `0x02` | `0x2A` | Mic 音效 |
| 美声 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_BEL_CANTO)` | 美声 | `0x02` | `0x2B` | Mic 音效 |
| 标准美声 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_STANDARD_BEL_CANTO)` | 标准美声 | `0x02` | `0x2C` | Mic 音效 |
| 专业美声 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_PRO_BEL_CANTO)` | 专业美声 | `0x02` | `0x2D` | Mic 音效 |
| 电音 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_ELECTRIC)` | 电音 | `0x02` | `0x2E` | Mic 音效 |
| 喊麦 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_SHOUT)` | 喊麦 | `0x02` | `0x2F` | Mic 音效 |
| 直播模式 / 户外 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_LIVE)` | 直播模式 | `0x02` | `0x3A` | V2.6 新增 |
| 男变女音效 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_MALE_TO_FEMALE)` | 男变女 | `0x02` | `0x51` | 属于 Mic 音效 |
| 女变男音效 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_FEMALE_TO_MALE)` | 女变男 | `0x02` | `0x52` | 属于 Mic 音效 |
| 娃娃音效 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_BABY)` | 娃娃音 | `0x02` | `0x53` | 属于 Mic 音效 |
| 魔音音效 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_MAGIC)` | 魔音 | `0x02` | `0x54` | 属于 Mic 音效 |
| 标准音效 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_STANDARD)` | 标准 | `0x02` | `0x55` | 属于 Mic 音效 |
| 萝莉音效 | `amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_LOLI)` | 萝莉 | `0x02` | `0x56` | 属于 Mic 音效 |

---

## 3. 话筒变调函数表

| 按钮 | 对外调用函数 | 参数 / 枚举 | 协议 Data0 | 协议 Data1 | 说明 |
|---|---|---|---:|---:|---|
| 男变女 | `amp_mcu_set_mic_pitch(AMP_MCU_MIC_PITCH_MALE_TO_FEMALE)` | 男变女 | `0x02` | `0x25` | 话筒变调 |
| 女变男 | `amp_mcu_set_mic_pitch(AMP_MCU_MIC_PITCH_FEMALE_TO_MALE)` | 女变男 | `0x02` | `0x26` | 话筒变调 |
| 娃娃音 | `amp_mcu_set_mic_pitch(AMP_MCU_MIC_PITCH_BABY)` | 娃娃音 | `0x02` | `0x27` | 话筒变调 |
| 魔音 | `amp_mcu_set_mic_pitch(AMP_MCU_MIC_PITCH_MAGIC)` | 魔音 | `0x02` | `0x28` | 话筒变调 |
| 标准 | `amp_mcu_set_mic_pitch(AMP_MCU_MIC_PITCH_STANDARD)` | 标准 | `0x02` | `0x29` | 话筒变调 |

---

## 4. 音乐音效函数表

| 按钮 | 对外调用函数 | 参数 / 枚举 | 协议 Data0 | 协议 Data1 | 说明 |
|---|---|---|---:|---:|---|
| 平调 / 人声 / 电影 | `amp_mcu_set_music_effect(AMP_MCU_MUSIC_EFFECT_FLAT)` | 平调 | `0x02` | `0x30` | 音乐音效 |
| 古典 / 乡村 | `amp_mcu_set_music_effect(AMP_MCU_MUSIC_EFFECT_CLASSICAL)` | 古典 | `0x02` | `0x31` | 音乐音效 |
| 流行 | `amp_mcu_set_music_effect(AMP_MCU_MUSIC_EFFECT_POP)` | 流行 | `0x02` | `0x32` | 音乐音效 |
| 摇滚 / DJ | `amp_mcu_set_music_effect(AMP_MCU_MUSIC_EFFECT_ROCK)` | 摇滚 | `0x02` | `0x33` | 音乐音效 |
| 爵士 | `amp_mcu_set_music_effect(AMP_MCU_MUSIC_EFFECT_JAZZ)` | 爵士 | `0x02` | `0x34` | 音乐音效 |
| 室内 | `amp_mcu_set_music_effect(AMP_MCU_MUSIC_EFFECT_INDOOR)` | 室内 | `0x02` | `0x35` | 音乐音效 |
| 室外 | `amp_mcu_set_music_effect(AMP_MCU_MUSIC_EFFECT_OUTDOOR)` | 室外 | `0x02` | `0x36` | 音乐音效 |
| 广场舞 | `amp_mcu_set_music_effect(AMP_MCU_MUSIC_EFFECT_SQUARE_DANCE)` | 广场舞 | `0x02` | `0x37` | V2.8 新增 |

---

## 5. 特效音函数表

| 按钮 | 对外调用函数 | 参数 / 枚举 | 协议 Data0 | 协议 Data1 |
|---|---|---|---:|---:|
| 开场 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_OPENING)` | 开场 | `0x02` | `0x15` |
| 鼓掌 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_APPLAUSE)` | 鼓掌 | `0x02` | `0x16` |
| 尴尬 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_AWKWARD)` | 尴尬 | `0x02` | `0x17` |
| 贼拉拉 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_ZEILALA)` | 贼拉拉 | `0x02` | `0x18` |
| 鄙视 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_DESPISE)` | 鄙视 | `0x02` | `0x40` |
| 笑声 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_LAUGH)` | 笑声 | `0x02` | `0x41` |
| 欢呼 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_CHEER)` | 欢呼 | `0x02` | `0x42` |
| 么么哒 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_KISS)` | 么么哒 | `0x02` | `0x43` |
| 呐喊 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_SHOUT)` | 呐喊 | `0x02` | `0x44` |
| 口哨 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_WHISTLE)` | 口哨 | `0x02` | `0x45` |
| 烟花 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_FIREWORKS)` | 烟花 | `0x02` | `0x46` |
| 喝彩 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_BRAVO)` | 喝彩 | `0x02` | `0x47` |
| 飞吻 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_FLYING_KISS)` | 飞吻 | `0x02` | `0x48` |
| 尖叫 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_SCREAM)` | 尖叫 | `0x02` | `0x49` |
| 机枪 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_MACHINE_GUN)` | 机枪 | `0x02` | `0x4A` |
| 鼓励 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_ENCOURAGE)` | 鼓励 | `0x02` | `0x4B` |
| 怪笑 | `amp_mcu_play_effect_sound(AMP_MCU_SOUND_EVIL_LAUGH)` | 怪笑 | `0x02` | `0x4C` |

---

## 6. 滑动条 / 参数函数表

| 滑动条 | 对外调用函数 | 参数范围 | 协议 Data0 | 协议 Data1 | Data2 | 说明 |
|---|---|---:|---:|---:|---:|---|
| 总音量 / 音乐音量 | `amp_mcu_set_master_volume(value)` | `0~32` | `0x01` | `value` | 无 | 协议音量命令 |
| 音乐高音 | `amp_mcu_set_music_treble(value)` | `0~14` | `0x04` | `0x01` | `value` | 音乐高音 |
| 音乐低音 | `amp_mcu_set_music_bass(value)` | `0~14` | `0x04` | `0x02` | `value` | 音乐低音 |
| 话筒高音 | `amp_mcu_set_mic_treble(value)` | `0~14` | `0x04` | `0x03` | `value` | 麦高音 |
| 话筒低音 | `amp_mcu_set_mic_bass(value)` | `0~14` | `0x04` | `0x04` | `value` | 麦低音 |
| 话筒混响 / 回响 | `amp_mcu_set_mic_reverb(value)` | `0~15` | `0x04` | `0x05` | `value` | 麦混响，实际为麦回响 |
| 话筒音量 | `amp_mcu_set_mic_volume(value)` | `0~32` | `0x04` | `0x06` | `value` | 麦音量 |
| 录音音量 / 直播音量 | `amp_mcu_set_record_volume(value)` | `0~15` | `0x04` | `0x07` | `value` | 直播音量 |
| 吉他音量 | `amp_mcu_set_guitar_volume(value)` | `0~15` | `0x04` | `0x08` | `value` | 吉他音量 |
| 话筒延迟 / 回声延时 | `amp_mcu_set_mic_delay(value)` | `0~15` | `0x04` | `0x09` | `value` | 麦克风延迟 |
| 音乐重低音 | `amp_mcu_set_music_subwoofer(value)` | `0~15` | `0x04` | `0x0A` | `value` | 低音增强 |
| 音乐中音 | `amp_mcu_set_music_mid(value)` | `0~14` | `0x04` | `0x0B` | `value` | 音乐中音 |
| 话筒中音 | `amp_mcu_set_mic_mid(value)` | `0~14` | `0x04` | `0x0C` | `value` | 麦克风中音 |

---

## 7. EQ 函数表

| EQ 滑条 | 对外调用函数 | UI 参数范围 | 协议值范围 | 协议 Data0 | Data1 | Data2~Data11 |
|---|---|---:|---:|---:|---:|---|
| EQ 开关 | `amp_mcu_set_eq_enable(true/false)` | 开 / 关 | `0x00/0x01` | `0x05` | `0x00/0x01` | 关闭无频段；打开发送当前 10 段值 |
| 32 Hz | `amp_mcu_set_eq_band(AMP_MCU_EQ_32HZ, value)` | `-12~+12` | `0x00~0x18` | `0x05` | `0x01` | Data2 |
| 62 Hz | `amp_mcu_set_eq_band(AMP_MCU_EQ_62HZ, value)` | `-12~+12` | `0x00~0x18` | `0x05` | `0x01` | Data3 |
| 125 Hz | `amp_mcu_set_eq_band(AMP_MCU_EQ_125HZ, value)` | `-12~+12` | `0x00~0x18` | `0x05` | `0x01` | Data4 |
| 250 Hz | `amp_mcu_set_eq_band(AMP_MCU_EQ_250HZ, value)` | `-12~+12` | `0x00~0x18` | `0x05` | `0x01` | Data5 |
| 500 Hz | `amp_mcu_set_eq_band(AMP_MCU_EQ_500HZ, value)` | `-12~+12` | `0x00~0x18` | `0x05` | `0x01` | Data6 |
| 1 kHz | `amp_mcu_set_eq_band(AMP_MCU_EQ_1KHZ, value)` | `-12~+12` | `0x00~0x18` | `0x05` | `0x01` | Data7 |
| 2 kHz | `amp_mcu_set_eq_band(AMP_MCU_EQ_2KHZ, value)` | `-12~+12` | `0x00~0x18` | `0x05` | `0x01` | Data8 |
| 4 kHz | `amp_mcu_set_eq_band(AMP_MCU_EQ_4KHZ, value)` | `-12~+12` | `0x00~0x18` | `0x05` | `0x01` | Data9 |
| 8 kHz | `amp_mcu_set_eq_band(AMP_MCU_EQ_8KHZ, value)` | `-12~+12` | `0x00~0x18` | `0x05` | `0x01` | Data10 |
| 16 kHz | `amp_mcu_set_eq_band(AMP_MCU_EQ_16KHZ, value)` | `-12~+12` | `0x00~0x18` | `0x05` | `0x01` | Data11 |
| 一次性设置 10 段 EQ | `amp_mcu_set_eq_all(values[10])` | 每段 `-12~+12` | 每段 `0x00~0x18` | `0x05` | `0x01` | Data2~Data11 |

EQ 换算规则：

```c
protocol_value = ui_value + 12;
// UI -12 -> 协议 0x00
// UI   0 -> 协议 0x0C
// UI +12 -> 协议 0x18
```

---

## 8. 查询 / 状态同步函数表

| 功能 | 对外调用函数 | 协议 Data0 | 返回内容 |
|---|---|---:|---|
| 查询当前所有状态 | `amp_mcu_query_status(&status)` | `0x03` | 话筒优先、内录、输入选择、EQ 自定义、混响模式、监听、当前模式、音量、静音、蓝牙状态、Mic 音效、音乐音效、电量 |
| 查询当前所有状态原始帧 | `amp_mcu_query_status_raw(buf, buf_size, &out_len)` | `0x03` | 返回 MCU 原始协议帧 |
| 查询音乐/话筒参数 | `amp_mcu_query_audio_params(&params)` | `0x06` | 音乐高音、音乐低音、麦高音、麦低音、麦混响、麦音量、录音音量、吉他音量 |
| 查询 EQ | `amp_mcu_query_eq(&eq)` | `0x05` + `Data1=0x02` | 10 段 EQ 值，返回 UI 值 `-12~+12` |

状态结构体：

```c
typedef struct {
    bool mic_priority;
    bool audio_record;
    bool input_is_guitar;
    bool eq_custom;
    bool professional_mode;
    bool effect_no_save;
    bool lyric_utf8;
    bool monitor;

    uint8_t input_mode;
    uint8_t master_volume;
    uint8_t mute_state;
    uint8_t bluetooth_state;
    uint8_t mic_effect;
    uint8_t music_effect;
    uint8_t battery_raw;

    bool battery_charging;
    bool battery_icon_5bars;
    bool battery_hidden;
    uint8_t battery_level;
} amp_mcu_status_t;
```

---

## 9. 系统 / 初始化 / 其他命令表

| 功能 | 对外调用函数 | 协议 Data0 | 参数 | 说明 |
|---|---|---:|---|---|
| 设置串口设备 | `amp_mcu_set_uart_dev("/dev/ttyS1")` | 无 | 字符串 | 必须在第一次命令前调用 |
| 释放 MCU | `amp_mcu_shutdown()` | 无 | 无 | 程序退出时可选调用 |
| 初始化开始 | `amp_mcu_init_begin()` | `0x07` | `Data1=0` | App 启动初始化开始 |
| 初始化结束 | `amp_mcu_init_end()` | `0x07` | `Data1=1` | 结束后 MCU 才播放提示音 |
| 一键重置 | `amp_mcu_reset(music_effect, mic_effect, reverb_mode)` | `0x09` | Data1~Data3 | 音乐音效、Mic 音效、Mic 混响模式 |
| 蓝牙断开 | `amp_mcu_disconnect_bluetooth()` | `0x0E` | `Data1=0x01` | 安卓发送给 MCU |
| BLE 转发 | `amp_mcu_forward_ble_data(data, len)` | `0x0F` | 不固定长度，最大 70 字节 | MCU 和手机 BLE 数据转发 |
| 原始发送 | `amp_mcu_send_raw(data, len)` | 原始帧 | 调试用 | 调试 / 兼容未封装命令 |

---

## 主控制页推荐最小调用方式

```c
#include "amp_mcu.h"

void ktv_control_init(void)
{
    amp_mcu_set_uart_dev("/dev/ttyS1");
    amp_mcu_init_begin();

    amp_mcu_set_master_volume(20);
    amp_mcu_set_mic_volume(24);
    amp_mcu_set_mic_reverb(10);
    amp_mcu_set_mic_effect(AMP_MCU_MIC_EFFECT_KTV);
    amp_mcu_select_input(AMP_MCU_INPUT_MIC);
    amp_mcu_monitor(true);
    amp_mcu_mute(false);

    amp_mcu_init_end();
}

void on_mute_button(bool checked)
{
    amp_mcu_mute(checked);
}

void on_master_volume_changed(uint8_t value)
{
    amp_mcu_set_master_volume(value);
}
```

---

## 编译命令

```bash
make clean
make
```

编译产物：

```text
libamp_mcu.a
example_main
```
