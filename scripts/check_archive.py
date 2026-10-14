#!/usr/bin/env python3
"""Validate archived/archive.json (stdlib only, no network, no code execution).

Checks: schema shape, unique ids, date format, that `path` exists when set and
sits inside archived/, and that `successor` (when set) is a repo path or the id
of another registry entry. Malformed entries (non-object project, non-list
`known_issues`, non-string `path`/`successor`) are reported as errors instead of
crashing the script. Mirrors the Gradle `checkArchive` task. Exit code 1 on any
error.
"""
import json, re, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
REG = ROOT / "archived" / "archive.json"
REQUIRED = ["id", "name", "kind", "status", "archived_on", "reason",
            "last_version", "license", "deploy", "successor"]
KINDS = {"datapack", "mod", "resourcepack", "script", "other"}
STATUS = {"archived", "frozen", "superseded"}
DEPLOY = {"not_recommended", "review_required", "ok"}
ALLOWED = set(REQUIRED) | {"minecraft", "path", "source_url", "known_issues"}

def main() -> int:
    errs = []
    try:
        data = json.loads(REG.read_text(encoding="utf-8"))
    except Exception as e:
        print(f"[check_archive] cannot read {REG}: {e}")
        return 1
    if not isinstance(data, dict):
        print("[check_archive] ERROR top level must be an object")
        return 1
    if data.get("schema_version") != 1:
        errs.append("schema_version must be 1")
    projects = data.get("projects")
    if not isinstance(projects, list):
        print("[check_archive] ERROR 'projects' must be an array")
        return 1
    archived_root = (ROOT / "archived").resolve()
    ids = {p.get("id") for p in projects if isinstance(p, dict)}
    seen = set()
    for i, p in enumerate(projects):
        if not isinstance(p, dict):
            errs.append(f"projects[{i}]: must be an object")
            continue
        tag = f"projects[{i}] ({p.get('id', '?')})"
        for k in REQUIRED:
            if k not in p:
                errs.append(f"{tag}: missing '{k}'")
        for k in p:
            if k not in ALLOWED:
                errs.append(f"{tag}: unknown field '{k}'")
        if p.get("id") in seen:
            errs.append(f"{tag}: duplicate id")
        seen.add(p.get("id"))
        if not re.fullmatch(r"[a-z0-9][a-z0-9._-]*", str(p.get("id", ""))):
            errs.append(f"{tag}: bad id")
        if p.get("kind") not in KINDS: errs.append(f"{tag}: bad kind")
        if p.get("status") not in STATUS: errs.append(f"{tag}: bad status")
        if p.get("deploy") not in DEPLOY: errs.append(f"{tag}: bad deploy")
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", str(p.get("archived_on", ""))):
            errs.append(f"{tag}: archived_on must be YYYY-MM-DD")
        if p.get("known_issues") is not None and not isinstance(p["known_issues"], list):
            errs.append(f"{tag}: known_issues must be an array")
        path = p.get("path")
        if path is not None and not isinstance(path, str):
            errs.append(f"{tag}: path must be a string or null")
        elif path:
            rp = (ROOT / path).resolve()
            if ROOT not in rp.parents:
                errs.append(f"{tag}: path escapes repo")
            elif not rp.exists():
                errs.append(f"{tag}: path '{path}' does not exist")
            elif archived_root not in rp.parents and rp != archived_root:
                errs.append(f"{tag}: archived project path must be inside archived/")
        succ = p.get("successor")
        if succ is not None and not isinstance(succ, str):
            errs.append(f"{tag}: successor must be a string or null")
        elif succ:
            if succ == p.get("id"):
                errs.append(f"{tag}: successor cannot be itself")
            elif not (ROOT / succ).exists() and succ not in ids:
                print(f"[check_archive] warn: {tag}: successor '{succ}' is neither a repo path nor a registry id")
    for e in errs:
        print(f"[check_archive] ERROR {e}")
    print(f"[check_archive] {len(seen)} project(s), {len(errs)} error(s)")
    return 1 if errs else 0

if __name__ == "__main__":
    sys.exit(main())
