# Security Policy

## Reporting a vulnerability

If you find a security issue in any project under this repository (Fabric
mods, datapacks, or helper scripts), please report it privately rather than
opening a public issue.

- Preferred: use [GitHub's private vulnerability reporting](https://github.com/vortaforge/core/security/advisories/new)
  for this repo.
- If that's not available to you, open an issue with minimal detail
  (e.g. "possible command injection in X, details sent privately") and we'll
  follow up for the specifics.

Do not include working exploit code or live payloads in public issues or pull requests (see "Prohibited content and practices" below).

Please include:
- Affected project/path (e.g. `packs/RTWrapper`, `mods/...`)
- Steps to reproduce, or a minimal example
- Impact (what an attacker could actually do)
- Minecraft/Fabric/Loom version, if relevant

We'll acknowledge reports as soon as we can and aim to have a fix or
mitigation out within a reasonable timeframe depending on severity. Low-risk
findings in archived/frozen projects (see below) may not get a fix, but will
be documented.

## Scope

This repo consolidates multiple projects with different security postures:

| Area | Status |
|---|---|
| `mods/` | Fabric mods. Compiled, type-safe. |
| `packs/` | Datapack and resource-pack roots, including a nested historical RTWrapper datapack. The archive registry currently lists no pack paths; an in-tree historical banner is not the same as a registered archive. |
| `scripts/` | Helper tooling. Treat as lower trust; review before running. |
| `examples/` | Templates and sample code. Not intended for production use. |
| `archived/` | Reserved for no-longer-maintained projects, kept for reference only — do not deploy on a live server without review. Tracked in `archived/archive.json`; see `archived/README.md`. |

Datapacks and Fabric mods carry different security postures by nature; where
practical, security-sensitive logic lives in a Fabric mod rather than a
datapack. Projects that have stopped receiving updates are frozen and marked
archived rather than left in an inconsistent, partially-hardened state.

## Validation tooling

`NOTICE.md` refers readers here for the tooling that validates a change. What
actually runs, and what each tool does and does not prove:

| Tool | Invoked by | Checks | Does **not** check |
|---|---|---|---|
| `scripts/lint_datapacks.sh` (Spyglass 0.4.70 + strict JSON) | `verifyProject` / the CI graph **when run** | Static diagnostics at one inferred version per pack; strict JSON and coverage checks; explicit Ward and permission exceptions | All supported versions, real permissions, complete reference resolution, loading or runtime behaviour |
| `python3 -m unittest discover -s scripts/tests` | `verifyProject` / the CI graph **when run** | Focused pack/merge invariants, action pinning and common credential shapes | GitHub org settings, all secret types, runtime behaviour; see `scripts/README.md` for gaps |
| `python3 scripts/build_release.py --check` | manual (not a CI step yet) | release ZIPs are deterministic and the release minifier is idempotent; the build also inventories dynamic command-execution surfaces (`docs/dynamic-command-gate.md`) | Runtime behaviour; whether a listed surface is reachable by an untrusted player |
| `./gradlew checkPacks` | `quality.yml` via `verifyProject` in the `ci` graph | `pack.mcmeta` shape and format range, JSON validity, cross-references between packs | Command semantics |
| `./gradlew checkOriginWatermarks` | `quality.yml` via `verifyProject`; `zipPacks` also runs its provenance guard during packaging | every pack carries `data/<namespace>/function/_vc_origin.mcfunction` | Content of the watermark (covered by the next row) |
| `python3 scripts/origin_watermarks.py --check` | `quality.yml` via Gradle task `checkProvenance` in `verifyProject` | every watermark equals what the template generates for its pack and namespace, and contains only comments (a no-op) | That the pack's code is what the watermark claims; it proves consistency, not authorship |
| `./gradlew mergeDatapacks` | `quality.yml` via `packageProject` -> root `build` in the `ci` graph | load/tick reference resolution (`strictLoadRefs`), pack-format agreement across the merged set | Runtime behaviour |
| `./gradlew buildAll` | `quality.yml` via `packageProject` in the `ci` graph | the **Gradle** subprojects (mods and other discovered Gradle projects) | Datapack behaviour. The root `lint` task is a narrower local Checkstyle task and is not a separate CI step |
| `scripts/ward_ci.sh` (mcward 1.4.0, Ward) | `ward.yml` when that workflow is enabled - **starts a Minecraft test server**, CI only. It was manually disabled at the 2026-10-29 audit | Behaviour of datapack functions through `data/<namespace>/test/**.mcfunction` tests, on an isolated loopback-only server (`scripts/ward_guard.py` proves it before and after) | Anything without a Ward test; mods; multi-player behaviour |

> **⚠️ Warning:** `ward.yml` is the only place in this repository that starts a Minecraft server. It runs on GitHub-hosted runners only, binds to `127.0.0.1`, enforces an empty whitelist, fails if any socket is reachable outside loopback, and deletes the server afterwards. It downloads Fabric, mods and a JRE from third-party hosts (listed in the workflow header), so a compromised upstream is a supply-chain risk for that job. It has no secrets and a read-only token.

A green CI run therefore says the repository *parses and builds*. Ward tests
add behaviour evidence only when `ward.yml` is enabled and that separate run
is green. A green `build.yml` run has never
said a datapack behaves correctly - that still needs a load test in a real
world, which is what the `NOTICE.md` checklist asks for.

## Prohibited content and practices

The following are not accepted in this repository (code, issues, pull requests, documentation, examples, or releases) and are not recommended by any project in it. This applies **even when the stated intent is benign** (testing, education, "admin convenience", research).

### 1. Exploits for Minecraft or its ecosystem

- No exploit code, proof-of-concept payloads, or step-by-step exploitation guides for zero-day or unpatched vulnerabilities in Minecraft (client or server), Fabric, Forge/NeoForge, Paper/Spigot, other mod loaders, mods, plugins, or their dependencies.
- No weaponized use of known vulnerabilities such as Log4Shell (CVE-2021-44228) or similar injection and deserialization flaws. Describing a vulnerability class at a high level so that others can defend against it is fine; shipping a working chain is not.
- Vulnerabilities in third-party software should be reported to the vendor or upstream maintainer (for Minecraft itself, to Mojang/Microsoft) and not published here before a fix exists.

### 2. Prompt injection and AI-targeted payloads

- No payloads, text, or file content designed to manipulate AI assistants, code reviewers, or automated tooling that reads this repository (prompt injection), including instructions hidden in comments, metadata, item names, books, signs, or datapack/mod files.
- Reports about prompt injection weaknesses in a project's own AI-facing features are welcome through the private reporting channel above. Do not include working payloads in public issues.

### 3. Running operating-system commands from datapacks

- Datapacks cannot run PowerShell, Bash, `cmd`, or any other OS command on their own. Any method that claims to do so depends on an exploit, on a vulnerable, misconfigured or malicious mod or plugin, or on an external tool that executes console or chat output.
- We do not publish, accept, or recommend such methods, including "harmless" or "admin-only" variants, wrappers, bridges, or file-watcher setups that turn in-game commands, storage, signs, books, or command output into shell execution.
- Projects here must not depend on a component that provides in-game shell or file-system execution.

### 4. RCON

- **Malicious use:** RCON must never be used to gain, keep, or escalate unauthorized access to a server, and no code or documentation in this repo may help with that (for example brute-forcing, scanning for exposed RCON ports, or password guessing).
- **Legitimate use is discouraged and restricted.** RCON is not recommended by any project in this repo. A project may support it only if all of the following hold:
  - RCON is disabled by default (`enable-rcon=false`) and documented as optional.
  - It is bound to `127.0.0.1` or a firewalled, trusted network and is never exposed to the public internet.
  - A strong, unique `rcon.password` is used and is supplied through a secret store or environment variable, never committed to the repository or printed in logs.
  - It is never used as a bridge from a datapack, chat, or player input to a shell or the file system.
  - It is limited to the minimum set of commands the project needs.
- RCON-related security findings should be reported privately.

### 5. Enforcement

- Content that violates this section will be removed, and the related issue or pull request closed without a fix or discussion of exploit details.
- Repeated or deliberate violations may result in a ban from the repository.
- Archived and frozen projects are covered as well: their code is kept for reference only and is not an endorsement of any method listed above.

## Supported versions

Only the versions/branches actively referenced in each subproject's own
README receive security fixes. Archived projects (see table above) are
provided as-is.

## Third-party forks and converters

If you're using a fork, a "datapack to mod converter" output, or any
derivative of a project in this repo, verify it against the original source
here before trusting it — converted or forked artifacts are not covered by
this policy and may not reflect the same security posture.