# Contributing to vortaforge/core

Thanks for your interest in contributing to this project.

**Read [NOTICE.md](NOTICE.md) before opening a PR.** It covers the
Gradle/datapack split in this monorepo (what's covered by `ci`/`buildAll`
and what isn't), what a PR should contain, and what will get a PR closed
(obfuscated code, undisclosed behavior, misuse of the macro/command
tooling for griefing or exploit purposes). This guide assumes you've
already read it.

> **⚠️ Warning - a Minecraft server is started in exactly one place.** `.github/workflows/ward.yml` (via `scripts/ward_ci.sh`) runs datapack tests with mcward on a throw-away Fabric server on a GitHub-hosted runner. It is bound to `127.0.0.1`, whitelist enforced and empty, verified loopback-only by `scripts/ward_guard.py` before and after the tests, and deleted afterwards. Nothing else in this repository starts, connects to or tests against a Minecraft server. Never run that script on a developer machine, a production host or next to a real world.

## Getting started

1. Fork or clone the repository.
2. Create a branch for your change:

   ```bash
   git checkout -b your-branch-name
   ```

3. Make your changes.
4. Run the canonical local CI graph before opening a PR:
   ```bash
   ./gradlew ci -PconfirmZip=yes
   ```
   This runs `verifyProject` (provenance, repository audit, offline tests,
   dpgen tests, datapack syntax, pack/archive metadata) and `packageProject`
   (subprojects plus the individual/merged pack archives). `buildAll` and
   `lint` are still available as narrower, faster compatibility tasks if you
   only touched `mods/` or only want the Checkstyle pass.

## Branch naming

Use `<type>/<short-description>` in kebab-case, matching the commit type below:

```
fix/macroengine-condition-gate      feat/guikit-radio-tabs
ci/consolidate-lint-jobs            chore/bump-fabric-loader
docs/security-validation-table
```

Avoid the names GitHub generates for web edits (`<user>-patch-1`) and avoid
long-lived catch-all branches. Historical branches in this repository used
`devlop` (a misspelling of "develop") and `<user>-patch-N`; neither is a
pattern to copy.

## Commit messages

This repository uses [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <imperative summary, <= 72 chars>

<optional body: what changed and why, wrapped at 72>
```

`type` is one of `feat`, `fix`, `ci`, `docs`, `chore`, `refactor`, `test`,
`perf`, `build`, `revert`. `scope` is the area touched (`macroEngine`,
`guikit`, `backup`, `deps`, ...) and is optional for repo-wide changes.

A one-word or placeholder subject is not acceptable: an audit of this
repository's history found 34 of 379 commits whose entire message was `.`,
which makes `git log`, `git blame` and every generated changelog useless for
those changes. If you cannot summarise the change in one line, the commit is
probably two commits. Reference related issues or PRs in the body
(`Fixes #123`).

## Pull requests

- Open a PR against the `main` branch.
- Make sure the **`CI`** workflow is green before requesting review. Inside its `Verify, test and package` job, the one step that can fail you is `Run canonical project CI task graph` (`./gradlew ci -PconfirmZip=yes`), which runs `verifyProject` and `packageProject`; `publish` then only runs after that job succeeds on a `main` push.
- Describe what changed and why in the PR description — and whether the change touches `mods/`, `packs/`, or both; `ci` covers both, while `buildAll` alone only covers `mods/`.
- Run through the checklist at the bottom of [NOTICE.md](NOTICE.md) before requesting review.
- Request a reviewer with write access; for paths listed in
  [`.github/CODEOWNERS`](.github/CODEOWNERS), request one of the named code
  owners. A PR author cannot approve their own PR, and a bot comment is not
  an approval. If no independent reviewer is available and a maintainer uses
  a ruleset bypass, say **“not independently reviewed (Anti-Review)”** in the
  PR and merge record. Never describe a bypass, a green CI run or an AI/tool
  comment as a human review.

## Security

This project follows a security-first development philosophy, particularly around Minecraft datapack macro injection risks and namespace isolation. If you find a security issue, do **not** open a public issue - use [GitHub's private vulnerability reporting](https://github.com/vortaforge/core/security/advisories/new), and fall back to a detail-free public issue only if that is unavailable to you. The full procedure, including what must not be included in a report, is in [SECURITY.md](SECURITY.md).

## Provenance watermark (`_vc_origin.mcfunction`)

Every datapack under `packs/` carries a `_vc_origin.mcfunction` file (under
`data/<namespace>/function/`) that `build.gradle`'s `zipPacks` task checks
for before packaging. This file is not build output and should not be
removed, renamed, or hand-edited in `packs/` by a contributor's PR —
`zipPacks` treats a missing watermark as a build failure, and the project
maintainers ask that it stay untouched in the source tree. Only `build.gradle`
itself (via its `build/packs-remap/` working copy, never `packs/`) and
maintainers acting through the project's own tooling are expected to
touch these files. That tooling is `scripts/origin_watermarks.py`:
`--write` regenerates every watermark from one template, `--check` (run in CI)
rejects hand edits and any executable line, `--report` lists packs and namespaces. This is a contribution-conduct expectation, not a
license restriction — the Unlicense in `LICENSE` continues to govern
what anyone may do with a copy of this code once obtained.

## Code style

- Java code should be clear and documented; complex logic should include comments explaining intent.
- Avoid introducing unnecessary dependencies.
- Fabric mod code must remain tick-safe (see project TPS guidelines).

## Questions

Open an issue if something in this guide is unclear or if you need help getting your environment set up.
