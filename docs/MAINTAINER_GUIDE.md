# Maintainer guide

This is the human-facing project guidance for `vortaforge/core`. It preserves
project rules and technical context previously kept in the AI-specific
instruction files, without requiring an automated AI agent.

## Project and provenance

**Datapacks are retired (2026-11-05).** This monorepo now ships Fabric mods
only; every datapack, datapack generator, linter and test harness is archived
and disarmed in `archived/archive.json` and blocked by
`scripts/datapack_guard.py`. See `docs/ARCHIVAL.md`. The historical
`archived/packs/macroEngine-Datapack-v26.3/THIRD_PARTY_LICENSES.md` is kept
intact for reference.

It also contains historical reference material and example Fabric mods. It is
independent of Mojang and Microsoft. The repository uses the Unlicense
(`LICENSE`); third-party code retains its own licences.

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
   `_vc_origin.mcfunction` watermarks (now under `archived/`), historical
   records, `CREDITS.md` and third-party licence notices intact. Pin
   third-party Actions by commit SHA and give workflows the minimum required
   permissions.
10. **Do not re-arm the datapacks.** `datapacks.disabled.json` must stay
    `"enabled": false`; `archived/archive.json` entries must stay
    `"disarmed": true`; the guard and the `datapack-guard` CI job must not be
    weakened or bypassed. Re-enabling is a deliberate, reviewed decision with a
    written reason (see `docs/ARCHIVAL.md`), never a side effect of a cleanup.

> **⚠️ Warning - a Minecraft server used to be started in exactly one place,
> and that place is archived.** The Ward harness and its workflow now live in
> `archived/tools/ward/` and are inert (no workflow file under
> `.github/workflows/`). Never run `ward_ci.sh` on a developer machine, a
> production host or a real world. Nothing live starts a Minecraft server.

## Repository layout

| Path | Contents |
|---|---|
| `mods/` | Fabric mods, each with its own Gradle subproject and version pins. |
| `packs/` | **Empty.** Datapacks were retired on 2026-11-05; the guard refuses new content here. |
| `blocklist/` | Account blocklist enforced by the guard (mirrored by `vortaforge/.github`). |
| `.githooks/` | `pre-commit` / `pre-push` guard hooks (`git config core.hooksPath .githooks`). |
| `datapacks.disabled.json` | The datapack kill switch (`"enabled": false`). |
| `scripts/` | Lint, provenance, audit, backup and self-contained developer tools. |
| `examples/` | Example mods and packs. |
| `archived/` | Every retired project and the extracted datapack Gradle logic; do not deploy without review. |
| `index.html`, `.nojekyll`, `robots.txt`, `sitemap.xml`, `banner.png` | Static site source and related metadata. Pages enablement is a GitHub setting; verify it before calling the site live. |

## Validation map

The canonical checks and their prerequisites are documented in `README.md`.
In brief:

```bash
./gradlew verifyProject                  # guard + kill switch + archive registry + tests
./gradlew checkDatapackSwitch checkArchive
./gradlew packageProject
./gradlew ci
./gradlew buildAll
./gradlew lint
python3 scripts/datapacks_disable.py verify
python3 scripts/datapack_guard.py --staged --protect --blocklist
python3 -m unittest discover -s scripts/tests -v
python3 -m pytest scripts/gui_generator/tests
# Archived (nothing invokes these): archived/tools/lint_datapacks.sh,
# archived/tools/ward/ward_ci.sh, archived/tools/build-release/build_release.py,
# scripts/origin_watermarks.py --check (still present, no longer wired)
```

`verifyProject` is the canonical repository-validation graph: the datapack
guard, the kill switch, the archive registry, the mod checks and the Python/Node
suites. `packageProject` builds the Fabric modules and the inventory. Nothing
in the live graph touches a datapack. The archived Spyglass/JSON linter
(`archived/tools/datapack-lint/README.md`) and the archived Ward harness are
reference only; the Ward harness **starts a Minecraft server and must never be
run by hand**.

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
  `api/placeholder/*` and `api/data/*` modules are gone (`docs/store.md`).
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
