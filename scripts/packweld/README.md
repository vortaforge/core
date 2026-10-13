# packweld

Generate **your own namespaced copy** of [macroEngine](https://github.com/vortaforge/core) and **guikit** as a
Java datapack, plus a Bedrock add-on. Python, standard library only. CLI, local web UI, or import it as a library.

Made for people who:

1. want a library inside their own pack without depending on macroEngine or managing a library,
2. don't want to merge macroEngine into their pack by hand,
3. don't want to install yet another library.

> **AI disclosure:** the generator code is AI-assisted (written by Claude, Anthropic) — see [CREDITS.md](CREDITS.md).
> The upstream pack code in `packweld/vendor/` is not AI-written and is not modified.

## What you get

```
out/
  java/<Name>-vX-datapack(.zip)      one datapack: macroEngine + guikit under YOUR namespaces
  java/<Name>-vX-resourcepack(.zip)  the macroEngine resource pack (text, sounds), renamed
  bedrock/<Name>-vX.mcaddon          behavior pack + resource pack
  bedrock/<Name>-vX-BP/RP(.mcpack)   the same, separately
```

Every Java pack contains `LICENSE`, `NOTICE.md`, `README.md` and `licenses/` (upstream Unlicense texts, upstream
READMEs, the PlayerAction **MIT** notice). You can add your own note (`--notice`).

## Quick start

```bash
python -m packweld ui                      # local web UI on http://127.0.0.1:8765
python -m packweld build --name "Acme Lib" --namespace acme --author "You"
python -m packweld build --name "Acme Lib" --namespace acme --modules api/store,systems/math --set hud_rate=5
python -m packweld modules                 # selectable modules, size, closure
python -m packweld config-keys             # runtime config knobs (type, range, default)
python -m packweld verify-vendor           # prove upstream code is byte-identical
python -m packweld init packweld.json      # starter config; then: build --config packweld.json
```

Library use:

```python
from packweld.config import BuildConfig
from packweld.build import build
rep = build(BuildConfig(name="Acme Lib", namespace="acme", modules=["api/store"], output_dir="out"))
print(rep.ok, rep.errors, rep.warnings, rep.outputs)
```

## What can be customised

* **Identity:** display name, namespace, GUI namespace/name, version, description, author, homepage, extra notice.
* **Content:** macroEngine / guikit / resource pack / docs on or off; pick macroEngine modules.
* **Runtime config:** any of the 54 macroEngine config keys, validated against the schema read from the upstream
  `config.mcfunction`; applied at load through the upstream `core/config/set` (generated `generated/apply_config`).
* **Formats:** `min_format`/`max_format` for datapack and resource pack, custom `pack.png`.
* **Options:** attribution comment on every `.mcfunction` (`--stamp-headers`), PlayerAction identifier isolation.
* **Bedrock:** module list, namespace, Script API versions, `min_engine_version`, GUI menus (JSON), open-item.

### How "same code" works

Upstream functions are copied as-is. Only these strings are rewritten, in one regex pass over file contents **and**
file paths: `macroengine` -> your namespace, `guikit` -> your GUI namespace, display names, the two
`vortacraftmc.*` fake-player prefixes, and (optionally) `player_action` -> `<ns>_pa`. A test masks the new names and
compares all ~1,390 generated `.mcfunction` files with upstream.

### How module selection works

macroEngine is selected by module (`api/store`, `systems/hook`, ...). The generator builds a static reference graph
(`ns:path` tokens in every function/tag/advancement/predicate/...; `ns:dir/$(x)` means "everything below dir") and keeps
the selection plus whatever it needs, plus the always-on load/tick core. A kept reward function keeps its advancement.
A tag keeps all its entries. After the build a verifier fails on **new** dangling references and on leftover upstream names.

## Bedrock add-on: read this

Bedrock has no data storage, no function macros, no item components, no `execute if items`. The Java datapacks cannot be
transpiled. The add-on is a **separate Script API implementation of a portable subset** (`store`, `math`, `string`,
`rng`, `perm`, `rate_limit`, `toggle`, `cb`, `hook`, `title`, `gui`) driven by
`/scriptevent <ns>:<module>.<function> {json}`, with guikit-style menus rendered as `ActionFormData` forms.
The Java `input/`, `api/cmd`, geo, uuid, wand and interaction systems are **not** ported.

## Limits you should know

* Not verified in a live Minecraft client. Static checks and mocked-API tests only (`python -m unittest discover -s tests`).
  Load the pack and read `latest.log`; for Bedrock check the content log.
* Java target: **26.3 only** (pack format 121). Older versions need a backport of the upstream code, not a rename.
* Upstream macroEngine ships ungated command wrappers (`api/cmd/*`, `api/perm/exec|run`): anyone able to call a function
  can run what it wraps. Meant for server admins and map makers on servers/maps they control. Don't hand those functions
  untrusted text. Prune `api/cmd` and `api/perm` if you don't need them.
* Upstream bug (also present in your output, not changed because the code is kept as-is): `events/fire_queued` queues
  `events/internal/fire_deferred`, which does not exist. `packweld doctor` lists such findings.
* Bedrock: dynamic-property limits, the exact `@minecraft/server` / `server-ui` versions (default 2.0.0) and
  `min_engine_version` (default 1.21.130) are configurable and unverified against your game version.
* The UI binds to 127.0.0.1 and rejects foreign `Host`/`Origin`. Don't expose it on a network; it has no authentication.

## Layout

```
packweld/            config, index (reference graph), rename, java, bedrock, verify, build, cli, ui_server
packweld/vendor/     upstream packs, untouched + MANIFEST.sha256
packweld/bedrock_js/ Script API modules (templates)
tests/               Python tests + Node tests with a mocked @minecraft/server
```
