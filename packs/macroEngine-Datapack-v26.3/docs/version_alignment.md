# Version alignment

Current targets (also the folder names):

| Pack | Minecraft | Format |
| --- | --- | --- |
| `macroEngine-Datapack-v26.3` | Java Edition **26.3** (release) | data pack `min_format`/`max_format` **121.0** |
| `macroEngine-Resourcepack-v26.3` | Java Edition **26.3** (release) | resource pack `min_format`/`max_format` **97.1** |

## Minecraft 26.3 (audited 2026-10-28)

The pack was written against late 26.3 snapshots/pre-releases. This pass audited
both packs line-by-line against the breaking changes that landed across
26.3 Snapshot 1 – Snapshot 10 and Pre-Release 1 – 3 (Mojang's snapshot articles;
misode's [Technical Changelog](https://misode.github.io/changelog/), `breaking`
filter). Outcome: the code was already in release shape almost everywhere —
the snapshot-4 loot/predicate overhaul and the pre-release number-provider
split are used throughout — except for one older staleness the audit netted
(first row). Nothing else needed a code change.

| Area (snapshot) | Verdict |
| --- | --- |
| Entity attributes NBT — `attributes[{id}].base` (renamed back in 1.21, found via the block-state `Name`→`id` check below) | **Fixed.** `player/get_armor` and `player/get_health` read `Attributes[{Name:"…"}].Base`, which no longer resolves; `result`/`toughness`/`max` came back stale while `found` said 1b. Now the 1.21+ path. (Not a 26.3 change — pre-existing bug on the target version.) |
| Signs no longer run click events / resolve text by default; `allow_op_features`; `sign_text_front`/`back` components (Snapshot 4) | Clean — sign input only reads `front_text`/components. See `docs/text_components.md`. The `26.3-pre` header comments in `input/private/sign_capture` and `lectern_capture` now say release; the paths themselves did not change after pre-3. |
| Loot tables / item modifiers / predicates format overhaul (`type` instead of `function`/`condition`, singular `condition`/`modifier`, no list shorthand, `reference` removed, `block_state_property`→`match_block`; Snapshot 4) | Clean — 0 legacy keys under `data/`. |
| `set_loot_table` (`type` removed, `loot_table_id`; Snapshot 10), `exploration_map` (`destination` required, no map→filled_map conversion; Snapshots 4+7) | Not used. |
| Number providers: explicit `type` required (Snapshot 4); context int/float split, `sum`→`add` etc., `value_check`→`int`/`float_value_check` (Pre-1); `sum` operands (Snapshot 9) | Clean — no `{min,max}`/`{n,p}` shorthands in loot/item-modifier JSON; the one value check (`equals_uuid`) already uses `int_value_check` with `value`/`test`. (The `{min,max}` in `is_day`/`is_night` is a `time_check` range, not a provider.) |
| Advancement triggers: stricter entity fields (explicit `entity_properties`, `all_of`), renamed fields (`block`→`blocks`, `loot_table`→`loot_tables`, `recipe_id`/`recipe`→`recipes`), `brewed_potion` takes `potion_contents` (Snapshot 4); `potion_contents` component-predicate shape (Snapshot 3) | Clean — the three entity-field triggers already use `entity_properties`; none of the renamed-field triggers are used; `brewed_potion` carries no conditions. |
| Cooking recipes: `cookingtime` now required, smoker/blast times match furnace (Pre-1, Snapshot 4); `/recipe` drops `crafting_special` support (Snapshot 6) | Not applicable — the five `recipe/util/*` files are crafting recipes; no cooking recipes, no `/recipe` command use. |
| Brewing/furnace block entities: `BrewTime`/`Fuel`/cooking & lit timers widened to int, `speed_multiplier` added; `#brewing_fuel` item tag replaced by the `brewing_fuel` component (Snapshot 4) | Clean — no code reads those NBT fields or the removed tag (container code never touches fuel state). Note the NBT-pattern trap for the future: `{Fuel:0b}`-style patterns would stop matching an int field. |
| Block states in NBT/JSON: `Name`→`id`, `Properties`→`properties` (Snapshot 7) | Clean — no block-state compounds are written anywhere (the only `{Name:"minecraft:…"}` patterns were the attribute reads above). |
| Removed item components `swing_animation`, `map_color`; `exploration_map` drops `map_color` (Snapshot 7). `pot_decorations` + `decorated_pot` sherds now `{back,left,right,front}` item stacks; trim materials `asset_name`→`palette`, `override_armor_assets` removed (Snapshot 1) | Clean — none are referenced (decorated_pot appears only in the `containers` block tag). No trim-material registry entries ship in the datapack, and the resource pack has no equipment-asset JSONs, so the equipment `trim_palette_replacements`→`trim_overrides` change (Snapshot 6) has nothing to bite either. Palette textures already live at the new `textures/palettes/trim/` path. |
| Explorer-map structure tags renamed (`#on_*_explorer_maps` → `#on_*_mansion/monument/…_maps`); `#on_abandoned_camp_windswept`→`…_forest` (Snapshot 10, Pre-2) | Not used. |
| Commands: `/item` takes slot sources and `replace` now zips pairwise (use `fill` for the old "same item everywhere"); new `execute if slots` condition; `items` takes slot sources (Snapshot 1). `/publish` lost its gamemode argument (Snapshot 6) | Clean — all 15 `item replace`/`item modify` call sites are single-slot, so the zip semantics change nothing; string slot notation in `execute if items` is still valid; no `/publish`. |
| Commands: `/give` over-limit now signals an error; `/tick step` etc. signal errors; `team join`/`leave` result counts only entities whose team changed; tellraw caps `nbt` resolution at 64k (Snapshot 1) | No behaviour change for this pack — nothing stores the success/result of a `give` or a team wrapper, and `/tick` is unused. Noted here because wrappers (`player/team/*`) return those results to *callers*. |
| Resource pack: unused-core-shader removals (text backgrounds), block-model `shade` removed (Snapshots 8, 3), `item/filled_map_markings.png` removed, `map_color` tint source removed (Snapshot 7) | Clean — the resource pack ships no shaders, no models, no `minecraft`-namespace overrides at all; only `sounds.json`, two `lang` files (custom `item.macroengine.*` keys only) and trim/palette textures. |
| Worldgen (features, density functions, noise, biome spawners → environment attributes, …) | Not applicable — neither pack ships worldgen, dimension, enchantment, trade or dialog registries. |

## Guard

`scripts/tests/test_version_alignment.py` (repo root) pins the release formats
and fails on the legacy shapes above ever coming back: snapshot-era loot /
predicate / item-modifier keys, number-provider shorthands, removed types
(`value_check`, `block_state_property`, `reference`, `swing_animation`,
`map_color`, `#brewing_fuel`, the old explorer-map tags), capital-`Properties`
block states, `Attributes[{Name:…}]` reads, renamed advancement-trigger fields,
bare entity predicates in trigger `entity`/`player` fields, and the removed
resource-pack keys (`trim_palette_replacements`, `filled_map_markings`,
`map_color`).

## Next version bump — checklist

1. Read Mojang's snapshot articles for the target + misode's changelog with the
   `breaking` filter for every snapshot since the current target.
2. Re-run the audit greps per breaking item before touching formats.
3. Update both `pack.mcmeta` files **and** the pins in
   `scripts/tests/test_version_alignment.py` in the same change.
4. Add a dated section here with per-item verdicts, including "no code change"
   outcomes — the next auditor should not have to re-derive them.
