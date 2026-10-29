# vortaforge/core

Monorepo for VortaForge: Fabric mods, Minecraft datapacks and resource
packs, plus the datapack tooling built around them.

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

## Structure

- `mods/`        — Fabric mods (Gradle subprojects, auto-discovered by `settings.gradle`)
- `packs/`       — Datapacks / resource packs. `guikitfw` is the active successor to `guikit-datapack`.
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
- Gradle Wrapper (included, no separate Gradle install needed)

### Project lifecycle tasks

The root build exposes project-specific entry points in addition to the
per-module Gradle tasks:

```bash
# Offline checks: provenance, audit, tests, datapack syntax and pack metadata.
# pytest, guigenmc (editable) and Mecha must be installed first.
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

Pushes, pull requests and manual dispatches trigger `build.yml`, named
**CI**. Its read-only `quality` job calls `quality.yml`, the reusable workflow
that runs the canonical `./gradlew ci -PconfirmZip=yes` graph on Python 3.12
and a guigenmc source/wheel package check. guigenmc declares Python 3.9+
support, but there is currently no Python 3.9 CI job, so the minimum version
is declared rather than CI-tested. Every job behind the reusable workflow's
explicit quality gate must pass before its `verified` output is true; whether
GitHub *requires* that gate for a merge is a repository-ruleset setting, not
something this file can prove.

Only a successful `main` push or manual run can reach `publish`. That job has
`contents: write`, runs in the `release` environment, does not check out or
execute repository code, and publishes only the release-candidate artifact
produced by the read-only quality job. An environment name alone is not an
approval: manual approval happens only if required reviewers are configured
for `release` in GitHub settings. Keeping code execution and publication in
separate jobs is the enforced part of this design.

Workflow *enablement* is also a GitHub setting and is not stored in git. At
the 2026-10-29 audit, the **AI Agent** and **Ward** workflows were manually
disabled in GitHub Actions. Their files and safety rules remain in the tree,
but a green PR from that period must not be described as AI-reviewed or
Ward-tested. Check Settings -> Actions before relying on either workflow.

`verifyProject` enforces provenance, the repository audit, offline tests,
dpgen tests, datapack syntax, and pack/archive metadata checks. `packageProject`
builds subprojects and the individual/merged pack archives.

The datapack lint still skips the paths listed in `IGNORE_PATHS` at the top of
`scripts/lint_datapacks.sh` (`archived/*`, `packs/cmdTunnel-datapack/*` and two
26.x `time query` files in `macroEngine-Datapack-v26.3`). Mecha only checks
command *syntax* — it does not load the pack, so a green run is not proof that a
datapack behaves correctly.

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

