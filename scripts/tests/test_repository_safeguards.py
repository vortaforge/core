"""Focused, offline repository safeguards and their negative controls.

These tests replace selected local high-severity audit checks, not the old
GitHub/org audit. They never start or contact a Minecraft server.
"""
from __future__ import annotations

import json
import os
from pathlib import Path
import re
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[2]
SKIP_DIRS = {".git", ".gradle", ".toolchains", ".cache", "build", "node_modules", "__pycache__"}
NAMESPACE = re.compile(r"^[a-z0-9_.-]+$")
NBT_FILTER_AFTER_INDEX = re.compile(r"(?<=[\w\]])\[-?\d+\]\{")
QUOTED = re.compile(r'"(?:[^"\\]|\\.)*"|\'(?:[^\'\\]|\\.)*\'')
FUNCTION_CALL = re.compile(r"(?<![\w:#$])function\s+([a-z0-9_.-]+:[a-z0-9_./-]+)", re.I)
SECRET_PATTERNS = (
    ("GitHub fine-grained token", re.compile(r"github_pat_[A-Za-z0-9_]{20,}")),
    ("GitHub token", re.compile(r"gh[pousr]_[A-Za-z0-9]{36,}")),
    ("Slack token", re.compile(r"xox[baprs]-[A-Za-z0-9-]{10,}")),
    ("private key", re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----")),
    ("AWS access key", re.compile(r"AKIA[0-9A-Z]{16}")),
)
BINARY_EXTENSIONS = {".jar", ".class", ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".zip", ".gz",
                     ".7z", ".ogg", ".mp3", ".mp4", ".ttf", ".otf", ".woff", ".woff2", ".nbt", ".dat", ".pdf"}


def walk_files(root: Path):
    for current, dirs, files in os.walk(root, followlinks=False):
        dirs[:] = sorted(d for d in dirs if d not in SKIP_DIRS and not Path(current, d).is_symlink())
        for name in sorted(files):
            path = Path(current, name)
            if not path.is_symlink():
                yield path


def pack_roots(packs: Path):
    return sorted(p.parent for p in walk_files(packs) if p.name == "pack.mcmeta")


def format_pair(value):
    if isinstance(value, int) and not isinstance(value, bool) and value >= 0:
        return value, 0
    if (isinstance(value, list) and len(value) == 2 and
            all(isinstance(x, int) and not isinstance(x, bool) and x >= 0 for x in value)):
        return tuple(value)
    raise ValueError(f"invalid pack format: {value!r}")


def validate_layout(packs: Path):
    problems = []
    if not packs.is_dir():
        return ["packs directory is missing"]
    for child in packs.iterdir():
        if child.is_dir() and (child / "data").is_dir() and not (child / "pack.mcmeta").is_file():
            problems.append(f"{child}: data directory has no pack.mcmeta")
    for pack_root in pack_roots(packs):
        meta = pack_root / "pack.mcmeta"
        try:
            doc = json.loads(meta.read_text(encoding="utf-8"))
            pack = doc["pack"]
            if not isinstance(pack, dict):
                raise ValueError("pack is not an object")
            low = format_pair(pack.get("min_format", pack.get("pack_format")))
            high = format_pair(pack.get("max_format", pack.get("pack_format")))
            if low > high:
                raise ValueError("minimum format exceeds maximum")
        except (OSError, UnicodeError, ValueError, KeyError, TypeError) as error:
            problems.append(f"{meta}: invalid metadata ({error})")
            continue
        data = pack_root / "data"
        if not data.is_dir():
            continue  # Resource packs have assets instead of data.
        for ns in sorted(p for p in data.iterdir() if p.is_dir()):
            if not NAMESPACE.fullmatch(ns.name):
                problems.append(f"{ns}: invalid namespace")
            singular, plural = ns / "function", ns / "functions"
            if singular.is_dir() and plural.is_dir():
                dead = plural if low[0] >= 48 else singular
                if any(p.suffix == ".mcfunction" for p in walk_files(dead)):
                    problems.append(f"{ns}: both function and functions directories contain incompatible files")
            tags = ns / "tags"
            if not tags.is_dir():
                continue
            if (tags / "function").is_dir() and (tags / "functions").is_dir():
                problems.append(f"{tags}: both function tag directory spellings exist")
            for file in walk_files(tags):
                if file.suffix == ".mcfunction":
                    problems.append(f"{file}: function file is inside tags")
                elif file.suffix == ".json":
                    try:
                        tag = json.loads(file.read_text(encoding="utf-8"))
                        if not isinstance(tag, dict) or ("values" in tag and not isinstance(tag["values"], list)):
                            raise ValueError("tag must be an object with list-valued values")
                    except (OSError, UnicodeError, ValueError) as error:
                        problems.append(f"{file}: invalid tag ({error})")
    return problems


def index_functions(roots):
    functions, tags = set(), set()
    for root in roots:
        data = root / "data"
        if not data.is_dir():
            continue
        for ns in (p for p in data.iterdir() if p.is_dir()):
            for kind in ("function", "functions"):
                function_dir, tag_dir = ns / kind, ns / "tags" / kind
                if function_dir.is_dir():
                    for file in walk_files(function_dir):
                        if file.suffix == ".mcfunction":
                            functions.add(f"{ns.name}:{file.relative_to(function_dir).with_suffix('').as_posix()}")
                if tag_dir.is_dir():
                    for file in walk_files(tag_dir):
                        if file.suffix == ".json":
                            tags.add(f"{ns.name}:{file.relative_to(tag_dir).with_suffix('').as_posix()}")
    return functions, tags


def required_tag_reference_problems(roots):
    functions, tags = index_functions(roots)
    problems = []
    for root in roots:
        data = root / "data"
        if not data.is_dir():
            continue
        for ns in (p for p in data.iterdir() if p.is_dir()):
            for kind in ("function", "functions"):
                directory = ns / "tags" / kind
                if not directory.is_dir():
                    continue
                for file in walk_files(directory):
                    if file.suffix != ".json":
                        continue
                    try:
                        doc = json.loads(file.read_text(encoding="utf-8"))
                    except (ValueError, OSError, UnicodeError):
                        continue  # The layout test reports malformed JSON separately.
                    if not isinstance(doc, dict) or not isinstance(doc.get("values"), list):
                        continue
                    for value in doc["values"]:
                        if isinstance(value, dict):
                            if value.get("required") is False:
                                continue
                            value = value.get("id")
                        if not isinstance(value, str):
                            problems.append(f"{file}: invalid required tag value")
                            continue
                        is_tag = value.startswith("#")
                        identifier = value[1:] if is_tag else value
                        if ":" not in identifier:
                            identifier = "minecraft:" + identifier
                        if identifier not in (tags if is_tag else functions):
                            problems.append(f"{file}: required {'tag' if is_tag else 'function'} {value} is unresolved")
    return problems


def merged_function_reference_problems(packs: Path):
    try:
        manifest = json.loads((packs / "merge-manifest.json").read_text(encoding="utf-8"))
        include = manifest["include"]
        excluded = set(manifest.get("exclude", []))
        if not isinstance(include, list) or (not include and not manifest.get("allowEmpty", False)):
            raise ValueError("include must be a nonempty list unless allowEmpty is true")
        roots = []
        for entry in include:
            if not isinstance(entry, str) or entry in excluded:
                if not isinstance(entry, str):
                    raise ValueError("pack names must be strings")
                continue
            path = (packs / entry).resolve()
            if packs.resolve() not in path.parents or not (path / "pack.mcmeta").is_file():
                raise ValueError(f"included pack is missing or outside packs/: {entry}")
            roots.append(path)
    except (OSError, UnicodeError, KeyError, TypeError, ValueError) as error:
        return [f"merge manifest invalid: {error}"]
    functions, _tags = index_functions(roots)
    problems = []
    for root in roots:
        for file in walk_files(root):
            if file.suffix != ".mcfunction":
                continue
            for line_no, line in enumerate(file.read_text(encoding="utf-8").splitlines(), 1):
                if line.lstrip().startswith("#"):
                    continue
                for match in FUNCTION_CALL.finditer(line):
                    target = match.group(1).rstrip("/")
                    # Macro-generated destinations and Minecraft built-ins cannot be
                    # resolved from this repository's static files.
                    if target.startswith("minecraft:") or line[match.end():].startswith(("$", "%")):
                        continue
                    if target not in functions:
                        problems.append(f"{file}:{line_no}: unresolved merged function {target}")
    return problems


def invalid_nbt_path_lines(text):
    return [number for number, line in enumerate(text.splitlines(), 1)
            if not line.lstrip().startswith("#") and NBT_FILTER_AFTER_INDEX.search(QUOTED.sub('""', line))]


def secret_labels(text):
    return [label for label, pattern in SECRET_PATTERNS if pattern.search(text)]


class LiveTreeSafeguards(unittest.TestCase):
    def test_pack_metadata_layout_and_tag_shapes(self):
        self.assertEqual(validate_layout(ROOT / "packs"), [])

    def test_required_function_tag_values_resolve_somewhere_in_tree(self):
        self.assertEqual(required_tag_reference_problems(pack_roots(ROOT / "packs")), [])

    def test_merged_pack_static_function_references_and_manifest(self):
        self.assertEqual(merged_function_reference_problems(ROOT / "packs"), [])

    def test_invalid_nbt_filter_after_index_is_absent(self):
        problems = []
        for file in walk_files(ROOT / "packs"):
            if file.suffix == ".mcfunction":
                problems.extend(f"{file.relative_to(ROOT)}:{line}" for line in invalid_nbt_path_lines(file.read_text(encoding="utf-8")))
        self.assertEqual(problems, [])

    def test_dpgen_license_metadata_matches_its_existing_license(self):
        dpgen = ROOT / "scripts" / "dpgen"
        package = json.loads((dpgen / "package.json").read_text(encoding="utf-8"))
        lock = json.loads((dpgen / "package-lock.json").read_text(encoding="utf-8"))
        self.assertEqual(package["license"], "Unlicense")
        self.assertEqual(lock["packages"][""]["license"], package["license"])
        self.assertIn("free and unencumbered software", (dpgen / "LICENSE").read_text(encoding="utf-8"))

    def test_linter_license_and_dependency_notices_are_present(self):
        lint = ROOT / "scripts" / "datapack_lint"
        package = json.loads((lint / "package.json").read_text(encoding="utf-8"))
        lock = json.loads((lint / "package-lock.json").read_text(encoding="utf-8"))
        self.assertEqual(package["license"], "Unlicense")
        self.assertEqual(lock["packages"][""]["license"], package["license"])
        self.assertEqual((lint / "LICENSE").read_bytes(), (ROOT / "LICENSE").read_bytes())
        notices = (lint / "THIRD_PARTY_NOTICES.md").read_text(encoding="utf-8")
        for text in ("SPGoding and SpyglassMC contributors", "Microsoft Corporation", "Kevin Mårtensson", "MIT License"):
            self.assertIn(text, notices)

    def test_macroengine_mit_notice_is_present(self):
        pack = ROOT / "packs" / "macroEngine-Datapack-v26.3"
        notice = (pack / "THIRD_PARTY_LICENSES.md").read_text(encoding="utf-8")
        self.assertIn("MIT License", notice)
        self.assertIn("Copyright (c) 2022 Michael Weatherby", notice)
        self.assertTrue((pack / "LICENSE").is_file())

    def test_common_credential_shapes_absent_from_text(self):
        problems = []
        for file in walk_files(ROOT):
            if file.suffix.lower() in BINARY_EXTENSIONS or file.stat().st_size > 2_000_000:
                continue
            try:
                labels = secret_labels(file.read_text(encoding="utf-8"))
            except (UnicodeError, OSError):
                continue
            if labels:
                # Report only the path and type, never the matched secret.
                problems.append(f"{file.relative_to(ROOT)}: {', '.join(labels)}")
        self.assertEqual(problems, [], "possible credentials; inspect privately, not in public logs")


class NegativeControls(unittest.TestCase):
    def test_layout_detects_missing_metadata_bad_namespace_and_reversed_format(self):
        with tempfile.TemporaryDirectory(prefix="vorta-layout-") as tmp:
            packs = Path(tmp)
            (packs / "missing" / "data").mkdir(parents=True)
            broken = packs / "broken"
            (broken / "data" / "Bad Namespace").mkdir(parents=True)
            (broken / "pack.mcmeta").write_text('{"pack":{"min_format":10,"max_format":1}}', encoding="utf-8")
            self.assertTrue(any("no pack.mcmeta" in s for s in validate_layout(packs)))
            self.assertTrue(any("minimum format" in s for s in validate_layout(packs)))
            (broken / "pack.mcmeta").write_text('{"pack":{"min_format":1,"max_format":1}}', encoding="utf-8")
            self.assertTrue(any("invalid namespace" in s for s in validate_layout(packs)))

    def test_required_but_not_optional_missing_tag_is_rejected(self):
        with tempfile.TemporaryDirectory(prefix="vorta-tags-") as tmp:
            root = Path(tmp)
            tag = root / "data" / "minecraft" / "tags" / "function" / "load.json"
            tag.parent.mkdir(parents=True)
            tag.write_text('{"values":["demo:missing", {"id":"demo:optional","required":false}]}', encoding="utf-8")
            problems = required_tag_reference_problems([root])
            self.assertEqual(len(problems), 1)
            self.assertIn("demo:missing", problems[0])

    def test_missing_merged_function_is_rejected(self):
        with tempfile.TemporaryDirectory(prefix="vorta-merge-") as tmp:
            packs = Path(tmp)
            pack = packs / "demo"
            function = pack / "data" / "demo" / "function" / "run.mcfunction"
            function.parent.mkdir(parents=True)
            (pack / "pack.mcmeta").write_text('{"pack":{"pack_format":121}}', encoding="utf-8")
            (packs / "merge-manifest.json").write_text('{"include":["demo"]}', encoding="utf-8")
            function.write_text('function demo:missing\n', encoding="utf-8")
            self.assertTrue(any("demo:missing" in s for s in merged_function_reference_problems(packs)))
            function.write_text('$function demo:$(target)\n', encoding="utf-8")
            self.assertEqual(merged_function_reference_problems(packs), [])

    def test_nbt_path_rejects_unquoted_filter_after_index(self):
        self.assertEqual(invalid_nbt_path_lines('data get storage demo:x a[0]{foo:1}\n'), [1])
        self.assertEqual(invalid_nbt_path_lines('say "a[0]{foo:1}"\n# a[0]{foo:1}\n'), [])

    def test_secret_scan_detects_samples_without_returning_values(self):
        sample = "gh" + "p_" + "A" * 36
        self.assertIn("GitHub token", secret_labels(sample))
        self.assertNotIn(sample, secret_labels(sample))


if __name__ == "__main__":
    unittest.main()
