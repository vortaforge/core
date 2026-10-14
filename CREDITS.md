# Credits & AI-assistance disclosure

This file records which parts of the repository were written or changed with AI assistance, so that
AI involvement is visible in the repository itself and not only through commit authorship.

## 2026-10-14 - chore: archive all datapacks and move the repository to Fabric only

**Tool:** Claude (Anthropic), working from a prompt by the maintainer. Review status: _pending - update
when reviewed_.

### Changed (AI-assisted edit)

| File | Change |
|---|---|
| `packs/` -> `archived/data-packs/packs/` | `git mv` of every datapack, the macroEngine resource pack and `merge-manifest.json`. No file contents changed, except the status line in `InteractionClickDetection/SECURITY.md`. |
| `scripts/{dp-depman,dpgen,gui_generator,lint_datapacks.sh,fix_text_components.py,origin_watermarks.py}`, `examples/template-datapack`, `.github/ISSUE_TEMPLATE/bug_report_pack.yml` -> `archived/data-packs/other/` | `git mv`. The issue form also lost its status banner. |
| `build.gradle` | Sections 3-6 (origin watermarks, `zipPacks`, `checkPacks`, `printPackList`, `printPackFormats`, `mergeDatapacks`) removed and copied verbatim to `archived/tasks/datapack-tasks.gradle`. `clean`, root `build` and `checkArchive` were rewritten for a Fabric-only tree. |
| `settings.gradle` | `packs` removed from `SCAN_ROOTS`; the `rtwrapper-fabric` exclusion removed. |
| `.github/workflows/build.yml` | Reduced to build + Gradle lint + source archive + summary. Datapack lint, guigenmc matrix, release gate, pack zips and the `publish` job removed; the original is kept in `archived/tasks/workflows/build.datapack-ci.yml`. |
| `.github/workflows/codeowners-sync.yml` | Pack rules removed from the generated CODEOWNERS and from its validation; the old rules are in `archived/tasks/workflows/codeowners-sync.datapack-rules.txt`. |
| `.github/scripts/ai-agent.js` | The `lint` check now runs `./gradlew lint --continue` instead of `scripts/lint_datapacks.sh`. |
| `scripts/check_archive.py`, `archived/archive.json`, `archived/README.md` | Registry gained 21 entries; the checker no longer looks at `packs/` or the merge manifest. |
| `README.md`, `NOTICE.md`, `SECURITY.md`, `CONTRIBUTING.md`, `AGENT.md`, `CLAUDE.md`, `scripts/README.md`, issue and PR templates | Datapack sections removed (kept in `archived/data-packs/other/docs/removed-doc-sections.md`). The "Project status (maintenance paused)" section, banners and anchor links were deleted, including in `mods/*/README.md`. |

- **Verified:** `scripts/check_archive.py` passes (22 entries, 0 errors); `build.yml`, `codeowners-sync.yml` and the issue forms parse as YAML; `ai-agent.js` passes `node --check`; `check_archive.py` compiles.
- **Not verified:** no Gradle run. The wrapper could not be downloaded in the sandbox, so `build.gradle` and `settings.gradle` were only checked for balanced braces. The new `build.yml` and `./gradlew lint` in `ai-agent.js` have not run on GitHub. `scripts/audit_repo.py` still expects `packs/` and reports two critical findings. `index.html` still lists the datapack downloads.
- **Left as is on purpose:** the "maintenance pause" comments in `.github/dependabot.yml`, `.github/workflows/codeowners-sync.yml` and `.github/workflows/backup-org.yml`, which explain settings that are still switched off (Dependabot limit 0, no weekly schedule, no unattended token use). The Fabric mods `datapack-blocker` and `datapack-fixer` stay in `mods/`.

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

