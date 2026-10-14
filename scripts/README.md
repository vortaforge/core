# scripts/

Helper tooling for this monorepo. `NOTICE.md` treats everything here as
**lower trust by default** - read a script before running it, especially
`backup-org.sh`, which handles a token with org-wide read access.

There was previously no index for this directory: six scripts and three
self-contained tools sat side by side with nothing saying what any of them did,
which is why three one-off fixers from a single audit session were still
checked in and looked like part of the toolchain. They were removed; this file
exists so the next reader does not have to reconstruct the difference.

## Repository tooling

| Script | Run by | What it does |
|---|---|---|
| [`audit_repo.py`](audit_repo.py) | by hand | Working-tree consistency audit: `pack.mcmeta` shape and format ranges, plural/singular data folders, load/tick references, merge-manifest coherence, broken Markdown links, dangling workflow references, CI shape, and commit-message quality. Also flags invalid NBT paths (`[N]{}`, which Mecha and the game both reject), unresolvable load/tick tag values, and stale branches. `--json` / `--format github` for machine output, `--fail-on <severity>` to use it as a CI gate (exit 0 by default), `--min-severity`, `--only`/`--skip` to filter, `--fix [--dry-run]` for the safe file fixes; deleting remote branches additionally needs `--delete-stale-branches` and only ever touches fully merged, unprotected branches. |
| [`audit_full.py`](audit_full.py) | by hand | Superset of the above that also queries GitHub: org plan and 2FA policy, repository settings and topics, workflow/action pinning, and Dependabot/secret-scanning state. Calls `audit_repo.py` for the local half. Needs a token. |
| [`check_archive.py`](check_archive.py) | by hand (mirrors `./gradlew checkArchive`) | Validates `archived/archive.json` against its schema and that every registered path exists inside `archived/`. Stdlib only, no network. |
| [`backup-org.sh`](backup-org.sh) | `backup-org.yml`, or by hand | Full organization backup: bare git clones, wikis, issues/PRs/releases, Actions/Dependabot/security metadata, team membership and repo access, topics and languages, org settings — then sanitises credentials out of the metadata, archives it (optionally encrypted) and verifies the result. |

```bash
bash scripts/backup-org.sh --help          # full flag list
bash scripts/backup-org.sh --dry-run       # rehearsal; writes nothing but the log
python3 scripts/audit_repo.py              # local consistency report
```

## Archived tools

`dp-depman/`, `dpgen/`, `gui_generator/` (guigenmc), `lint_datapacks.sh`, `fix_text_components.py` and `origin_watermarks.py` were datapack tools. They moved to `archived/data-packs/other/scripts/` on 2026-10-14 together with the datapacks. CI does not run them and they were not re-checked after the move.
