# Agent Guidelines

Context for the repository AI agent. Keep it short and factual.

> **Live setting checked 2026-10-29:** the `AI Agent` and `Ward` workflows
> were manually disabled in GitHub Actions. Do not claim that either one ran
> for a change unless a current Actions run proves it.

## Project
- Minecraft Java Edition datapacks and Fabric mods (Mojang mappings).
- Target version: Minecraft 26.3. Production server runs 26.2.
- `packs/` contains the individual datapacks; `packs/merge-manifest.json` drives the `mergeDatapacks` task.

## Checks available to the agent
- `verifyProject`: `./gradlew verifyProject` (canonical offline repository validation; requires its Python/Node tools; includes the repository audit and datapack lint below)
- `audit`: `python3 scripts/audit_repo.py` (repository structure audit)
- `lint`: `./gradlew lint` or `bash scripts/lint_datapacks.sh` (datapack syntax lint)
- `packageProject`: `./gradlew packageProject -PconfirmZip=yes` (module and pack release artifacts)

## Rules
- Static checks only: lint, build, reading files. Never suggest or run tests on the live server.
- **Warning:** the only server that is ever started is the isolated, loopback-only Ward test server of
  `.github/workflows/ward.yml` (`scripts/ward_ci.sh`, GitHub-hosted CI only). An agent never runs it locally.
- Never delete git history, repositories or organizations. Retire things by hiding or archiving.
- Never put tokens or secrets into code, comments or logs.
- In `merge-manifest.json`, `output.min_format` / `output.max_format` must match the format of the included packs.
- Every loadable datapack needs a top-level `pack.mcmeta`.
- Do not claim a change works unless a check actually passed. If a check could not run, say so.

## Review checklist for PRs
1. Summarize what the diff changes (files, intent).
2. Run `audit` and `lint`; report findings with file paths.
3. Check version/format consistency against the rules above.
4. List concrete problems first, then minor notes. Do not pad with praise.

## Known issues
- `packs/RTWrapper` has no top-level `pack.mcmeta` (nested under `datapack/RTWrapper-Datapack/`); not directly loadable.
