# blocklist/

> [!WARNING]
> **This file is public and will be read by the person who is blocked.** Every entry must state a *policy decision*, not a personal accusation. An entry without a reason is rejected by the tests.

Account-level blocklist for the retired datapack programme.

- `blocklist.json` — the list itself (schema: the file's own `$comment`s and
  the table below). Read by `scripts/repo/datapack_guard.py` and mirrored
  organisation-wide by `vortaforge/.github`.
- Enforcement points: `scripts/git/hooks/pre-commit`, `scripts/git/hooks/pre-push`, the
  `datapack-guard` job in `.github/workflows/quality.yml`, and the
  `Datapack blocklist sync` workflow in `vortaforge/.github`.

## The override label

`datapack-approved` is the only override, and it is deliberately narrow:

- It clears entries whose `enforcement` is `review`. It becomes a warning, not
  a pass, so the override is still visible in the guard report.
- It does **not** clear `enforcement: block` entries, and it does not touch
  content rules: a new datapack under `packs/` is refused with or without the
  label.
- It does not disable the archive-registry or kill-switch checks.

## What an entry means

| Field | Meaning |
|---|---|
| `id` | Stable id, `[a-z0-9-]+`. Referenced by copies in `.github/blocklist/`. |
| `reason` | Required. A block without a written reason is a bug; `check_archive`-style review will reject it. |
| `enforcement` | `block` (refuse outright) or `review` (refuse, but a maintainer may clear it with the `datapack-approved` label). Only these two are accepted; anything else fails the blocklist load. |
| `scope` | Where it applies: `pull_request`, `push`, `org_membership`. Omit it to apply everywhere. An unknown or empty value fails the blocklist load rather than being silently ignored. |
| `logins` | Exact GitHub logins, lower-case. **No wildcards** in this file — a pattern like `misode*` would also match unrelated accounts. |
| `user_ids` | Optional immutable numeric ids; survive a login rename. Get them with `gh api users/<login> --jq .id`. Enforced by `--login-id`, which `quality.yml` feeds from the pull request payload; the login check on its own cannot see a rename, so an entry with ids is only rename-proof when the caller supplies the id. |
| `ref_patterns` | Branch/tag *name* globs (e.g. `*/misode*`) used by `--audit-refs` / the sync job. |
| `match_bot_suffix` | Match any login ending in `[bot]`, `-bot`, `_bot`, `.bot`. |
| `match_ai_accounts` | Match AI-agent-looking logins (see the entry's `notes`). |

Accounts in `managed.accounts` / `managed.owners` are **never** matched by the
broad rules. Put your own bots there instead of in `blocked`.

## Blocking a developer

```bash
# 1. Find the immutable id (survives renames)
gh api users/<login> --jq '.id'

# 2. Add an entry and validate it
$EDITOR blocklist/blocklist.json
python3 scripts/repo/datapack_guard.py --audit-refs --blocklist

# 3. Mirror it org-wide (from the vortaforge/.github repository)
python3 scripts/blocklist_sync.py --check
```

Do not add someone for a technical disagreement. Write down in `reason` what
happened and which policy decision it maps to; this file is public and will be
read by the blocked person.

## What this list blocks, and what it no longer blocks

Two categories, both about **behaviour**, not about people:

| Entry | What it matches |
| --- | --- |
| `bot-accounts` | Logins ending in `[bot]`, `-bot`, `_bot` or `.bot`. |
| `ai-agent-accounts` | Logins containing a vendor or agent token as a **whole** token between separators - never as a substring, because `"claude" in login` also matches `claudette`. |

Plus `managed.accounts`, which are never enforced against, and the
`user_ids` mechanism, which survives a rename by matching the numeric id instead
of the login.

Removed on 2026-11-08: the entry for a named datapack tooling author, and an
entry that collected seven more datapack tooling authors under one id. Both said
in their own `reason` that they were policy rather than accusation - the policy
being that a retired programme's authors were not invited to maintain it. That
policy is now enforced where it belongs: `datapacks.disabled.json` and
`datapack_guard.py` decide what may exist in this repository, and a file listing
human names could only ever decide who is allowed to be a person here. Both
entries are gone, and the profile-scanning mechanism that existed to find more
of the same is gone with them.

Two things that removal costs, stated rather than hidden:

* **`user_ids` is empty in every remaining entry.** The mechanism is tested
  (`test_a_renamed_account_is_caught_by_its_id`) against a fixture, not against
  production data, because there is no production id left to test it with.
* **Nothing now catches a datapack author who is not a bot.** That is the
  intended trade: the guard blocks datapack *content* unconditionally, which is
  both more effective and not a judgement about a person.

## Removing an entry

## Removing an entry

Remove it from `blocked`, run `--audit-refs --blocklist` and `--check-archive`,
and say why in the commit message. Exemptions are permanent record: prefer
moving a login into `managed.accounts` over deleting the entry if the person
should keep contributing to mods.
