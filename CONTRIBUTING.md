# Contributing to vortaforge/core

Thanks for your interest in contributing to this project.

**Read [NOTICE.md](NOTICE.md) before opening a PR.** It covers the
layout of this monorepo, what a PR should contain, and what will get a PR closed
(obfuscated code, undisclosed behavior, misuse of the macro/command
tooling for griefing or exploit purposes). This guide assumes you've
already read it.

## Getting started

1. Fork or clone the repository.
2. Create a branch for your change:

   ```bash
   git checkout -b your-branch-name
   ```

3. Make your changes.
4. Build and lint before opening a PR:
   ```bash
   ./gradlew buildAll
   ./gradlew lint
   ```

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
- Make sure the **`CI`** workflow is green before requesting review. Inside its `Build & lint` job the steps that can fail you are `Build all subprojects` (`./gradlew buildAll`) and `Gradle lint` (`./gradlew lint`).
- Describe what changed and why in the PR description.
- Run through the checklist at the bottom of [NOTICE.md](NOTICE.md) before requesting review.

## Security

This project follows a security-first development philosophy, particularly around permission handling and injection risks in mods. If you find a security issue, do **not** open a public issue - use [GitHub's private vulnerability reporting](https://github.com/vortaforge/core/security/advisories/new), and fall back to a detail-free public issue only if that is unavailable to you. The full procedure, including what must not be included in a report, is in [SECURITY.md](SECURITY.md).

## Code style

- Java code should be clear and documented; complex logic should include comments explaining intent.
- Avoid introducing unnecessary dependencies.
- Fabric mod code must remain tick-safe (see project TPS guidelines).

## Questions

Open an issue if something in this guide is unclear or if you need help getting your environment set up.
