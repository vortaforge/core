# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
from __future__ import annotations
from functools import lru_cache
from .catalog import describe
from .index import PackIndex
from .paths import ME_DP, ME_NS


@lru_cache(maxsize=1)
def _ix():
    return PackIndex(ME_DP, ME_NS)


def list_modules() -> list:
    ix = _ix()
    base = ix.closure(ix.base_roots())
    out = []
    for m, res in ix.modules().items():
        kept = ix.closure(res, base)
        out.append({"id": m, "functions": sum(1 for k, _ in res if k == "function"), "resources": len(res),
                    "closure": len(kept) - len(base), "desc": describe(m)})
    return out


def doctor() -> str:
    ix = _ix()
    L = ["Static findings about the vendored macroEngine 26.3 pack (not changed by packweld):", ""]
    live = sorted({(f, n, t) for f, n, t in ix.live_unresolved})
    for f, n, t in live:
        L.append(f"- {f}:{n} references {t}, which does not exist" + (" (probably a storage id, harmless)" if "/temp" in t else " (REAL dangling function reference)"))
    L += ["", f"Always-on base (load/tick closure): {len(ix.closure(ix.base_roots()))} resources of {len(ix.files)}."]
    return "\n".join(L)
