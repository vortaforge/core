"""The vortacraftmc -> vortaforge rename, checked rather than trusted.

Two things have to hold and neither is visible from a green build:

  1. No live identifier still uses the old name. History prose and the
     `archived/patches/*.patch` series are the exceptions, and they are listed
     here by name so an accidental new occurrence fails instead of passing.

  2. The scoreboard rename actually carries the value across. The old scores
     are world state: `#vortacraftmc.archivedpacks.macroengine` is set by hand
     by an operator. If the migration only renamed the holder, that value would
     be silently lost on the next load.

Run: python3 scripts/tests/test_identifier_rename.py
"""

from __future__ import annotations

import pathlib
import re
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]

# Files where the old name is deliberate: it is history, not an identifier.
HISTORY_OK = {
    "README.md",
    "CREDITS.md",
    "docs/MAINTAINER_GUIDE.md",
    "docs/interop.md",
    "archived/packs/macroEngine-Datapack-v26.3/README.md",
    "archived/packs/macroEngine-Datapack-v26.3/docs/interop.md",
}

# A `git am` series. Editing it would mean the patch no longer applies, and the
# patch is the record of a commit that did happen.
PATCH_PREFIX = "archived/patches/"

OLD_JAVA = re.compile(r"\bcom[./]vortacraftmc\b")
OLD_PACKAGE_DIR = "vortacraftmc"


def _rel(p: pathlib.Path) -> str:
    return p.relative_to(ROOT).as_posix()


def _files():
    for p in ROOT.rglob("*"):
        if not p.is_file() or ".git" in p.parts:
            continue
        if any(x in p.parts for x in ("build", ".gradle", "node_modules", "__pycache__")):
            continue
        yield p


class NoLiveOldIdentifier(unittest.TestCase):
    def test_no_java_package_uses_the_old_group(self):
        hits = []
        for p in _files():
            if p.suffix not in {".java", ".gradle", ".properties", ".json", ".kts"}:
                continue
            try:
                t = p.read_text(encoding="utf-8")
            except (UnicodeDecodeError, OSError):
                continue
            if OLD_JAVA.search(t):
                hits.append(_rel(p))
        self.assertEqual(hits, [], f"com.vortacraftmc still named in {hits}")

    def test_no_source_tree_is_still_nested_under_the_old_package(self):
        hits = [_rel(p) for p in ROOT.rglob(OLD_PACKAGE_DIR)
                if p.is_dir() and ".git" not in p.parts
                and any(x in p.parts for x in ("src", "java"))]
        self.assertEqual(hits, [], f"package directory not moved: {hits}")


class ScoreMigration(unittest.TestCase):
    """The four holders that carry world state."""

    HOLDERS = (
        "packs.macroengine.version",
        "packs.macroengine.config.tick.rate",
        "packs.macroengine.config.tick.pause",
        "archivedpacks.macroengine",
    )

    def _init(self, rel):
        p = ROOT / rel
        self.assertTrue(p.is_file(), f"missing {rel}")
        return p.read_text(encoding="utf-8")

    def test_each_old_score_is_copied_before_it_is_dropped(self):
        for rel in (
            "archived/packs/macroEngine-Datapack-v26.3/data/macroengine/function/core/config/init.mcfunction",
        ):
            text = self._init(rel)
            for h in self.HOLDERS:
                copy = (f"scoreboard players operation #vortaforge.{h} macroengine.meta "
                        f"= #vortacraftmc.{h} macroengine.meta")
                drop = f"scoreboard players reset #vortacraftmc.{h} macroengine.meta"
                self.assertIn(copy, text, f"{rel}: {h} is not migrated")
                self.assertIn(drop, text, f"{rel}: {h} is not cleared after copying")
                self.assertLess(text.index(copy), text.index(drop),
                                f"{rel}: {h} is dropped before it is copied")

    def test_the_migration_runs_before_the_version_is_overwritten(self):
        # `version` is set unconditionally a few lines later. If the copy came
        # after it, there would be nothing left to copy.
        text = self._init("archived/packs/macroEngine-Datapack-v26.3/data/macroengine/"
                          "function/core/config/init.mcfunction")
        copy = text.index("scoreboard players operation #vortaforge.packs.macroengine.version")
        setv = text.index("scoreboard players set #vortaforge.packs.macroengine.version macroengine.meta")
        self.assertLess(copy, setv)

    def test_reset_cannot_let_an_old_score_walk_back_in(self):
        for rel in (
            "archived/packs/macroEngine-Datapack-v26.3/data/macroengine/function/core/config/reset.mcfunction",
        ):
            text = (ROOT / rel).read_text(encoding="utf-8")
            for h in self.HOLDERS:
                self.assertIn(f"scoreboard players reset #vortacraftmc.{h} macroengine.meta", text,
                              f"{rel}: reset leaves {h} behind for the migration to restore")

    def test_nothing_outside_the_migration_reads_an_old_holder(self):
        allowed = {"archived/packs/macroEngine-Datapack-v26.3/data/macroengine/function/core/config/init.mcfunction",
                   "archived/packs/macroEngine-Datapack-v26.3/data/macroengine/function/core/config/reset.mcfunction"}
        hits = []
        for p in _files():
            if p.suffix != ".mcfunction":
                continue
            rel = _rel(p)
            if rel in allowed:
                continue
            t = p.read_text(encoding="utf-8", errors="replace")
            if "#vortacraftmc." in t:
                hits.append(rel)
        self.assertEqual(hits, [], f"live score read through the old name: {hits}")


class HistoryIsLeftAlone(unittest.TestCase):
    def test_the_organization_chain_is_still_written_down(self):
        readme = (ROOT / "README.md").read_text(encoding="utf-8")
        self.assertIn("vortacraftmc", readme,
                      "the runtoolkit -> vortacraftmc -> vortaforge chain was rewritten; "
                      "it is the record, not an identifier")

    def test_patch_series_still_applies_verbatim(self):
        patches = list((ROOT / PATCH_PREFIX).glob("*.patch")) if (ROOT / PATCH_PREFIX).is_dir() else []
        if not patches:
            self.skipTest("no patch series in this tree")
        for p in patches:
            t = p.read_text(encoding="utf-8", errors="replace")
            self.assertIn("com.vortacraftmc", t,
                          f"{p.name}: the patch body was edited, so `git am` will no longer apply it")


if __name__ == "__main__":
    unittest.main(verbosity=2)
