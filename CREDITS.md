# Credits & AI-assistance disclosure

This file records which parts of the repository were written or changed with AI assistance, so that
AI involvement is visible in the repository itself and not only through commit authorship.

## 2026-10-28 - feat: cmd_gate kill-switch and settings book

**Tool:** Arena.ai Agent Mode, working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/data/macroengine/function/systems/cmd_gate/{enable,disable}.mcfunction`, `.../function/config.mcfunction`, `.../core/config/{apply,ensure}.mcfunction`, `.../systems/cmd_gate/check.mcfunction` | An operator can now turn the dynamic-command gate off on purpose: config key `cmd_gate_disabled` (default `0b`, `config_rev` 4), admin-only enable/disable functions through the validated config path, one audit entry and an admin warning per state change. The bypass sits after the `module_cmd` guard, so a disabled module stays disabled. The eleven `api/cmd`/`api/perm` runners that read the master switch directly honour the same key. |
| `packs/macroEngine-Datapack-v26.3/data/macroengine/function/api/settings/`, `.../core/internal/api/settings/`, `tags/function/input/writable_book.json` | Settings book: an input book (`settings:1b`) prefilled from the live gate scores and config storage as `Key: Value` lines; editing it and re-selecting it (existing writable-book capture) or running `api/settings/apply` applies the lines - five pack gates, permit, `cmd_gate`, any `cfg.<key>` via `core/config/set`, and `blocklist.add/remove/reset/clear`. Text is parsed as data only (never macro-substituted), non-admin captures are ignored silently, rejected lines are reported in `macroengine:settings result.errors`. `api/settings/status` prints the live state read-only. |
| `packs/macroEngine-Datapack-v26.3/data/macroengine/test/cmd_gate_disable_toggle.mcfunction`, `scripts/tests/test_settings_book.py` | Ward test for the kill-switch defaults/toggle via the config mirror score; offline invariant tests for bypass placement, admin guards, tag registration, no dynamic function selection and no macro-executed book text. |
| `packs/macroEngine-Datapack-v26.3/docs/settings_book.md`, `docs/cmd_gate.md`, `docs/config.md`, `docs/dynamic-command-gate.md` | Book grammar, flow and limits; the disable contract and its audit trail; config table row; cross-pack inventory updated. |

- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0) passed; `./gradlew :checkPacks` on Temurin 25
  (`--configure-on-demand`, memory-capped) checked 12 packs / 3248 functions with 0 errors and 0 warnings;
  `python3 -m unittest discover scripts/tests` - 38 tests OK (10 new); `python3 scripts/origin_watermarks.py --check`,
  `python3 scripts/audit_repo.py` (only the two pre-existing `pack.format-mixed` notes) and
  `python3 scripts/build_release.py --check` passed; every static `function` reference in the changed files
  resolves (the pre-existing `api/cmd/$(type)` dispatch in `action_run` aside), and the `_give` macro arguments
  match the `_view` fields exactly. The change was also exported with `git format-patch`, re-applied to a fresh
  clone with `git am`, and the same checks re-run there.
- **Not verified:** no Minecraft server was started (CLAUDE.md rule 7). The book flow end to end (prefill,
  newline splitting of a real edited page, capture timing, apply against live players), the kill-switch at
  runtime and the new Ward test all still need their first execution - the `ward.yml` CI job for the test, the
  `NOTICE.md` in-world acceptance pass for the flow. The full `verifyProject`/`ci` graph was not run (Fabric
  Loom subprojects exhaust the sandbox's 2 GiB of RAM); only `checkPacks` ran in isolation.

## 2026-10-27 - feat: default-off dynamic command gate + deterministic release build

**Tool:** Arena.ai Agent Mode, working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/data/macroengine/function/systems/cmd_gate/` | New fail-closed gate for stored-string command execution: config switch, `cmd.dynamic` permission via `api/perm/require`, length/control-character checks, and a developer-controlled root-token blocklist (`blocklist.mcfunction`, seeded only when missing). The command string is only ever handled as storage data - no macro line in the gate touches it. |
| `packs/macroEngine-Datapack-v26.3/data/macroengine/function/api/perm/group/`, `.../core/internal/api/perm/group/` | Permission groups on top of the existing `perm.<name>` tags: admin-only create / grant-perm / assign / remove / list, every name checked with `systems/validate/safe_name` before it reaches a macro line. |
| `packs/macroEngine-Datapack-v26.3/` (executors + config) | All stored-string executors (queue, hooks, wand, triggers, `multi_cmd`, `once_cmd`, region watchers, command-block runners) now call the gate; `api/cmd/*` string runners and `api/perm/run|exec` read the same new config keys `dynamic_cmd` (default `0b`) and `dynamic_cmd_max_len` (`config_rev` bumped to 3). The fake "safely executed via pipeline" step in `multi_cmd/exec_macro` now runs the real check. Supporting docs in `docs/cmd_gate.md` and `docs/config.md`; two Ward tests under `data/macroengine/test/`. |
| `packs/guikit-datapack/`, `packs/guikitfw/` | Stored menu commands are off until an operator sets `guikit:cfg dynamic_cmd` to `1b` (default seeded in `core/load`). |
| `packs/RTWrapper-v1.0.1/`, `packs/RTWrapper/` | The single wrapper dispatch is off by default (`#dynamic`, `rtw.config`); `rtwrapper:api/dynamic/on|off` toggles it. |
| `packs/TunnelScript/`, `packs/cmdTunnel-datapack/` | The legacy command-block runners are off by default (`#dynamic_enabled` / `#dynamic`), on top of the existing trusted-tag and confirmation gates; pre-macro syntax only, so the packs stay loadable on their target versions. |
| `scripts/build_release.py`, `scripts/tests/test_build_release.py` | New release pipeline: one deterministic ZIP per pack (release copy minified, source untouched, nothing renamed, `_vc_origin` kept verbatim, Ward `test/` folders excluded) plus `SHA256SUMS.txt` and a line-by-line inventory of dynamic command-execution surfaces. No obfuscation or encryption by design. |
| `docs/dynamic-command-gate.md`, `README.md`, `SECURITY.md`, `scripts/lint_datapacks.sh` | Cross-pack inventory of every dynamic surface (including the code-supplied `$(invoke)` helpers and prefix-constrained dispatches reviewed and deliberately not gated, and the packs with no surface), enable instructions per pack, and the new lint ignore for the macroEngine Ward tests. |

- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0) passed; `./gradlew :checkPacks` on Temurin 25
  (`--configure-on-demand`, memory-capped) checked 12 packs / 3217 functions with 0 errors and 0 warnings;
  `python3 -m unittest discover scripts/tests` - 28 tests OK (including the new build_release tests);
  `python3 scripts/origin_watermarks.py --check` passed; `python3 scripts/audit_repo.py` reports only the two
  pre-existing `pack.format-mixed` notes; `python3 scripts/build_release.py --check` passed and all 12 release
  ZIPs were built and spot-checked; every static `function` reference in the changed files resolves.
  The finished diff was also written out as a `.patch`, applied to a fresh clone with `git apply`, and the
  same checks re-run there (the patch file itself is not part of the tree).
- **Not verified:** no Minecraft server was started (CLAUDE.md rule 7). The two new Ward tests are written but
  unrun - their first execution is the `ward.yml` CI job. The gate's runtime semantics (permission, blocklist,
  group assign/remove against live players) still need the in-world acceptance pass from `NOTICE.md`. The full
  `verifyProject`/`ci` graph was not run: configuring the Fabric Loom subprojects exhausts the sandbox's
  2 GiB of RAM, so only `checkPacks` ran in isolation.

## 2026-10-23 - feat: add ten guikit condition types

**Tool:** Copilot SDK in VS Code, working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

| Path | Change |
|---|---|
| `packs/guikit-datapack/data/guikit/function/cond/` | Added biome, health, hunger, air-supply, fire, ground, sneaking, sprinting, swimming, and elytra-flight conditions; wired them into condition dispatch and composition. |
| `packs/guikit-datapack/data/guikit/predicate/cond/` | New player-state predicates for fire, ground, sneaking, sprinting, swimming, and elytra flight. |
| `packs/guikit-datapack/data/guikit/dialog/page.json`, `packs/guikit-datapack/data/guikit/function/play/tab_visual.mcfunction` | Added an editor option for page tabs and active-page highlighting. |
| `packs/guikit-datapack/README.md`, `packs/guikit-datapack/data/guikit/function/help.mcfunction`, `packs/guikit-datapack/pack.mcmeta` | Documented the v6 features and updated the pack version description. |

- **Verified:** `./gradlew verifyProject` passed in a Python 3.12 environment with pytest, Mecha 0.101.0, and the local editable `guigenmc` package; the pinned Mecha datapack lint, `python3 scripts/origin_watermarks.py --check`, and `git diff --check` passed.
- **Not verified:** no live Minecraft server or bot was started; the repository prohibits local server tests.

## 2026-10-20 - docs: macroEngine README overhaul, PlayerAction rewrite plan

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

| Path (under `packs/macroEngine-Datapack-v26.3/`) | Change |
|---|---|
| `README.md` | Rewrote the project-history header to cover the full organization chain (runtoolkit → vortacraftmc → VortaForge), both archived and neither deleted; added an explicit AI-disclosure line; expanded Installation into platform-specific sections (manual/UI, Linux/macOS Bash, Windows PowerShell, generic server install, Claude Code/agent-assisted install). |
| `THIRD_PARTY_LICENSES.md` | Linked the PlayerAction "scheduled for removal" status to the new rewrite plan document. |
| `docs/playeraction-rewrite-plan.md` | New. A phased plan (not implementation) for removing the `core/internal/player/` PlayerAction dependency, based on reading the current 82-file tree. Separates the dependency into a low-risk namespace-only portion (lifecycle + state/statistics + advancement-relay pairs) and the one subsystem that actually carries PlayerAction-specific technique (click detection via a tracked invisible `interaction` entity). Records two candidate designs for that subsystem without choosing between them, per the maintainer's instruction to leave that decision open. |

- **Verified:** read-through of all 82 files under `core/internal/player/`, its 12 predicates and 27 advancement JSONs, to produce the scope breakdown in the plan document. No code in `core/internal/player/` was changed.
- **Not verified:** the rewrite plan itself is unimplemented and untested — no click-detection code was written, ported, or run. The Installation section's platform-specific commands (Bash, PowerShell, Claude Code instructions) were written from general knowledge of Minecraft datapack install mechanics and were not executed against a live server in this session. Nothing was run in a Minecraft server.

## 2026-10-19 - ci: reusable quality gate and artifact-only publishing

**Tool:** Arena.ai Agent Mode, working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `.github/workflows/quality.yml` | New reusable, read-only quality workflow. It runs the canonical Gradle `ci` graph on Java 25/Python 3.12/Node 20, guigenmc Python 3.9 compatibility tests, source/wheel checks, bounded artifacts and an explicit all-jobs gate. Release assets include a SHA-256 manifest. |
| `.github/workflows/build.yml` | Reduced the public CI entrypoint to a reusable-quality caller and an approval-gated publish job. The only writable job does not check out or execute repository code; it verifies the SHA-256 manifest and publishes only the gated ZIP artifact. |
| `scripts/audit_repo.py`, `scripts/tests/test_repo_invariants.py` | The documentation audit discovers Gradle tasks in root-owned `build-logic/` scripts; offline regression coverage now guards the reusable-workflow trust boundary as well as SHA-pinned actions. |
| `README.md`, `CLAUDE.md` | Updated CI documentation to match the reusable quality and artifact-only publication design. |

- **Verified:** YAML parsed with PyYAML; `python3 scripts/audit_repo.py --format github --fail-on high` passed with one existing medium RTWrapper warning; offline regression tests: 18 passed.
- **Not verified:** GitHub Actions execution, release-environment approval and publishing have not run. No Minecraft server was started.

## 2026-10-19 - feat(build): project-level Gradle lifecycle tasks

**Tool:** Arena.ai Agent Mode, working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `build-logic/project-tasks.gradle`, `build.gradle` | New project-specific Gradle task graph: provenance, audit, offline Python tests, guigenmc tests, locked dpgen install/tests, datapack lint, `verifyProject`, `packageProject`, `ci`, and a deterministic project inventory report. Existing task names remain intact for compatibility. |
| `scripts/audit_repo.py` | Pack roots are now discovered recursively from `pack.mcmeta`, aligning the audit with the Gradle pack tasks and validating RTWrapper's nested distributable pack instead of reporting its source container as broken. |
| `README.md`, `CLAUDE.md`, `AGENT.md` | Documented the canonical Gradle lifecycle commands and their offline-only scope. |

- **Verified:** with JDK 25, `./gradlew tasks --group verification`; `./gradlew verifyProject` passed all 10 offline tasks, including Mecha, 65 guigenmc tests, 5 dpgen tests and 18 repository tests. `checkPacks` reports 29 existing external-reference warnings; the audit reports one existing medium RTWrapper format warning.
- **Not verified:** `packageProject` reached archive generation and initial Fabric compilation, but the sandbox Gradle daemon was killed during Loom remapping even with one worker and a 1.5 GiB heap cap. The complete package/CI graph and GitHub Actions workflow therefore still need a hosted-runner confirmation. No Minecraft server was started.

## 2026-10-19 - feat: macroEngine `tui/` text UI module

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path (under `packs/macroEngine-Datapack-v26.3/`) | Change |
|---|---|
| `data/macroengine/function/tui/{line,header,divider,button}` | New. Print a line, title bar, rule and clickable function button to `@s`. Text is read from `macroengine:tui` storage and rendered with `api/store/render`. |
| `data/macroengine/function/core/internal/tui/{render_text,render_label,render_hover,button_send}` | New. Internals. `button_send` is the only macro line; its single argument `fn` is validated with `systems/validate/function_id` first. |
| `docs/tui.md`, `README.md` | New doc; one feature bullet. |

- **Verified:** Mecha 0.101.0 passes with the new files; text components set `interpret:false` and `plain:true`; click/hover use the 1.21.5+ field names.
- **Not verified:** nothing was run in a Minecraft server (repository rule). The click/hover rendering, the `execute if function` chain into `api/store/render` and the `$tellraw` macro were checked by reading, not executing. The module has no `config` on/off switch.

## 2026-10-19 - fix: macroEngine hover_event field names and missing `plain` on NBT text components

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path (under `packs/macroEngine-Datapack-v26.3/data/macroengine/function/`) | Change |
|---|---|
| `systems/string/hover_text`, `systems/string/tag_badge` | **Fix.** `hover_event` / `show_text` still used the pre-1.21.5 `contents` key; it is `value`. The component did not match the 1.21.5+ format. |
| `systems/string/tooltip_item` | **Fix.** `hover_event` / `show_item` used `contents:{id,Count}`; the 1.21.5+ format is flat `id` and `count`. |
| `api/store/show`, `api/store/player/show`, `api/title/actionbar_p`, `core/internal/api/title/_apply`, `core/config/list` | **Fix.** Six `nbt` text components lacked `plain` (and in two lines `interpret`/`plain` pairs), so string values printed with quotes on 26.1+. Applied with `scripts/fix_text_components.py --fix`; the script now reports 0 remaining. |

- **Verified:** Mecha 0.101.0 passes on the pack (the two documented `time query` files excluded as in `lint_datapacks.sh`); `scripts/origin_watermarks.py --check` ok; `pytest scripts/tests` 17 passed; every pack JSON file (loot tables, item modifiers, recipes, advancement triggers) checked against the vanilla registries of misode/mcmeta (snapshot 26.4-snapshot-4, slightly newer than 26.3) with no findings; all 1085 `function` references resolve.
- **Not verified:** nothing was run in a Minecraft server (repository rule). The `hover_event` field names follow the 1.21.5+ text component format and were not exercised in game. No new features were added: the stable commands from 1.21.5 to 26.3 (`/waypoint`, `/dialog`, `/fetchprofile`, `/compute`, `/posteffect`) have no matching API module in this pack.

## 2026-10-18 - fix/ci/test: restore macroEngine watermark, pin remaining actions, add repository tests

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/data/macroengine/function/_vc_origin.mcfunction` | Restored with `scripts/origin_watermarks.py --write`. Commit `5f2a74b` had deleted it, so `--check` (the first CI step) failed on `main`. Only this one file was written. |
| `.github/workflows/ai-agent.yml`, `codeql.yml` | `actions/checkout`, `actions/setup-node` and `github/codeql-action/{init,analyze}` pinned by commit SHA (were floating tags), as `CLAUDE.md` requires. SHAs resolved with `git ls-remote` against the upstream repositories. |
| `scripts/tests/test_repo_invariants.py` | New. Offline regression tests: real tree passes the watermark check; missing/hand-edited watermarks are rejected (on a temporary copy); every workflow `uses:` is SHA-pinned. |
| `.github/workflows/build.yml` | New required step "Repository tests" (guigenmc pytest suite, `scripts/tests`, `scripts/check_archive.py`), wired into the release gate, diagnostics and the final summary. These tests existed but CI never ran them. |
| `scripts/lint_datapacks.sh` | Excluded paths are now found with `-prune`, each one is reported once with its `.mcfunction` count, and the summary prints the total number of files excluded from validation. Exit-status behaviour is unchanged. |
| `packs/DailyBonus/data/dailybonus/function/tick.mcfunction` | **Fix.** A player with no `db_last_day` score was never granted (a score comparison against an unset score never succeeds), so the daily bonus could never be claimed for the first time. One line added before the existing comparison; the existing line, namespaces, objectives and loot table are unchanged. Not verified in a running game: the regression is covered by a Ward test that only runs in CI. |
| `packs/DailyBonus/data/dailybonus/test/*.mcfunction` (3 files) | New Ward tests (load constant, tick day, first login is granted). Excluded from Mecha lint (`scripts/lint_datapacks.sh`) because `assert`/`await` are not vanilla commands; the exclusion is reported like the others. Written from Ward's documentation, never executed. |
| `.github/workflows/ward.yml`, `scripts/ward_ci.sh`, `scripts/ward_guard.py`, `scripts/tests/test_ward_guard.py` | New. Isolated Ward job (see below); 16 offline tests in `scripts/tests` cover the guard (fake loopback / `0.0.0.0` listeners) and keep the workflow, script and docs from being loosened. |
| `CLAUDE.md`, `AGENT.md`, `README.md`, `CONTRIBUTING.md`, `NOTICE.md`, `SECURITY.md`, `scripts/README.md` | Rule 7 now names the single Ward exception; warning notes added. |
| `scripts/dpgen/test/builder.test.js`, `scripts/dpgen/package.json` | New. 5 offline `node:test` tests (examples validate and build, tick/load tags, invalid configs raise `ConfigError`); `npm test` was a placeholder that always failed. Also run by the CI "Repository tests" step. |

- **Verified (run in a sandbox, not in CI):** `origin_watermarks.py --check` (fails before the restore, passes after); `pytest` 81 passed (65 guigenmc + 16 in `scripts/tests`); orchestration against a stub `mcward` in 5 scenarios (loopback pass, `0.0.0.0` aborts before tests, test failure propagates, no tests fails, bypass flag); every negative control failed as intended; `npm test` in `scripts/dpgen` 5 passed (a deliberately wrong expectation made one fail); the SHA-pin test fails when one action is unpinned again; `scripts/lint_datapacks.sh` with Mecha 0.101.0 exits 0, and exits 1 with a deliberately malformed function (removed afterwards); `check_archive.py`; JSON/YAML parse of every tracked file; `py_compile`, `bash -n` and `node --check` on all scripts.
- **Not verified:** `./gradlew buildAll`, `build` and `lint` were not run (sandbox has JDK 21, the repo needs JDK 25, and Gradle/Loom downloads are outside the allowed network). The new CI step has not run on GitHub Actions. Nothing was run in a Minecraft server (repository rule).
- **`mcward==1.4.0` is integrated as an isolated, CI-only job (maintainer-authorised exception to the no-server rule):** `.github/workflows/ward.yml` + `scripts/ward_ci.sh` + `scripts/ward_guard.py`. Server bound to `127.0.0.1`, whitelist enforced and empty, online-mode on, status/query/RCON off; seeded before start, proven loopback-only before and after the tests, inbound 25565 dropped when iptables is available, stopped and deleted in an always-run cleanup. Warning notes added to `CLAUDE.md`, `AGENT.md`, `README.md`, `CONTRIBUTING.md`, `NOTICE.md`, `SECURITY.md`, `scripts/README.md`, the workflow and both scripts, guarded by tests. **Never executed against real mcward or a real server** (sandbox: Python 3.12, no Mojang/Modrinth/Adoptium access); only the guard and the orchestration were tested, against a stub `mcward` and plain Python sockets. **The job fails until a pack contains Ward tests** (`data/<ns>/test/**.mcfunction`); none exist. Whether Ward builds exist for 26.3 and whether the server needs the Minecraft EULA (not accepted by the workflow) is unverified.

## 2026-10-18 - feat: macroEngine `cb/run_repeating`, `cb/time_left`, `container/info`

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path (under `packs/macroEngine-Datapack-v26.3/`) | Change |
|---|---|
| `data/macroengine/function/api/cb/run_repeating`, `core/internal/api/cb/repeat_build` | New. Repeats one command 1..100 times at a fixed interval by building a `cmds` list and reusing `systems/cb/seq_expand`. |
| `data/macroengine/function/api/cb/time_left`, `core/internal/systems/cb/time_left_step` | New. Read-only: ticks until the next pending entry of a `cb_id`, plus the pending count. |
| `data/macroengine/function/api/container/info` | New. Size, used, free, empty, full and first free slot in one call; reuses the existing `_addr`, `_count`, `_size_pick` and `_ff_loop` internals. |
| `docs/cb.md`, `docs/container.md` | Document the new functions; `container.md` is new and also lists the existing container functions. |

- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0) passes with the new files. `scripts/origin_watermarks.py --check` still reports the missing macroEngine watermark; that was already the case before this change and is untouched.
- **Not verified:** nothing was run in a Minecraft server (repository rule). The `first_free` scan and the `time_left` counters were checked by reading the code paths they reuse, not by executing them. `cb_time_left` for an entry pushed back by the fire spacing reports its current counter, not its real fire tick.

## 2026-10-15 - feat: macroEngine load gates 4 and 5, two item tags, four block tags

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path (under `packs/macroEngine-Datapack-v26.3/data/macroengine/`) | Change |
|---|---|
| `function/gate/load_guard`, `load_begin`, `load_end`, `loads_decay`, `clear_incomplete`, `clear_tripped`, `set/4_on`, `4_off`, `5_on`, `5_off` | New. Gate 4 (incomplete-load gate) and gate 5 (reload-loop gate), both default on. |
| `function/gate/version`, `refresh`, `status`, `function/setup` | Initialise gates 4/5, call `gate/load_guard`, close `#macroengine.open` for both gates, print their state, bracket the load with `load_begin` / `load_end`. |
| `tags/item/books`, `tags/item/buckets` | New item tags. |
| `tags/block/command_blocks`, `chests`, `containers`, `workstations` | New block tags (first block tags in this pack). Not added to `tags/item/all.json`. |

- **Verified:** Mecha 0.101.0 on the pack (without the two files the lint script already ignores) reports no errors; every new JSON file parses.
- **Not verified:** nothing was run in a Minecraft server (repository rule). Block and item IDs were written from knowledge of vanilla, not checked against a 26.3 registry dump. Gate 4 only detects a setup that did not reach its last line; it does not see a failing command inside a finished setup. The 6-loads-in-1200-ticks threshold for gate 5 is a guess, not measured.

## 2026-10-12 - docs: fix stale function paths in macroEngine usage comments

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| File | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/.../api/cmd/time_of.mcfunction` | Usage comment named the old `ame:clock_handler`; now `macroengine:api/cmd/time_of`. |
| `.../api/macro/with_advancement`, `with_function`, `with_score` | Usage comments pointed to `macroengine:engine/macro/...`; now `macroengine:api/macro/...`. |

- **Verified:** Mecha 0.101.0 on the macroEngine datapack (comment-only change, no command lines touched).
- **Not verified:** nothing was run in a Minecraft server. Known and left unchanged: `api/cmd/other/action_run` substitutes `$(player)`, `$(type)`, `$(arguments)` into a macro line without `systems/validate/safe_name`; `systems/rate_limit/config` documents `delete` and `list` functions that do not exist.

## 2026-10-10 - refactor: remove dead `multiCommands` storage writes in macroEngine

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.4/.../api/cmd/other/multi_cmd.mcfunction` | Removed `data remove` of `macroengine:engine multiCommands.type` / `.active`; nothing in this call path sets either. |
| `packs/macroEngine-Datapack-v26.4/.../api/cmd/other/multi_cmd_adv.mcfunction` | Same two `data remove` lines removed. |
| `packs/macroEngine-Datapack-v26.4/.../multi_cmd/advanced/run_with_options.mcfunction` | Removed the only writer of `multiCommands.type` (and its "Validate" comment, which described validation that does not exist). Nothing in the repository reads the value. |

### Verification status

- Verified: repo-wide grep shows no remaining reader of `multiCommands.type` / `.active`; `scripts/lint_datapacks.sh` (Mecha 0.101.0) passes.
- **Not verified:** runtime behaviour in a real Minecraft server. Datapacks or tools outside this repository that read `macroengine:engine multiCommands.*` would be affected.

## 2026-10-11 - retarget to Minecraft 26.3

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-{Datapack,Resourcepack}-v26.3/` | Renamed from `-v26.4`; `pack.mcmeta` now data pack format 121.0 / resource pack format 97.1; version string `v26.3`, meta score 263; README updated |
| `packs/{DailyBonus,QuickShare,RTWrapper-v1.0.1,guikit-datapack,guikit-demo}/pack.mcmeta` | format 122 -> 121 |
| `packs/LeftClickDetection/pack.mcmeta` | `supported_formats` array -> object form |
| `index.html`, `scripts/*`, docs | path and label updates for the rename |

Verification: Mecha lint, `audit_repo.py`, `check_archive.py` and the `index.html` zip-list check pass.
**Not verified:** loading on a real Minecraft 26.3 server; that nothing in the 26.4-snapshot content relies on data pack format 122 features; Fabric/Gradle builds.

## 2026-10-07 - fix: release assets not found (`packs-latest`)

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| Path | Change |
|---|---|
| `.github/workflows/build.yml` | `release` job: `files:` now points to `release-assets/*.zip` (the downloaded `release-packs` artifact) instead of `build/packs-dist/*.zip` / `build/dist/*.zip`, which do not exist in that job (no checkout). Added `fail_on_unmatched_files: true` and a duplicate-file-name check in "Collect release assets". |

### Verification status

- Verified: YAML parses; duplicate-name check logic exercised locally with a shell test.
- **Not verified:** an actual GitHub Actions run (needs a push to `main` / `workflow_dispatch`).

## 2026-10-04 - improvements batch + two new Fabric mods

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Reviewed and merged by a human
maintainer (review status: _pending at the time of writing - update when reviewed_).

### New (AI-written; every new Java file carries an "AI-assisted" header comment)

| Path | What |
|---|---|
| `mods/join-throttle/` | Login-rate limiter mod (1.21.1, Yarn) incl. unit tests |
| `mods/afk-manager/` | Idle detection / `/afk` / optional AFK kick mod (1.21.1, Yarn) incl. unit tests |
| `CREDITS.md` | This file |

### Changed (AI-assisted edits to existing files)

| Path | Change |
|---|---|
| `mods/rtwrapper-mod/build.gradle` | `project.archivesBaseName` (removed in Gradle 9) -> `base.archivesName` |
| `build-logic/shared-fabric-mod.gradle` | Reproducible archives (no timestamps, stable file order) |
| `build.gradle` | Removed ~235 lines of blank padding (whitespace only) |
| `settings.gradle` | Deterministic (sorted) subproject discovery order |
| `mods/TEMPLATE-MOD/gradle/wrapper/gradle-wrapper.properties` | Gradle 9.4.1 -> 9.8.0 (matches root) |
| `.github/workflows/build.yml` | Top-level `permissions: contents: read` (least privilege) |
| `.github/dependabot.yml` | `pip` pointed at the real manifest dir; added `npm` for `scripts/dpgen` |
| `scripts/check_archive.py` | Parity with Gradle `checkArchive` + type guards instead of crashing |
| `scripts/backup-org.sh` | Token passed to `github-backup` via a 0600 temp file instead of argv |

### Verification status at the time of writing

- Verified by running: `check_archive.py` (real registry + malformed inputs), `backup-org.sh` (stubbed
  `github-backup`), YAML parsing of the changed workflow files, and the unit tests of the Minecraft-free
  classes of both new mods.
- **Not verified (no Gradle / Fabric Maven access in the authoring environment):** Gradle configuration of
  all changed `.gradle` files, compilation of the Fabric-facing code (`*Mod.java`, `PlayerManagerMixin`)
  against Minecraft 1.21.1 Yarn mappings, and runtime behaviour in a real server. Treat these as
  needing a CI run and a manual server test before release.

## index.html: escape error messages in the warning banner

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| File | Change |
|---|---|
| `index.html` | `errors` entries (which can contain `err.message` and the release `tag_name` returned by the GitHub API) were concatenated into `innerHTML` unescaped; each entry now goes through `escapeHtml()` before rendering. |

- **Not verified:** rendering in a real browser; only the string replacement and its uniqueness were checked.

## Organization migration to vortaforge (links and provenance text)

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Area | Change |
|---|---|
| Repo URLs | `github.com/vortacraftmc/...`, `vortacraftmc/core` and `vortacraftmc.github.io` replaced with the `vortaforge` equivalents in docs, scripts, Gradle files, `index.html` (`OWNER`, cache key) and metadata. |
| Provenance | `scripts/origin_watermarks.py` template now states runtoolkit -> vortacraftmc -> vortaforge; all 20 `_vc_origin.mcfunction` files regenerated with `--write`, `--check` passes. |
| Deliberately unchanged | Datapack namespaces (`data/vortacraftmc/`), scoreboard fake players (`#vortacraftmc.*`) and the Java package `com.vortacraftmc`: renaming them would break existing worlds or APIs and needs a separate migration decision. The `runtoolkit` origin statements are kept on purpose. |

- **Not verified:** Gradle build and CI run; the target org does not exist yet, so no link was checked online.


## License alignment: Unlicense everywhere

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

Decision (maintainer): the project is Unlicense; older repos that carried MIT are private and archived.

| File(s) | Change |
|---|---|
| `scripts/origin_watermarks.py` + 20 `_vc_origin.mcfunction` | Header now says Unlicense instead of MIT; regenerated, `--check` passes. |
| `packs/{DailyBonus,LeftClickDetection,InteractionClickDetection,cmdTunnel-datapack,QuickShare}/NOTICE` | MIT line replaced with Unlicense. |
| `scripts/gui_generator/pyproject.toml` | `license` and trove classifier changed to Unlicense. |
| `examples/opmod-example` | `LICENSE` replaced with the root Unlicense text; `fabric.mod.json` license set to Unlicense (was CC0-1.0). |
| `packs/macroEngine-Datapack-v26.4/README.md` | Removed the note about the inconsistent MIT header, which no longer applies. |

- **Left as is on purpose:** third-party MIT/other licenses (`THIRD_PARTY_LICENSES.md`, `jszip.min.js`, `package-lock.json`).
- **Not verified:** legal effect; this is not legal advice.

## macroEngine: storage-based `api/store/*` module, `api/placeholder/*` deprecated

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.4/data/macroengine/function/api/store/**` | New public module: global and per-player variables (`set/get/has/remove/add/default`), multilingual templates (`text/define`, `text/remove`) and `render`, which returns a plain string. |
| `.../core/internal/api/store/**` | Internals. Names and language keys go through `systems/validate/safe_name` before any macro line; player keys are built from the UUID ints only. |
| `.../api/placeholder/*` | Marked deprecated in the file header; most functions now print a one-time admin notice. Behaviour is unchanged. `parse`, `actionbar*` and `load` stay silent because `api/title/*_p` and `setup` still call them. |
| `docs/store.md`, `README.md` | Documentation and migration table. |

- **Verified:** Mecha 0.101.0 parses the new files without errors (the only two errors in the pack are the existing `time query minecraft:day` lines, which this Mecha version does not know).
- **Not verified:** nothing was run in a Minecraft server. In particular `%player%` and `%score:...%` rely on the existing `to_plain` helper (text_display trick) and the module has never been executed. Treat it as untested.

## SEO files, CLAUDE.md and removal of the store self-test

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `index.html` | Meta description, robots, canonical, Open Graph/Twitter tags, JSON-LD (`SoftwareSourceCode`), `<noscript>` summary and a "not affiliated with Mojang/Microsoft" footer line. |
| `robots.txt`, `sitemap.xml` | New; point at `https://vortaforge.github.io/core/`. |
| `CLAUDE.md` | New project guidance for Claude Code. |
| `packs/macroEngine-Datapack-v26.4/.../api/store/selftest.mcfunction` | Removed at the maintainer's request (no in-game tests). |

- **Not verified:** how Google indexes the page (Search Console not available); JSON-LD and sitemap were only parsed for well-formedness. The target Pages site does not exist yet.

## Authors, copyright lines and contact metadata

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `mods/*/fabric.mod.json`, `packs/RTWrapper/rtwrapper-fabric/.../fabric.mod.json` | `authors` entry `vortacraftmc` -> `VortaForge` (the `Runtoolkit (original source)` credit is kept); `contact.sources` now `https://github.com/vortaforge/core`. `datapack-fixer` gained a `contact` block. |
| `packs/*/NOTICE`, `scripts/origin_watermarks.py` (+ 20 regenerated watermark headers) | Copyright holder now `Legends11 / VortaForge (formerly Runtoolkit)` / `VortaForge (formerly Runtoolkit)`. |
| `packs/DailyBonus`, `packs/QuickShare` `pack.mcmeta` | Description credits VortaForge. |
| `scripts/gui_generator/pyproject.toml`, `scripts/dpgen/package.json` | Author set to `VortaForge`. |
| `packs/macroEngine-Datapack-v26.4/README.md` | Maintainer links point at VortaForge. |

- **Left as is:** `TEMPLATE-MOD` and `opmod-example` placeholder authors (`Me!`, `you`), third-party copyright (`THIRD_PARTY_LICENSES.md`), `maven_group` / Java packages (`com.vortacraftmc`).
- **Maintainer to confirm:** the exact legal name to use as copyright holder; I used the existing `Legends11 / ...` form from the older NOTICE files.

## banner.png converted to a real PNG

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

`banner.png` was a JPEG with a `.png` extension and a long EXIF description string. It is now a real PNG (same 1408x736 picture, no metadata). The image itself was not redesigned.

## macroEngine: `api/store/show` and `api/store/player/show`

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/data/macroengine/function/api/store/show.mcfunction`, `.../api/store/player/show.mcfunction` | New. Call `get` / `player/get` and print the value to `@s` with an NBT `tellraw` (`interpret: false`). `get` itself stays silent. |
| `packs/macroEngine-Datapack-v26.3/docs/store.md` | Documents `show` and printing `out.value` after `get`. |

- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0) passed.
- **Not verified:** nothing was run in a Minecraft server.

## macroEngine: store/data merge, placeholder module removed, functional config; org references

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/macroEngine-Datapack-v26.3/.../api/data/*` | Moved to `api/store/nbt/*`; the scratch keys are now `macroengine:store nbt.value` / `nbt.result` (was `macroengine:data value` / `result`). `docs/data.md` merged into `docs/store.md`. There was no `api/nbt` module. |
| `.../api/placeholder/**`, `.../core/internal/api/placeholder/**`, `docs/placeholder.md` | Removed. `to_plain` resolved `{selector:"@s"}` through a text_display, where `@s` is the display and not the player; `send*` and `actionbar*` only printed to chat. |
| `.../core/internal/api/store/_tok_score*`, `_player_name`, `_tok_ent` | `%score:obj%` reads the scoreboard directly; `%player%` resolves a tagged selector through a short-lived text_display and keeps only the string; new `%health%`, `%food%`, `%xp_level%`, `%dimension%` read entity data. |
| `.../api/store/convert`, `render_all`, `show`, `player/show` | New. Strings, ints, bytes and lists of strings only; `show` prints with an NBT `tellraw`. |
| `.../api/title/show_p`, `actionbar_p`, `core/internal/api/title/_apply` | Rebuilt on `api/store/render`; titles are plain strings printed with `interpret: false`. |
| `.../config.mcfunction`, `core/config/*`, `core/tick*`, `core/tick/dispatch`, `systems/log/set_level` | Config keys `enabled` and `namespace_allowlist` removed (nothing read them); `tick_rate`, `hud_rate`, `admin_rate`, `log_level`, `reload_warn` now drive the tick, dispatch and log systems. `exec`, `score_get`, `score_set`, `set_int`, `set_default`, `has`, `delete`, `config/tick_cfg` and the `macroengine.config` objective removed. See `docs/config.md`. |
| Workflows, scripts, `settings.gradle`, `pack.mcmeta` descriptions, README | Stale `vortacraftmc` / `VortaCraftMC` references changed to `vortaforge` / `VortaForge`. |

- **Kept on purpose:** runtime identifiers (`data/vortacraftmc/`, `#vortacraftmc.*` fake players, `com.vortacraftmc`; CLAUDE.md rule 8) and provenance text (`runtoolkit -> vortacraftmc -> vortaforge`, "Original source: Runtoolkit", NOTICE source URLs, `archived/archive.json`).
- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`.
- **Not verified:** nothing was run in a Minecraft server. In particular `%player%`, the `tick_rate` divider and the new config functions were never executed in game.

## macroEngine: `systems/nbt` removed, schema-driven runtime config

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `.../systems/nbt/*`, `.../core/internal/systems/nbt/*` | Removed. Nothing in the repo called them; `api/store/nbt/*` covers the same ground except `first`, `move` and `swap`, which now have no equivalent. |
| `.../config.mcfunction`, `core/config/*` | 54 config keys with a schema (`config_schema`): module switches, tick systems and rates, handler intervals, queue depth, store limits and token switches, title defaults, name length. `set` and `get` are table-driven and validate against the schema; `ensure` uses a revision marker (`config_rev`). |
| 376 files under `api/<module>/` and `systems/<module>/` | One guard line each: `execute if data storage macroengine:engine modules{<module>:0b} run return 0`. `validate`, `toggle`, `flag` and `systems/color` are not guarded. |
| `systems/flag/toggle_system`, `.../flip` | Rewritten. The old `exec` flipped the score 1 to 0 and back to 1 in one call, so it never toggled anything. |
| `api/toggle/<module>/true,false` | Write `config.module_<module>` and apply it. |
| Scans, queue, store, title, validator | The hook, geo, interaction, wand and perm-trigger scans honour `*_interval`; the queue honours `queue_max_depth`; `api/store/render`, `_dispatch`, `_resolve`, `_find_tpl`, `api/title/show_p` and `safe_name` read their limits from the config. |

- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`.
- **Not verified:** nothing was run in a Minecraft server. The module guards, the `%` interval counters and every `core/config/*` function are untested in game.


## Datapacks: Gate 1 (version gate) on format-121 packs

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/{DailyBonus,QuickShare,guikit-datapack,macroEngine-Datapack-v26.3,RTWrapper-v1.0.1}/data/<ns>/function/gate/version.mcfunction` | New. Creates the `vortaforge.gate` objective and sets `#<ns>.version` to 1. |
| Each pack's load entry (`load`, `core/load`, `setup`) | First executable line calls `<ns>:gate/version`. |
| Each pack's tick entry (`tick`, `core/tick`, `core/trigger_tick`) | First executable line: `execute unless score #<ns>.version vortaforge.gate matches 1 run return 0`. |

- **What it is:** a safeguard against partial or mixed installs (tick running without the pack's own load). It is not a sandbox and not tamper-proof: a datapack is plain text and the line can be deleted. Non-bypassable checks belong in a Fabric mod. Gates 2-4 (permission check, player consent, age declaration) are planned in later PRs; the age gate can only be a player's own declaration, not verification.
- **Not covered:** legacy packs (`pack_format` below 48, `functions/` directory naming), `guikit-demo` (no tick entry), `archived/`.
- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`.
- **Not verified:** nothing was run in a Minecraft server. Load order and `return 0` behavior in game are untested.

## Datapacks: Gate 2 (trigger permission), toggles, simple packs excluded

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/{guikit-datapack,macroEngine-Datapack-v26.3,RTWrapper-v1.0.1}/data/<ns>/function/gate/*` | `version` rewritten as a real version gate (downgrade protection: inactive when the world was last saved by a newer pack version). New: `permit_prompt`, `permit_tick`, `permit_grant` (approval through `/trigger <ns>.permit set 1`, no cheats, no `allowCommands`, no `/op`), `approve`, `revoke`, `status`, `set/1_on`, `1_off`, `2_on`, `2_off`. |
| Load entries (`core/load`, `setup`, RTWrapper `core/trigger_load`) | The version gate now also ends the load function with `return 0`. |
| Tick entries (`core/tick`, RTWrapper `core/trigger_tick`) | Version check, permission check and the permission tick, each bound to `return 0` and each skippable with `gate/set/N_off`. |
| `packs/DailyBonus`, `packs/QuickShare` | Gate 1 removed again: no input handling, no macros, no command execution, so no gate. |

- **Defaults:** both gates on. An updated world stays inactive until a player approves with `/trigger <ns>.permit set 1` (or an operator runs `<ns>:gate/approve`).
- **Limits:** `/trigger` is not authenticated; on a server with untrusted players any player can approve. Datapack gates are removable plain text; real enforcement belongs in a Fabric mod. Gate 3 (per-player consent) and Gate 4 (age declaration, a self-declaration, not verification) are not part of this PR.
- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`.
- **Not verified:** nothing was run in a Minecraft server. `click_event` text, `/trigger` flow, load order and `return 0` behavior are untested in game.

## Datapacks: gate line in every function of the complex packs

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/{guikit-datapack,macroEngine-Datapack-v26.3,RTWrapper-v1.0.1}/data/*/function/**` (2166 files) | First executable line: `execute unless score #<ns>.open vortaforge.gate matches 1 run return 0`. The separate version and permission return lines are folded into this one line. |
| `.../gate/refresh` | New. Recomputes `#<ns>.open` (1 only when every enabled gate passes); called from `version`, approve/revoke/grant and the `set/*` toggles. |
| `.../gate/rerun_load`, `permit_grant`, `approve` | Load entries are blocked while the pack is not approved, so approval schedules a re-run of them one tick later. |
| `.../gate/status` | Also prints `open`. |

- **Not gated:** `gate/*` itself, `_vc_origin.mcfunction` (watermarks stay comment-only), comment-only files, resource packs, simple packs, legacy packs, `archived/`.
- **Behavior to know:** a closed gate makes a function return 0, so `execute if function ...` callers (for example `macroengine:api/store/render`) see a failure. Cost: one score check per function call.
- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`. The Gradle build was not run.
- **Not verified:** nothing was run in a Minecraft server. The re-run of the load entries after approval is untested in game (double initialization is possible for load code that is not idempotent).

## Datapacks: Gate 3 (per-player consent)

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `packs/{guikit-datapack,macroEngine-Datapack-v26.3,RTWrapper-v1.0.1}/data/<ns>/function/gate/*` | New: `consent_tick`, `consent_prompt`, `consent_grant`, `consent_reset`, `set/3_on`, `set/3_off`. `version` creates the `<ns>.consent` trigger and the `gate.3` default (on); `status` prints `gate.3`. |
| The same 2166 functions | Second gate line: `execute if entity @s[type=minecraft:player] unless entity @s[tag=<ns>.consented] unless score #<ns>.gate.3 vortaforge.gate matches 0 run return 0`. Functions that run as a player who has not consented do nothing. |
| `core/tick` of each pack | Calls `<ns>:gate/consent_tick` for every player without the `<ns>.consented` tag (prompt once, then `/trigger <ns>.consent set 1`). |

- **Defaults:** gate 3 on. Every player must agree once before pack functions run as them; server-context functions (tick, load) are not affected.
- **Limits:** consent is a tag plus a trigger, not authentication. Withdrawal is an operator function (`gate/consent_reset`), there is no player-side withdraw trigger yet. Datapack gates are removable plain text. Gate 4 (age declaration, a self-declaration and not verification) is not part of this PR.
- **Verified:** `scripts/lint_datapacks.sh` (Mecha 0.101.0), `scripts/origin_watermarks.py --check`. The Gradle build was not run.
- **Not verified:** nothing was run in a Minecraft server. The `as @a[tag=!...]` loop and the prompt flow are untested in game.

## Temporary archive notice (maintenance paused)

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

| Path | Change |
|---|---|
| `README.md` | New "Project status (maintenance paused)" section listing the packs below. |
| `packs/guikit-demo/README.md` | New file: archive notice; notes this pack has no `minecraft:load` of its own and hooks into `guikit-datapack`'s tags instead. |
| `packs/macroEngine-Datapack-v26.3/.../function/setup.mcfunction` | One-line `# [TEMPORARILY ARCHIVED] ...` comment prepended (`macroengine:setup`, the pack's `minecraft:load` target). |
| `packs/guikit-datapack/.../function/core/load.mcfunction` | Same comment prepended (`guikit:core/load`). |
| `packs/RTWrapper/datapack/RTWrapper-Datapack/.../function/core/load.mcfunction` | Same comment prepended (`rtwrapper:core/load`). |
| `packs/RTWrapper-1.21.1/.../function/core/load.mcfunction` | Same comment prepended (`rtwrapper:core/load`). |
| `packs/RTWrapper-v1.0.1/.../function/core/load.mcfunction` | Same comment prepended (`rtwrapper:core/load`). |

- **Scope:** comment-only edits to existing load/setup functions plus README additions. No logic, scoring, or gating behavior was changed.
- **Not covered:** `RTWrapper-1.21.1`'s separate `vortacraftmc:core/load` function was left untouched (out of the requested scope).
- **Verified:** nothing run; these are comment/doc-only changes.
- **Not verified:** nothing was run in a Minecraft server (not applicable — no executable logic changed).

## Archive notice reverted (unarchive)

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update when reviewed_.

The archive pass above was never finished: `archived/archive.json` was never
given entries for these packs, and `SECURITY.md` / `NOTICE.md` already stated
that nothing under `packs/` is archived. This pass completes the reversal.

| Path | Change |
|---|---|
| `README.md` | Removed the "Project status (maintenance paused)" section; added a note that `guikitfw` is the active successor to `guikit-datapack`. |
| `packs/macroEngine-Datapack-v26.3/.../function/setup.mcfunction` | Removed the `# [TEMPORARILY ARCHIVED] ...` comment line. |
| `packs/guikit-datapack/.../function/core/load.mcfunction` | Removed the comment line **and** the `tellraw`/`return 1` pair that had been blocking the function's own gate/registry logic from ever running. |
| `packs/RTWrapper/datapack/RTWrapper-Datapack/.../function/core/load.mcfunction` | Removed the comment line. |
| `packs/RTWrapper-v1.0.1/.../function/core/load.mcfunction` | Removed the comment line. |

- **`packs/guikit-demo/` and `packs/RTWrapper-1.21.1/`:** the previous pass above records edits to these two paths, but neither exists anywhere in this repository (`git log --all --diff-filter=A` for either returns nothing). Whatever those edits landed on, it was never part of this monorepo's `packs/` tree; no corresponding cleanup was possible or needed here. Other mentions of `guikit-demo` in this file's table above are kept as a historical record of that earlier, apparently unmerged work rather than edited to look consistent after the fact.
- **Scope:** reverts the comment-only edits above, plus the two extra lines in `guikit-datapack`'s load function noted above. No scoring, gating, or data-storage logic was changed beyond that.
- **Verified:** `scripts/check_archive.py` (passes: `1 project(s), 0 error(s)` — the single `archived/archive.json` entry is `runtoolkit/suite`, unaffected by this change).
- **Not verified:** `./gradlew checkArchive` was not run (no network access to `services.gradle.org` to fetch the Gradle distribution in this environment); nothing was run in a Minecraft server.
