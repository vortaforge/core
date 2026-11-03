# VF Macro Backport

A VortaForge datapack intended to provide string-based macro substitution,
return-like flags and command execution for older Minecraft Java versions. Its
implementation is under `data/vf_macro/functions/`; it bundles an `ostr`
string library under `data/ostr/functions/`. The ordinary execution path uses
an in-pack command-block engine rather than a separately installed plugin.

**Status:** this document is based on static source inspection. No Minecraft
server, world or integration tests were run for this README. The earlier
1.19.3–1.20.1 compatibility claim has not been verified for every release.
`pack.mcmeta` declares **data-pack format 13**, whereas its description says
1.20–1.20.1. Mojang lists format 12 for Java 1.19.4 and 15 for Java 1.20;
the metadata and intended release range therefore need a maintainer review,
not an assumption that every version loads or behaves correctly. See the
[Mojang 1.19.4 notes](https://www.minecraft.net/en-us/article/minecraft-java-edition-1-19-4)
and [1.20 notes](https://feedback.minecraft.net/hc/en-us/articles/16499677456781-Minecraft-Java-Edition-1-20-Trails-Tales).

## Important safety and world changes

**Back up the world and review the source before enabling this pack.** This is
a privileged command-execution tool, not a sandbox. Never pass untrusted player
input, chat, book text or arbitrary storage content into a command template or
`vf_macro:in Command`. A substituted value can change the command that runs;
there is no demonstrated input isolation here. Command-block settings,
permissions and other installed packs matter.

The source has fixed, potentially destructive world locations:

- `vf_macro:core/load` force-loads chunk `0 0` in its execution dimension and
  creates a marker at `0 -64 0` if needed. Before execution,
  `vf_macro:core/engine/setup` uses `setblock ... replace` to put a command
  block at `0 -64 0`; it can overwrite an existing block. The engine writes
  the command into that block and turns `auto` on, then schedules a reset
  after three ticks. Do not assume simultaneous calls are isolated.
- The bundled `ostr:assets/reload` calls unload and load. Those functions
  affect the far-away chunk at `29999999 43392`, use a fixed marker UUID and
  modify blocks at `29999984 -64 43392` and `29999984 -63 43392`, including
  `fill ... barrier`, a sign and a lectern. This can overwrite world data and
  conflict with another copy or another pack using the same coordinates or
  UUID. `minecraft:load` invokes this reload.
- Load also creates/sets scoreboards and storage, including resetting
  `vf_macro:args`. Disabling or removing the pack does not by itself prove
  that blocks, force-loaded chunks, entities, scores and storage were cleaned
  up. Inspect the relevant functions before planning removal.

The examples below describe API inputs; they were **not executed**. Use only
in a disposable, isolated test world after separately reviewing the exact
Minecraft version and the fixed-location effects above. Do not run the
repository's Ward server script on a developer machine or production host.

## Installation and layout

The datapack root is this `packs/vf_macro/` directory, containing `pack.mcmeta`
and `data/`. A standalone copy must retain those at the root of the folder or
ZIP placed in the world's `datapacks/` directory. Use `/reload` only after the
safety review. The `minecraft:load` tag calls `vf_macro:core/load` and
`ostr:assets/reload`; loading itself changes world state as described above.

| Path | Role visible in source |
| --- | --- |
| [`pack.mcmeta`](pack.mcmeta) | Declares format 13 and describes version 1.4.2. |
| [`data/vf_macro/functions/api/`](data/vf_macro/functions/api/) | Public macro, data, return and conditional helper functions. |
| [`data/vf_macro/functions/core/`](data/vf_macro/functions/core/) | Private substitution and command-block engine implementation. |
| [`data/ostr/functions/`](data/ostr/functions/) | Bundled string and world-asset functions used by substitution. |
| [`data/ostr/LICENSE`](data/ostr/LICENSE) | MIT license and copyright notice for the bundled ostr code. |
| [`data/minecraft/tags/functions/load.json`](data/minecraft/tags/functions/load.json) | Load entry points for VF Macro and ostr. |
| [`LICENSE`](LICENSE) | Unlicense text supplied at the pack root. |

## Inputs, outputs and shared state

| State | Purpose |
| --- | --- |
| `vf_macro:in` | Inputs such as `template`, `replace_list`, `parts`, `source`, `data`, `value` and `Command`. |
| `vf_macro:args` | Shared argument compound; load and `api/data/clear` reset it. |
| `vf_macro:out` | Observable intermediate/result data such as `Command`, `resolved`, `return_value` and `return_success`. |
| `vf_macro:internal`, `vf_macro:engine` | Internal scratch/engine state; not a stable external interface. |
| `ostr:io`, `ostr:data` | Bundled string-library input/output and temporary state. |
| objective `vf_macro` | Flags including `#vf_macro.returned`, `#vf_macro.skip` and `#vf_macro.if_success`. |

State is shared, not scoped automatically to a caller. Clear or explicitly
replace stale inputs as appropriate, and account for repeated or concurrent
calls. In particular, a leftover `replace_list` is applied before the
convenience arguments during template substitution.

## Macro APIs

### Template substitution

Set a template and arguments, then call **`api/macro/template`**. The direct
`api/macro/run` function instead expects an already resolved `Command`; it does
not expand `template` by itself.

```mcfunction
# Commands shown for source/API review; not tested in a running game.
data remove storage vf_macro:in replace_list
data modify storage vf_macro:args name set value "Steve"
data modify storage vf_macro:args amount set value "5"
data modify storage vf_macro:in template set value "say Hello $(name), amount $(amount)"
function vf_macro:api/macro/template
```

The source applies explicit `vf_macro:in replace_list` entries of the form
`{key:"...",value:"..."}` first, then applies recognized argument names
from `vf_macro:args`. The convenience list in `core/macro/substitute` is
`name`, `amount`, `value`, `player`, `id`, `x`, `y`, `z`, `pos`, `cmd`,
`func`, `msg`, `text`, `count`, `score`, `target`, `selector`, `path`,
`storage` and `key`. Arbitrary argument-compound keys should not be assumed
to expand; use reviewed explicit replacement entries where needed.

`api/macro/with_storage` merges the compound in `vf_macro:in source` into
`vf_macro:args` and then calls the template API. It does not create a
separate per-call argument store.

### Structured parts

`api/macro/parts` reads a list of **compounds**, not a mixed NBT list of
strings and compounds. `{text:"..."}` contributes literal text;
`{key:"name"}` looks up a recognized argument; `{key:"...",value:"..."}`
uses the inline value. The source appends `$(missing)` for an unresolved key.

```mcfunction
data modify storage vf_macro:args name set value "Steve"
data modify storage vf_macro:args amount set value "5"
data modify storage vf_macro:in parts set value [{text:"say Hello "},{key:"name"},{text:", amount "},{key:"amount"}]
function vf_macro:api/macro/parts
```

The function resolves and joins the parts into a command and then invokes the
same privileged execution path. Inline values are not an escaping or security
boundary.

### Direct command string

```mcfunction
data modify storage vf_macro:in Command set value "say Hello!"
function vf_macro:api/macro/run
```

This path passes the supplied command string to the command-block engine.
A missing or empty `Command` sets the skip flag and reports an error in the
source. Do not use it with untrusted content.

## Return-like and conditional helpers

`api/return/success` sets the returned flag, output value `1` and success
`1b`; `api/return/fail` sets the flag, value `0` and success `0b`.
`api/return/value` reads `vf_macro:in value`, falling back to scoreboard
`#vf_macro.return_value` when present. For example, the source documents the
storage form as:

```mcfunction
data modify storage vf_macro:in value set value 5
function vf_macro:api/return/value
execute if score #vf_macro.returned vf_macro matches 1 run say returned
```

These helpers write state; they do not automatically stop the remainder of
an arbitrary caller function. Callers must deliberately guard subsequent
commands and inspect the flag/result. No equivalence to Minecraft's native
return semantics has been demonstrated.

`api/if_function/run` accepts a complete command string in
`vf_macro:in Command` and writes `#vf_macro.if_success`. Its fallback calls
`mce:api/run/cmd` when `mce:cmd Command` is present and the VF input is not;
that `mce` implementation is not part of this pack's tracked tree. Review
that optional integration and the timing of command-block execution before
relying on its result; behavior was not tested.

## Argument helpers

- `api/data/set` merges `vf_macro:in data` into `vf_macro:args`.
- `api/data/from_storage` merges `vf_macro:in source` into `vf_macro:args`.
- `api/data/from_score` stores scoreboard `#vf_macro.value` as integer
  `vf_macro:args.value`.
- `api/data/clear` resets the argument compound and sets `vf_macro:out cleared`.

These functions alter shared storage. Review type conversion and command
construction before using their results in command strings.

## Verification and licensing

This README corrects examples to match the entry points and data shapes visible
in source; it is **not** a successful build, security review or in-game test.
The Minecraft version range, pack metadata, command-block timing, reload,
cleanup and cross-pack interaction remain to be validated by a maintainer in
an appropriately isolated environment.

The root [`LICENSE`](LICENSE) contains the Unlicense. The tree also contains
bundled `ostr` code; verify its provenance and applicable third-party notices
before redistribution rather than assuming that the root file resolves every
component's licensing. Keep the existing notices and origin watermark intact.
