# archived/build/

The datapack Gradle logic that used to live in the root `build.gradle`, extracted
verbatim as separate files on 2026-11-05. See `probe.lock` for the exact source
line ranges and `../archive.json` (ids `build-*`) for the registry entries.

| File | Root build.gradle section |
|---|---|
| `origin-watermark-helpers.gradle` | 3 - watermark finding/validation + `checkOriginWatermarks` |
| `pack-packaging-helpers.gradle` | 3b - copy/zip helpers and path filters |
| `zip-packs.gradle` | 4 - `zipPacks` |
| `pack-validation-helpers.gradle` | 5 - `vc*` helpers |
| `check-packs.gradle` | 5 - `checkPacks`, `printPackList`, `printPackFormats` |
| `merge-datapacks.gradle` | 6 - `mergeDatapacks` |

None of these files is applied. `settings.gradle` does not scan `archived/`, and
no build script includes them. They are kept because they are the only exact
record of how the packs were validated, merged and packaged, and because a
future restore should start from the real code instead of a rewrite.

Do not apply them from the live build. If the datapack programme is ever
re-enabled, read `../README.md` first: it was retired for concrete reasons
(no type safety, no security model, no debugging, no warnings).
