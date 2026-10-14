# NOTICE

Read this before opening a pull request. It explains the layout of
this monorepo and sets expectations for what a PR
should — and should not — contain.

## Repo layout, in short

This is a **monorepo**, not a single Gradle project with some extra files
next to it:

- `mods/` — Fabric mods. Each subproject is built and linted through the
  root Gradle build (`./gradlew buildAll` / `./gradlew lint`). Changes
  here must build cleanly across **all** subprojects, not just the one you
  touched — a shared dependency bump or API change can silently break a
  sibling mod.
- `scripts/` — Helper tooling, lower trust by default. Review before
  running locally.
- `examples/` — Example mods. Not shipped, not covered by the same
  security posture as `mods/`.
- `archived/` — Frozen, reference only. This includes every datapack and
  resource pack (`archived/data-packs/`) and the datapack Gradle tasks and CI
  steps (`archived/tasks/`). Nothing there is built, linted or maintained.

## Gradle specifics

- JDK 25, wrapper included — don't add a second build system or bypass the
  wrapper.
- `./gradlew buildAll` and `./gradlew lint` must both pass before you
  request review. CI does enforce **both of these** on every push and PR —
  the steps are marked `continue-on-error` so the diagnostics can still run,
  but the "Final summary" step re-fails the job if either one did not
  succeed (see `.github/workflows/build.yml`).
- Building a single subproject during iteration is fine
  (`./gradlew :mods:<subproject-name>:build`), but run the full `buildAll`
  before opening the PR — cross-subproject breakage is the most common
  thing missed by scoped builds.
- Avoid adding dependencies unless necessary; every added dependency is
  shared build surface for the whole monorepo, not just your subproject.

## Archived datapacks

All datapacks were archived on 2026-10-14. Do not submit feature PRs against anything under `archived/`; fixes only, and only if the issue is significant (see `archived/README.md`). Validate the registry with `./gradlew printArchiveList`.

## Do not misuse this project

This notice exists because of the nature of what's in this repo — Fabric mods that can touch
server/client behavior, and archived datapack macro and command-generation tooling. To be explicit:

- Do not use anything in this repository to build griefing tools, cheat
  clients/mods, exploit kits, or anything designed to bypass another
  server's protections without authorization.
- Do not submit PRs that add obfuscated code, hidden network calls,
  backdoors, or any behavior not clearly described in the PR itself. A PR
  whose behavior doesn't match its description will be closed without
  further discussion, regardless of technical quality.
- Do not use this repo's macro/command-generation systems to build tooling
  intended to inject unsafe or attacker-controlled input into commands on
  a target server.
- Security-relevant contributions (anything touching namespace isolation,
  macro injection surfaces, or permission handling) should follow the
  private reporting process in `SECURITY.md` for the underlying issue
  first — don't post a working exploit in a public PR description.

Violation of the above is grounds for the PR being closed and, for repeat
or clearly malicious cases, the contributor being blocked from the repo.

## Before opening a PR

- [ ] `./gradlew buildAll` passes
- [ ] `./gradlew lint` passes
- [ ] PR description explains **what** changed and **why**
- [ ] No unexplained dependencies, obfuscation, or behavior not covered by
      the description
