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
