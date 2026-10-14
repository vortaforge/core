# Datapack text removed from the root docs

Verbatim lines removed from the root documents on 2026-10-14 when the datapacks were archived. Reference only; each block shows the file it came from. Status banners are not kept here.

## From `README.md`

```text
Monorepo for VortaForge: Fabric mods, Minecraft datapacks and resource
packs, plus the datapack tooling built around them.



- `packs/`       — Datapacks / resource packs
- `examples/`    — Templates, example Fabric mods, example datapacks, test files
- `archived/`    — Reserved for projects no longer developed but kept for reference (registry: `archived/archive.json`, validate with `scripts/check_archive.py`)
Pushes and pull requests trigger the `build.yml` workflow, named **`CI`**. Its two jobs are `Verify & package` and `Publish release`; the first runs `buildAll` and `lint` across all subprojects and uploads build artifacts. See `.github/workflows/build.yml` for the full pipeline, including the release-publishing job.

The workflow has three checks with **different levels of enforcement**:

| Check | Enforced? | Notes |
|---|---|---|
| `build` (`buildAll`) | yes | failure fails the job |
| Gradle `lint` | yes | step is `continue-on-error`, but "Final summary" re-fails the job |
| Datapack lint (`scripts/lint_datapacks.sh`, Mecha) | yes | step is `continue-on-error` for diagnostics, but the script propagates Mecha's exit status, so "Release gate" blocks publishing and "Final summary" fails the job |
All three checks are enforced. (The datapack lint used to be advisory only: the
script ended in an unconditional `exit 0` while the step was `continue-on-error`,
making it a no-op that could never fail a build. Mecha 0.101.0 validates all
3681 `.mcfunction` files here and passes with zero errors, so it was made
enforcing on 2026-10-07. Set `LINT_WARN_ONLY=1` for a one-off advisory run.)
The datapack lint still skips the paths listed in `IGNORE_PATHS` at the top of
`scripts/lint_datapacks.sh` (`archived/*`, `packs/cmdTunnel-datapack/*` and two
26.x `time query` files in `macroEngine-Datapack-v26.3`). Mecha only checks
command *syntax* — it does not load the pack, so a green run is not proof that a
datapack behaves correctly.
```

## From `NOTICE.md`

```text
Read this before opening a pull request. It explains the mixed Gradle/
datapack layout of this monorepo and sets expectations for what a PR
- `packs/` — Datapacks. These are **not** part of the Gradle build. There is
  nothing to compile; validity is checked by loading the pack plus the
  syntax/reference tooling listed in `SECURITY.md` § "Validation tooling"
  (Mecha lint, `checkPacks`, `mergeDatapacks`), not by `buildAll`. Don't
  assume a green Gradle run says anything about a datapack change.
- `examples/` — Templates and sample code. Not shipped, not covered by the
  same security posture as `mods/` or `packs/`.
- `archived/` — Frozen, reference only.

If your change spans both a mod and a pack (e.g. a Fabric mod that reads
data from a companion datapack), say so explicitly in the PR description —
this is the case most likely to be missed by CI, since `buildAll` only
covers the Gradle side.
- CI's separate **datapack** lint (Mecha, `scripts/lint_datapacks.sh`) is
  also enforced: the script propagates Mecha's exit status, so a syntax
  error in any `.mcfunction` fails the job and blocks the release gate.
  Note that Mecha only validates command *syntax* — it never loads the
  pack, so the "you've validated the pack loads correctly" checkbox below
  still applies. Paths listed in the script's `IGNORE_PATHS` are skipped.
## Datapacks specifics
- Datapacks in `packs/` follow the pack-format and namespace conventions
  documented per-project — check the subproject's own README before
  assuming a version target.
- Namespace isolation matters: don't introduce function/tag names that can
  collide with another pack in this repo or with common third-party packs.
- Macro-heavy or command-generation logic is a known risk area in this
  project (see `SECURITY.md`). If your change touches macro expansion,
  dynamic function generation, or anything that assembles commands from
  external input, call that out explicitly in the PR — it will get closer
  review than an average change.
- Packs listed in `archived/archive.json` are frozen. Don't submit feature PRs
  against them; fixes only, and only if the issue is significant. Note that
  **nothing is currently archived under `packs/`** - the registry's only
  entry is the retired `runtoolkit/suite` repository with `"path": null`, so
  today every pack in `packs/` accepts normal PRs. Validate with
  `./gradlew printArchiveList` rather than trusting this sentence.
This notice exists because of the nature of what's in this repo — datapack
macro systems, command-generation tooling, and Fabric mods that can touch
server/client behavior. To be explicit:
- [ ] If you touched `packs/`, you've validated the pack loads correctly
      (Gradle passing does not cover this)
- [ ] PR description explains **what** changed and **why**, and says
      whether the change touches mods, packs, or both
```

## From `SECURITY.md`

```text
As of 2026-10-04 the maintainer expects to be inactive on GitHub until at least 2027–2028. Until then:


- Affected project/path (e.g. `packs/RTWrapper`, `mods/...`)
| `packs/` | 14 live packs (datapacks + the macroEngine resource pack), all under active layout. **Not** archived: `archived/` currently holds no packs at all (see `archived/archive.json`, whose only entry is the retired `runtoolkit/suite` repo with `"path": null`). |
| `archived/` | Reserved for no-longer-maintained projects, kept for reference only — do not deploy on a live server without review. Tracked in `archived/archive.json`; see `archived/README.md`. |
| `scripts/lint_datapacks.sh` (Mecha 0.101.0) | `build.yml`, step `Lint datapacks` - enforced | `.mcfunction` **command syntax** for every pack not in `IGNORE_PATHS` | Whether the pack **loads**, whether references resolve, whether behaviour is correct |
| `./gradlew checkPacks` | `build.yml` via `check` | `pack.mcmeta` shape and format range, JSON validity, cross-references between packs | Command semantics |
| `./gradlew checkOriginWatermarks` | `build.yml` via `zipPacks` | every pack carries `data/<namespace>/function/_vc_origin.mcfunction` | Content of the watermark (covered by the next row) |
| `python3 scripts/origin_watermarks.py --check` | `build.yml`, step `Check provenance watermark content` | every watermark equals what the template generates for its pack and namespace, and contains only comments (a no-op) | That the pack's code is what the watermark claims; it proves consistency, not authorship |
| `./gradlew mergeDatapacks` | `build.yml`, step `Build merged datapack` | load/tick reference resolution (`strictLoadRefs`), pack-format agreement across the merged set | Runtime behaviour |
| `./gradlew buildAll` / `lint` | `build.yml` | the **Gradle** side only (`mods/`) | Anything under `packs/` |
A green CI run therefore says the repository *parses and builds*. It has never
said a datapack behaves correctly - that still needs a load test in a real
world, which is what the `NOTICE.md` checklist asks for.
```

## From `CONTRIBUTING.md`

```text
Gradle/datapack split in this monorepo (what's built by `buildAll` and what
isn't), what a PR should contain, and what will get a PR closed
- Make sure the **`CI`** workflow is green before requesting review. Inside its `Verify & package` job the steps that can fail you are `Build all subprojects` (`./gradlew buildAll`), `Gradle lint` (`./gradlew lint`) and `Lint datapacks` (`scripts/lint_datapacks.sh`, Mecha); `Release gate` then blocks publishing if any of them failed.
- Describe what changed and why in the PR description — and whether the change touches `mods/`, `packs/`, or both, since only the former is covered by `buildAll`.
This project follows a security-first development philosophy, particularly around Minecraft datapack macro injection risks and namespace isolation. If you find a security issue, do **not** open a public issue - use [GitHub's private vulnerability reporting](https://github.com/vortaforge/core/security/advisories/new), and fall back to a detail-free public issue only if that is unavailable to you. The full procedure, including what must not be included in a report, is in [SECURITY.md](SECURITY.md).

## Provenance watermark (`_vc_origin.mcfunction`)

Every datapack under `packs/` carries a `_vc_origin.mcfunction` file (under
`data/<namespace>/function/`) that `build.gradle`'s `zipPacks` task checks
for before packaging. This file is not build output and should not be
removed, renamed, or hand-edited in `packs/` by a contributor's PR —
`zipPacks` treats a missing watermark as a build failure, and the project
maintainers ask that it stay untouched in the source tree. Only `build.gradle`
itself (via its `build/packs-remap/` working copy, never `packs/`) and
maintainers acting through the project's own tooling are expected to
touch these files. That tooling is `scripts/origin_watermarks.py`:
`--write` regenerates every watermark from one template, `--check` (run in CI)
rejects hand edits and any executable line, `--report` lists packs and namespaces. This is a contribution-conduct expectation, not a
license restriction — the Unlicense in `LICENSE` continues to govern
what anyone may do with a copy of this code once obtained.
```

## From `AGENT.md`

```text
- Minecraft Java Edition datapacks and Fabric mods (Mojang mappings).
- `packs/` contains the individual datapacks; `packs/merge-manifest.json` drives the `mergeDatapacks` task.
- `lint`: `bash scripts/lint_datapacks.sh` (datapack lint)
- In `merge-manifest.json`, `output.min_format` / `output.max_format` must match the format of the included packs.
- Every loadable datapack needs a top-level `pack.mcmeta`.
3. Check version/format consistency against the rules above.

## Known issues
- `packs/RTWrapper` has no top-level `pack.mcmeta` (nested under `datapack/RTWrapper-Datapack/`); not directly loadable.
```

## From `CLAUDE.md`

```text
A monorepo of Minecraft Java Edition projects: Fabric mods (`mods/`), datapacks and resource packs
(`packs/`), tooling (`scripts/`), examples (`examples/`) and read-only reference material (`archived/`).
Unlicense (`LICENSE`); third-party code keeps its own license (`packs/macroEngine-Datapack-v26.3/THIRD_PARTY_LICENSES.md`).
   server. Static checks (Mecha, Gradle build, script `--check` modes) are fine.
8. Do not rename runtime identifiers (datapack namespaces such as `data/vortacraftmc/`, scoreboard fake players such
   as `#vortacraftmc.*`, the Java package `com.vortacraftmc`) without an explicit migration plan: that breaks existing
   worlds and dependents.
| `packs/` | Datapacks and resource packs; `macroEngine-Datapack-v26.3` is the largest; `merge-manifest.json` drives the merged datapack |
| `scripts/` | `lint_datapacks.sh` (Mecha), `origin_watermarks.py`, `gui_generator`, `dpgen`, `dp-depman`, audit helpers |
scripts/lint_datapacks.sh               # Mecha validation of all datapacks (needs `pip install mecha==0.101.0`)
python3 scripts/origin_watermarks.py --check   # watermark headers up to date; use --write to regenerate
CI (`.github/workflows/build.yml`) runs these on Java 25 and Python 3.9 / 3.12. Actions are pinned by commit SHA;
Known: the pinned Mecha reports two errors on `time query minecraft:day` (26.3 World Clocks syntax it does not
know yet). They are not bugs in the pack.

## Datapack conventions (macroEngine)

- Public functions live under `api/`, internals under `core/internal/`, shared helpers under `systems/`.
- **Never substitute untrusted text into a macro line.** Validate names with `systems/validate/safe_name` while the
  value is still data in storage, then pass it as a macro argument. See `api/perm/require` and `api/store/*`.
- Prefer storage in, storage out. Plain strings over text components unless the caller needs a component.
- `api/store/*` is the single storage module (variables, `api/store/nbt/*`, templates); the old `api/placeholder/*` and `api/data/*` modules are gone (`docs/store.md`).
- Keep `pack.mcmeta` `min_format`/`max_format` in sync with the targeted Minecraft version; do not guess pack formats.
```

## From `scripts/README.md`

```text
| [`lint_datapacks.sh`](lint_datapacks.sh) | `build.yml`, step **Lint datapacks** — enforced | Installs Mecha (pinned, `MECHA_VERSION`) and validates `.mcfunction` **command syntax** for every pack not in `IGNORE_PATHS`. Propagates Mecha's exit status; `LINT_WARN_ONLY=1` makes one run advisory. Does **not** load packs or resolve references. |
| [`check_archive.py`](check_archive.py) | by hand (mirrors `./gradlew checkArchive`) | Validates `archived/archive.json` against its schema, and that nothing registered as archived is still under `packs/` or still in `merge-manifest.json`. Stdlib only, no network. |
| [`fix_text_components.py`](fix_text_components.py) | by hand | Rewrites `{"storage":…,"nbt":…}` text components so they set `interpret` and `plain` explicitly. On 26.1+ a missing pair makes a string render **with its quotes** and a number or boolean render with vanilla colouring. Referenced from `packs/macroEngine-Datapack-v26.3/README.md`. |
## Self-contained tools
Each has its own README, licence and dependency manifest, and is versioned
independently of the repository tooling above.

| Directory | What it is | Manifest |
|---|---|---|
| [`dp-depman/`](dp-depman/) | Dependency resolver and editor for datapacks that declare a `datapack_depends.json`. | `datapack_depends.lock` |
| [`dpgen/`](dpgen/) | Generates a datapack from a YAML description, so generated files do not have to be checked in. | `package.json` |
| [`gui_generator/`](gui_generator/) | `guigenmc` — generates the `guikit` in-game GUI datapack from a menu spec; ships a browser UI and a test suite. | `pyproject.toml`, `requirements.txt` |

`dpgen` and `gui_generator` are the two directories Dependabot watches
(`.github/dependabot.yml`); `build.yml` runs the `guigenmc` tests on Python 3.9
and 3.12.

## Removed from here

`apply_audit_fixes.py`, `fix_macro_lines.py`, `datapack_risk_scan.py` and
`datapack_lock/check_lock.py` were deleted on 2026-10-08. The first two were
one-off fixers from a single audit session whose changes were already
committed; `check_lock.py` implemented a lock that nothing invoked, against a
workflow that never existed. If you are looking for one of them, that is why it
is gone — see the commit that removed them for the evidence.
```
