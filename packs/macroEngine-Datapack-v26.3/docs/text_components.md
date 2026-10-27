# Text-component click/hover events in macroEngine

## The rule

The pre-1.21.5 JSON field names **`clickEvent`** and **`hoverEvent`** are out of
use in this pack and must not come back. Since snapshot 25w02a (Java Edition
1.21.5) the fields are **`click_event`** and **`hover_event`**, and most payload
keys changed with them ([Mojang, 25w02a](https://www.minecraft.net/en-us/article/minecraft-snapshot-25w02a),
[wiki: Text component format](https://minecraft.wiki/w/Text_component_format)).
A legacy name does not error in game — the component just renders without the
click/hover behaviour — which is exactly why the rule is enforced statically
(see *Enforcement* below) instead of by review alone.

## Payload keys (1.21.5+)

`click_event`:

| Action | Payload key | Notes |
| --- | --- | --- |
| `run_command` | `command` | `/` prefix optional; commands with disallowed characters no longer parse |
| `suggest_command` | `command` | |
| `open_url` | `url` | Must be a valid `http://`/`https://` URI or the component fails to parse |
| `open_file` | `path` | Client-side only; not usable from server-sent chat |
| `copy_to_clipboard` | `value` | The only action that kept `value` |
| `change_page` | `page` | Positive **integer** (was a string), books only |
| `show_dialog` | `dialog` | Added 1.21.6 |
| `custom` | `id` (+ optional `payload`) | Added 1.21.6 |

`hover_event`:

| Action | Payload | Notes |
| --- | --- | --- |
| `show_text` | `value` (text component) | Was `contents` before 1.21.5 |
| `show_item` | `id`, optional `count`/`components` | `contents` was inlined |
| `show_entity` | `id` (entity type), `uuid`, optional `name` | `contents` was inlined; old `type`→`id`, old `id`→`uuid` |

## Where macroEngine uses click events today

All of them are `run_command` with a `command` payload:

- `gate/consent_prompt`, `gate/permit_prompt` — shown to every player, so they
  click through `/trigger ...` (see the confirmation note below).
- `api/toggle/show`, `core/internal/tui/button_send` — operator surfaces;
  `button_send`'s `/function $(fn)` target is validated as data by
  `systems/validate/function_id` before it is ever pasted into a component.
- `core/internal/load/main` — load message.

## Two update-notes consequences worth knowing

**Confirmation prompts (1.21.6, 25w20a).** A `run_command` click whose command
cannot be parsed by the client or needs permission level above 0 (anything
starting `/function`, for example) now shows a confirmation screen before it
runs. For operator surfaces that is Mojang's intended anti-misclick behaviour,
not a bug. For prompts aimed at players without operator rights it is a dead
end, which is why the gate prompts use `/trigger` — keep it that way.

**Signs (26.3 Snapshot 4, data pack 111.0).** Signs and hanging signs no
longer execute click events contained in sign text, and text components on
newly placed signs are no longer resolved by default; the new per-sign boolean
`allow_op_features` restores the old behaviour
([Mojang, 26.3 Snapshot 4](https://www.minecraft.net/en-us/article/minecraft-26-3-snapshot-4)).
macroEngine is unaffected: its sign input (`input/sign`, `input/private/sign_*`)
only *reads* `front_text` of the sign the player is looking at, and the pack
never writes sign text. If a future feature wants clickable sign text, it has
to set `allow_op_features` deliberately — and update the guard test.

## Scope note

This rule is enforced for **macroEngine only**. TunnelScript still contains
`clickEvent`/`hoverEvent` on purpose: that pack is the Minecraft **1.19.2**
build (`pack_format: 10`, see its CHANGELOG), where the legacy names are the
only valid syntax. Do not "fix" it without porting the pack to a newer
Minecraft first.

## Enforcement

`scripts/tests/test_text_component_events.py` (repo root) fails if, anywhere
under this pack's `data/`:

- a legacy `clickEvent`/`hoverEvent` field name appears,
- a `click_event`/`hover_event` uses a legacy payload key (`value` where it was
  renamed, hover `contents`, a string `change_page` page, …),
- sign text fields are combined with a `click_event`, or
- the gate consent/permit prompts click through anything but `/trigger`.

Run it with the rest of the offline suite:
`python3 -m unittest discover scripts/tests`.
