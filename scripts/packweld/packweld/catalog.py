# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
"""Human descriptions for selectable macroEngine modules (derived from upstream README/docs)."""

DESC = {
 "api/cb": "Callback queue: run, run_delayed, run_sequence, cancel, list",
 "api/cmd": "Wrappers for ~100 vanilla commands driven by macro arguments (ungated, admin tool)",
 "api/color": "Colour helpers", "api/dialog": "Dialog helpers",
 "api/gamerule": "Gamerule read/set helpers with callbacks", "api/interaction": "Interaction-entity binds",
 "api/item": "Item helpers (glint, lore, tooltip, rename, hidden flags)", "api/macro": "Macro helpers",
 "api/perm": "Tag/storage based permissions: grant, revoke, has, check, run, exec",
 "api/store": "Storage variables, per-player values, raw NBT helpers, message templates",
 "api/title": "Title / action bar with tokens", "api/toggle": "Per-module runtime on/off switches",
 "api/trigger": "Trigger objectives helpers", "api/wand": "Wand items bound to functions/commands",
 "systems/audit": "Audit record buffer", "systems/color": "Colour utils", "systems/flag": "Per-player and per-system flags",
 "systems/geo": "Regions, spheres, near-entity checks, region watch", "systems/hook": "Bind functions to ~18 game events",
 "systems/log": "Levelled logging", "systems/logic": "if_eq / gt / lt / and / or helpers",
 "systems/math": "Trig, vectors, lerp, gcd/lcm, weighted random ...", "systems/rate_limit": "Global / player / channel throttling",
 "systems/rng": "Deterministic seedable RNG", "systems/sound": "Sound helpers", "systems/string": "pad, format_coords, progress_bar ...",
 "systems/text": "NBT-backed text component helpers", "systems/uuid": "UUID cache store/recall/match", "systems/validate": "Input validation",
 "input/sign": "Capture text via sign", "input/lectern": "Capture text via lectern", "input/writable_book": "Capture text via writable book",
 "input/name_tag": "Capture text via name tag", "input/anvil": "Capture text via anvil",
 "input/command_block_minecart": "Capture text via command block minecart", "input/validate": "Shared int/float/bool/tag-safe validators",
 "player": "Player-side systems", "world": "World / entity systems", "events": "Event fire/register helpers",
 "data/predicates": "Public predicates (biome, weather, dimension, holding ...)", "data/loot_recipes": "Utility loot tables and recipes",
 "data/item_modifiers": "Item modifier definitions", "data/item_tags": "Item tags",
}


def describe(mod: str) -> str:
    return DESC.get(mod, "")
