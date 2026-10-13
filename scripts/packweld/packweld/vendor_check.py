# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
import hashlib
from .paths import VENDOR


def verify_vendor() -> list:
    """Compare every vendored file with MANIFEST.sha256. Returns a list of problems (empty = byte-identical)."""
    problems, listed = [], set()
    for line in (VENDOR / "MANIFEST.sha256").read_text().splitlines():
        h, _, rel = line.partition("  ")
        listed.add(rel)
        p = VENDOR / rel
        if not p.exists():
            problems.append(f"missing {rel}")
        elif hashlib.sha256(p.read_bytes()).hexdigest() != h:
            problems.append(f"modified {rel}")
    for p in VENDOR.rglob("*"):
        if p.is_file() and p.name != "MANIFEST.sha256" and p.relative_to(VENDOR).as_posix() not in listed:
            problems.append(f"unlisted {p.relative_to(VENDOR).as_posix()}")
    return problems
