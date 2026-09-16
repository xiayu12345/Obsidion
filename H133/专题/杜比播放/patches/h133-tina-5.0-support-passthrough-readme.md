附件是H133 tina 5.0 HDMI 透传支持AC3\EAC3\DTS format的补丁

一个是patch文件，一个是源文件

使用方法：
1.直接打补丁：patch -p1 < xxxx.patch
打补丁的方式打完补丁后需要确认 platform/allwinner/multimedia/libcedarx/external/lib32/openwrt-arm-glibc-gcc-v830/libadecoder.so 文件更新了没有
如果没有更新解压源文件更新这个文件

2.解压源文件，对比添加

