# vortaforge/core

Monorepo for VortaForge: Fabric mods, Minecraft datapacks and resource
packs, plus the datapack tooling built around them.

---
# 🚨 CRITICAL SECURITY RISK

> [!CAUTION]
> **CRITICAL SECURITY & PRIVACY ISSUE**
>
> BTK Decision No. 2023/DK-İD/119 introduces serious structural risks:
>
> - **Privacy:** Potential exposure of sensitive user data (Articles 12–13).
> - **Infrastructure:** Broad technical information disclosure requirements (Article 18).
> - **Availability:** Up to 90% network bandwidth throttling (Articles 22, 29, 32).
> - **Data security:** Increased data concentration risks (Article 13).
> - **Content integrity:** Potential over-removal of legitimate content (Article 36).
>
> **Impact:** Potential systemic consequences for users, developers, businesses, and digital infrastructure.
>
> **Classification: CRITICAL**
>
> *This assessment identifies structural risks, not confirmed security breaches or exploitable vulnerabilities.*
---

<!--
This opening line is the repository's GitHub description verbatim. Change one,
change the other:
  curl -X PATCH -H "Authorization: Bearer $TOKEN" \
    https://api.github.com/repos/vortaforge/core \
    -d '{"description": "<the new line>"}'
They had already drifted apart once ("Consolidated monorepo for the
vortacraftmc ecosystem."), which is circular - the organization *is*
the project name, so the description said nothing about what is in here.
-->

## Maintenance status

As of 2026-10-29, a maintainer handover is being prepared. The current
maintainer remains responsible until a successor has explicitly accepted and
the transfer checklist in [HANDOVER.md](HANDOVER.md) is complete. Developers
interested in maintaining the Fabric mods, datapacks, or tooling should read
that document and `CONTRIBUTING.md` before taking on release or organization
administration work.

## Structure

- `mods/`        — Fabric mods (Gradle subprojects, auto-discovered by `settings.gradle`)
- `packs/`       — Datapacks / resource packs. `guikitfw` is the active successor to the retired `guikit-datapack`.
- `scripts/`     — Helper scripts and tools
- `README.md`   — Cross-pack design and security notes (reference sections below)
- `examples/`    — Templates, example Fabric mods, example datapacks, test files
- `build-logic/` — Shared Gradle script (`shared-fabric-mod.gradle`) applied by the mod subprojects
- `archived/`    — Reserved for projects no longer developed but kept for reference (registry: `archived/archive.json`, validate with `scripts/check_archive.py`)

Content that does not fit another category is not given its own directory.
Register it in `archived/archive.json` with `"kind": "other"` instead; the
schema (`archived/archive.schema.json`) enumerates the valid kinds.

---

## Building

> **⚠️ Warning - a Minecraft server is started in exactly one place.** `.github/workflows/ward.yml` (via `scripts/ward_ci.sh`) runs datapack tests with mcward on a throw-away Fabric server on a GitHub-hosted runner. It is bound to `127.0.0.1`, whitelist enforced and empty, verified loopback-only by `scripts/ward_guard.py` before and after the tests, and deleted afterwards. Nothing else in this repository starts, connects to or tests against a Minecraft server. Never run that script on a developer machine, a production host or next to a real world.

This repo uses Gradle to build all Fabric mod subprojects.

### Requirements

- JDK 25
- Node.js 20+ and npm; Python 3 with pytest and an editable guigenmc install
- Gradle Wrapper (included, no separate Gradle install needed)
- Network access for initial dependency and Spyglass vanilla-data downloads

### Project lifecycle tasks

The root build exposes project-specific entry points in addition to the
per-module Gradle tasks:

```bash
# Provenance, regression tests, Spyglass + strict JSON, and pack metadata.
# Spyglass may download vanilla data; no Minecraft server is started.
./gradlew verifyProject

# Builds Fabric modules, individual pack ZIPs, the merged pack and an inventory.
./gradlew packageProject -PconfirmZip=yes

# The canonical local CI graph: verifyProject + packageProject.
./gradlew ci -PconfirmZip=yes
```

`buildAll` and `lint` remain available as focused compatibility tasks: the
first builds every Gradle subproject, and the second runs configured Checkstyle
tasks. `writeProjectInventory` writes a deterministic build report at
`build/reports/repository/project-inventory.json`.

### Build a single subproject

```bash
./gradlew :mods:<subproject-name>:build
```

### CI

When enabled in GitHub, pushes, pull requests and manual dispatches can trigger
`build.yml`, named **CI**. The workflow was manually disabled at the
2026-10-29 status check; historical successful runs do not prove new runs are
occurring. Its read-only `quality` job calls `quality.yml`, the reusable workflow
that runs the canonical `./gradlew ci -PconfirmZip=yes` graph on Python 3.12
and a guigenmc source/wheel package check. guigenmc declares Python 3.9+
support, but there is currently no Python 3.9 CI job, so the minimum version
is declared rather than CI-tested. Every job behind the reusable workflow's
explicit quality gate must pass before its `verified` output is true; whether
GitHub *requires* that gate for a merge is a repository-ruleset setting, not
something this file can prove.

The `publish` job is **paused in the workflow file** pending a reviewed,
append-only design and recovery plan. Its disabled implementation has
`contents: write`, runs in the `release` environment and consumes the
release-candidate artifact rather than checking out repository code. An
environment name alone is not an approval: manual approval happens only if
required reviewers are configured for `release` in GitHub settings.

Workflow *enablement* is also a GitHub setting and is not stored in git. At the
2026-10-29 status check, CI, CodeQL, Reusable Quality, Organization Backup,
CODEOWNERS Sync and Ward were manually disabled. Check the current GitHub
settings and actual run records before claiming coverage. This change retires
the separate AI Agent workflow and implementation; previous green runs or AI
comments are not independent human reviews. See the
[maintainer guide](MAINTAINER_GUIDE.md) for preserved project rules.

`verifyProject` runs provenance, focused repository safeguards, Python and
Node tests, Spyglass/JSON lint, mod verification, and pack/archive checks.
`packageProject` builds subprojects and the individual/merged pack archives.
The old repository and GitHub audit scripts were removed; the retained checks
and important coverage gaps are listed in [scripts/README.md](scripts/README.md).

Spyglass analyzes each pack at one inferred Minecraft version, including the
legacy cmdTunnel and the 26.x World Clock functions. Explicit Ward-test
exclusions and hash-bound RTWrapper permission warnings are documented in
[scripts/datapack_lint/README.md](scripts/datapack_lint/README.md). Warnings
need review; neither static lint nor a green build proves in-game behaviour.

The separate `mods/rtwrapper-mod` and `mods/datapack-fixer` sources were
removed in the 2026-10-30 cleanup. The historical
`packs/RTWrapper/rtwrapper-fabric` source remains excluded from the Gradle
build; no RTWrapper Fabric mod is built as a replacement.

### Release ZIPs for the packs

`python3 scripts/build_release.py` writes one deterministic ZIP per pack to
`build/release/`: the release copy is minified (comments and blank lines
dropped), the source tree is never touched and nothing is renamed, so a
release ZIP is byte-for-byte reproducible from this repository
(`SHA256SUMS.txt` is written next to the ZIPs). The same run inventories every
place a pack executes a command string that is not literal source text
(`dynamic-surfaces.json`); those surfaces are gated off by default in every
pack that has them - see [dynamic-command gate reference](#cross-pack-dynamic-command-gate).

## History

This monorepo consolidates projects that were previously scattered across
individual repositories under the `runtoolkit` GitHub organization
(TunnelScript, LeftClickDetection, dp-depman, RTWrapper, datapack-fixer, template-datapack, InteractionClickDetection,
cmdTunnel-datapack, dpgen, TEMPLATE-MOD, macroEngine, guigen). That
organization has since been retired; its projects moved to `vortacraftmc` and then to `vortaforge`. The old repos
are archived with a pointer to this monorepo, and are not otherwise
maintained.

> **Correction (2026-10-08).** Earlier revisions of this list also named
> `inv_gui`, and a later paragraph warned against using it because its
> licensing as a [rarula/Sketch](https://github.com/rarula/Sketch) fork had
> never been cleared. **No `inv_gui` pack has ever existed in this
> repository** - `git log --all --diff-filter=A -- '*inv_gui*'` returns
> nothing, and no directory, `pack.mcmeta` or namespace by that name is
> present. The warning was about a project that was discussed but never
> merged in, so both the list entry and the paragraph have been removed
> rather than kept as a caveat about absent code.

**Original source:** this project originated as [`runtoolkit/suite`](https://github.com/runtoolkit/suite)
by **Runtoolkit**. It is maintained here as `vortaforge/core`; the original
copyright notices in each `LICENSE`/`NOTICE` file are preserved.



## Cross-pack documentation and historical analysis

The following references consolidate material previously stored under `docs/`. The maintainer guide is also kept as [`MAINTAINER_GUIDE.md`](MAINTAINER_GUIDE.md) because repository safety checks and contributor guidance refer to it; its obsolete documentation reference was updated without changing the rule itself. Dated analysis is historical, not a new test result. Historical paths mentioned in `CREDITS.md` are provenance records.


<a id="cross-pack-maintainer-guide"></a>
<details>
<summary>Maintainer guide (formerly docs/MAINTAINER_GUIDE.md)</summary>

# Maintainer guide

This is the human-facing project guidance for `vortaforge/core`. It preserves
project rules and technical context previously kept in the AI-specific
instruction files, without requiring an automated AI agent.

## Project and provenance

This monorepo contains Minecraft Java Edition datapacks, resource packs, Fabric
mods, tooling, examples and historical reference material. It is independent
of Mojang and Microsoft. The repository uses the Unlicense (`LICENSE`);
third-party code retains its own licences, including
`packs/macroEngine-Datapack-v26.3/THIRD_PARTY_LICENSES.md`.

The documented publishing history is `runtoolkit` -> `vortacraftmc` ->
`vortaforge`; keep the provenance and older locations intact. Prior project
guidance named Minecraft 26.3 as the pack target and 26.2 as the production
server version on 2026-10-29. Those are historical notes, not proof of the
current deployment: verify each pack's metadata and deployment separately.

## Project safety rules

1. **Preserve project content and history.** Do not delete project files,
   release assets, repositories or organizations without the maintainer's
   explicit, scoped permission. Never rewrite Git history, use force-push or
   `git filter-repo`, or delete a repository or organization. Retire or archive
   material instead. The specific retirement of the AI automation and its two
   instruction files is not permission to remove other content.
2. **Protect credentials.** Never put a token, password or key in a file,
   workflow, issue, comment, commit message, log or chat. Rotate credentials
   exposed outside their secret store; do not repeat their values.
3. **Disclose AI assistance honestly.** Identify AI-assisted changes in commit
   text and `CREDITS.md`, including what was not verified. Removing the
   repository automation does not remove the historical disclosure obligation.
4. **Use branches and honest reviews.** Submit changes on branches, not as
   loose patches. Do not describe an AI or bot comment, a passing CI job or a
   ruleset bypass as independent human review. If no independent review occurred,
   say **not independently reviewed (Anti-Review)**.
5. **Use English** for code, comments, commit messages, issues, PR text and
   documentation, except for documented translation files such as `lang/tr_tr.json`
   and the Turkish text-engine tables.
6. **Report evidence accurately.** Claim a check passed only when it was run;
   distinguish static validation, builds, runtime tests and checks not run.
7. **Do not run Minecraft-server tests locally or against a live server.** No
   local self-test server, RCON or live-game smoke test. The sole documented
   server exception is the isolated Ward job on GitHub-hosted runners; its
   network isolation, whitelist, verification and cleanup must not be weakened.
8. **Preserve runtime identifiers.** Do not rename `data/vortacraftmc/`,
   `#vortacraftmc.*`, `com.vortacraftmc` or other public identifiers without an
   explicit world/API migration plan.
9. **Preserve notices and provenance.** Keep `LICENSE`, `NOTICE.md`, the
   `_vc_origin.mcfunction` watermarks, historical records, `CREDITS.md` and
   third-party licence notices intact. Pin third-party Actions by commit SHA
   and give workflows the minimum required permissions.

> **⚠️ Warning - a Minecraft server is started in exactly one place.**
> `.github/workflows/ward.yml` (via `scripts/ward_ci.sh`) runs Ward datapack
> tests on a throw-away Fabric server on a GitHub-hosted runner. It is bound to
> `127.0.0.1`, whitelist-enforced and empty, verified loopback-only by
> `scripts/ward_guard.py` before and after the tests, and deleted afterwards.
> Never run that script on a developer machine, production host or real world.

## Repository layout

| Path | Contents |
|---|---|
| `mods/` | Fabric mods, each with its own Gradle subproject and version pins. |
| `packs/` | Datapacks and resource packs; `merge-manifest.json` drives the merged datapack. |
| `scripts/` | Lint, provenance, audit, backup and self-contained developer tools. |
| `examples/` | Example mods and packs. |
| `archived/` | Historical registry and reference-only material; do not deploy without review. |
| `index.html`, `.nojekyll`, `robots.txt`, `sitemap.xml`, `banner.png` | Static site source and related metadata. Pages enablement is a GitHub setting; verify it before calling the site live. |

## Validation map

The canonical checks and their prerequisites are documented in `README.md`
and `HANDOVER.md`. In brief:

```bash
./gradlew verifyProject
./gradlew packageProject -PconfirmZip=yes
./gradlew ci -PconfirmZip=yes
./gradlew buildAll
./gradlew lint
scripts/lint_datapacks.sh
python3 scripts/origin_watermarks.py --check
python3 -m pytest scripts/gui_generator/tests scripts/tests
# inside scripts/dpgen: npm test
```

`verifyProject` is the canonical repository-validation graph and needs its
Python/Node tools; Spyglass may download vanilla data. `packageProject`
prepares individual and merged pack artifacts. Spyglass and strict JSON are
static checks, with exclusions and version limits in
`scripts/datapack_lint/README.md`; the retired audit's coverage gaps are in
`scripts/README.md`. None proves an in-game result. `scripts/ward_ci.sh`
starts a Minecraft server and must never be run by hand.

Workflow enablement is a GitHub setting, not a Git file. On 2026-10-29, the
GitHub API showed CI (`build.yml`), CodeQL, Reusable Quality, Organization
Backup, CODEOWNERS Sync and Ward as manually disabled. Re-check the settings and
actual run records before describing a workflow as active or a test as passed.
The CI publish job is separately paused in the workflow file. Do not resume
publication without an independently reviewed, append-only design and recovery
procedure. A reusable workflow may also be invoked by another workflow; do not
infer its execution history from the enablement flag alone.

The repository's AI Agent workflow and implementation are retired by this
change. Historical records remain; GitHub secrets and the provider-side API key
may still exist and must be checked separately by an authorized person.

## Datapack conventions

- Public macroEngine functions belong under `api/`, internals under
  `core/internal/`, and shared helpers under `systems/`.
- Never substitute untrusted text into a macro line. Validate names with
  `systems/validate/safe_name` while the value is still data in storage.
- Prefer storage in, storage out; use plain strings where text components are
  unnecessary. `api/store/*` is the unified storage API; the old
  `api/placeholder/*` and `api/data/*` modules are gone (`packs/macroEngine-Datapack-v26.3/README.md#macro-reference-store`).
- Keep `pack.mcmeta` format ranges in sync with the target Minecraft version;
  do not guess them. Every loadable datapack needs a top-level `pack.mcmeta`.
- In `merge-manifest.json`, `output.min_format` / `output.max_format` must match
  the included packs.

## Java, Gradle and web conventions

- Each mod pins its own Minecraft, Fabric Loader, Fabric API and Java versions;
  keep those internally consistent and check current versions before bumps.
- Do not add network calls or desktop APIs unless a mod's documented purpose
  requires them. Use the mod permission layer rather than hard-coded operator
  levels.
- `index.html` is a single static file. Escape GitHub API and error-message
  content before adding it to `innerHTML`. Keep canonical, Open Graph, JSON-LD
  and `sitemap.xml` metadata aligned with the intended Pages URL.

Before finishing, run the relevant checks where safe, disclose what was not
verified, and update `CREDITS.md` for AI-assisted work.

</details>


<a id="cross-pack-dynamic-command-gate"></a>
<details>
<summary>Dynamic command gate (formerly docs/dynamic-command-gate.md)</summary>

# Dynamic command execution: inventory and gate

Several packs in this repository can execute a Minecraft command that is not
written literally in a `.mcfunction` file - a string from storage expanded by a
macro (`$$(cmd)`, `run $(cmd)`), a dynamically named `function` dispatch, or a
string copied into a command block. Those executors run at the server's
`function-permission-level`, not at the permission level of the player who
happened to trigger them, so who may feed them a string is a security
question. This document is the inventory of those surfaces and the switch
that now sits in front of each of them.

## Rule after this change

**Stored-string command execution is off by default in every pack that has
it.** An operator enables it per pack, deliberately, with the pack's own
config mechanism:

| Pack | Dynamic surfaces | Gate | How an operator enables it |
|---|---|---|---|
| `macroEngine-Datapack-v26.3` | stored-string executors (queue, hooks, wands, triggers, `multi_cmd`, `once_cmd`, region watchers, command-block runners) and the `api/cmd/*` string runners | `macroengine:systems/cmd_gate/check`: config switch + `cmd.dynamic` permission + length/control checks + root blocklist. Full contract: `packs/macroEngine-Datapack-v26.3/README.md#macro-reference-cmd-gate` | `data modify storage macroengine:engine config_in set value {key:"dynamic_cmd",value:1b}` then `function macroengine:core/config/set`, and grant `cmd.dynamic` (directly or via a permission group) |
| `guikit-datapack` (retired source; historical distributions only) | historically, menu/button `cmd` actions (`play/act/cmd_do`, `internal/btn/cmd`) | `guikit:cfg dynamic_cmd` (storage, default `0b`, seeded in `core/load`) | `data modify storage guikit:cfg dynamic_cmd set value 1b` |
| `guikitfw` | menu `commands` actions (`act/_commands_one`) | same storage flag, seeded in `core/load` | `data modify storage guikit:cfg dynamic_cmd set value 1b` |
| `RTWrapper-v1.0.1` and `RTWrapper` | the single wrapper dispatch (`core/wrappers/handler/exec`) that every storage-driven request funnels through | score `#dynamic` in `rtw.config` (default 0, seeded in `core/load`) | `function rtwrapper:api/dynamic/on` (`.../off` to revert) |
| `TunnelScript` | the command-block runner (`tunnelscript_core:internal/run_block`) behind `ts:run*`, batches and the minecart input queue | score `#dynamic_enabled` in `tunnelscript.vars` (default 0), *in addition to* the existing `tunnelscript.trusted` tag and confirmation gate; dry-run preview still works while off | `function ts:config/dynamic_on` |
| `cmdTunnel-datapack` (archived, legacy format) | `cmd_tunnel_sys:run` → command block at 0 -66 0 | score `#dynamic` in `cmd_tunnel_cfg` (default 0, objective created by `init`) | `function cmd_tunnel_sys:dynamic_on` |
| `DailyBonus`, `QuickShare`, `LeftClickDetection`, `InteractionClickDetection`, `macroEngine-Resourcepack-v26.3` | none found | n/a | n/a |

"No surface found" means: no whole-command macro, no `run $(...)`, no dynamic
`function` dispatch and no storage-fed command block in the pack's
`.mcfunction` files. `python3 scripts/build_release.py` re-runs exactly this
scan on every release build and writes the line-by-line result to
`build/release/dynamic-surfaces.json`, so the inventory cannot silently rot -
diff that file when reviewing a change that touches command execution.

## Reviewed and deliberately not gated

Two patterns *look* dynamic in the scan but are not arbitrary-string
executors, so the default-off switch does not cover them:

* **Code-supplied `$(invoke)` helpers** in macroEngine (`systems/geo/*`,
  `player/inv/*`, `world/block_if|block_unless`): the invoked text is a macro
  argument written by another `.mcfunction` file in this repository, i.e. by
  already-trusted pack code. Gating them would not separate trusted from
  untrusted input; it would just break the pack's own features. If a future
  caller passes player-controlled text as `invoke`, that caller is the bug -
  `systems/cmd_gate/check` is the function to route it through first.
* **Prefix-constrained dispatch** in guikitfw (`guikit:cond/t_$(ctype)`,
  `guikit:act/$(kind)`, `guikit:widget/$(kind)`): the substituted text can
  only select among functions under one fixed prefix of the same pack; it
  cannot express an arbitrary command. Menu definitions stay operator-trusted
  input, as documented in the packs themselves.

`api/perm/run` and `api/perm/exec` in macroEngine keep their per-call
permission check *and* now also require the `dynamic_cmd` switch, so the
switch really is a master off for stored strings.

## Honest limits

* A datapack is plain text. Anyone who can edit the pack can delete the gate;
  anyone with operator rights can turn it on and grant themselves the
  permission. The gate separates *untrusted players* from function-level
  command execution and makes the trust decision explicit and auditable. It
  is a safeguard, not a sandbox (the same note `gate/version` already makes).
  Non-bypassable enforcement belongs in a Fabric mod.
* The blocklist in `systems/cmd_gate/blocklist` only inspects the first token
  of the command. `execute ... run op @s` has root `execute` and is not
  filtered by it. Do not treat the blocklist as the boundary; the boundary is
  *off by default* plus the `cmd.dynamic` permission.
* Macro executors capture their string through a quoted macro line
  (`set value "$(cmd)"`), as they already did before this change, so a command
  containing a double quote or backslash cannot pass through those specific
  executors at all. The command-block runners copy from storage and are not
  subject to that limit.
* macroEngine ships no Ward tests: `data/macroengine/test/` does not exist
  (the `cmd_gate_*` tests this paragraph used to cite were never added to the
  tree). The gate has been checked statically only (historically with Mecha,
  and now with Spyglass plus source inspection); no server execution is claimed.

## Why not obfuscation instead?

Hiding these executors behind name mangling, split-up macro strings, dead
code or encrypted sources would make this document impossible to write
honestly, would undermine static lint, the origin-watermark and repository
checks, and every existing world that references these namespaces -
and would look *more* like malware to any reviewer, human or automated, not
less. The defence against false-positive "this datapack is a virus" verdicts
is the opposite posture: plain readable source under the Unlicense, this
inventory, reproducible release ZIPs (`scripts/build_release.py`, with
SHA-256 sums), and dangerous strings off until an operator opts in.

</details>


<a id="cross-pack-static-analysis-2026-10-30"></a>
<details>
<summary>Static analysis findings, 2026-10-30</summary>

# Static-analysis findings, 2026-10-30

These are **unresolved findings**, not claims of runtime testing or human
review. The cleanup's full Spyglass/strict-JSON run analyzed 12 pack roots,
coverage-checked 3,278 files, excluded three Ward test files, and reported
zero errors and **58 warnings**. The language server selected one version per
pack, not every version supported by the metadata. No Minecraft server was
started. A clean syntax result is not permission to publish: publication
remains paused pending appropriate human review and runtime validation.

| Area | Evidence and next step |
|---|---|
| QuickShare (one warning) | `drop_mainhand_copy.mcfunction` summoned an item entity with `Item.id` set to `minecraft:air`. Spyglass flags it, and [Minecraft Wiki](https://minecraft.wiki/w/Air) says this summon does nothing in Java Edition. **Changed on 2026-10-31 (statically, not runtime-tested):** the scratch entity now starts as a `minecraft:stone` placeholder that is overwritten from `SelectedItem`; it is killed if the copy fails. Separately, `share.mcfunction`'s last guard (`unless score ... matches 101..`) was true for every cooldown value 1-100, so the item was still dropped while "Cooldown active" was shown. The drop and the cooldown reset now both test `unless score ... matches 1..` before the reset runs, and an empty hand neither drops nor starts a cooldown. Both changes still need an isolated runtime test and human review before they count as fixed. |
| TunnelScript (27 warnings) | The metadata declares pack format 10, while the warning sites use the NBT text-component `plain` field. [Mojang introduced `plain` in 26.1](https://www.minecraft.net/en-us/article/minecraft-java-edition-26-1). Its handling on the declared older version was not tested; review compatibility rather than silently raising the pack version. |
| LeftClickDetection (16 warnings) | Spyglass selected 26.1.2 from the declared broad range and flagged `Team`, `NoAI`, `DeathTime` and `Size` on interaction entities. The source primarily uses plural `functions`/`tags/functions`, while [Mojang renamed these directories in 1.21](https://www.minecraft.net/en-us/article/minecraft-java-edition-1-21). The metadata range extends across that boundary; its actual compatibility needs review. This pack's README labels it archived. |
| RTWrapper datapacks (10 warnings) | Five privileged commands per pack exceed Spyglass's default permission level. Only exact path/message/file-hash exceptions are downgraded to warnings. Runtime authorization and operator safety remain unverified. |
| macroEngine (four warnings) | Spyglass reports a potentially undeclared `macroengine.rnd_idx` objective, an `Invisible` key on a chest minecart, and two `_comment` keys in item-modifier JSON. Correction (2026-10-31): the earlier note that the objective was not found being created was wrong - `scoreboard objectives add macroengine.rnd_idx dummy` is in `core/internal/load/loader/scoreboards.mcfunction`, which `core/internal/load/all.mcfunction` calls, so this warning looks like a false positive from file-by-file analysis (not runtime-checked). The `Invisible` and `_comment` warnings are unchanged: investigate ignored fields and runtime effects before relying on them. |

Warnings may include false positives, but they must not be silently dismissed.
These observations did not justify untested gameplay changes in the cleanup.
Future investigations should use the project's isolated server-backed CI
procedure only after the required human authorization; the Ward workflow is
currently disabled and was not run for this work.

</details>
