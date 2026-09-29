# H133 京龙 HXR10106B-28 N91 屏驱

| 项 | 内容 |
|---|---|
| 日期 | 2026-09-28 |
| 工程 | `/root/Work/AI-tq` |
| 板型 | `p1_nor_JL_HXR101`、`p1_emmc_JL_HXR101` |
| 屏 | HXR10106B-28 LB，ILI9881C-0H，`jl_hxr_n91` |
| 资料 | [HXR10106B28/](../../../硬件资料/四川京龙/HXR10106B28/) |
| 状态 | NOR M101 上试亮后，驱动改挂到 HXR 板。HXR 镜像未重编 |
| 正文 | [开发记录.md](./开发记录.md) |
| 补丁 | [patches/](./patches/) |

## 一句话

HXR 板不再用群创 ILI9881C-0D 那份 init，改用厂商 `N91ILI9881最新版本.txt`。JL-M101 仍是 JD9365DA。

## 补丁

先有 [20260918 独立板件](../20260918-H133-JL-HXR101-新建板件/patches/)，再：

```bash
cd /root/Work/AI-tq
bash AI-skiil/板件开发记录/JL_HXR101/20260928-H133-JL-HXR101-N91屏驱/patches/apply.sh
```

## 编译

```bash
./tools/build_p1_nor_JL_HXR101.sh kernel
./tools/build_p1_emmc_JL_HXR101.sh kernel
```
