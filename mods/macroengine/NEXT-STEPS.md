# Next step: porting the engine to Java

The mod used to carry the macroEngine datapack inside its jar. That copy is gone. What remains in this repository is:

- the archived pack, at `archived/packs/macroEngine-Datapack-v26.3` — readable, disarmed, not built;
- this mod, which validates whatever packs a world loads and ships none of its own.

This page is a scope proposal for the step that comes next: making macroEngine an engine a server can run without a datapack at all. It is a proposal, not a plan of record, and nothing here is implemented.

## Why port instead of keeping the pack

A datapack cannot hold a permission model, cannot keep state that survives without a scoreboard, cannot read a config file, and cannot be tested without launching a server. Every one of those was a real limitation hit during the pack's life. The mod already has the pieces the pack lacked — a real registry, a real command tree, a logger — so the engine belongs on the Java side of the boundary.

The other reason is distribution. The mod was being removed from hosting platforms *because* it contained a datapack. A mod that is a mod, and a pack that is a pack the operator chose to install, are two separate things a platform can reason about.

## Scope

### 1. Core: command tree, state, config

Replace the pack's `core/*` with Java: a Brigadier tree registered under `/macroengine`, a state store, and a TOML config file in `config/macroengine/`. The pack's dispatcher and deferred queue exist because a function cannot re-enter itself; Java has no such constraint, so the queue does not get ported — it gets deleted.

*Done when:* a server can run `/macroengine version` and `/macroengine reload` with no datapack installed.

### 2. Permissions as real permission checks

The pack's `perm` module approximated permissions with scoreboard flags because a datapack has no other option. In Java this is a `PermissionNode` check against the command source, using the same level gate the existing commands already use.

**The gates must not come back in their old form.** The pack's five-gate layer (version, approval, consent, incomplete-load, reload-loop) was removed because it blocked honest users and read as closed while it was open. What replaces it is not a new gate: it is a permission check on a command that says who may run what. A denied command returns an error; it does not silently disable the engine.

*Done when:* a non-operator cannot run a destructive command, and the refusal names the node that was missing.

### 3. Modules as classes, not functions

The pack's 33 modules become Java classes behind a service loader, mirroring the `MacroModule` registry that exists today. The rule that made the pack split work — a module is independently installable — becomes a rule about jars: a module is a separate mod that registers itself and depends on the core.

This is the largest item and it does not need to happen in one step. The existing `MacroModule` ids (`vf_log`, `vf_report`, `vf_alert`, `vf_quarantine`) are already the right shape; the rest arrive one at a time.

*Done when:* removing a module jar leaves the engine running, which is the property the pack had and the one that has to survive the port.

### 4. Text, storage and the input system

The pack's text engine and storage are scoreboard-backed scratch space. Java has strings and maps, so most of `text/*` and `store/*` disappears into library code. What must be preserved is the validation contract: `input/validate/check`'s `tag_safe` rule is the thing that kept player-typed text out of command strings, and it has to exist in the port under the same name and the same behaviour.

*Done when:* the existing `SuspiciousText` scanner and the ported input validator agree on a corpus of test strings.

### 5. Keep the archived pack runnable

The pack stays in `archived/` and stays installable by hand. Nothing in the port may require it to be deleted, and nothing in the mod may silently ship it again — `scripts/repo/datapack_guard.py` now fails the build if `data/*/function/**.mcfunction` or `pack.mcmeta` reappears under `mods/`, which is the structural version of that promise.

*Done when:* the guard test fails on a deliberately planted pack and passes on the tree as it is.

## What this proposal deliberately does not include

- No port of the pack's dialog/consent flow. It was removed for a reason.
- No network access of any kind, ever. That boundary is what makes the rest of this mod reviewable.
- No automatic migration of a world's existing scoreboard state. That is a separate decision and needs its own discussion.
