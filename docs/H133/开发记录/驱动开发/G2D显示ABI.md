# G2D / 显示 ABI 开发

## 资料来源

| 文档 | 说明 |
|---|---|
| `docs/debug-notes-g2d-abi-and-toplevel-build.md` | G2D ABI 与顶层编译缓存问题 |

## 问题线索

G2D、display ABI、OpenWrt `build_dir` 缓存之间存在联动。修改 package 源码后，如果 build_dir 中仍保留旧构建结果，可能出现“源码已改但运行现象未变”的错觉。

## 关注文件

| 路径 | 说明 |
|---|---|
| `platform/allwinner/` | 全志平台库和显示相关组件 |
| `kernel/linux-5.4/` | 内核显示/G2D 驱动 |
| `openwrt/build_dir/` | OpenWrt 构建缓存目录 |

## 常用排查

```bash
cd /home/xiayu/Workspace/HDMI_new/HDMI
find openwrt/build_dir -iname '*g2d*'
rg "g2d|G2D|disp_layer|disp_get_layer" docs kernel/linux-5.4 platform openwrt/package
```

## 开发记录

### 待记录

- ABI 变更点：`[待填写]`
- 清理范围：`[待填写]`
- 验证镜像：`[待填写]`
