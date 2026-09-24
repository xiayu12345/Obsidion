# 补丁说明 — 触摸

把 ZS 板的触摸从 GSL3670 换成 GT928。`gt9xx.h` 配置表不在本补丁里。

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/ZS101/20260924-H133-ZS101-触摸/patches/apply.sh
```

`tp_rotate` 保持 0，本补丁不改 `setting.ini` 里的这一项。
