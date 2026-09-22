# 补丁说明

本目录保存 H133-K1 GPADC0 + PG18 组选实现 20 个按键的补丁。工作区已经落地，补丁用于移植、归档或从基线重放。

## 补丁内容

### 0001-sunxi-gpadc-optional-dual-key-groups.patch

修改 `sunxi_gpadc.c/.h`：

- 增加可选的 `key-group-gpios`。
- 空闲时每 10ms 翻转 A/B 组。
- 检测到按键后锁定组别，松开后恢复扫描。
- A、B 组使用相同 ADC 电压表和不同键码表。
- 正确保存按下键码，确保松开事件与按下事件一致。
- 挂起时停止组选任务，恢复时从 A 组重新开始。
- 未配置组选 GPIO 的设备继续使用原单组流程。

### 0002-h133-k1-gpadc-20-key-map.patch

修改 `p1_nor_XYC_K1/linux-5.4/board.dts`：

- PG18 配为组选输出。
- 写入现场实测的 10 档 ADC 电压。
- 配置 A 组导航/功能键和 B 组音效键。
- 所有键码均带中文功能注释。

同目录的 `board.dts` 是板级设备树入口，与 `linux-5.4/board.dts` 保持同步。

## 应用

在 `AI-tq` 根目录执行：

```sh
AI-skiil/专题开发记录/GPADC双组键/20260909-H133-K1-GPADC双组20键/patches/apply.sh
```

当前工作区已包含修改，再次应用可能提示补丁已经应用或上下文不匹配。

## 验证

```sh
rg 'key-group-gpios|Bkey9_val|key_cnt = <10>' \
  device/config/chips/h133/configs/p1_nor_XYC_K1/linux-5.4/board.dts

rg 'KEY_GROUP_SCAN_INTERVAL_MS|scankeycodes_group_b' \
  kernel/linux-5.4/drivers/input/sensor/sunxi_gpadc.c \
  kernel/linux-5.4/drivers/input/sensor/sunxi_gpadc.h
```

完整构建：

```sh
./tools/build_p1_nor_XYC_K1.sh full
```

