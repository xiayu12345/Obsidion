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
    })
  }
} catch {
  // Plugin index may be empty; mapFn is also patched into @quartz-community/explorer defaults.
}

const config = await loadQuartzConfig()
export default config
export const layout = await loadQuartzLayout()
