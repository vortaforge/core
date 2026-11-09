# Removed dead code

Found by walking the call graph from every root: all functions outside `core/internal/`, function tags, advancements and JSON files.
Nothing live referenced any of the items below.

## Functions

| Function | Why it was dead |
|---|---|
| `core/internal/api/cmd/other/multi_cmd/exec` | Old raw executor, replaced by `exec_macro` |
| `core/internal/api/cmd/other/multi_cmd/exec_func` | Only called by `step_func` |
| `core/internal/api/cmd/other/multi_cmd/step_func` | Only called itself; replaced by `step` and `exec_func_macro` |
| `core/internal/core/queue/tick` | Never called; `tick_loop` was its only callee |
| `core/internal/core/queue/tick_loop` | Only called by `tick` and itself |
| `core/internal/systems/rate_limit/player_ensure` | Replaced by `player_check`, which `systems/rate_limit/check` calls |

## Scoreboard objectives

| Objective | Why |
|---|---|
| `macroengine.pre_version` | Created and removed at load, never read or written |

## Kept on purpose (unused, but not dead code)

- `core/internal/load/cleanup` and `core/internal/text/unload`: manual teardown tools.
- `core/internal/text/count` and `core/internal/text/has`: helper API of the text module.
- Predicates, loot tables, item modifiers and recipes: public assets for dependent packs, not referenced internally by design.

## Revived instead of removed

- `core/internal/events/fire_deferred`: `events/fire_queued` queued the wrong path (`events/internal/fire_deferred`), so a queued event never ran and the queue logged a missing-function error instead. The path now points at the real function. A queued event now fires when its delay ends, which is what `events/fire_queued` always promised.
