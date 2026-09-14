# total_count 与 page_size

两个参数都在 `inflist_cfg_t` 里、`inflist_open` 时传入，但**含义完全不同**。混用是集成 libinflist 时最常见的坑。

---

## 对照表

| | **total_count** | **page_size** |
|---|-----------------|---------------|
| **回答的问题** | 列表一共有几条？能滚到 id 几？ | 文字库把 id 按多少条切成「一页」缓存？ |
| **谁用** | 网格滚动范围 `get_count()` | 文字库 `inflist_text`：`id / page_size` |
| **会随 JSON 变吗** | 会 — parse 完应 `inflist_set_total_count(N)` | 不会 — open 时写一次，全程固定 |
| **例：真实 4 条** | `set_total_count(4)` | 仍可 `page_size=50`（4 条都在文字页 0） |
| **例：真实 77 条** | `set_total_count(77)` | 仍 `page_size=50`（文字页 0: id 0–49，页 1: 50–76） |

---

## 典型流程

```
1. inflist_open({ total_count=100000, page_size=50, ... })
      → 先当「很长」，滚动上限很大

2. 用户滑到首屏 → 文字库缺文字页 0 → request_page(0) → 下 JSON

3. parse_page → 数出真实 N 条 → commit_item → inflist_set_total_count(N)
      → 滚动上限变成 N，已 commit 的数据保留，不重新下载

4. 用户滑到 id 50+ → 文字库缺文字页 1 → request_page(1) → 再下/再 parse 该页 id 范围
```

换分类 / 换歌单：**`inflist_reset(估计值)`**（清库 + gen++ + 回顶），不是 `set_total_count`。

---

## 两个 API 别搞反

| 函数 | 何时用 |
|------|--------|
| `inflist_set_total_count(N)` | parse 完 JSON，**仅知道真实条数** |
| `inflist_reset(N)` | **换数据源**（分类、歌单），要清空重来 |

---

## 常见误解

1. **「JSON 只有 4 条，page_size 要不要改成 4？」** — 不要。改的是 `total_count`→4。
2. **「page_size=50 表示 API 每页 50 条」** — 在 libinflist 里表示**文字缓存页大小**；API 一次全量还是服务端分页，由业务 glue 在 `parse_page` 里适配。
3. **「parse 完 reset(N) 就行」** — `reset` 会清库重拉；parse 后收紧用 **`set_total_count(N)`**。
