# vortaforge/core

Monorepo for VortaForge: **Fabric mods**. The Minecraft datapacks, resource
packs and the datapack tooling that used to live here are **archived and
hard-disabled** (2026-11-05) - see [Datapacks are disabled](#datapacks-are-disabled).

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

## Datapacks are disabled

> [!IMPORTANT]
> **The datapack programme in this repository is retired and hard-disabled.**
> `packs/` is empty, every datapack, generator, linter and test harness is
> archived and disarmed in [`archived/archive.json`](archived/archive.json), and
> [`datapacks.disabled.json`](datapacks.disabled.json) (`"enabled": false`) is
> the switch that keeps it that way.
>
> **Why:** datapacks here had no type safety (every value crossing a function
> call, storage read, scoreboard comparison or macro expansion is an untyped
> string), no enforced security model (stored-string command execution at
> `function-permission-level`), no debugging or inspection tooling, no warning
> or error surface, and a low review score. It was bad enough that it would have
> been better not to ship it at all. The maintainer also hit real problems as a
> plain player using a datapack with **no client mod installed**, and the same
> class of problems kept coming back in pull requests.
>
> *Datapack'de tip güvenliği, güvenlik modeli, hata ayıklama, uyarılar ve birçok
> önemli şey olmadığı ve düşük puanlı olduğu için vazgeçiyorum. Client'a mod
> kurmadan datapack kullanırken bile sorunlar yaşadım ve PR'lerde de aynı
> sorunlar çıktı; olmasaydı daha iyi olurdu.*
>
> **Blocked automatically:** new datapack content, new packs, revival of the
> archived tooling and blocklisted datapack developers are refused by
> `scripts/datapack_guard.py` in `pre-commit`, `pre-push` and CI
> (`.github/workflows/quality.yml`, job `datapack-guard`).
>
> Read [`archived/README.md`](archived/README.md) for the policy and
> [`docs/ARCHIVAL.md`](docs/ARCHIVAL.md) for the whole system in Turkish and
> English, including how to install and how to re-enable it deliberately.

## Structure

- `mods/`        — Fabric mods (Gradle subprojects, auto-discovered by `settings.gradle`)
- `packs/`       — **Empty.** Datapacks were retired on 2026-11-05; the guard refuses new content here.
- `archived/`    — Every retired project, frozen and disarmed: `archived/packs/`, `archived/tools/`, `archived/build/` (the datapack Gradle logic extracted from the root `build.gradle`), `archived/docs/`, `archived/examples/`. Registry: `archived/archive.json` (schema v2), validate with `scripts/check_archive.py`.
- `blocklist/`   — Account blocklist (`blocklist.json`) enforced by the guard and mirrored org-wide by `vortaforge/.github`.
- `.githooks/`   — Versioned `pre-commit` / `pre-push` hooks (`git config core.hooksPath .githooks`).
- `scripts/`     — Helper scripts and tools (guard, switch, archive validator, gui generator)
- `docs/`        — Maintainer notes, including [`docs/ARCHIVAL.md`](docs/ARCHIVAL.md)
- `examples/`    — Example Fabric mods (the datapack template was archived)
- `build-logic/` — Shared Gradle script (`shared-fabric-mod.gradle`) applied by the mod subprojects
- `datapacks.disabled.json` — The kill switch (`"enabled": false`)

Content that does not fit another category is not given its own directory.
Register it in `archived/archive.json` with `"kind": "other"` instead; the
schema (`archived/archive.schema.json`) enumerates the valid kinds.

---

## Building

> **⚠️ Warning - a Minecraft server used to be started in exactly one place, and that place is archived.** The Ward (mcward) datapack test harness - `archived/tools/ward/ward_ci.sh`, `ward_guard.py` and its `ward.yml` workflow - was archived on 2026-11-05. The workflow is no longer under `.github/workflows/`, so GitHub does not run it, and nothing in the live repository starts, connects to or tests against a Minecraft server any more. Never run `ward_ci.sh` on a developer machine, a production host or next to a real world.

This repo uses Gradle to build all Fabric mod subprojects.

### Requirements

- JDK 25
- Node.js 20 (only for the offline website behaviour test) and Python 3 with pytest and an editable guigenmc install
- Gradle Wrapper (included, no separate Gradle install needed)
- Network access for initial dependency downloads

### Project lifecycle tasks

The root build exposes project-specific entry points in addition to the
per-module Gradle tasks:

```bash
# Guard (no new datapacks, no blocklisted accounts), kill switch, archive
# registry, repository regression tests. No Minecraft server is started.
./gradlew verifyProject

# Builds the Fabric modules and writes the project inventory.
./gradlew packageProject

# The canonical local CI graph: verifyProject + packageProject.
./gradlew ci

# Datapack-specific, all read-only:
./gradlew checkDatapackSwitch     # is the kill switch engaged?
./gradlew checkArchive            # is archived/archive.json valid and disarmed?
./gradlew printArchiveList        # what is archived, and why
python3 scripts/datapacks_disable.py status
python3 scripts/datapack_guard.py --staged --protect --blocklist
```

The datapack tasks (`zipPacks`, `mergeDatapacks`, `checkPacks`,
`lintDatapacks`, `checkProvenance`, `installDatapackLintDependencies`,
`testDpgen`, ...) **no longer exist**. Their implementation is archived verbatim
in [`archived/build/`](archived/build/) and [`archived/tools/`](archived/tools/).

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
[maintainer guide](docs/MAINTAINER_GUIDE.md) for preserved project rules.

`verifyProject` runs the datapack guard, the kill switch, the archive registry
validation, focused repository safeguards, and the Python/Node regression
suites. `packageProject` builds the Fabric mods and writes the project
inventory. The old repository and GitHub audit scripts were removed; the
retained checks and important coverage gaps are listed in
[scripts/README.md](scripts/README.md).

Spyglass/JSON lint, the Ward runtime tests and the deterministic pack release
builder are **archived** with the packs they served; they are not run by any
build or workflow any more.

The separate `mods/rtwrapper-mod` and `mods/datapack-fixer` sources were
removed in the 2026-10-30 cleanup. The historical
`packs/RTWrapper/rtwrapper-fabric` source remains excluded from the Gradle
build; no RTWrapper Fabric mod is built as a replacement.

### Release ZIPs for the packs

Retired. `scripts/build_release.py` is archived as
`archived/tools/build-release/build_release.py`; its `dynamic-surfaces.json`
inventory and the `docs/dynamic-command-gate.md` contract it referenced are
archived under `archived/tools/build-release/` and `archived/docs/`.

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

