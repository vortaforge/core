# macroEngine (v26.3)

**macroEngine** is a macro/module framework datapack for Minecraft Java Edition, providing a large library of reusable command-based systems (math, string, NBT, geo, permissions, UUID cache, hooks, rate limiting, and more) plus a multi-source text/value input system (books, signs, lecterns, name tags, command block minecarts).

> **Project history:** originally developed under the `runtoolkit` organization (`runtoolkit/suite`), later moved to `vortacraftmc`. Both organizations are now archived — kept online and publicly visible, never deleted, but no longer maintained. Active development moved to **VortaForge**, which is itself temporarily archived as of October 2026 while maintainer/process changes (see below) are completed; nothing in this history was deleted or hidden.
>
> Minecraft: **26.3** (`min_format` / `max_format` **121.0**)
>
> License: Unlicense (third-party components listed in [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md))
>
> Namespace: `macroengine`
>
> AI disclosure: portions of this pack's code, documentation and refactoring were produced with AI assistance. This is stated explicitly rather than left to the commit author field — see [`CREDITS.md`](../../CREDITS.md) if present, or the repository's AI-disclosure notes. This is not a statement that every line was AI-written, only that AI assistance was used in this project's development and is not being concealed.

---

## Features

![macroEngine layers](docs/media/architecture.svg)

- **API layer** (`api/`) — stable public entry points: `cmd`, `cb` (callback queue), `color`, `gamerule`, `interaction`, `item`, `macro`, `perm`, `store`, `title`, `toggle`, `trigger`, `wand`, plus `block` (custom block entity interface) and `container` (slot and inventory helpers)
- **Systems layer** (`systems/`) — internal utility modules: `math`, `string`, `nbt`, `logic`, `geo`, `flag`, `hook`, `log`, `rate_limit`, `sound`, `uuid`, `color`
- **Input system** (`input/`) — capture player-provided values via writable book, sign, lectern, name tag, or command block minecart, with shared validation (`input/validate`) for int/float/bool/tag-safe strings
- **Toggle system** — per-module runtime enable/disable for `cb`, `perm`, `geo`, `wand`, `interaction`, `hook`, `block`, and `container` modules (`block` and `container` are the two load gates of the new API: `function macroengine:api/toggle/<module>/false` closes one)
- **Rate limiting** — global, per-player, and per-channel request throttling
- **Hook system** — bind functions to fire on events such as block break, dimension change, and advancement grant
- **Item modifiers** (`item_modifier/`) — reusable `item_modifier` definitions for enchanting, glint, lore, tooltip, and rename operations
- **Advancement-driven triggers** (`advancement/`) — core, hidden, and system advancements used to drive internal logic and hooks
- **Command conditions and nested groups** (`api/cmd/other/multi_cmd/`) — queue entries accept a `condition` object with boolean composition (`all_of`, `any_of`, `not`, nestable to depth 8) and a `commands` list that expands in place, so a group can be gated as a unit. Leaves: `tag`, `score` (target and bounds now optional), `predicate`, `entity`, `storage` (existence), and `data` (numeric range). Every leaf fails closed — a missing required key or an unreadable path reports *not passed* rather than silently passing
- **Deterministic RNG** (`systems/rng/`) — `seed`, `state`, `next`, `int`, `chance`, `pick`. Seeding makes randomised behaviour reproducible, which the previous generator could not do: it kept an undocumented `_rng_state` key with no way to set it. `systems/math/random` is now a thin wrapper over `systems/rng/int`, so there is one generator rather than two
- **Text-component rendering** (`systems/text/`) — helpers for NBT-backed components. On 26.1+ a `{"storage":...,"nbt":...}` component renders a string *with its quotes* and a number or boolean *with vanilla colouring* unless `interpret` and `plain` are both set. Every such component in this pack now sets both explicitly; `scripts/fix_text_components.py` at the repository root enforces it

- **Store module** (`api/store/`) — storage-based variables, per-player values, raw NBT helpers (`api/store/nbt/*`: `get`, `set`, `set_default`, `append`, `merge`, `remove`, `exists`, `count`, `copy`, `add`, `toggle`, `pop`, `shift` over any storage/path) and multilingual message templates (`render`, `render_all`, `convert`, `show`) that return plain strings; see [`docs/store.md`](docs/store.md). It replaced the old `api/data` and `api/placeholder` modules. Untrusted text is never substituted into a command or JSON string, so chat/sign/book input is safe. Migration notes: [`docs/migrating-from-data-api.md`](docs/migrating-from-data-api.md)
- **Title / action bar with tokens** (`api/title/*_p`, plus `clear`, `reset`, `times`; see [`docs/title.md`](docs/title.md)) — storage-driven (no quote/backslash breakage), rendered with `api/store/render` per recipient
- **Text UI** (`tui/`) — `line`, `header`, `divider` and `button` print formatted lines and clickable function buttons to the executor from storage (no text is pasted into a command); see [`docs/tui.md`](docs/tui.md)
- **Runtime config** (`core/config/*`, see [`docs/config.md`](docs/config.md)) — every behaviour knob is a validated key: module on/off switches, tick systems and rates, handler scan intervals, queue depth, template limits and token switches, title defaults, name length

---

## Requirements

- Minecraft Java Edition **26.3**
- Datapack `min_format`/`max_format`: **121**

---

## Installation

macroEngine is a datapack: it ships as a folder (or zip) that goes into a world's `datapacks/` directory. There is no separate "installer" — the steps below just cover different ways of getting the folder there and reloading it, for different setups.

### Singleplayer / any OS (manual, UI-based)

1. Download or clone this pack so you have the `macroEngine-Datapack-v26.3` folder (or a zip of it).
2. Open your world's folder and go into `datapacks/`. In the Minecraft world-select screen this is reachable via **Edit → Open World Folder**.
3. Copy the `macroEngine-Datapack-v26.3` folder in (or the zip — Minecraft can load zipped datapacks directly, no need to extract).
4. Load the world (or if already in it, run `/reload`), then run `/datapack list enabled` to confirm `macroengine` is listed.

### Linux / macOS (Bash)

```bash
# Run from the repository root
WORLD_DIR="$HOME/.minecraft/saves/YourWorldName"   # adjust to your world path
cp -r packs/macroEngine-Datapack-v26.3 "$WORLD_DIR/datapacks/"
```

For a dedicated server (any Linux distribution — Debian/Ubuntu, Fedora/RHEL, Arch, etc. — the steps are identical, since this only touches the world save, not the OS):

```bash
SERVER_WORLD_DIR="/path/to/server/world"
cp -r packs/macroEngine-Datapack-v26.3 "$SERVER_WORLD_DIR/datapacks/"
# Then, from the server console or an operator in-game:
#   /reload
```

### Windows (PowerShell)

```powershell
# Run from the repository root
$WorldDir = "$env:APPDATA\.minecraft\saves\YourWorldName"   # adjust to your world path
Copy-Item -Recurse -Path "packs\macroEngine-Datapack-v26.3" -Destination "$WorldDir\datapacks\"
```

For a Windows-hosted dedicated server, replace `$WorldDir` with the server's world directory and run `/reload` from the console or in-game as an operator afterward.

### Server install, in general

1. Copy the pack folder into the **world's** `datapacks/` directory on the server (not the server's root directory — datapacks are per-world).
2. Run `/reload` as an operator, or restart the server.
3. Run `/datapack list enabled` to confirm `macroengine` loaded without errors; check the server log for any function errors on load.
4. macroEngine initializes automatically via `#macroengine:events/on_load` — no further setup commands are required for the base install.

### Installing via Claude Code (or another coding agent)

If you're scripting the install (e.g. provisioning a test server, or doing it as part of a larger Claude Code task), the operation is just a directory copy plus a `/reload`; there is no build step for the datapack itself. For example, ask Claude Code to:

> "Copy `packs/macroEngine-Datapack-v26.3` from this repo into `<world-path>/datapacks/`, then tell me the server needs a `/reload` or restart to pick it up."

Claude Code (or any agent) can safely automate the file copy; it cannot run `/reload` for you unless it has console/RCON access to the running server — that step still needs an operator.

To check the default tick configuration, see `data/macroengine/function/config/`.

---

## Usage

Most functionality is exposed through the `public/` namespace, configuration through
`engine/config/`, and the reusable helpers through `modules/`, e.g.:

```mcfunction
function macroengine:public/perm/grant
function macroengine:public/wand/give {player:"Steve",tag:"my_wand",name:"Wand"}
function macroengine:modules/math/clamp {value:50,min:1,max:10}
function macroengine:engine/config/set          # data first: config_in {key,value}
```

> **FIX (v26.3-r1):** the previous README documented `macroengine:api/cmd/actionbar`,
> `macroengine:api/perm/grant`, `macroengine:api/wand/give`, `macroengine:systems/...`
> and `macroengine:core/config/set`. None of those paths exist in this build — every
> one of them answers `Unknown function`. The real paths are `public/`, `modules/`,
> `internal/`, `engine/` and `gameplay/`.

Internal systems under `internal/` are used by the public functions and are not intended to be called directly by end users, though they remain accessible for advanced/custom integrations.

---

## Notes

- This is the 26.3 build of macroEngine, derived from the earlier build in the archived `runtoolkit/suite` monorepo (`packs/macroEngine-Datapack-v26.3`). Development continues in `vortaforge/core`; do not file issues or PRs against `runtoolkit/*`.

---

## FAQ

> This section is based on a **static review** of the source (the code was read, not run in-game). Test on a staging server before deploying to production.

### Is it safe?

**Short answer:** no malicious content was found, but it is not safe to install blindly either. It is a powerful toolkit and can be dangerous if misused.

- **What is not in the pack:** the zip contains no `.jar`, `.exe`, scripts, `.git/` or `.env` files, only datapack files (`.mcfunction`, `.json`, `pack.png`). A datapack cannot open network connections or write to the server's file system on its own.
- **The real risk is the command-executing APIs.** Several functions run a caller-supplied string as a command (the `$execute ... run $(cmd)` pattern: `api/cmd/as_player`, `api/cmd/other/run_*`, `api/perm/run`, `api/perm/exec`, `core/lib/queue_add_cmd`, `core/lib/schedule_cmd`). Passing player-controlled text (sign, book, name tag) into them results in **command injection**.
- **The input system does not execute input.** Captured raw text is only written to the `macroengine:input` storage. Validate it with `input/validate/check` (`int`, `float`, `bool`, `tag_safe`) before using it.
- **There is no built-in protection.** The pack has no load gate or caller authorization. Any other datapack in the same world can call these functions (there is no isolation between datapacks).
- **Permission level:** everything runs at the server's function permission level.

### Can I install it on a server?

Yes. It is a purely server-side datapack, and players do not need any mods. Requirements:

1. **Version:** the pack targets `26.3` (pack format `121.0`).
2. **Text rendering:** use it together with `macroEngine-Resourcepack-v26.3`.
3. **Back up first** and try it on a test server.
4. **Removal:** delete the pack from the world's `datapacks` folder (Realms: re-upload the world without it). The pack no longer ships server-administration commands (`/datapack`, `/op`, ...).

### Is it paid?

No. The pack is released under the **Unlicense** (public domain): free, including commercial use, and no attribution is required. Two notes:

- This is not legal advice.

### How is the performance?

Not measured. From the code: while players are online, the `time`, `player` and `queue` systems run **every tick**, `hud` every 2 ticks and `admin` every 4 ticks. `player_systems` also runs NBT-filtered `execute as @e` / `kill @e` scans over all `item` entities every tick, so cost grows with the number of dropped items. Systems you do not use can be turned off with `systems/flag/toggle_system`.

### Screenshots and demos

<!--
In-game media is not included yet. Add real captures under docs/media/ and uncomment:

![Input capture via writable book](docs/media/input-book.gif)
-->

The diagrams above are generated from the source code. Real in-game captures (input capture) are not available yet.

## Known Issues

Verified on a real Minecraft **26.3** server (Java 25) while running this build — every
item below was reproduced, not read off the source.

- **Single target.** Minecraft Java 26.3 only (data pack format `121.0`).
- **First install is inert until someone approves it.** `#macroengine.open` is `0`
  after a fresh install because the permit gate (gate 2) has no score yet, so every
  function returns 0 and the pack does nothing. `gate/permit_tick` keeps running
  while closed, which is what makes the `/trigger macroengine.permit set 1`
  button work — approving from the console (`function macroengine:gate/approve`)
  is the operator path. The README line "no further setup commands are required for
  the base install" is therefore wrong.
- **`public/inventory/*` does not work.** `find_slot`, `has_item` and `move_stack`
  are wrappers around six `internal/inventory/_*` functions that are comment-only
  stubs. They used to return `slot:-1` / `count:0` / silence — indistinguishable
  from a real answer. They now return `supported:0b` plus an error string.
- **Command-executing APIs do not check who is calling.** `public/cmd/other/run_*`,
  `public/perm/run`, `public/perm/exec` and `cb` run a caller-supplied string. Feeding
  player-controlled text (sign, book, name tag) into them is command injection. The
  input system itself only writes to storage, so nothing in this pack does that on
  its own — but there is no authorization layer either.
- **`forceload add 0 0` on every load, removed by cleanup.** Cleanup removes `0 0`
  even when the server owner added it themselves. (The stray
  `forceload add -30000000 1600` that used to reserve chunk `[-1875000, 100]` forever
  has been removed in v26.3-r1.)
- **Reload-loop gate.** Six loads within 1200 ticks trips gate 5 and the pack stays
  inactive until `function macroengine:gate/clear_tripped`. Repeated `/reload` while
  setting a world up is enough to trigger it.
- **`time`, `player`, `queue` systems run every tick** while players are online;
  `player_systems` also runs NBT-filtered `execute as @e`/`kill @e` scans over all
  item entities every tick, so cost grows with dropped items.
- **Documentation rot.** `docs/*.md` still refer to `core/config/*`, `api/*` and
  `systems/*` paths that no longer exist. The `docs/` examples were not updated in
  this pass; use the `public/`, `modules/` and `engine/` paths.

## Changes in v26.3-r1 (this build)

Every fix below was verified in-game on 26.3 before and after.

| # | Where | Problem | Fix |
|---|-------|---------|-----|
| 1 | `internal/_api/cb/exec` | Callbacks were run by placing a real command block at (x,y,z) with `setblock` + `forceload`, then overwriting it with air 2t later. It destroyed whatever stood there, leaked the block when two callbacks fired in the same 2 ticks (shared `_cb_last`), and on 26.3 the command never ran at all (`SuccessCount: 0`) because an impulse command block with `auto:1b` does not execute on its own. | The command now runs via `execute positioned <x> <y> <z> run <cmd>` (`internal/_api/cb/run_cmd`). No blocks placed, no forceload, no race. `cb/reset*` became no-ops. |
| 2 | `modules/math/mod` | `divisor < 0` was caught by the `matches ..0` guard, so `mod(7,-3)` returned 0 (as if dividing by zero). | Divisor is folded to its absolute value (INT_MIN saturates), remainder stays positive. |
| 3 | `modules/math/pow` | Negative exponent fell through the loop guard and returned **1**, as if `n` were 0. | Negative exponent returns 0 and stops. |
| 4 | `modules/math/abs` | `abs(-2147483648)` returned `-2147483648` (32-bit overflow). | Saturates to `2147483647`. |
| 5 | `modules/math/clamp` | With `min > max` the value always ended at `max` (`clamp(5,10,1)` → 1). | Bounds are swapped first; `clamp(5,10,1)` → 5. |
| 6 | `engine/config/_set_int`, `_set_bool` | A non-numeric value was coerced: `data get` on a string returns its **length**, so `hud_rate="abc"` stored **3**, contradicting "wrong value types change nothing". | The value is type-checked by expanding it into a scoreboard command; strings, compounds and lists leave a sentinel and are rejected. |
| 7 | `internal/load/all` | `forceload add -30000000 1600` on every load, never removed; it really did reserve chunk `[-1875000, 100]` permanently. | Removed. |
| 8 | `modules/format/duration_words` | `text` was documented but never produced — the four `_duration_words_render*` functions were comment-only stubs. | Implemented: `72000t` → `"1h 0m"`, `1500t` → `"1m 15s"`, `30t` → `"1s"`. |
| 9 | `public/inventory/*` | Silent fake results (see Known Issues). | Fail closed with `supported:0b` and an explanatory `error` string. |
| 10 | `setup` | Every load printed `[MacroEngine] loaded` twice (`internal/load/final` also announces). | Duplicate removed. |

## License

- macroEngine original code: Unlicense (public domain) — see [`LICENSE`](LICENSE).
- String module (`core/lib/string`, `core/internal/text`): macroEngine original code.

Both files ship inside the distributed zip.
