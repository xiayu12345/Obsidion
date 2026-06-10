# H133 Git 相关

## 仓库类型

工程为 **repo 多 Git 仓库**，顶层 `.repo/` 管理 manifest。

## 常用命令

```bash
cd ~/Workspace/HDMI_new/HDMI

# 所有子仓状态
repo status

# 同步 manifest 指定版本
repo sync

# 进入单个子仓
cd platform/thirdparty/gui/lvgl-8/lv_projector
git log --oneline -5
git diff
```

## 提交规范（子仓内）

```bash
git add <files>
git commit -m "fix: 描述改动"
# push 需配置 remote，按团队流程
```

## 不建议

- 不要在顶层当普通 git 仓 commit（无单一 .git）
- 不要 `repo sync` 覆盖未提交改动前不 stash

## 与笔记同步

| 仓库 | 用途 |
|---|---|
| Ubuntu HDMI 工程 | 固件源码（repo 多仓） |
| GitHub Obsidion | MkDocs 笔记发布 |
| C:\Career | Obsidian 本地笔记源 |

笔记更新流程：Career 编辑 → 构建脚本同步到 Obsidion → push → GitHub Pages 自动部署。

## Windows 访问 Ubuntu 工程

```bash
ssh h133-ubuntu "cd ~/Workspace/HDMI_new/HDMI && repo status"
```

SSH 配置：`~/.ssh/config` → `Host h133-ubuntu`


## 自动补充 - 2026-06-10

### 源码仓库状态

```bash
cd /home/xiayu/Workspace/HDMI_new/HDMI
git status
repo status
```

### 常用 Git 命令

```bash
git status
git diff
git add <file>
git commit -m "message"
git log --oneline -20
```

### Repo 多仓库线索

```bash
repo status
repo diff
repo manifest -r -o manifest.lock.xml
```
