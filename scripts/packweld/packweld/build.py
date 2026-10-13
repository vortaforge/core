# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
"""Orchestrator: config in, files + report out. Used by the CLI, the UI server and the library API."""
from __future__ import annotations
import re, shutil
from dataclasses import dataclass, field
from pathlib import Path
from .config import BuildConfig
from .java import build_datapack, build_resourcepack, BuildError
from .bedrock import build_bedrock, mcaddon, BedrockError
from .verify import verify_datapack


@dataclass
class Report:
    ok: bool = True
    outputs: list = field(default_factory=list)
    warnings: list = field(default_factory=list)
    errors: list = field(default_factory=list)
    info: dict = field(default_factory=dict)

    def to_dict(self):
        return self.__dict__


def slug(name: str) -> str:
    return re.sub(r"[^A-Za-z0-9._-]+", "-", name).strip("-") or "pack"


def build(cfg: BuildConfig, write: bool = True) -> Report:
    rep = Report()
    try:
        rep.warnings += cfg.validate()
    except ValueError as e:
        rep.ok = False; rep.errors.append(str(e)); return rep
    out = Path(cfg.output_dir)
    base = f"{slug(cfg.name)}-v{cfg.version}"
    artifacts = []     # (relative name, FileSet|bytes)
    try:
        if "java" in cfg.targets:
            dp, info = build_datapack(cfg)
            v = verify_datapack(cfg, dp)
            rep.warnings += v["warnings"]; rep.errors += v["errors"]
            rep.info["java"] = {**info, "files": len(dp), "longest_fake_player": v["longest_fake_player"]}
            artifacts.append((f"java/{base}-datapack", dp))
            if cfg.include_macroengine and cfg.include_resourcepack:
                artifacts.append((f"java/{base}-resourcepack", build_resourcepack(cfg)))
        if "bedrock" in cfg.targets and cfg.bedrock.enabled:
            parts = build_bedrock(cfg)
            rep.info["bedrock"] = parts["info"]
            artifacts.append((f"bedrock/{base}-BP", parts["bp"]))
            artifacts.append((f"bedrock/{base}-RP", parts["rp"]))
            artifacts.append((f"bedrock/{base}.mcaddon", mcaddon(cfg, parts)))
    except (BuildError, BedrockError, KeyError) as e:
        rep.ok = False; rep.errors.append(str(e)); return rep
    if rep.errors:
        rep.ok = False
    if write and rep.ok:
        out.mkdir(parents=True, exist_ok=True)
        for name, content in artifacts:
            dest = out / name
            dest.parent.mkdir(parents=True, exist_ok=True)
            if isinstance(content, bytes):
                dest.write_bytes(content); rep.outputs.append(str(dest)); continue
            if cfg.keep_dirs:
                if dest.exists():
                    shutil.rmtree(dest)
                content.write_dir(dest); rep.outputs.append(str(dest))
            if cfg.make_zip:
                z = dest.with_name(dest.name + (".mcpack" if name.startswith("bedrock/") else ".zip"))
                z.write_bytes(content.zip_bytes()); rep.outputs.append(str(z))
    return rep
