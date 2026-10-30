# scripts/

Helper tooling for this monorepo. `NOTICE.md` treats everything here as
**lower trust by default**: inspect code and dependencies before use, and
avoid running quality tooling with privileged credentials.

## Repository tooling

| Script or test | Role when explicitly run |
|---|---|
| [`lint_datapacks.sh`](lint_datapacks.sh) and [`datapack_lint/`](datapack_lint/README.md) | Spyglass 0.4.70 static diagnostics plus a separate strict JSON parser, with per-file coverage enforcement and explicit Ward/permission exceptions. Uses Node 20+ and a pinned lock; may download vanilla data. No Minecraft server. |
| [`tests/`](tests/) | Python regression tests, including focused repository safeguards, workflow-action pinning, pack/merge invariants, credential patterns, release packaging and offline Ward-guard tests. |
| [`check_archive.py`](check_archive.py) | Validates `archived/archive.json` against its schema and that registered archives are not still under `packs/` or in the merge manifest; stdlib only. |
| [`origin_watermarks.py`](origin_watermarks.py) | Checks or generates the no-op provenance watermarks. `--check` does not modify sources. |
| [`fix_text_components.py`](fix_text_components.py) | Rewrites selected text components; it can change files, so review it and the diff before use. |
| [`backup-org.sh`](backup-org.sh) | Historical organization-backup tool. **Do not assume even `--dry-run` is non-destructive:** its current paths can remove or overwrite files. It handles privileged organization data and needs a separate safety review before any use. It was not run as part of this cleanup. |

`verifyProject` wires the static linter and regression suites into the Gradle
graph, along with provenance, mod, pack and archive checks. The workflow
configuration describes that graph; it does not itself mean GitHub workflows
are enabled or have run. Publishing remains paused pending human validation.
See [`datapack_lint/README.md`](datapack_lint/README.md) for setup, network,
cache, security override, exclusions, version coverage and warning semantics.
Ward test files remain in source but are excluded from runtime pack ZIPs.
Generated pack-root build output is also omitted; nested datapack function
paths named `build` are retained. Normal Gradle packaging clears and recreates its generated `build/` output
locations; keep personal files elsewhere. The merge dry-run now returns before
clearing or creating its output directory.

## Audit retirement and coverage gaps

`audit_repo.py` and `audit_full.py` were removed in the 2026-10-30 cleanup;
`auditRepository` is no longer a Gradle task. The independent regression
checks in `tests/test_repository_safeguards.py` retain selected safeguards:
pack metadata and layout, load/tick tag shape and required function targets,
static merged-function references and merge-manifest checks, invalid indexed
NBT path patterns, common credential shapes, and license consistency. Other
existing tests check workflow action pinning, ZIP contents, archive rules and
provenance. Negative fixtures exercise several of these checks.

These are **not a full replacement** for the old audits. In particular:

- Required tag targets are resolved across the repository's pack tree, not
  proven available in every combination of installed packs. Function macros,
  generated or dynamic calls, and all cross-pack runtime effects cannot be
  fully resolved statically.
- Credential matching covers selected common token/key forms in small working-
  tree text files; it skips symlinks, binary files and files over 2 MB. It is not secret
  scanning, does not prove the absence of credentials and does not revoke any.
- The removed scripts' broad Markdown-link, workflow/Gradle reference,
  commit-message, stale-branch and other general repository audit checks are
  not all replicated. Run specialized checks and human review where needed.
- No replacement queries organization/repository settings, branch protection,
  2FA, billing, Dependabot status or other remote GitHub state. No automatic
  fix or remote-branch deletion functionality was carried forward.
- Static tooling cannot establish the safety of dynamic commands or prove
  game behaviour, permissions, compatibility across every supported version,
  or that release assets are suitable for publishing.

## Self-contained tools

Each has its own README, licence and dependency manifest, and is versioned
independently of the repository tooling above.

| Directory | What it is | Manifest |
|---|---|---|
| [`dpgen/`](dpgen/) | Generates a datapack from a YAML description. | `package.json` |
| [`gui_generator/`](gui_generator/) | `guigenmc` — generates a GUI datapack from a menu spec; ships a browser UI and tests. | `pyproject.toml`, `requirements.txt` |

Dependabot configuration watches `scripts/gui_generator`, `scripts/dpgen`
and `scripts/datapack_lint`. Dependency proposals require human review; the
linter's runtime version pin and decompressor override need coordinated
updates. The configured quality workflow tests guigenmc on Python 3.12 only;
its declared Python 3.9 minimum is not covered by that job.

## Removed from here

`apply_audit_fixes.py`, `fix_macro_lines.py`, `datapack_risk_scan.py` and
`datapack_lock/check_lock.py` were deleted on 2026-10-08. The first two were
one-off fixers from a single audit session whose changes were already
committed; `check_lock.py` implemented a lock that nothing invoked, against a
workflow that never existed. `dp-depman/` and the two audit scripts were
retired in the 2026-10-30 cleanup. Git history preserves their provenance.

## Ward test server (CI only)

> **Warning: this path starts a Minecraft server.** `.github/workflows/ward.yml`
> (via `scripts/ward_ci.sh`) defines datapack tests using mcward on a
> throw-away Fabric server on a GitHub-hosted runner, with loopback binding,
> an empty whitelist, guard checks and cleanup. It was manually disabled at
> the 2026-10-29 audit; its configuration is not evidence of a run. Never run
> that script on a developer machine, a production host or next to a real
> world.

- `ward_ci.sh` orchestrates install, lockdown, tests and cleanup; it refuses
  to run outside GitHub Actions.
- `ward_guard.py` seeds locked `server.properties`, checks listeners and
  discovers packs with Ward tests.
- `tests/` contains offline guard tests; the "server" there is a plain Python
  socket, not Minecraft.
