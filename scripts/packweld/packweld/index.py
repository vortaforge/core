# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
"""Static reference graph of a datapack: which resource needs which.

Resources are indexed by (kind, id). Edges are found by scanning every text file for
`ns:path` tokens (with or without a leading '#'). This over-approximates (a token inside a
comment or a storage id that happens to equal a function id adds a harmless extra edge) and
never under-approximates for static references. A token that ends in '/' is a *prefix*
(the pack builds the id at runtime, e.g. `ns:api/cmd/$(type)`) and pulls in everything below it.
"""
from __future__ import annotations
import json, os, re
from collections import defaultdict
from pathlib import Path

Res = tuple  # (kind, "ns:path")

TAG_PREFIX = "tag_"


def _kind_and_id(ns: str, rest: list):
    """data/<ns>/<rest...>  ->  (kind, id) or None."""
    if not rest:
        return None
    if rest[0] == "tags" and len(rest) >= 3:
        kind, parts = TAG_PREFIX + rest[1], rest[2:]
    else:
        kind, parts = rest[0], rest[1:]
    if not parts:
        return None
    stem = "/".join(parts)
    stem = stem.rsplit(".", 1)[0] if "." in parts[-1] else stem
    return kind, f"{ns}:{stem}"


class PackIndex:
    def __init__(self, pack_root: Path, ns: str):
        self.root = Path(pack_root)
        self.ns = ns
        self.files: dict = {}        # Res -> Path
        self.edges = defaultdict(set)
        self.live_unresolved = []    # (file, line, token) outside comments
        self._tok = re.compile(r"(#?)(%s:[a-z0-9_./\-]+)" % re.escape(ns))
        self._scan()

    # ---- indexing ------------------------------------------------------
    def _scan(self):
        data = self.root / "data"
        for nsdir in sorted(data.iterdir()):
            for dp, _, fs in os.walk(nsdir):
                for f in sorted(fs):
                    p = Path(dp) / f
                    rel = p.relative_to(nsdir).parts
                    r = _kind_and_id(nsdir.name, list(rel))
                    if r:
                        self.files[r] = p
        by_id = defaultdict(list)
        for (k, i) in self.files:
            by_id[i].append(k)
        self.by_id = by_id
        fn_ids = sorted(i for (k, i) in self.files if k == "function")
        self.adv_reward = {}
        for res, p in self.files.items():
            try:
                txt = p.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
            is_fn = res[0] == "function"
            for n, line in enumerate(txt.splitlines(), 1):
                is_comment = is_fn and line.lstrip().startswith("#")
                for m in self._tok.finditer(line):
                    hashed, tid = m.group(1) == "#", m.group(2).rstrip(".")
                    if tid.endswith("/"):                      # runtime-built id -> prefix
                        for i in fn_ids:
                            if i.startswith(tid):
                                self.edges[res].add(("function", i))
                        continue
                    hit = False
                    for k in by_id.get(tid, ()):
                        if hashed == k.startswith(TAG_PREFIX):
                            self.edges[res].add((k, tid)); hit = True
                    if not hit and not is_comment and "/" in tid and not hashed and not line[:m.start()].rstrip().endswith("storage"):
                        self.live_unresolved.append((str(p.relative_to(self.root)), n, tid))
            if res[0] == "advancement":
                try:
                    fn = json.loads(txt).get("rewards", {}).get("function")
                except ValueError:
                    fn = None
                if fn and ("function", fn) in self.files:
                    self.adv_reward[res] = ("function", fn)
        self.rev_adv = defaultdict(set)
        for adv, fn in self.adv_reward.items():
            self.rev_adv[fn].add(adv)

    # ---- queries -------------------------------------------------------
    def closure(self, roots, base=frozenset()) -> set:
        seen, stack = set(base), [r for r in roots if r in self.files]
        while stack:
            n = stack.pop()
            if n in seen:
                continue
            seen.add(n)
            stack.extend(self.edges.get(n, ()))
            stack.extend(self.rev_adv.get(n, ()))       # a kept reward function keeps its advancement
        return seen

    def base_roots(self):
        return [("tag_function", "minecraft:load"), ("tag_function", "minecraft:tick")]

    def module_of(self, res: Res) -> str | None:
        """Selectable module a resource belongs to; None = always-on core/base."""
        kind, rid = res
        path = rid.split(":", 1)[1]
        parts = path.split("/")
        if kind == "function":
            if parts[0] in ("api", "systems", "input") and len(parts) >= 3:
                return f"{parts[0]}/{parts[1]}"
            if parts[0] == "input" and len(parts) == 2:
                return f"input/{parts[1]}"
            if parts[0] in ("player", "world", "events"):
                return parts[0]
            return None
        return {"predicate": "data/predicates", "loot_table": "data/loot_recipes",
                "recipe": "data/loot_recipes", "item_modifier": "data/item_modifiers",
                "tag_item": "data/item_tags"}.get(kind)

    def modules(self) -> dict:
        mods = defaultdict(list)
        for res in self.files:
            if res[0] in ("function", "predicate", "loot_table", "recipe", "item_modifier", "tag_item"):
                m = self.module_of(res)
                if m:
                    mods[m].append(res)
        return dict(sorted(mods.items()))

    def select(self, modules, extra_roots=()) -> tuple:
        """Return (kept resources, {module: reason-count}) for a module selection."""
        mods = self.modules()
        unknown = [m for m in (modules or []) if m not in mods]
        if unknown:
            raise KeyError(f"unknown modules: {unknown}")
        base = self.closure(self.base_roots())
        roots = list(extra_roots)
        for m in modules:
            roots.extend(mods[m])
        kept = self.closure(roots, base)
        pulled = defaultdict(int)
        for res in kept - base:
            m = self.module_of(res)
            if m and m not in modules:
                pulled[m] += 1
        return kept, dict(pulled)
