# scripts/

> [!WARNING]
> **Buradaki her betik "düşük güvenilirlik" varsayılanıyla ele alınır** (`NOTICE.md`). Çalıştırmadan önce okuyun; ayrıcalıklı kimlik bilgileriyle kalite araçları çalıştırmayın.

Helper tooling for this monorepo. `NOTICE.md` treats everything here as
**lower trust by default**: inspect code and dependencies before use, and
avoid running quality tooling with privileged credentials.

## Repository tooling

| Script or test | Role when explicitly run |
|---|---|
| [`datapack_guard.py`](datapack_guard.py) | **The gate.** Fail-closed policy: no new datapack content, no revived archived tooling, no blocklisted accounts, kill switch engaged, registry consistent. Runs in `pre-commit`, `pre-push`, CI (job `datapack-guard`) and Gradle (`guardArchives`). |
| [`datapacks_disable.py`](datapacks_disable.py) | The kill-switch CLI: `status`, `disable`, `enable --token ... --reason ...`, `verify`. |
| [`check_archive.py`](check_archive.py) | Validates `archived/archive.json` (schema v2): shape, hard-disable flags, path bijection, no workflows under `archived/`, empty `packs/`. Stdlib only. |
| [`tests/`](tests/) | Python regression tests: guard/blocklist/switch behaviour, archive invariants, workflow-action pinning, credential patterns, credential-shape scan, the static site's retirement notices, plus offline tests for the archived Ward guard and release builder. |
| [`origin_watermarks.py`](origin_watermarks.py) | Checks or generates the no-op provenance watermarks. `--check` does not modify sources. Kept for the archived packs; no build step invokes it any more. |
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
| [`gui_generator/`](gui_generator/) | `guigenmc` — generates a GUI datapack from a menu spec; ships a browser UI and tests. | `pyproject.toml`, `requirements.txt` |

`guigenmc` emits datapack output, so it is a generator: its output cannot be
checked into `packs/` (the guard blocks it), and using it is a deliberate,
local act, not a repository contribution. `archived/tools/dpgen` was retired
with the programme.

Dependabot configuration used to watch `scripts/dpgen` and
`scripts/datapack_lint`; those paths are archived, so their entries were
removed. `scripts/gui_generator` is still watched. Dependency proposals require
human review. The configured quality workflow tests guigenmc on Python 3.12
only; its declared Python 3.9 minimum is not covered by that job.

## Removed from here

`apply_audit_fixes.py`, `fix_macro_lines.py`, `datapack_risk_scan.py` and
`datapack_lock/check_lock.py` were deleted on 2026-10-08. The first two were
one-off fixers from a single audit session whose changes were already
committed; `check_lock.py` implemented a lock that nothing invoked, against a
workflow that never existed. `dp-depman/` and the two audit scripts were
retired in the 2026-10-30 cleanup. Git history preserves their provenance.

## Ward test server (archived)

> **Warning: this path used to start a Minecraft server.** The Ward harness
> (`ward_ci.sh`, `ward_guard.py` and `.github/workflows/ward.yml`) was archived
> on 2026-11-05 into `archived/tools/ward/`. The workflow file is no longer
> under `.github/workflows/`, so GitHub does not run it, and nothing in the live
> repository starts, connects to or tests against a Minecraft server. Never run
> the archived script on a developer machine, a production host or next to a
> real world.

- `archived/tools/ward/ward_ci.sh` orchestrated install, lockdown, tests and
  cleanup; it refused to run outside GitHub Actions.
- `archived/tools/ward/ward_guard.py` seeded locked `server.properties`,
  checked listeners and discovered packs with Ward tests.
- `tests/test_ward_guard.py` still runs in the normal suite against the
  archived module, so the isolation rules stay asserted if it is ever restored.
