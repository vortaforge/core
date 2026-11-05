#!/usr/bin/env python3
"""Fix path-less `data remove storage <id>` lines for pre-1.20.2 packs.

Pack formats before 1.20.2 require a NBT path for `data remove storage`.
Whole-storage removal is rewritten as `data modify storage <id> set value {}`.

Usage:
    python scripts/fix_vf_macro_storage_remove.py            # dry run
    python scripts/fix_vf_macro_storage_remove.py --apply    # write changes
"""
import argparse
import re
import sys
from pathlib import Path

PACK_DIR = Path("packs/vf_macro")

# Matches only lines where the storage id is the last token (no NBT path).
# `head` keeps any prefix such as `$`, `execute ... run `, or indentation.
PATTERN = re.compile(r"^(?P<head>.*?)data remove storage (?P<id>\S+)\s*$")


def fix_line(line: str) -> str | None:
    """Return the rewritten line, or None if no change is needed."""
    m = PATTERN.match(line)
    if not m:
        return None
    return f"{m['head']}data modify storage {m['id']} set value {{}}"


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true", help="write changes")
    args = parser.parse_args()

    changed = 0
    for path in sorted(PACK_DIR.rglob("*.mcfunction")):
        original = path.read_text(encoding="utf-8").splitlines()
        updated = []
        file_changed = False
        for lineno, line in enumerate(original, start=1):
            new = fix_line(line)
            if new is not None:
                print(f"{path}:{lineno}\n  - {line.strip()}\n  + {new.strip()}")
                updated.append(new)
                file_changed = True
                changed += 1
            else:
                updated.append(line)
        if file_changed and args.apply:
            path.write_text("\n".join(updated) + "\n", encoding="utf-8")

    mode = "applied" if args.apply else "dry run"
    print(f"[fix] {changed} line(s) rewritten ({mode}).")
    return 0


if __name__ == "__main__":
    sys.exit(main())