# Settings book (`api/settings/*`)

A writable book that shows the current gate/config values as editable
`Key: Value` lines; writing new values and submitting the book applies them.
It rides the existing input-book pipeline (`input/give_writable_book` +
`input/private/book_capture`) instead of inventing a second capture path: the
settings book is an input book with an extra `settings:1b` marker, and the
applier is registered as a listener in the `#macroengine:input/writable_book`
tag. Nothing is clickable - the settings are the text you write.

Cross-pack overview of the gate this configures:
`docs/dynamic-command-gate.md` in the repository root; the gate itself:
[cmd_gate.md](cmd_gate.md).

## Using it

```mcfunction
function macroengine:api/settings/book     # as an admin player; you get the book
# edit the values in the book, close it,
# switch the hotbar slot away and back     <- the tick capture submits it
function macroengine:api/settings/apply    # ... or apply at once while holding it
function macroengine:api/settings/status   # read-only live state in chat
```

The slot-switch submit is the input system's own one-shot rule: a held book
is captured once per hold session, and the session ends when the book leaves
the main hand. `api/settings/apply` reads the held book directly (all pages,
not only the capture's page 0) for operators who do not want to wait.

Everything is admin-only (`macroengine.admin` tag): the book is only given to
admins, a capture from a non-admin is silently ignored, and the manual apply
refuses non-admins. Applied and rejected lines are counted and printed back;
the rejected lines themselves land in `macroengine:settings result.errors`,
and every apply writes an audit entry (`settings.book_apply`).

## Grammar

One setting per line, `Key: Value`. Blank lines and lines starting with `#`
are comments. Keys are case-insensitive. Boolean values accept
`1/0`, `on/off`, `true/false`, `yes/no`, `enable/disable` (and
`approve/revoke` for the permit), case-insensitive. Applying an unchanged
book is a no-op, so re-submitting it is safe.

| Key | Values | Effect |
|---|---|---|
| `gate.1` .. `gate.5` | boolean | the pack's five gates, through the existing `gate/set/*_on|off` toggles (1 version, 2 permit, 3 per-player consent, 4 incomplete load, 5 reload loop) |
| `gate.permit` | boolean / `approve` / `revoke` | `gate/approve` or `gate/revoke`, only when the live permit score differs |
| `cmd_gate` | boolean | `1`/`on`: dynamic-command checks active; `0`/`off`: **cmd_gate disabled** (stored strings run unchecked - audited warning, see [cmd_gate.md](cmd_gate.md)) |
| `cfg.<key>` | per schema | *any* runtime config key from [config.md](config.md), converted from text and forwarded to the validated `core/config/set` (unknown keys refused, ints clamped, strings safe-checked) |
| `blocklist.add` | command root | adds a root to the cmd_gate blocklist if not already listed (lower-cased; spaces, quotes, backslashes and control characters refused) |
| `blocklist.remove` | command root | removes every copy of the root |
| `blocklist.reset` | boolean | `1` deletes the storage list, restoring the shipped defaults from `systems/cmd_gate/blocklist` |
| `blocklist.clear` | boolean | `1` empties the blocklist (an empty list is kept, so the defaults do **not** reseed) |

The prefilled book shows a useful subset (gates, permit, `cmd_gate`,
`cfg.dynamic_cmd`, `cfg.dynamic_cmd_max_len`, a few module/tick/queue keys)
snapshotted from the live scores and config storage at the moment it is
given. Any other `cfg.<key>` line works whether or not it is prefilled;
`macroengine:core/config/list` prints every key.

## Limits worth knowing

- Auto-apply refuses a book whose captured text trips the prompt-injection
  screen (see `prompt_injection.md`); the manual `api/settings/apply` is
  the deliberate override, and the line parser stays whitelist-based either way.
- The writable-book tick capture only guarantees page 0
  (`macroengine:input book.raw`). The settings apply reads the held item
  itself and therefore sees every page, but that only works because the
  capture fires while the book is still in hand; keep the whole menu in the
  given book rather than moving pages between books.
- A value containing a double quote or backslash cannot be normalised by the
  pack's text engine and is rejected. Settings values never need either.
- Keys are exact up to case: `gate.1` works, `gate .1` or `gate1` is reported
  as a rejected line. Values keep everything after the first `:` (so
  `blocklist.add: minecraft:fill` is fine), with leading spaces trimmed.
- `cfg.*` string keys keep their case; bool/int keys are numbers by the time
  `core/config/set` sees them, so an int key does not accept `on`.
- The whole flow sits behind the pack's own gates (open + consent), like
  every other function in the pack: on a closed pack the book capture still
  runs at the input layer, but the applier returns without changing anything.
- The book is an operator convenience on top of the real state (config
  storage + `vortaforge.gate` scores). It adds no new state of its own
  besides the last apply result in `macroengine:settings result`.
