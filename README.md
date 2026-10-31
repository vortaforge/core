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
- `docs/`        — Cross-pack design and security notes
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
[maintainer guide](docs/MAINTAINER_GUIDE.md) for preserved project rules.

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
pack that has them - see [docs/dynamic-command-gate.md](docs/dynamic-command-gate.md).

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

