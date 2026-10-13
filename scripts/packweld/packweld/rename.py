# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
"""Namespace / branding rewrite. Only identifiers and display strings change; logic is untouched."""
from __future__ import annotations
import re


class Renamer:
    """One regex pass (no double replacement even if new names contain old ones)."""

    def __init__(self, rules: dict):
        # rules: literal old string -> new string. Longest first so specific beats generic.
        self.rules = dict(rules)
        keys = sorted(self.rules, key=len, reverse=True)
        self._re = re.compile("|".join(re.escape(k) for k in keys)) if keys else None
        self.count = 0

    def text(self, s: str) -> str:
        if not self._re:
            return s
        def sub(m):
            self.count += 1
            return self.rules[m.group(0)]
        return self._re.sub(sub, s)

    def path(self, p: str) -> str:
        return self.text(p)


def build_rules(cfg, *, macroengine: bool, guikit: bool) -> dict:
    X, Y = cfg.namespace, cfg.gui_ns
    r = {}
    if macroengine:
        r.update({
            "vortacraftmc.packs.macroengine": f"{X}.pack",
            "vortacraftmc.archivedpacks.macroengine": f"{X}.archived",
            "macroengine": X,
            "MACROENGINE": X.upper(),
            "MacroEngine": cfg.name, "macroEngine": cfg.name, "Macroengine": cfg.name,
        })
        if cfg.isolate_player_action:
            r["player_action"] = f"{X}_pa"
    if guikit:
        r.update({
            "guikit": Y, "GUIKIT": Y.upper(),
            "GUIKit": cfg.gui_display, "GuiKit": cfg.gui_display, "Guikit": cfg.gui_display,
        })
    return r
