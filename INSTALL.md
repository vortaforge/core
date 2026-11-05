# Kurulum / Installation

Bu depo (`vortaforge/core`) için 2026-11-05 datapack emekliliğini uygulayan
yamalar ve adımlar. Ayrıntılı sistem açıklaması: [`docs/ARCHIVAL.md`](docs/ARCHIVAL.md)
(Türkçe + İngilizce). Politika: [`archived/README.md`](archived/README.md).

Yama dosyaları:

| Depo | Yama |
|---|---|
| `vortaforge/core` | `archived/patches/0001-chore-datapacks-retire-the-datapack-programme-disarm.patch` |
| `vortaforge/.github` | `archived/patches-gh/0001-feat-blocklist-organisation-wide-datapack-blocklist-.patch` |

## 1. Core deposu

```bash
git clone https://github.com/vortaforge/core.git
cd core
git checkout -b datapacks-retired
git am archived/patches/*.patch        # sıra: dosya adına göre
```

`git am` commit'i yeniden oluşturur (hash değişir), `main`'i yeniden yazmaz.
Uygulama patlarsa `git am --abort` ile temiz duruma dönün.

Alternatif (yalnızca dosyalar, kendi commit'inizle):

```bash
git apply --stat  archived/patches/0001-*.patch
git apply --check archived/patches/0001-*.patch
git apply         archived/patches/0001-*.patch
```

## 2. .github deposu (core'dan SONRA)

```bash
git clone https://github.com/vortaforge/.github.git
cd .github
git checkout -b datapack-blocklist
git am /path/to/core/archived/patches-gh/*.patch
```

## 3. Kancaları kur (push öncesi engelleme)

```bash
cd core
git config core.hooksPath .githooks
```

## 4. Doğrula

```bash
python3 scripts/check_archive.py --strict          # 28 kayıt, 0 hata
python3 scripts/datapacks_disable.py verify         # 0 problem
python3 scripts/origin_watermarks.py --check        # 15 watermark, 11 datapack
python3 -m unittest discover -s scripts/tests       # 77 test
node scripts/tests/site_behavior.test.mjs
./gradlew checkDatapackSwitch checkArchive verifyProject
```

Beklenen son durum: `packs/` yalnızca `README.md` içerir; `archived/packs/`
altında 12 paket, `archived/tools/` altında 6 araç, `archived/build/` altında
kök `build.gradle`'dan çıkarılmış 6 Gradle bölümü vardır;
`datapacks.disabled.json` → `"enabled": false`.

## 5. Günlük kullanım

```bash
python3 scripts/datapacks_disable.py status        # kapalı mı?
./gradlew printArchiveList                         # ne arşivlendi, neden
python3 scripts/datapack_guard.py --staged --protect --blocklist   # elle kontrol
```

## 6. Geri açma (bilinçli)

```bash
python3 scripts/datapacks_disable.py enable \
    --token VORTAFORGE-DATAPACKS-2026-11-05-DISARMED \
    --reason "neden geri açıldığını anlatan bir cümle"
```

Bu yalnızca anahtarı çevirir; paketler `archived/` altında `disarmed` kalır.
Tam geri dönüş adımları `docs/ARCHIVAL.md` içinde.

## Notlar

- Ağaç ile yama birebir aynı sonucu verir (uygulama sonrası `diff -r` boş).
- Yama, arşivlenen paketlerin `_vc_origin.mcfunction` watermark'larını
  **değiştirmez**: onlar `packs/<ad>` kaynak yolunu kaydeden provenans
  kaydıdır; `scripts/origin_watermarks.py` taşınmış ağacı anlar.
- Doğrulandı: `check_archive --strict`, `datapacks_disable verify`,
  `origin_watermarks --check`, 77 Python testi, Node site testi, Groovy parse,
  ve Gradle 9.8.2 (JDK 21) ile `guardArchives checkDatapackSwitch checkArchive
  verifyMod testRepository writeProjectInventory` + `printArchiveList`.
  Doğrulanmadı: gerçek `mods/` ağacıyla tam `./gradlew ci` (Fabric Loom +
  ağ), `testGuiGenerator` (pytest + guigenmc kurulumu), Ward (sunucu
  başlatılmadı), `.github` workflow'unun çalışması (yalnızca YAML doğrulandı).
