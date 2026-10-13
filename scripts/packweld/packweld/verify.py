# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
"""Post-build static checks. Static only: nothing here runs Minecraft."""
from __future__ import annotations
import re, tempfile
from pathlib import Path
from .index import PackIndex
from .paths import ME_DP, GUI_DP, ME_NS, GUI_NS, VENDOR
from .rename import Renamer, build_rules

LEFTOVER = re.compile(rb"(?i)macroengine|guikit|vortacraft")
PLAYER = re.compile(r"scoreboard players (?:set|add|remove|operation|reset|get|enable) (\S+)")
SKIP_LEFTOVER = ("NOTICE.md", "README.md", "LICENSE")
SKIP_PREFIX = ("licenses/", "docs/")


def verify_datapack(cfg, fs) -> dict:
    errors, warnings = [], []
    # 1. leftover upstream names
    for p, b in fs.items():
        if p in SKIP_LEFTOVER or p.startswith(SKIP_PREFIX) or not p.endswith((".mcfunction", ".json", ".mcmeta")):
            continue
        if LEFTOVER.search(b) and p not in ("pack.mcmeta",):
            warnings.append(f"leftover upstream name in {p}")
    # 2. dangling references (compared with the upstream baseline)
    with tempfile.TemporaryDirectory() as td:
        fs.write_dir(Path(td))
        rn = Renamer(build_rules(cfg, macroengine=cfg.include_macroengine, guikit=cfg.include_guikit))
        for ns, up_root, up_ns, on in ((cfg.namespace, ME_DP, ME_NS, cfg.include_macroengine),
                                       (cfg.gui_ns, GUI_DP, GUI_NS, cfg.include_guikit)):
            if not on:
                continue
            base = {rn.text(t) for (_, _, t) in PackIndex(up_root, up_ns).live_unresolved}
            ix = PackIndex(Path(td), ns)
            new = sorted({t for (_, _, t) in ix.live_unresolved if t not in base})
            for t in new:
                errors.append(f"new dangling reference {t} (selection cut something it needs)")
            if base:
                warnings.append(f"{len(base)} dangling reference(s) already present upstream in {up_ns} (not caused by packweld)")
    # 3. fake player name length
    longest = 0
    for p, b in fs.items():
        if p.endswith(".mcfunction"):
            for m in PLAYER.finditer(b.decode("utf-8", "replace")):
                t = m.group(1)
                if t[0] in "#$" and "$(" not in t:
                    longest = max(longest, len(t))
    if longest > 40:
        errors.append(f"a scoreboard fake-player name is {longest} chars (> 40): use a shorter namespace")
    return {"errors": errors, "warnings": warnings, "longest_fake_player": longest}
