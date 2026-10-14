# archived/

Frozen, reference-only projects. **Do not deploy on a live server without review.**

## Contents

| Path | What it is |
|---|---|
| `data-packs/packs/` | Every datapack and resource pack that used to live in `packs/`, including `merge-manifest.json` |
| `data-packs/other/` | Datapack tooling and templates: `scripts/` (dp-depman, dpgen, gui_generator, lint, text-component and watermark helpers), `examples/template-datapack`, the datapack issue form (`github/`), and `docs/removed-doc-sections.md` (datapack text removed from the root docs) |
| `tasks/` | Datapack Gradle tasks (`datapack-tasks.gradle`) and CI workflow pieces (`workflows/`). Not loaded by Gradle or GitHub Actions |

All datapacks were archived on 2026-10-14 when the repository moved to Fabric mods only. Nothing here is built, zipped, merged, linted or run by CI: `settings.gradle` scans `mods/` and `examples/` only, and `archived/` is deliberately outside both. The moved files were not re-checked after the move, and relative paths inside them (for example scripts that expect to run from the repository root against `packs/`) may no longer work.

`archive.json` is the registry (schema: `archive.schema.json`). Validate with:

    ./gradlew checkArchive             # also runs as part of `check`
    ./gradlew printArchiveList         # list registry entries
    python3 scripts/check_archive.py   # standalone, no Gradle needed

`checkArchive` fails if a registered `path` does not exist or is not inside `archived/`.

## Archiving a project

1. `git mv <path> archived/<path>` (or set `"path": null` if the code lives elsewhere).
2. Add an entry to `archive.json`: `status`, `archived_on`, `reason`, `last_version`,
   `license`, `deploy`, `successor`, and any `known_issues`.
3. Update the project's README with a pointer to its successor.
4. Run `./gradlew checkArchive`.

## Restoring

Move the folder back out of `archived/` and delete its registry entry. For datapacks, also restore the Gradle tasks from `tasks/datapack-tasks.gradle` and the CI steps from `tasks/workflows/` (the header of `datapack-tasks.gradle` says how), and re-add `packs` to `SCAN_ROOTS` in `settings.gradle`.

## Rules

- Only fixes for significant issues; no feature PRs against archived projects (see `NOTICE.md`).
- Keep each project's `LICENSE` and `THIRD_PARTY_LICENSES.md` intact.
- Low-risk findings in archived projects are documented in `known_issues`, not necessarily fixed (see `SECURITY.md`).
