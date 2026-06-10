# rootfs 空间与应用占用

## 资料来源

| 文档 | 说明 |
|---|---|
| `H133-rootfs空间与应用占用说明.md` | rootfs 分区与应用体积说明 |

## 关注内容

| 项目 | 状态 |
|---|---|
| rootfs 类型 | `[待确认]` |
| 可用空间 | `[待确认]` |
| `lv_projector` 体积 | `[待确认]` |
| 第三方库占用 | `[待确认]` |

## 常用命令

```bash
adb shell df -h
adb shell du -sh /usr/bin/lv_projector
adb shell du -sh /usr/lib/* 2>/dev/null | sort -h | tail
```

## 开发记录

### 待记录

- 空间问题现象：`[待填写]`
- 调整项：`[待填写]`
- 验证结果：`[待填写]`
