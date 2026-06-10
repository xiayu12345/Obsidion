# 存储 / SD 卡驱动开发

## 资料来源

| 文档 | 说明 |
|---|---|
| `docs/H133-Tina-SD卡调试经验.md` | SD 卡 DiskManager 调试经验 |

## 自动识别到的存储接口

| 接口 | 引脚 | 备注 |
|---|---|---|
| SPI NOR | PC2-PC7 | 当前 `p1_nor` 方案关键存储总线 |
| SDC0 | PF0-PF5 | SD 卡 4bit，高速接口 |
| SDC2 | PC2-PC7 | 与 SPI0/SPI NOR 同组冲突 |

## 当前风险

- `p1_nor` 下 SPI0/NOR 与 SDC2 同组 pinmux 冲突，需要避免误开。
- SDC0 与 I2S2/LEDC/JTAG 等功能存在复用可能，需结合实际板卡确认。

## 开发记录

### 待记录

- SD 卡识别日志：`[待填写]`
- mount 路径：`[待填写]`
- DiskManager 行为：`[待填写]`
- 异常复现：`[待填写]`
