---
project: JL_M101
kind: peripheral
---
# GPADC 电阻按键

- 脚：原理图 KEY ADC，球 C11 = GPADC0；J9536 外侧接电阻，RA20 51k + RA22 6.8k
- 读：`cat /sys/class/gpadc/data`；evdev 看键码
- 坑：两块板电压不同，**当前镜像用板乙**，换板先读 ADC，不要混表
- 资料：`H133-AI-Skills/硬件资料/四川京龙/s10-h133-v1_0625.pdf`
