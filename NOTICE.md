# NOTICE

Read this before opening a pull request. It explains the mixed Gradle/
datapack layout of this monorepo and sets expectations for what a PR
should — and should not — contain.

## Repo layout, in short

This is a **monorepo**, not a single Gradle project with some extra files
next to it:

- `mods/` — Fabric mods. Each subproject is built and linted through the
  root Gradle build (`./gradlew ci -PconfirmZip=yes`, which runs
  `verifyProject` + `packageProject`; the narrower `buildAll` / `lint`
  tasks still work for a quick local pass). Changes here must build
  cleanly across **all** subprojects, not just the one you touched — a
  shared dependency bump or API change can silently break a sibling mod.
- `packs/` — Datapacks. These are checked by `verifyProject` as part of
  the same `ci` graph (syntax/reference tooling listed in `SECURITY.md`
  § "Validation tooling": Spyglass/JSON lint, `checkPacks`, `mergeDatapacks`), but
  are not Gradle-*compiled* — there is nothing to build for them, so
  `buildAll` alone says nothing about a datapack change.
- `scripts/` — Helper tooling, lower trust by default. Review before
  running locally.
- `examples/` — Templates and sample code. Not shipped, not covered by the
  same security posture as `mods/` or `packs/`.
- `archived/` — Frozen, reference only.

If your change spans both a mod and a pack (e.g. a Fabric mod that reads
data from a companion datapack), say so explicitly in the PR description —
`ci` covers both `mods/` and `packs/`, but calling it out still helps
review.

## Gradle specifics

- JDK 25, wrapper included — don't add a second build system or bypass the
  wrapper.
- `./gradlew ci -PconfirmZip=yes` must pass before you request review.
  This is the exact task graph CI runs, in the single "Run canonical
  project CI task graph" step of the `Verify, test and package` job (see
  `.github/workflows/quality.yml`); there is no separate `buildAll`/`lint`
  step in CI to pass independently.
- When `ci` actually runs, `verifyProject` invokes Spyglass and strict JSON
  lint. Error diagnostics fail the graph unless advisory mode is explicitly
  selected. Ward-test exclusions, permission warnings, one-version-per-pack
  coverage and the patched decompressor are explained in
  `scripts/datapack_lint/README.md`. Static checks do not prove a pack loads
  or behaves correctly; workflow enablement is a separate GitHub setting.
- Building a single subproject during iteration is fine
  (`./gradlew :mods:<subproject-name>:build`), but run the full `ci`
  before opening the PR — cross-subproject breakage is the most common
  thing missed by scoped builds.
- Avoid adding dependencies unless necessary; every added dependency is
  shared build surface for the whole monorepo, not just your subproject.

## Datapacks specifics

- Datapacks in `packs/` follow the pack-format and namespace conventions
  documented per-project — check the subproject's own README before
  assuming a version target.
- Namespace isolation matters: don't introduce function/tag names that can
  collide with another pack in this repo or with common third-party packs.
- Macro-heavy or command-generation logic is a known risk area in this
  project (see `SECURITY.md`). If your change touches macro expansion,
  dynamic function generation, or anything that assembles commands from
  external input, call that out explicitly in the PR — it will get closer
  review than an average change.
- Packs listed in `archived/archive.json` are frozen. Don't submit feature PRs
  against them; fixes only, and only if the issue is significant. Note that
  **nothing is currently archived under `packs/`** - the registry's only
  entry is the retired `runtoolkit/suite` repository with `"path": null`, so
  today every pack in `packs/` accepts normal PRs. Validate with
  `./gradlew printArchiveList` rather than trusting this sentence.

## Do not misuse this project

This notice exists because of the nature of what's in this repo — datapack
macro systems, command-generation tooling, and Fabric mods that can touch
server/client behavior. To be explicit:

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

> **⚠️ Warning:** the CI job `ward.yml` starts an isolated, loopback-only Minecraft test server to run Ward datapack tests (see `SECURITY.md`, "Validation tooling"). Do not start a server yourself for a PR check, and never run `scripts/ward_ci.sh` outside GitHub Actions.

- [ ] `./gradlew ci -PconfirmZip=yes` passes
- [ ] If you touched `packs/`, you've validated the pack loads correctly
      (Gradle passing does not cover this)
- [ ] PR description explains **what** changed and **why**, and says
      whether the change touches mods, packs, or both
- [ ] No unexplained dependencies, obfuscation, or behavior not covered by
      the description
