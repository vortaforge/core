# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
from pathlib import Path

ROOT = Path(__file__).resolve().parent
VENDOR = ROOT / "vendor"
ME_DP = VENDOR / "macroengine_dp"
ME_RP = VENDOR / "macroengine_rp"
GUI_DP = VENDOR / "guikit_dp"
ASSETS = ROOT / "assets"

# Namespaces / identifiers used by the vendored upstream packs
ME_NS = "macroengine"
GUI_NS = "guikit"
