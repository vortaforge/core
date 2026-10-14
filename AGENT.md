# Agent Guidelines

Context the AI agent reads on every run. Keep it short and factual.

## Project
- Minecraft Java Edition Fabric mods (Mojang mappings). All datapacks are archived under `archived/data-packs/`.
- Target version: Minecraft 26.3. Production server runs 26.2.

## Checks available to the agent
- `audit`: `python3 scripts/audit_repo.py` (repository structure audit)
- `lint`: `./gradlew lint --continue` (Gradle lint)

## Rules
- Static checks only: lint, build, reading files. Never suggest or run tests on the live server.
- Never delete git history, repositories or organizations. Retire things by hiding or archiving.
- Never put tokens or secrets into code, comments or logs.
- Do not claim a change works unless a check actually passed. If a check could not run, say so.

## Review checklist for PRs
1. Summarize what the diff changes (files, intent).
2. Run `audit` and `lint`; report findings with file paths.
3. Check version consistency (Minecraft, Fabric Loader, Fabric API, Java) inside each mod.
4. List concrete problems first, then minor notes. Do not pad with praise.
