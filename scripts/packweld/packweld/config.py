# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
"""Build configuration: one dataclass, validated, JSON round-trippable."""
from __future__ import annotations
import json, re
from dataclasses import dataclass, field, asdict
from typing import Optional

NS_RE = re.compile(r"^[a-z][a-z0-9_]{1,23}$")
RESERVED_NS = {"minecraft", "realms", "bedrock", "mojang"}
# Display names end up inside JSON strings / tellraw text, so keep them boring.
DISPLAY_RE = re.compile(r"^[A-Za-z0-9 _.+&()\[\]!#@:,/-]{1,40}$")


class ConfigError(ValueError):
    pass


@dataclass
class BedrockConfig:
    enabled: bool = True
    namespace: Optional[str] = None          # defaults to the Java namespace
    modules: Optional[list] = None           # None = all bedrock modules
    server_version: str = "2.0.0"            # @minecraft/server  (stable track)
    server_ui_version: str = "2.0.0"         # @minecraft/server-ui
    min_engine_version: list = field(default_factory=lambda: [1, 21, 130])
    menus: list = field(default_factory=list)  # GUI menus (see bedrock/gui schema)
    gui_open_item: Optional[str] = None      # e.g. "minecraft:compass": use item to open menu
    gui_default_menu: Optional[str] = None
    single_mcaddon: bool = True


@dataclass
class BuildConfig:
    # identity
    name: str = "My Library"
    namespace: str = "mylib"
    gui_namespace: Optional[str] = None
    gui_name: Optional[str] = None
    version: str = "1.0.0"
    description: str = ""
    author: str = ""
    homepage: str = ""
    extra_notice: str = ""
    # content
    include_macroengine: bool = True
    include_guikit: bool = True
    include_resourcepack: bool = True
    include_docs: bool = True
    modules: Optional[list] = None           # None = every macroEngine module (faithful full copy)
    config_overrides: dict = field(default_factory=dict)
    isolate_player_action: bool = True
    stamp_headers: bool = False
    # pack formats
    min_format: list = field(default_factory=lambda: [121, 0])
    max_format: list = field(default_factory=lambda: [121, 0])
    rp_min_format: list = field(default_factory=lambda: [97, 1])
    rp_max_format: list = field(default_factory=lambda: [97, 1])
    icon: Optional[str] = None               # path to a custom pack.png
    # targets / output
    targets: list = field(default_factory=lambda: ["java", "bedrock"])
    output_dir: str = "out"
    make_zip: bool = True
    keep_dirs: bool = True
    bedrock: BedrockConfig = field(default_factory=BedrockConfig)

    # ---- derived -------------------------------------------------------
    @property
    def gui_ns(self) -> str:
        return self.gui_namespace or f"{self.namespace}_gui"

    @property
    def gui_display(self) -> str:
        return self.gui_name or f"{self.name} GUI"

    @property
    def bedrock_ns(self) -> str:
        return self.bedrock.namespace or self.namespace

    # ---- io ------------------------------------------------------------
    @classmethod
    def from_dict(cls, d: dict) -> "BuildConfig":
        d = dict(d)
        b = d.pop("bedrock", {}) or {}
        known = set(cls.__dataclass_fields__)
        bad = set(d) - known
        if bad:
            raise ConfigError(f"unknown config keys: {sorted(bad)}")
        bknown = set(BedrockConfig.__dataclass_fields__)
        bbad = set(b) - bknown
        if bbad:
            raise ConfigError(f"unknown bedrock keys: {sorted(bbad)}")
        return cls(bedrock=BedrockConfig(**b), **d)

    @classmethod
    def load(cls, path: str) -> "BuildConfig":
        with open(path, encoding="utf-8") as f:
            return cls.from_dict(json.load(f))

    def to_dict(self) -> dict:
        return asdict(self)

    def dump(self, path: str) -> None:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(self.to_dict(), f, indent=2, ensure_ascii=False)

    # ---- validation ----------------------------------------------------
    def validate(self) -> list:
        """Raise ConfigError on hard problems; return a list of warnings."""
        w = []
        def ns_ok(label, v):
            if not NS_RE.match(v):
                raise ConfigError(f"{label} '{v}' must match [a-z][a-z0-9_]{{1,23}}")
            if v in RESERVED_NS:
                raise ConfigError(f"{label} '{v}' is reserved")
        ns_ok("namespace", self.namespace)
        ns_ok("gui_namespace", self.gui_ns)
        if self.bedrock.enabled:
            ns_ok("bedrock namespace", self.bedrock_ns)
        if self.namespace == self.gui_ns:
            raise ConfigError("namespace and gui_namespace must differ")
        for label, v in (("name", self.name), ("gui_name", self.gui_display)):
            if not DISPLAY_RE.match(v):
                raise ConfigError(f"{label} '{v}': 1-40 chars, no quotes, backslash, $ or braces")
        for label, v in (("min_format", self.min_format), ("max_format", self.max_format),
                         ("rp_min_format", self.rp_min_format), ("rp_max_format", self.rp_max_format)):
            if not (isinstance(v, list) and len(v) in (1, 2) and all(isinstance(i, int) and i >= 0 for i in v)):
                raise ConfigError(f"{label} must be [major] or [major, minor]")
        if not re.match(r"^\d+\.\d+\.\d+$", self.version):
            raise ConfigError("version must look like 1.2.3")
        for t in self.targets:
            if t not in ("java", "bedrock"):
                raise ConfigError(f"unknown target '{t}' (java | bedrock)")
        if not self.targets:
            raise ConfigError("no targets selected")
        if not (self.include_macroengine or self.include_guikit):
            raise ConfigError("select at least one of macroEngine / guikit")
        if self.namespace in ("macroengine",) or self.gui_ns in ("guikit",):
            w.append("namespace equals the upstream name: it will clash with the real macroEngine/guikit pack if both are installed")
        if len(self.namespace) > 14:
            w.append("long namespace: some scoreboard fake-player names get close to the 40 char limit (checked at build time)")
        if "bedrock" in self.targets and not self.bedrock.enabled:
            w.append("bedrock target requested but bedrock.enabled=false: skipped")
        return w
