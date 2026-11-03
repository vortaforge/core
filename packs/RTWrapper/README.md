# RTWrapper

> ⚠️ **Archived.** This pack is archived and no longer maintained. The `vortaforge/core` datapacks are being superseded by [Fabric](https://fabricmc.net/) mods. Existing worlds may depend on this pack; compatibility is not verified here, and no new features or fixes are planned.

> ⚠️ **Structural exception (audit 2026-10-07) — needs a maintainer decision.**
> This directory breaks three conventions that the rest of the repo follows, and
> fixing them means moving ~700 files, so it was deliberately **not** done
> automatically:
>
> 1. **There is no top-level `pack.mcmeta`.** The datapack root is nested at
>    `datapack/RTWrapper-Datapack/`, so `packs/RTWrapper` itself is not a
>    loadable pack. Every other entry in `packs/` is. The Gradle pack tasks
>    (`zipPacks`, `checkPacks`, `mergeDatapacks`) discover packs by locating
>    `pack.mcmeta`, so they see the nested directory, not this one.
> 2. **It contains historical Fabric source** (`rtwrapper-fabric/`) under
>    `packs/`. This old implementation is intentionally excluded from the
>    Gradle build; the separate `mods/rtwrapper-mod` source was removed in
>    the 2026-10-30 cleanup. No RTWrapper Fabric mod is currently built.
> 3. **It says "Archived" but is not registered.** `archived/archive.json` holds
>    one entry (`runtoolkit-suite`); this pack is not in it, and it still lives
>    under `packs/`. `checkArchive` fails for an entry that is registered as
>    archived while still under `packs/`, so the banner and the registry cannot
>    both be satisfied as things stand.
>
> Related: `packs/RTWrapper-v1.0.1` (format 121, not currently included in
> `merge-manifest.json`). The three naming schemes — no suffix, `-1.21.1` (Minecraft version) and
> `-v1.0.1` (semver) — are not consistent with each other.

RTWrapper is a datapack for Java Edition 26.3.

## Layout

```text
datapack/RTWrapper-Datapack/      Standalone datapack root
datapack/commands-26.3.json       Command wrapper manifest + command parameter names
README.md#rtwrapper-api-reference  API/storage protocol
```

## Datapack API quick start

Generated command wrappers use meaningful command-specific parameter names. There is no generated catch-all or generic numeric parameter API.

Provide the named parameters in the order listed for that command in `datapack/commands-26.3.json`. The dispatcher calls the exact `<command>_<N>` variant and does not append unused params.

```mcfunction
# /tp @s 0 80 0 via queued handler
data modify storage rtwrapper:api request set value {cmd:"tp",params:{target:"@s",x:"0",y:"80",z:"0"}}
function rtwrapper:api/run

# /give @s minecraft:stone 1 via direct API
data modify storage rtwrapper:api params set value {target:"@s",item:"minecraft:stone",count:"1"}
function rtwrapper:api/commands/give
```

> **Note:** The previous `scoreboard` example in this section used the objective `rtw.test`, which was tied to an external integration and was not sandboxed. That example has been removed and will not work if you try to reuse it as-is — build your own `scoreboard` payload from `datapack/commands-26.3.json` instead.

Named convenience wrapper example:

```mcfunction
# $give $(target) $(item)$(components) $(count)
data modify storage rtwrapper:api params set value {target:"@s",item:"minecraft:stone",components:"",count:"1"}
function rtwrapper:api/commands/give_item
```

Autotick usage:

```mcfunction
function rtwrapper:api/autotick/on

data modify storage rtwrapper:api request set value {cmd:"say",params:{message:"queued hello"}}
function rtwrapper:api/enqueue
```

Autotick processes one queued action per tick. Use `function rtwrapper:api/run` only for immediate full queue drain.

See [the API and storage protocol below](#rtwrapper-api-reference) for the full protocol and debug/silent controls.

## Safety

RTWrapper intentionally exposes privileged macro-command execution for trusted datapacks/admins. Do not copy untrusted player-controlled text into `rtwrapper:api request` or `rtwrapper:api params`.

## Known issue

Test functions (`api/commands/test`, `core/wrappers/internal/test`, and the `test_0`–`test_4` variants) were intended to be removed from the shipped datapack — they were loading on a normal client, which is not intended behavior. **This cleanup has not actually happened yet**: the files are still present in `datapack/RTWrapper-Datapack/data/rtwrapper/function/`. Treat them as unfinished/unsupported until they're removed in a future commit; do not rely on them.

These `test` variants are not on the `#minecraft:tick` path by default — they only run if something explicitly queues `cmd:"test"` (e.g. `test_4` drives `/test run ...`). Note that `/test` here is **vanilla Minecraft's own `/test` command** (present on any vanilla server, not exclusive to the GameTest framework), and its `test_block[mode=log]` logging behavior is not something RTWrapper implements — RTWrapper only forwards the macro parameters to it. If autotick is enabled and a caller repeatedly enqueues `cmd:"test"` with `action`/`test_name` params (accidentally or via injected input), each drain can trigger vanilla `/test`'s own tick/log behavior — including `test_block[mode=log]` writes — which is a real TPS and disk-growth risk under sustained/malicious queuing. This is not a default-tick issue; it's an injection/misuse-triggered one, consistent with the macro-injection risk already noted under Safety.


## Complete API reference

The following protocol text was moved from the former `docs/API.md`; examples and runtime behavior were not executed for this documentation migration.


<a id="rtwrapper-api-reference"></a>
<details>
<summary>RTWrapper API and storage protocol</summary>

# RTWrapper API

Namespace: `rtwrapper`
Target: Java Edition 26.3 / pack format 104.

## Storage protocol

Immediate execution uses `storage rtwrapper:api request` plus `rtwrapper:api/run`.

RTWrapper no longer uses a single `$(tail)` catch-all. Generated command wrappers use meaningful command-specific parameter names stored under `params`.

```mcfunction
# /tp @s 0 80 0 immediately
data modify storage rtwrapper:api request set value {cmd:"tp",params:{target:"@s",x:"0",y:"80",z:"0"}}
function rtwrapper:api/run

# /scoreboard players set #smoke rtw.test 1 immediately
data modify storage rtwrapper:api request set value {cmd:"scoreboard",params:{category:"players",action:"set",subject:"#smoke",objective:"rtw.test",value:"1"}}
function rtwrapper:api/run
```

`type` is accepted as an alias for `cmd`:

```mcfunction
data modify storage rtwrapper:api request set value {type:"give",params:{target:"@s",item:"minecraft:stone",count:"1"}}
function rtwrapper:api/run
```

For delayed/autotick execution, enqueue the request instead of running it immediately:

```mcfunction
data modify storage rtwrapper:api request set value {cmd:"say",params:{message:"queued hello"}}
function rtwrapper:api/enqueue
```

Parameter order is command-specific and recorded in `datapack/commands-26.3.json` under `command_params`. Examples:

```json
{
  "tp": ["target", "x", "y", "z", "rotation", "facing_mode", "facing_target", "facing_anchor"],
  "give": ["target", "item", "count"],
  "scoreboard": ["category", "action", "subject", "objective", "value", "operation", "source", "source_objective"]
}
```

Important rule: provide contiguous parameters in that command's order. The dispatcher detects the highest present meaningful name and calls the matching variant, so unused params are not appended to the final command.

The immediate handler flow is:

```text
rtwrapper:api/run
  -> api/enqueue when request exists
  -> core/run/run_actions
    -> core/wrappers/handler/main
      -> proc
        -> dispatch
          -> exec
            -> core/wrappers/internal/<cmd>
              -> core/wrappers/internal/variants/<cmd>_<N>
```

A generated variant looks like:

```mcfunction
$<command> $(meaningful_name_a) $(meaningful_name_b) ...
```

Put one token or one already-formatted Brigadier group in each parameter. For example, JSON/text messages can still be stored as one parameter value if Minecraft expects that parameter as one continuous component.

## Direct API command wrappers

You can also place parameters in `storage rtwrapper:api params` and call a direct API function:

```mcfunction
# /give @s minecraft:stone 1
data modify storage rtwrapper:api params set value {target:"@s",item:"minecraft:stone",count:"1"}
function rtwrapper:api/commands/give
```

The direct API copies `rtwrapper:api params` to runtime storage and invokes `core/wrappers/internal/<command>`, which chooses the correct `<command>_<N>` variant.

## Convenience named wrappers

The datapack still includes named examples for common macro use:

```mcfunction
# $tp $(target) $(x) $(y) $(z)
data modify storage rtwrapper:api params set value {target:"@s",x:"0",y:"80",z:"0"}
function rtwrapper:api/commands/tp_pos

# $tp $(target) $(x) $(y) $(z) $(rotation)
data modify storage rtwrapper:api params set value {target:"@s",x:"0",y:"80",z:"0",rotation:"0 0"}
function rtwrapper:api/commands/tp_pos_rot

# $give $(target) $(item)$(components) $(count)
data modify storage rtwrapper:api params set value {target:"@s",item:"minecraft:stone",components:"",count:"1"}
function rtwrapper:api/commands/give_item
```

For `give_item`, `components:""` is allowed because it is concatenated directly to `item`, not appended as a separate trailing token.

## vortacraftmc loaded-pack registry (not shipped)

> **Status (2026-10-29 audit):** the current RTWrapper tree does **not**
> include a `data/vortacraftmc/` namespace or a
> `vortacraftmc:api/status` function. Do not call that function against this
> pack. The material below is retained only as a historical interop design
> example; it is not a description of files shipped here.

The unshipped design used a shared `vortacraftmc` namespace for datapack discovery:

```text
data/vortacraftmc/function/core/load.mcfunction
data/vortacraftmc/function/core/tick.mcfunction
data/vortacraftmc/function/api/status.mcfunction
data/vortacraftmc/advancement/root.json
data/vortacraftmc/advancement/packs/rtwrapper.json
```

The visual registry uses advancements with the `minecraft:tick` trigger and does not revoke them. After `/reload`, open **Advancements > Installed Datapacks** to see loaded packs/modules.

Proposed status helper (not present in this tree):

```mcfunction
function vortacraftmc:api/status
```

Other vortacraftmc datapacks can add themselves by including a child advancement under the shared namespace, for example:

```text
data/vortacraftmc/advancement/packs/my_pack.json
```

Use this pattern:

```json
{
  "parent": "vortacraftmc:root",
  "display": {
    "icon": {"id": "minecraft:knowledge_book"},
    "title": {"text": "My Pack", "color": "green"},
    "description": {"text": "Loaded: My Pack"},
    "show_toast": false,
    "announce_to_chat": false,
    "hidden": false
  },
  "criteria": {
    "loaded": {"trigger": "minecraft:tick"}
  }
}
```

Do not add revoke functions for this registry; the goal is a persistent loaded-pack marker.

## Debug / silent

```mcfunction
function rtwrapper:api/debug/listen
function rtwrapper:api/debug/on
function rtwrapper:api/silent/off
function rtwrapper:api/status
```

`silent` suppresses RTWrapper's own debug/status tellraw output. It intentionally does not permanently toggle vanilla gamerules.

## Auto tick

Auto tick is disabled by default.

```mcfunction
function rtwrapper:api/autotick/on
function rtwrapper:api/autotick/off
```

Current behavior: autotick processes **one** action per tick by calling `core/run/run_next`. It does not recursively drain the whole queue. This avoids tick spikes and runaway recursion.

Recommended autotick usage for multiple actions:

```mcfunction
function rtwrapper:api/autotick/on

data modify storage rtwrapper:api request set value {cmd:"say",params:{message:"first queued action"}}
function rtwrapper:api/enqueue

data modify storage rtwrapper:api request set value {cmd:"say",params:{message:"second queued action"}}
function rtwrapper:api/enqueue
```

Each queued action will be processed on a later tick, one per tick. If you write a single `rtwrapper:api request` and do not enqueue it, autotick will still consume that one direct request on the next tick; however, multiple producers should use `api/enqueue` to avoid overwriting the shared request storage.

Use `function rtwrapper:api/run` only when you want immediate full drain.

## Security note

Every macro command runs with the permission/context of the function caller. Only write trusted strings into `rtwrapper:api request` or `rtwrapper:api params`.

</details>
