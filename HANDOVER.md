# Maintainer handover

**Status as of 2026-10-29: handover preparation, not a completed transfer.**
The current maintainer is seeking a successor for the VortaForge organization
and repositories. No successor should be described as the new owner until they
have explicitly accepted the role, have been granted the agreed access, and the
completion checklist below has been recorded.

This document is the technical handover record for `vortaforge/core` and the
companion `vortaforge/.github` repository. It deliberately contains credential
*names* and ownership *locations*, never credential values.

## Preferred transfer model

Keep both repositories in the existing `vortaforge` organization and transfer
organization ownership:

1. The outgoing owner invites the successor to the organization if needed.
2. The successor accepts membership and confirms they can sign in with
   two-factor authentication.
3. The outgoing owner promotes the successor to organization **Owner**.
4. Both owners verify repositories, rulesets, Actions, environments, secrets by
   name, billing ownership, and recovery access.
5. The new owner updates or removes the outgoing owner's billing payment
   method if one exists. Leaving the organization does not update billing.
6. Only after those checks does the outgoing owner step down or leave.

Keeping the repositories under the same organization avoids changing repository
URLs, package namespaces, organization-level settings, and the intended GitHub
Pages address. It also allows a transition period with two owners instead of a
single irreversible handoff moment.

Do not transfer a repository to a personal account merely to make the successor
feel like the owner. A repository transfer is a separate operation: the target
must not already have a repository with the same name or a fork in the same
network, a personal-account recipient must accept within one day, GitHub Pages
URLs are not redirected, and organization-level configuration must be audited
separately. Use it only if the project intentionally leaves the `vortaforge`
namespace.

## Scope being handed over

| Asset | Current state to verify |
|---|---|
| `vortaforge/core` | Public monorepo: Fabric mods under `mods/`, packs under `packs/`, tooling under `scripts/`, examples, archived reference material, workflows, a rolling `packs-latest` release, issues, pull requests, discussions, and the source for the intended Pages download page. |
| `vortaforge/.github` | Organization profile and default community-health files. |
| GitHub organization | Members/owners, teams if any, billing, Apps/OAuth grants, organization rulesets, Actions policy, secrets/variables at organization scope, Projects, Packages, Sponsors settings if any, and profile metadata. These are not fully visible from either git tree. |
| External accounts | Any Modrinth, CurseForge, Discord, domain, package-registry, analytics, email, or social accounts are **not inventoried here**. The outgoing owner must list each account or explicitly state that none exists. |

## Non-negotiable project rules

The successor takes over subject to the repository rules in `CLAUDE.md`. In
particular:

- Never delete or rewrite git history, repositories, or organizations. No
  force-push and no `git filter-repo`; archive instead.
- Never put tokens, passwords, or keys in files, issues, pull requests, commit
  messages, or chat. Rotate any credential that has appeared outside its secret
  store.
- Mark AI involvement explicitly in commit text and `CREDITS.md`, including what
  was not verified.
- Push work to branches; do not distribute loose patch files as the canonical
  change.
- Keep repository content in English except for the documented translation and
  text-engine exceptions.
- Do not claim checks passed unless they were run, and do not describe a bot
  comment, green CI, or a bypass as independent human review.
- Do not run Minecraft-server tests locally. The only server exception is the
  isolated, loopback-only Ward job on GitHub-hosted runners.
- Do not rename runtime identifiers (`data/vortacraftmc/`, `#vortacraftmc.*`,
  `com.vortacraftmc`, and similar) without an explicit world/API migration plan.
- Preserve the Unlicense text, `NOTICE.md`, provenance, and third-party license
  notices.

## Build and validation map

Canonical commands from `README.md` and `CLAUDE.md`:

```bash
./gradlew verifyProject
./gradlew packageProject -PconfirmZip=yes
./gradlew ci -PconfirmZip=yes
./gradlew buildAll
./gradlew lint
scripts/lint_datapacks.sh
python3 scripts/origin_watermarks.py --check
python3 -m pytest scripts/gui_generator/tests scripts/tests
# inside scripts/dpgen:
npm test
```

Requirements include JDK 25 and the included Gradle wrapper. `verifyProject`
covers provenance, repository audit, offline tests, datapack syntax, and
pack/archive metadata. Mecha validates command syntax only; it does not prove
in-game behaviour. The Ward workflow is the sole server-backed validation path
and must never be loosened from its loopback-only, empty-whitelist, verified
cleanup design.

## GitHub automation inventory

Workflow files are in `.github/workflows/`:

| Workflow | Purpose / handover note |
|---|---|
| `build.yml` (`CI`) | Calls the read-only reusable quality workflow. **Automatic publishing is paused** after release assets were deleted contrary to the preservation requirement. The quality workflow still runs; resume publication only after an independently reviewed, append-only design and recovery procedure are ready. |
| `quality.yml` (`Reusable Quality`) | Runs `./gradlew ci -PconfirmZip=yes` and the guigenmc package checks. Its output is evidence only when a real run is linked. |
| `codeql.yml` | CodeQL Advanced analysis on push, pull request, and schedule. |
| `codeowners-sync.yml` | Manual workflow that derives code owners from repository collaborators with push access. It reads through `ORG_READ_TOKEN`; confirm the token's owner, scope, and expiry privately. |
| `backup-org.yml` | Manual organization backup. It uses `ORG_READ_TOKEN`, `BACKUP_ARCHIVE_PASSWORD`, and `BACKUP_ORG`. Confirm where encrypted backups and the password are held; neither belongs in git. |
| `ai-agent.yml` | AI automation. At the 2026-10-29 audit this workflow was manually disabled in GitHub. Before enabling it, confirm the model, API key account, spend limits, and the hardened tool policy in `.github/scripts/ai-agent.js`. |
| `ward.yml` | Isolated datapack server tests in CI. At the 2026-10-29 audit this workflow was manually disabled in GitHub. Do not claim Ward coverage for that period. |

Credential and variable **names** referenced by the current tree:

- Secrets: `BACKUP_ARCHIVE_PASSWORD`, `GEMINI_API_KEY`, `GITHUB_TOKEN`
  (GitHub-provided), `ORG_READ_TOKEN`.
- Variables: `BACKUP_ORG`, `GEMINI_MODEL`.
- Environment: `release`.

For each non-GitHub-provided secret, the incoming owner must record outside git:
the issuing service, account owner, purpose, scope, creation/expiry dates,
whether it is repository-, environment-, or organization-scoped, and the date
it was rotated during handover. GitHub does not reveal stored secret values for
copying. Prefer issuing successor-owned credentials, verifying a harmless run,
and revoking outgoing-owner credentials afterwards.

## Known open items at preparation time

- PR #52 proposes a "Power Tools" workflow with arbitrary shell and history
  rewriting operations. The audit recommendation is to close it without
  merging; if a successor disagrees, they should require a fresh read-only,
  artifact-only design and tests in a new pull request.
- The repository audit reports two pre-existing medium `pack.format-mixed`
  findings. Do not guess pack formats; decide the authoritative field from the
  targeted Minecraft version and verify loading through the approved Ward path.
- GitHub Pages was not enabled at the 2026-10-29 audit although the static
  download page source is in the tree. Confirm the current Pages setting before
  calling the site live.
- The `release` environment name alone is not an approval. Required reviewers
  must be configured in GitHub if manual release approval is intended.
- The full `./gradlew ci -PconfirmZip=yes` graph needs a machine that can fit
  the Fabric/Loom packaging work. A branch is not release-proven until that
  graph or the equivalent GitHub CI run passes.
- Runtime behaviour in a live Minecraft world remains separate from syntax and
  offline test evidence.

## Successor acceptance criteria

Before Owner access is granted, the candidate should be able to:

1. Clone both repositories and run at least `./gradlew verifyProject` or
   explain precisely which prerequisite prevents it.
2. Explain the no-deletion/no-history-rewrite rule, the Ward server exception,
   and the runtime-identifier migration rule.
3. Review one existing pull request and distinguish CI, bot comments, bypasses,
   and independent human approval.
4. Show two-factor authentication is enabled and provide a second recovery
   path that does not depend on the outgoing owner.
5. Agree to rotate credentials, preserve licenses/notices, keep security
   reports private, and disclose AI-assisted changes.
6. Serve a transition period as co-maintainer or second organization owner
   while access, billing, releases, and support channels are verified.

## Transfer-day checklist

### Before changing access

- [ ] Record the accepting successor's GitHub username and acceptance date.
- [ ] Confirm whether the outgoing owner will leave completely, remain a
      member, or remain temporarily as a second owner for continuity.
- [ ] Export or screenshot non-secret settings inventories: members/owners,
      teams, repository collaborators, rulesets, branch protection, Actions
      permissions, installed Apps, webhooks by destination host, deploy keys by
      title/fingerprint, environments and required reviewers, Packages, and
      Projects.
- [ ] List secret and variable names at organization, repository, and
      environment scopes. Never record the values in this repository.
- [ ] Decide the disposition of every open pull request and issue, including
      PR #52.
- [ ] Confirm the current default branch heads and the latest successful CI and
      release runs.
- [ ] Confirm billing contact/payment ownership and any paid plan features.
- [ ] Run the Organization Backup workflow or another verified backup and
      record its non-secret location and checksum.
- [ ] Freeze merges and releases during the access change.

### Access change

- [ ] Add the successor to the organization if they are not already a member.
- [ ] Promote the successor to organization Owner.
- [ ] Have the successor sign in and open organization settings, both
      repositories, Actions settings, environments, and billing settings.
- [ ] Update billing payment information under the new owner or a billing
      manager.
- [ ] Replace outgoing-owner credentials with successor-owned credentials where
      practical; otherwise record a rotation owner and deadline.
- [ ] Update `CODEOWNERS`, release-environment reviewers, and security contact
      documentation to name people who actually hold the roles.

### Verification after access change

- [ ] `git ls-remote` both repositories and confirm default branch heads.
- [ ] Open a harmless test pull request and confirm required checks, code-owner
      review requests, rulesets, and merge behaviour.
- [ ] Confirm `codeowners/errors` returns no errors for `core`.
- [ ] Run or dispatch a non-publishing CI validation and confirm artifacts.
- [ ] Confirm the release environment protection and reviewers before any
      publish to `packs-latest`.
- [ ] Confirm Pages state and the canonical site URL.
- [ ] Confirm CodeQL, Dependabot, secret scanning, and private vulnerability
      reporting settings.
- [ ] Revoke stale personal access tokens, App grants, deploy keys, and backup
      credentials that belong only to the outgoing owner.
- [ ] Publish a completion announcement naming the new maintainer and the
      outgoing maintainer's remaining role, if any.

### Only then

- [ ] The outgoing owner steps down or removes themselves from the
      organization.
- [ ] Update this file's status from preparation to completed, with the date and
      the public usernames involved.
- [ ] Keep the former organization/repository locations stable. If repositories
      are ever transferred, do not create a new repository at the old location,
      because that destroys redirects.

## Abort conditions

Stop the handover and keep the outgoing owner in place if:

- the candidate will not enable two-factor authentication;
- billing ownership cannot be separated;
- the successor cannot access organization settings after promotion;
- credential ownership or backup custody is unknown;
- open security reports or release-signing/publishing authority cannot be
  accounted for;
- the candidate intends to delete history, remove license/provenance notices,
  or bypass the documented safety rules.

A delayed transfer is better than an organization with an unreachable sole
owner.
