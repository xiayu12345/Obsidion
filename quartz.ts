// Explorer perf: inline script in @quartz-community/explorer dist must stay patched
// (trie cache + skip full DOM rebuild on nav). Re-apply from scripts/explorer-inline-perf.js
import { loadQuartzConfig, loadQuartzLayout } from "./quartz/plugins/loader/config-loader"

// Prefer TS override when plugin index is available.
try {
  const ExternalPlugin = await import("./.quartz/plugins/index.js")
  if (ExternalPlugin?.Explorer) {
    ExternalPlugin.Explorer({
      mapFn: (node: { slugSegments?: string[]; displayName: string }) => {
        const segs = node.slugSegments || []
        if (segs.length === 1 && (segs[0] === "h133" || segs[0] === "H133")) {
          node.displayName = "H133"
        }
        const i = segs.indexOf("开发记录")
        if (i >= 0 && i < segs.length - 1) {
          const name = node.displayName
          if (typeof name === "string" && /^\d{8}-/.test(name)) {
            node.displayName = name.replace(/^\d{8}-/, "")
          }
        }
        return node
      },
      sortFn: (a: { isFolder?: boolean; slugSegment?: string; displayName?: string }, b: { isFolder?: boolean; slugSegment?: string; displayName?: string }) => {
        const isH133 = (n: { slugSegment?: string; displayName?: string }) => {
          const seg = (n.slugSegment || "").toLowerCase()
          const name = n.displayName || ""
          return seg === "h133" || name === "H133"
        }
        const sink = (n: { slugSegment?: string; displayName?: string }) => {
          const seg = (n.slugSegment || "").toLowerCase()
          const name = n.displayName || ""
          let decoded = seg
          try { decoded = decodeURIComponent(seg) } catch {}
          return (
            seg === "工具目录" || seg === "驱动目录" ||
            name === "工具目录" || name === "驱动目录" ||
            decoded === "工具目录" || decoded === "驱动目录"
          )
        }
        const pin = (n: { slugSegment?: string; displayName?: string }) => {
          const seg = (n.slugSegment || "").toLowerCase()
          const name = n.displayName || ""
          return (
            seg === "板件与项目对照" ||
            name === "板件与项目对照" ||
            (seg.includes("%") && decodeURIComponent(seg) === "板件与项目对照")
          )
        }
        const ah = isH133(a), bh = isH133(b)
        if (ah && !bh) return -1
        if (!ah && bh) return 1
        const as = sink(a), bs = sink(b)
        if (as && !bs) return 1
        if (!as && bs) return -1
        const ap = pin(a), bp = pin(b)
        if (ap && !bp) return -1
        if (!ap && bp) return 1
        if ((!a.isFolder && !b.isFolder) || (a.isFolder && b.isFolder)) {
          return (a.displayName || "").localeCompare(b.displayName || "", undefined, {
            numeric: true,
            sensitivity: "base",
          })
        }
        if (!a.isFolder && b.isFolder) return 1
        return -1
      },
    })
  }
} catch {
  // Plugin index may be empty; mapFn is also patched into @quartz-community/explorer defaults.
}

const config = await loadQuartzConfig()
export default config
export const layout = await loadQuartzLayout()
