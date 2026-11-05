# archived/patches/

The archival change set for `vortaforge/core`, as a `git format-patch` mailbox.
One commit, one patch; apply it to a clean checkout of `main` to reproduce the
2026-11-05 retirement exactly.

| File | What it applies |
|---|---|
| `0001-chore-datapacks-retire-the-datapack-programme-disarm.patch` | Moves every datapack, generator, linter and test harness into `archived/` (renames preserved), extracts the datapack Gradle logic out of the root `build.gradle` into `archived/build/*.gradle`, rebuilds `archived/archive.json` as schema v2, and adds the kill switch, the guard, the blocklist, the hooks and the CI job. |

Sibling patches for `vortaforge/.github` (org-wide blocklist mirror, sync
script and workflow) live in that repository after this patch is applied; the
same `git am` workflow applies there.

## Apply

```bash
git clone https://github.com/vortaforge/core.git
cd core
git checkout -b datapacks-retired

# One patch today. Use a shell glob so a later split into 0002, 0003, ...
# still applies in filename order.
git am archived/patches/*.patch
```

`git am` recreates the commit (new hash) on your branch; it never rewrites
`main`. If a patch fails to apply, `git am --abort` returns to the clean state -
do not hand-fix a rejected hunk without understanding why it did not apply.

Alternative, if you only want the files and will craft your own commit:

```bash
git apply --stat  archived/patches/0001-*.patch   # summary
git apply --check archived/patches/0001-*.patch   # dry run
git apply         archived/patches/0001-*.patch
```

## Verify the applied result

```bash
python3 scripts/check_archive.py --strict          # 27 projects, 0 errors
python3 scripts/datapacks_disable.py verify        # 0 problems
python3 scripts/origin_watermarks.py --check       # 15 watermarks, 11 datapacks
python3 -m unittest discover -s scripts/tests      # 76 tests
node scripts/tests/site_behavior.test.mjs          # website retirement notices
./gradlew checkDatapackSwitch checkArchive verifyProject
```

Expected end state:

- `packs/` is an empty directory; `packs/merge-manifest.json` is gone.
- `archived/packs/` holds the 12 packs, `archived/tools/` the six retired tools,
  `archived/build/` the six extracted Gradle sections, `archived/docs/` the two
  retired documents, `archived/examples/` the template pack.
- `archived/archive.json` has `"schema_version": 2` and 27 entries, each with
  `"disarmed": true`.
- `datapacks.disabled.json` has `"enabled": false`.
- The root `build.gradle` contains no `zipPacks`, `mergeDatapacks`, `checkPacks`,
  `checkOriginWatermarks` or `lintDatapacks`.

## What is deliberately not in the patch

- No release assets, no server state, no credentials.
- No rewrite of the archived packs' `_vc_origin.mcfunction` watermarks: they
  still record the historical `packs/<name>` source path, which is the
  provenance record. `scripts/origin_watermarks.py` understands the moved tree.
- No change to `mods/` beyond moving `mods/datapack-blocker` into
  `archived/tools/`.
