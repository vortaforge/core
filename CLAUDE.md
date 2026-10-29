# CLAUDE.md

Guidance for Claude / Claude Code when working in `vortaforge/core`. Read it before changing anything.

## What this repo is

A monorepo of Minecraft Java Edition projects: Fabric mods (`mods/`), datapacks and resource packs
(`packs/`), tooling (`scripts/`), examples (`examples/`) and read-only reference material (`archived/`).
It is an independent project, not affiliated with Mojang or Microsoft. Everything is released under the
Unlicense (`LICENSE`); third-party code keeps its own license (`packs/macroEngine-Datapack-v26.3/THIRD_PARTY_LICENSES.md`).

Publishing history: `runtoolkit` -> `vortacraftmc` -> `vortaforge`. The older organizations are archived and stay
as they are.

## Hard rules

1. **Never delete or rewrite history, repositories or organizations.** No force-push, no `git filter-repo`, no
   repo or org deletion. Archive instead.
2. **Never put a token, password or key into any file** (code, workflows, docs, commit messages). Credentials
   come from the environment (`GH_TOKEN`, Actions secrets). If one shows up in a prompt, do not repeat it and tell
   the maintainer to revoke it.
3. **Mark AI involvement explicitly.** Commits and code written by Claude say so in the commit text, and every such
   change gets an entry in `CREDITS.md` (what changed, review status, what was not verified).
4. **Push fixes to a branch; do not hand out `.patch` files.**
5. **English only** in code, comments, commit messages, issue/PR text and docs. Translation files (`lang/tr_tr.json`)
   and the Turkish letter tables in the text engine are the only non-English content.
6. **Do not claim something works unless it was run.** Say what was linted, built or only read.
7. **Do not run tests on or against a Minecraft server.** No self-test functions, no test harnesses that need a game
   server, no RCON, no live-game smoke tests, and an AI agent never starts a server itself. Static checks (Mecha, Gradle
   build, script `--check` modes) are fine. **One documented exception:** the CI job `.github/workflows/ward.yml`
   (`scripts/ward_ci.sh`, mcward pinned to 1.4.0) runs datapack tests on a throw-away server that is loopback-only,
   whitelist-enforced, verified by `scripts/ward_guard.py` and deleted afterwards. It runs on GitHub-hosted runners only,
   is never run locally by an agent, and must not be loosened (no non-loopback bind, no open whitelist, no skipped
   verification, no skipped cleanup).
8. Do not rename runtime identifiers (datapack namespaces such as `data/vortacraftmc/`, scoreboard fake players such
   as `#vortacraftmc.*`, the Java package `com.vortacraftmc`) without an explicit migration plan: that breaks existing
   worlds and dependents.

> **⚠️ Warning - a Minecraft server is started in exactly one place.** `.github/workflows/ward.yml` (via `scripts/ward_ci.sh`) runs datapack tests with mcward on a throw-away Fabric server on a GitHub-hosted runner. It is bound to `127.0.0.1`, whitelist enforced and empty, verified loopback-only by `scripts/ward_guard.py` before and after the tests, and deleted afterwards. Nothing else in this repository starts, connects to or tests against a Minecraft server. Never run that script on a developer machine, a production host or next to a real world.

## Layout

| Path | Contents |
|---|---|
| `mods/` | Fabric mods (Gradle subprojects, each with its own `build.gradle` and Minecraft/Java version) |
| `packs/` | Datapacks and resource packs; `macroEngine-Datapack-v26.3` is the largest; `merge-manifest.json` drives the merged datapack |
| `scripts/` | `lint_datapacks.sh` (Mecha), `origin_watermarks.py`, `gui_generator`, `dpgen`, `dp-depman`, audit helpers |
| `examples/` | Example mods |
| `archived/` | Reference only. Do not deploy and do not fix |
| `index.html`, `robots.txt`, `sitemap.xml`, `banner.png` | Source files for the intended GitHub Pages download page and its SEO files. Pages was not enabled at the 2026-10-29 audit (`vortaforge.github.io/core/` returned 404), so do not describe the site as live until Settings -> Pages says otherwise |

## Commands

```bash
./gradlew verifyProject                 # canonical offline validation task graph
./gradlew packageProject -PconfirmZip=yes # build modules and release archives
./gradlew ci -PconfirmZip=yes           # verifyProject + packageProject
./gradlew buildAll                      # focused compatibility task: build every subproject
./gradlew lint                          # focused compatibility task: Gradle lint
scripts/lint_datapacks.sh               # Mecha validation (needs `pip install mecha==0.101.0`)
python3 scripts/origin_watermarks.py --check   # watermark headers up to date; use --write to regenerate
python3 -m pytest scripts/gui_generator/tests scripts/tests   # offline tests; `npm test` in scripts/dpgen
# scripts/ward_ci.sh starts a Minecraft server - CI only (see the warning above); never run it by hand
```

CI (`.github/workflows/build.yml`) delegates to the read-only reusable
`.github/workflows/quality.yml`, whose canonical check is `./gradlew ci
-PconfirmZip=yes` on Java 25 and Python 3.12. guigenmc declares Python 3.9+
support, but no Python 3.9 CI job currently exists; do not describe the
minimum version as CI-tested. Only the artifact-only publish job receives
write permission. Actions are pinned by commit SHA; keep it that way and keep
`permissions` minimal.

GitHub-side workflow enablement is not in git. At the 2026-10-29 audit,
`ai-agent.yml` and `ward.yml` were manually disabled in GitHub Actions. Their
files may be edited and statically checked, but no run, review or Ward test
must be claimed for that period unless the Actions settings were changed and
a run is linked as evidence.

Known: the pinned Mecha reports two errors on `time query minecraft:day` (26.3 World Clocks syntax it does not
know yet). They are not bugs in the pack.

## Datapack conventions (macroEngine)

- Public functions live under `api/`, internals under `core/internal/`, shared helpers under `systems/`.
- **Never substitute untrusted text into a macro line.** Validate names with `systems/validate/safe_name` while the
  value is still data in storage, then pass it as a macro argument. See `api/perm/require` and `api/store/*`.
- Prefer storage in, storage out. Plain strings over text components unless the caller needs a component.
- `api/store/*` is the single storage module (variables, `api/store/nbt/*`, templates); the old `api/placeholder/*` and `api/data/*` modules are gone (`docs/store.md`).
- Keep `pack.mcmeta` `min_format`/`max_format` in sync with the targeted Minecraft version; do not guess pack formats.

## Java / Gradle conventions

- Each mod pins its own Minecraft, Fabric Loader, Fabric API and Java version. Keep them consistent inside a mod and
  check current versions before bumping.
- No network calls or desktop APIs in mod code unless the mod's purpose requires it and it is documented.
- Permission checks go through the mod's permission layer; do not hard-code operator levels in new code.

## Web (`index.html`)

- Single static file, no build step. External scripts only from hosts the page already uses.
- Anything that comes from the GitHub API or from an error message must be escaped (`escapeHtml`) before it goes
  into `innerHTML`.
- Keep `canonical`, Open Graph, JSON-LD and `sitemap.xml` in step with the Pages URL (`https://vortaforge.github.io/core/`).

## Before you finish a task

- Run the relevant check from "Commands" and report the result honestly.
- Add or update the `CREDITS.md` entry for what you changed.
- Do not leave tokens, `.patch` files or generated junk in the tree.
