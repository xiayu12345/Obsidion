#!/usr/bin/env python3
"""For Quartz content only: under **/开发记录/*/, if README.md exists and index.md does not, copy README → index so folder pages show the note instead of a bare listing. Does not modify vault source when CONTENT_ROOT is the build content dir."""
from __future__ import annotations
import shutil
import sys
from pathlib import Path

root = Path(sys.argv[1] if len(sys.argv) > 1 else "/workspace/quartz-build/content")
n = 0
for readme in root.rglob("README.md"):
    parts = readme.parts
    if "开发记录" not in parts:
        continue
    # entry folder: .../开发记录/<entry>/README.md
    try:
        i = parts.index("开发记录")
    except ValueError:
        continue
    if len(parts) < i + 3:
        continue  # skip 开发记录/README.md itself
    if parts[i + 1] == "README.md":
        continue
    folder = readme.parent
    index = folder / "index.md"
    if index.exists():
        continue
    shutil.copy2(readme, index)
    n += 1
    print(f"promoted {index.relative_to(root)}")
print(f"done: {n} index.md created")
