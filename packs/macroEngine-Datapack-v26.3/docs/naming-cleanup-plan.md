# macroEngine v26.3 naming cleanup: plan and migration notes

**Status:** implemented on branch `fix/macroengine-v26.3-naming-cleanup`. **Type:** bug fixes plus a breaking
rename. **Target:** Minecraft 26.3 (`pack_format` 121); no command syntax was changed.

AI disclosure: written and applied by Claude (Anthropic) from a prompt by the maintainer. Not yet reviewed.
See `CREDITS.md` for what was and was not verified.

## 1. Audit method

Static only (no Minecraft server was started, per `CLAUDE.md`):

- Inventory of every scoreboard objective, fake player, entity tag, storage id and `$(macro)` key in `data/`.
- Dangling-reference scan (functions, function tags, predicates, advancement rewards): 0 before, 0 after.
- Inline macro-call scan (`function id {k:v}` against the `$(k)` keys the callee needs).
- Objective scan (used but never `add`ed; added but never removed by `cleanup`).
- Mecha 0.101.0 over the pack (same ignore list as `scripts/lint_datapacks.sh`).

## 2. Bugs fixed

| # | Where | Problem | Fix |
|---|---|---|---|
| B1 | `world/entity/random*` | `macroengine.rnd_idx` was used but no loader ever created it, so every assignment failed. | Added to `loader/scoreboards`, removed in `cleanup`. |
| B2 | `systems/hook/raycast/found` | `events/fire {id:"hook.placed"}` passes `id` but the callee needs `$(event)`. The guard `#m_hook ...Flags` was never set anywhere, so the line was dead. Comment was Turkish. | Removed the dead legacy line; the live `core/internal/_systems/hook/fire` path is unchanged; English comment. |
| B3 | `core/internal/load/cleanup` | `anvil_t`, `food`, `health` objectives were added at load but never removed. | Added removals. Gate-owned objectives (`vortaforge.gate`, `permit`, `consent`) are intentionally left as they are. |
| B4 | `api/cmd/storage_set` vs `api/cmd/other/storage_set` | Same function twice with different keys (`storage`/`actionType` vs `storageName`) and a pointless `execute at @s`. | Kept `api/cmd/storage_set`; removed the duplicate; unified keys (see section 3). |

## 3. Breaking renames

Runtime identifiers change, so worlds that used the old names need the notes in section 4.

| Kind | Old | New |
|---|---|---|
| Objective | `macroengine.Flags` | `macroengine.flags` |
| Objective | `macroengine.rightClick` | `macroengine.right_click` |
| Trigger | `macroengine_run` | `macroengine.run` |
| Trigger | `macroengine_action` | `macroengine.action` |
| Entity tag | `macroengine_input` | `macroengine.input` |
| Entity tag | `rw.<id>` (region watch) | `macroengine.rw.<id>` |
| Fake players | 135 unprefixed names (`#cfg_v`, `#cb_cid`, `#tx_ok`, ... full list in the commit diff) | `#macroengine.<name>`; `#macroengine_item_*` and `#macroengine_gamerule_scratch` become `#macroengine.item_*` / `#macroengine.gamerule_scratch` |
| Fake players | `#macroengine.AnvilVis/Len/NumOk/TagHit/TagSafe` | `#macroengine.anvil_vis/len/num_ok/tag_hit/tag_safe` |
| Macro key | `$(storageName)` (`api/cmd/other/storage_reset`) | `$(storage)` |
| Macro key | `$(actionType)` (`api/cmd/storage_set`) | `$(action_type)` |
| Macro key | `$(command)` (`api/cmd/execute_if_pred`) | `$(cmd)` |
| Macro key | `$(customData)` (`player/inv/*`) | `$(custom_data)` |
| Macro key | `$(obj)` / `tmp.k.obj` (internal store token) | `$(objective)` / `tmp.k.objective` |
| Function | `api/cmd/other/storage_set` | removed (use `api/cmd/storage_set`) |

## 4. Migration

- **Triggers:** player-typed `/trigger macroengine_run` and `/trigger macroengine_action` become
  `/trigger macroengine.run` and `/trigger macroengine.action`. Update any book, sign, dialog or tellraw
  `run_command` text outside this pack that uses the old names.
- **Old objectives:** `loader/scoreboards` now removes the four legacy objectives on load, so they do not linger
  in `scoreboard.dat`. Their values are transient per-tick or per-click state, so nothing needs copying.
- **Leftover tags:** `core/internal/load/cleanup` also kills command-block minecarts still tagged
  `macroengine_input`. Players inside a region-watch region at upgrade time will see one extra "enter" event
  because their old `rw.<id>` tag no longer matches.
- **Callers of renamed macro keys** must pass the new key names (section 3).
- **Fake players** are internal scratch/state; nothing outside the pack should read them.

## 5. Deliberately not changed

- `perm.<name>` entity tags: permission grants are stored on players, so renaming would silently drop every
  grant in existing worlds. Needs a per-player migration function first.
- `$name` scratch fake players (about 300, used mainly in `systems/math` and `systems/string`): kept as the
  documented convention for scratch values on `macroengine.tmp`; `#macroengine.<name>` is for state/constants.
- `fn` vs `func` macro key: `fn` is also a storage field shared by the queue, TUI and block registry, so renaming
  it needs a storage-schema migration, not a text rename.
- `macroengine:input customData` storage field, odd storage ids (`_item_tmp`, `rl_work`, `tmp`,
  `core/internal/_player/temp`), and everything under `core/internal/_player/` (PlayerAction code, see
  `playeraction-rewrite-plan.md`).
- Gate version number (`#macroengine.version`): not bumped; maintainer decision.
