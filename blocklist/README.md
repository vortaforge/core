# blocklist/

> [!WARNING]
> **Bu dosya herkese açıktır ve engellenen kişi tarafından okunacaktır.** Her girdi bir *politika kararı* yazmalıdır; kişisel bir suçlama değil. Gerekçesiz girdi testte reddedilir.

Account-level blocklist for the retired datapack programme.

- `blocklist.json` — the list itself (schema: the file's own `$comment`s and
  the table below). Read by `scripts/datapack_guard.py` and mirrored
  organisation-wide by `vortaforge/.github`.
- Enforcement points: `.githooks/pre-commit`, `.githooks/pre-push`, the
  `datapack-guard` job in `.github/workflows/quality.yml`, and the
  `Datapack blocklist sync` workflow in `vortaforge/.github`.

## What an entry means

| Field | Meaning |
|---|---|
| `id` | Stable id, `[a-z0-9-]+`. Referenced by copies in `.github/blocklist/`. |
| `reason` | Required. A block without a written reason is a bug; `check_archive`-style review will reject it. |
| `enforcement` | `block` (refuse PRs/pushes), `review` (allow only with the `datapack-approved` label), `org_membership` (do not invite). |
| `scope` | Where it applies: `pull_request`, `push`, `org_membership`, `profile`. |
| `logins` | Exact GitHub logins, lower-case. **No wildcards** in this file — a pattern like `misode*` would also match unrelated accounts. |
| `user_ids` | Optional immutable numeric ids; survive a login rename. Get them with `gh api users/<login> --jq .id`. |
| `ref_patterns` | Branch/tag *name* globs (e.g. `*/misode*`) used by `--audit-refs` / the sync job. |
| `match_bot_suffix` | Match any login ending in `[bot]`, `-bot`, `_bot`, `.bot`. |
| `match_ai_accounts` | Match AI-agent-looking logins (see the entry's `notes`). |
| `profile_scan` | Entry is a placeholder for a login discovered through public-profile scanning; a human confirms or exempts each hit. |

Accounts in `managed.accounts` / `managed.owners` are **never** matched by the
broad rules. Put your own bots there instead of in `blocked`.

## Blocking a developer

```bash
# 1. Find the immutable id (survives renames)
gh api users/<login> --jq '.id'

# 2. Add an entry and validate it
$EDITOR blocklist/blocklist.json
python3 scripts/datapack_guard.py --audit-refs --blocklist

# 3. Mirror it org-wide (from the vortaforge/.github repository)
python3 scripts/blocklist_sync.py --check
```

Do not add someone for a technical disagreement. Write down in `reason` what
happened and which policy decision it maps to; this file is public and will be
read by the blocked person.

## Profile scan (datapack developer detection)

`policy.profile_scan` is performed only by `vortaforge/.github`'s
`.github/scripts/blocklist_sync.py`, with a read-only token, against **public**
profile fields (`bio`, `company`, `name`, `blog`) and only for accounts that
already interacted with the organisation (PR author, issue author, org
invitation). It never reads private data, never scans GitHub globally, and a
hit does not auto-block anyone: it opens an issue in `vortaforge/.github` with
the matched token. Until that issue is resolved the account's pull requests are
refused (fail-closed).

## Removing an entry

Remove it from `blocked`, run `--audit-refs --blocklist` and `--check-archive`,
and say why in the commit message. Exemptions are permanent record: prefer
moving a login into `managed.accounts` over deleting the entry if the person
should keep contributing to mods.
