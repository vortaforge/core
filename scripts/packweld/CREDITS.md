# Credits and AI disclosure

## Who wrote what

| Part | Author | Licence |
|---|---|---|
| `packweld/*.py`, `packweld/ui/`, `packweld/bedrock_js/`, `tests/` | **Written by Claude (Anthropic), AI-assisted**, for the repository owner. Every such file carries an "AI-assisted" header. | Unlicense |
| `packweld/vendor/macroengine_dp/` (macroEngine datapack 26.3) | VortaForge / Runtoolkit (upstream) | Unlicense |
| `packweld/vendor/macroengine_rp/` (macroEngine resource pack 26.3) | VortaForge / Runtoolkit (upstream) | Unlicense |
| `packweld/vendor/guikit_dp/` (guikit datapack) | upstream guikit author | Unlicense |
| PlayerAction-derived code inside macroEngine (`player_action.*` identifiers, `core/internal/player/`) | Michael Weatherby (https://github.com/ICY105/PlayerAction) | MIT — notice in `packweld/vendor/macroengine_dp/THIRD_PARTY_LICENSES.md`, shipped in every output |

The vendored upstream trees are **not modified**. `packweld verify-vendor` compares each file with
`packweld/vendor/MANIFEST.sha256` (SHA-256).

## The Bedrock add-on

The generated Bedrock add-on is **not** a conversion of the Java datapacks. It is a separate JavaScript
(Script API) implementation written for this project by Claude (AI-assisted). It borrows module names and
behaviour ideas from macroEngine/guikit only.

## If you publish a fork

Keep this file and the "AI-assisted" headers. If you commit AI-written changes, say so in the commit message
and in this file, not only through the commit author name.
