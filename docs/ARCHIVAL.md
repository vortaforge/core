# Datapack retirement, kill switch and guard — `docs/ARCHIVAL.md`

> [!IMPORTANT]
> **Bu sistem fail-closed çalışır.** Bozuk bir blocklist, eksik bir git ref veya okunamayan bir artefakt "geçti" sayılmaz — hata verir. Kırmızı bir kapı, kuralın çalıştığının kanıtıdır.

> **Türkçe** aşağıda: [Nasıl kurarım?](#türkçe--nasıl-kurarım) ·
> **English** below: [How do I install it?](#english--how-do-i-install-it)
>
> Yamalar: `archived/patches/` (core) ve `archived/patches-gh/`
> (`vortaforge/.github`). Patch: 28 kayıt / 76 test / Gradle 9.8.2 ile
> doğrulandı.

This document is the operator manual for the 2026-11-05 datapack retirement in
`vortaforge/core`: what was moved, what is now blocked, how to install and use
the guard, and how to reverse the decision deliberately.

| Piece | Where | What it does |
|---|---|---|
| Kill switch | `datapacks.disabled.json`, `archived/datapacks.disabled` | `"enabled": false`. Missing/unreadable counts as disabled. |
| Switch CLI | `scripts/datapacks_disable.py` | `status`, `disable`, `enable`, `verify` |
| Guard | `scripts/datapack_guard.py` | blocks new datapacks, revived archived tooling, blocklisted accounts |
| Archive registry | `archived/archive.json` (schema v2), `archived/archive.schema.json` | every retired project, `"disarmed": true` |
| Registry validator | `scripts/check_archive.py` | fail-closed validation incl. disarmed/bijection/no-workflow rules |
| Account blocklist | `blocklist/blocklist.json` | logins, bot/AI rules, public-profile scan policy |
| Hooks | `.githooks/pre-commit`, `.githooks/pre-push` | run the guard before a commit/push |
| CI | `.github/workflows/quality.yml`, job `datapack-guard` | runs the guard + registry + switch; blocks the quality gate |
| Org-wide mirror | `vortaforge/.github` | `blocklist/`, `scripts/blocklist_sync.py`, `workflows/datapack-blocklist-sync.yml` |
| Extracted Gradle | `archived/build/*.gradle` | the datapack logic that was in the root `build.gradle` |

---

## Türkçe — Nasıl kurarım?

### 1. Yamaları uygula (önerilen yol)

Bütün değişiklikler `archived/patches/` altında **git format-patch** biçiminde
duruyor; geçmiş korunur, tek tek veya topluca uygulanabilir:

```bash
git clone https://github.com/vortaforge/core.git
cd core
git checkout -b datapacks-retired            # asla doğrudan main'e uygulamayın

# Hepsini sırayla uygula (mailbox biçimi, commit mesajları korunur):
git am archived/patches/*.patch

# Yalnızca bir kısmını denemek isterseniz:
git apply --stat archived/patches/0001-*.patch   # önce özet
git apply --check archived/patches/0001-*.patch  # sonra deneme
git apply archived/patches/0001-*.patch

# Uygulama başarısız olursa temiz duruma dönün; hunk'ları elle düzeltmeyin:
git am --abort
```

> `git am` uygulanan commit'leri **yeniden oluşturur** (hash'ler değişir); bu
> normaldir ve `main` geçmişini yeniden yazmaz, yeni bir dal oluşturur.
> Yamalar `archived/patches/README.md` içindeki sırayla uygulanmalıdır.

### 2. `.github` deposu (organizasyon geneli)

```bash
git clone https://github.com/vortaforge/.github.git && cd .github
git checkout -b datapack-blocklist
git am /path/to/core/archived/patches-gh/*.patch
```

`.github` deposundaki `blocklist/blocklist.json`, `core` deposundakinden
**türetilir** (`scripts/blocklist_sync.py`) ve `datapack-blocklist-sync.yml`
iş akışıyla güncel tutulur. Elle düzenlemeyin; `core`'dakini düzenleyip
senkronizasyonu çalıştırın.

### 3. Yerel kancaları (hooks) kur — push öncesi engelleme

```bash
# Depo kökünde:
git config core.hooksPath .githooks

# Deneme:
python3 scripts/datapack_guard.py --staged --protect --blocklist
.git/hooks/pre-commit 2>/dev/null || .githooks/pre-commit   # kanca doğrudan da çalışır
```

`pre-commit` her commit'te, `pre-push` her push'ta guard'ı çalıştırır. Atlatmak
mümkündür (`--no-verify`) — bu yüzden **aynı kontroller CI'da da çalışır**
(`datapack-guard` işi) ve atlatma orada yakalanır.

### 4. Doğrula

```bash
python3 scripts/datapacks_disable.py status      # enabled=false görmelisiniz
python3 scripts/datapacks_disable.py verify      # 0 problem
python3 scripts/check_archive.py --strict        # 28 kayıt, 0 hata
./gradlew checkDatapackSwitch checkArchive       # Gradle tarafı
python3 scripts/origin_watermarks.py --check     # 15 watermark, 11 datapack (arşivde)
./gradlew verifyProject                          # guard + testler
python3 -m unittest discover -s scripts/tests -v # 76 test
node scripts/tests/site_behavior.test.mjs        # site davranışı
```

### 5. Günlük kullanım

| İstek | Komut |
|---|---|
| Datapack'ler kapalı mı? | `python3 scripts/datapacks_disable.py status` |
| Neden arşivlendi, neler var? | `./gradlew printArchiveList` · `archived/README.md` |
| Yeni datapack engellensin mi? | Otomatik: kanca + CI. Elle: `python3 scripts/datapack_guard.py --staged --protect` |
| Birini blocklist'e ekle | `blocklist/blocklist.json` → `blocked[]` (zorunlu: `reason`, `added_on`) → `python3 scripts/datapack_guard.py --audit-refs --blocklist` |
| Datapack'leri geri aç (bilinçli) | `python3 scripts/datapacks_disable.py enable --token VORTAFORGE-DATAPACKS-2026-11-05-DISARMED --reason "..."` |

### 6. Geri açma (re-enable) — bilinçli ve pahalı

Geri açma **yalnızca anahtarı** çevirir. Paketler `archived/packs/` altında
`disarmed` olarak kalır ve build'e girmez. Tam geri dönüş için:

1. `python3 scripts/datapacks_disable.py enable --token ... --reason "..."`
2. Her paketi `git mv archived/packs/<ad> packs/<ad>` ile geri taşı, kayıt
   defterinden girdisini sil, `original_path` alanını temizle.
3. `archived/build/*.gradle` bölümlerini **elle** kök `build.gradle`'a geri
   uygula (otomatik "apply" edilmez; bilinçli bir karar olsun diye).
4. `scripts/check_archive.py` ve `./gradlew verifyProject` çalıştır.
5. Eski `archived/tools/` araçlarını geri getirmek **yeni bir proje teklifi**
   sayılır: eski halinin hak etmediği incelemeyi ister.

### 7. Sorun giderme

| Belirti | Sebep / çözüm |
|---|---|
| `datapack_guard: fail-closed: ...` | Guard bir girdiyi okuyamadı (git ref yok, blocklist bozuk). Hata **geçiş değil**, düzeltin. |
| `check_archive: path 'archived/...' does not exist` | Kayıt defteri ile dizin uyuşmuyor; `git status` ile dosyayı geri alın ya da girdiyi düzeltin. |
| `checkDatapackSwitch failed` | `datapacks.disabled.json` `enabled=false` değil veya marker/registry tutarsız. |
| Push reddedildi: `force-push` | Korumalı dala force-push engelli. Geçmişi yeniden yazmak yerine yeni commit ekleyin (bkz. `docs/MAINTAINER_GUIDE.md`). |
| CI `Datapack guard` kırmızı | PR diff'i yeni datapack içeriyor, hesap blocklist'te veya bir arşiv kuralı ihlal edildi. Rapor artifact'ında (`datapack-guard-report`) hangi kural olduğu yazar. |
| Tar/source arşivi (`.git` yok) | Diff tabanlı kontroller atlanır (uyarı olarak raporlanır); registry ve blocklist kontrolleri yine çalışır. |

---

## English — How do I install it?

### 1. Apply the patch series (recommended)

Every change is a `git format-patch` mailbox under `archived/patches/` (see its
own `README.md` for the order):

```bash
git clone https://github.com/vortaforge/core.git
cd core
git checkout -b datapacks-retired        # never apply straight to main
git am archived/patches/*.patch          # preserves commit messages

# or, to try a single patch first:
git apply --stat  archived/patches/0001-*.patch
git apply --check archived/patches/0001-*.patch
git apply         archived/patches/0001-*.patch
```

`git am` recreates the commits (new hashes); it does not rewrite `main`.

### 2. `vortaforge/.github` (organisation-wide)

```bash
git clone https://github.com/vortaforge/.github.git && cd .github
git checkout -b datapack-blocklist
git am /path/to/core/archived/patches-gh/*.patch
```

`blocklist/blocklist.json` in `.github` is **derived** from `core`'s copy by
`scripts/blocklist_sync.py` and kept current by
`workflows/datapack-blocklist-sync.yml`. Edit `core`'s file and let the sync
run; do not hand-edit the generated one.

### 3. Install the hooks (pre-push blocking)

```bash
git config core.hooksPath .githooks
python3 scripts/datapack_guard.py --staged --protect --blocklist   # try it
```

`pre-commit` runs on every commit, `pre-push` on every push. `--no-verify`
bypasses them, which is exactly why the same checks run in CI (job
`datapack-guard`) and a bypass is caught there.

### 4. Verify

```bash
python3 scripts/datapacks_disable.py status
python3 scripts/datapacks_disable.py verify
python3 scripts/check_archive.py --strict
python3 scripts/origin_watermarks.py --check
./gradlew checkDatapackSwitch checkArchive verifyProject
python3 -m unittest discover -s scripts/tests -v
node scripts/tests/site_behavior.test.mjs
```

Expected: switch `enabled=false`, `verify` 0 problems, registry 28 entries /
0 errors, 76 Python tests OK, website test passes.

### 5. What blocks what

| Surface | Rule | Where |
|---|---|---|
| New pack / new datapack file | blocked | guard, `live-packs-tree` / `new-datapack` |
| Reviving archived tooling (`scripts/dpgen`, `ward`, `mods/datapack-blocker`, ...) | blocked | guard, `retired-tooling` |
| Removing a pack (archiving) | allowed, warning + registry must be updated | guard + `check_archive.py` |
| Blocklisted account opening a PR | blocked | guard `--pr` (needs `datapack-approved` label to override) |
| Blocklisted commit identity pushed | blocked | `pre-push` (`--push`) |
| Force-push to a protected branch | blocked | `pre-push` (`PRE_PUSH_FORCE=1`) |
| Archived entry not `disarmed` | blocked | `check_archive.py` |
| Workflow file under `archived/` | blocked | `check_archive.py` |
| A new datapack-shaped test fixture | allowed | `scripts/tests/fixtures/` and `archived/` are exempt |

### 6. Blocking an account

1. Add the login to `blocklist/blocklist.json` under `blocked[]` with `reason`,
   `added_on`, `added_by`, `scope`, `enforcement`. Exact logins only; use
   `ref_patterns` for branch/tag names. Prefer adding the numeric `user_ids`
   too: `gh api users/<login> --jq .id`.
2. Validate: `python3 scripts/datapack_guard.py --audit-refs --blocklist`.
3. Mirror org-wide: the sync workflow runs on the next `core` push, or locally
   `python3 scripts/blocklist_sync.py --check --write` inside `.github`.
4. For a datapack developer discovered by **profile scan** (bio/company contains
   `datapack`, etc.), the sync job opens an issue with the matched token; the
   account is refused (fail-closed) until the issue is resolved. Public profile
   fields only — never private data.

### 7. Re-enabling (deliberate and expensive)

```bash
python3 scripts/datapacks_disable.py enable \
    --token VORTAFORGE-DATAPACKS-2026-11-05-DISARMED \
    --reason "why, in a sentence"
```

That only flips the switch. Packs stay disarmed in `archived/`. A real restore
means moving each pack back with `git mv`, deleting its registry entry and
`original_path`, re-applying the archived `archived/build/*.gradle` sections by
hand, then running `check_archive.py` and `verifyProject`. Treat it as a new
project proposal with the review the first one never had.

### 8. Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `datapack_guard ... fail-closed` | The guard could not read an input (missing git ref, broken blocklist). This is a failure, not a skip. |
| `check_archive: '...' does not exist` | Registry and tree disagree; restore the file or fix the entry. |
| `checkDatapackSwitch failed` | The switch is not `enabled=false`, or the marker/registry disagree. |
| `pre-push: force-push detected` | Protected branch; add commits instead of rewriting history (`docs/MAINTAINER_GUIDE.md`). |
| CI `Datapack guard` red | The diff adds datapack content, the account is blocklisted, or an archive rule broke; the artifact `datapack-guard-report` names the rule. |
| Source tarball, no `.git` | Diff checks are skipped with a warning; registry and blocklist checks still run. |
