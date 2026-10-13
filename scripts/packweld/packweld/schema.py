# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
"""Read the runtime-config schema + defaults straight out of the vendored config.mcfunction."""
from __future__ import annotations
import re
from .paths import ME_DP, ME_NS

_ENTRY = re.compile(r"(\w+):\{t:\"(bool|int|str)\"(?:,min:(-?\d+))?(?:,max:(-?\d+))?\}")
_DEFAULT = re.compile(r"config\.(\w+) set value (\S+)\s*$", re.M)


def config_schema() -> dict:
    text = (ME_DP / "data" / ME_NS / "function" / "config.mcfunction").read_text(encoding="utf-8")
    schema = {}
    for line in text.splitlines():
        if "config_schema merge value" not in line:
            continue
        for k, t, lo, hi in _ENTRY.findall(line):
            schema[k] = {"type": t, "min": int(lo) if lo else None, "max": int(hi) if hi else None, "default": None}
    for k, v in _DEFAULT.findall(text):
        if k in schema:
            schema[k]["default"] = v
    return schema


def snbt_value(key: str, value, schema: dict) -> str:
    """Validate an override against the schema and render it as SNBT."""
    if key not in schema:
        raise KeyError(f"unknown config key '{key}'")
    s = schema[key]
    t = s["type"]
    if t == "bool":
        if isinstance(value, str):
            value = value.lower() in ("1", "true", "yes", "on", "1b")
        return "1b" if value else "0b"
    if t == "int":
        v = int(value)
        if (s["min"] is not None and v < s["min"]) or (s["max"] is not None and v > s["max"]):
            raise ValueError(f"{key}={v} outside {s['min']}..{s['max']}")
        return str(v)
    v = str(value)
    if not re.fullmatch(r"[A-Za-z0-9_\-]{0,%d}" % (s["max"] or 16), v):
        raise ValueError(f"{key}: only [A-Za-z0-9_-] up to {s['max'] or 16} chars")
    return '"%s"' % v
