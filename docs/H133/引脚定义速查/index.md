# H133 引脚定义速查

> 来源：`device/config/chips/h133/configs/p1_nor/sys_config.fex` + `board.dts`  
> GPIO 格式：`port:PXYY<功能><上下拉><驱动能力><电平>`

## SPI NOR Flash

| 信号 | 引脚 |
|---|---|
| spi_sclk | PC02 |
| spi_cs | PC03 |
| spi0_mosi | PC04 |
| spi0_miso | PC05 |
| spi0_wp | PC06 |
| spi0_hold | PC07 |

## SD 卡（card0，四线）

| 信号 | 引脚 |
|---|---|
| sdc_clk | PF2 |
| sdc_cmd | PF3 |
| sdc_d0 | PF1 |
| sdc_d1 | PF0 |
| sdc_d2 | PF5 |
| sdc_d3 | PF4 |
| cd-gpio | PF6（board.dts） |

## 调试 UART0

| 信号 | 引脚 |
|---|---|
| uart_debug_tx | PB08 |
| uart_debug_rx | PB09 |

## UART3（P15 排针）

| 信号 | 引脚 |
|---|---|
| TX | PG0 |
| RX | PG1 |

> 使用 uart3 时须禁用 sdc1，避免 pin 冲突。

## eMMC（card2，部分板型）

| 信号 | 引脚 |
|---|---|
| sdc_clk | PC02 |
| sdc_cmd | PC03 |
| sdc_d0–d3 | PC04–PC07 |

## DRAM 识别 GPIO

| 信号 | 引脚 |
|---|---|
| select_gpio0 | PB7 |
| select_gpio1 | PB4 |
| select_gpio2 | PH1 |
| select_gpio3 | PH0 |

## 触摸 / I2C

GT911 接 TWI0，具体 SCL/SDA 引脚见 `board.dts` 中 `&twi0` / `pinctrl` 节点。

## 查阅完整定义

```bash
# Ubuntu 工程内
grep -E '^\[|port:' device/config/chips/h133/configs/p1_nor/sys_config.fex
grep -E 'pinctrl|function|gpio' device/config/chips/h133/configs/p1_nor/board.dts
```

## 硬件接线

外设接线汇总见 [[硬件接线/硬件接线]]。


## 自动补充 - 2026-06-10

以下表格来自 `device/config/chips/h133/configs/p1_nor/sys_config.fex`、`board.dts`、`uboot-board.dts` 自动整理。

| 功能 | 引脚 | 复用/说明 | 风险 |
|---|---|---|---|
| UART0 Debug | PB8/PB9 | 调试串口，`uart_debug_port=0` | 与 SPI1 部分引脚复用 |
| UART1 | PG6/PG7/PG8/PG9 | UART1 TX/RX/RTS/CTS | PG8/PG9 与 TWI1 复用 |
| UART2 | PC0/PC1 | UART2 TX/RX | 与 TWI2 复用 |
| UART3 | PG0/PG1 | P15 排针 TX/RX 线索 | 需确认是否启用 |
| TWI0 | PB10/PB11 | I2C0 | 与 USB VBUS/SPI1/LCD GPIO 等复用风险 |
| TWI1 | PG8/PG9 | I2C1，触摸候选总线 | 与 UART1 复用 |
| TWI2 | PC0/PC1 | I2C2 | 与 UART2 复用 |
| TWI3 | PE16/PE17 | I2C3 | 需确认外设 |
| SPI0 / NOR | PC2/PC3/PC4/PC5/PC6/PC7 | SCLK/CS/MOSI/MISO/WP/HOLD | 与 SDC2 同组冲突 |
| SPI1 | PB11/PB10/PB9/PB8/PB0/PB12 | SPI1 全组线索 | 与 UART0/TWI0/LCD GPIO 等复用 |
| SDC0 | PF0-PF5 | SD 卡 4bit | 与 I2S2/LEDC/JTAG 等可能复用 |
| SDC2 | PC2-PC7 | eMMC/SDC2 线索 | 与 SPI0/NOR 冲突，p1_nor 下尤其注意 |
| LCD GPIO | PB11/PB12 | `lcd_gpio_0`、`lcd_bl_en` | 与 TWI0/SPI1/DMIC 等复用 |
| PWM7 | PD22 | PWM 输出 | 用途待确认 |
| HDMI | HDMI controller | `hdmi_used=1` | 重点关注 screen1/layer 配置 |
| USB1 VBUS | PB10 | USB VBUS 控制 | 与 TWI0/SPI1 复用 |
| IR | PB1/PB0 | 红外相关 | 与 SPI1 PB0 可能复用 |
| WiFi clock | PG11 | `clk_fanout1` | 模组型号待确认 |
| I2S0 | PB29/PB23-PB28/PB22 | 音频总线 | 需结合原理图确认 |
| I2S1 | PB29/PB23-PB28 | 音频总线 | 需结合原理图确认 |
| I2S2 | PF6/PF3/PF5/PF1/PF0 | 音频总线 | 与 SDC0 部分引脚复用 |
| SPDIF | PG18 | 数字音频 | 需确认是否接出 |
| DMIC | PB12/PB11/PB10/PE14/PB8 | 数字麦克风 | 与 LCD/TWI0/UART0 等复用 |

待确认：最终引脚表应以原理图、实测板卡、当前 DTS/FEX 三者一致为准。
