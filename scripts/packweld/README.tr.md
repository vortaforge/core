# packweld (Türkçe özet)

macroEngine ve guikit'i **kendi namespace'inle** üreten araç: Java datapack (+ resource pack) ve Bedrock add-on.
Python, sadece standart kütüphane. CLI, yerel web arayüzü veya kütüphane olarak kullanılır.

* Upstream kod **aynen** kopyalanır; yalnızca namespace, görünen ad, scoreboard/tag/storage adları ve pack metadata değişir.
* Çıktıya `LICENSE`, `NOTICE.md`, `README.md`, `licenses/` (Unlicense metinleri + PlayerAction **MIT** bildirimi) eklenir; kendi notunu `--notice` ile ekleyebilirsin.
* **Yapay zeka notu:** generator kodu Claude (Anthropic) tarafından yazılmıştır, bkz. `CREDITS.md`. `vendor/` altındaki kod değiştirilmemiştir (`packweld verify-vendor`).

```bash
python -m packweld ui
python -m packweld build --name "Acme Lib" --namespace acme --modules api/store,systems/math --set hud_rate=5
python -m packweld modules
```

**Bedrock add-on datapack'in dönüşümü değildir.** Bedrock'ta storage, macro ve item component yok; add-on, taşınabilir bir
alt kümenin (store, math, string, rng, perm, rate_limit, toggle, cb, hook, title, gui) Script API ile yeniden yazımıdır.
`api/cmd`, geo, uuid, wand, interaction ve `input/` Bedrock'a **taşınmadı**.

**Sınırlar:** canlı Minecraft istemcisinde doğrulanmadı (statik kontroller + sahte API ile testler). Java hedefi yalnızca 26.3.
macroEngine'in `api/cmd/*` ve `api/perm/exec|run` fonksiyonları yetki kontrolsüzdür: sadece kontrol ettiğin sunucu/haritalarda
kullan, bu fonksiyonlara güvenilmeyen metin verme, gerekmiyorsa modülleri çıkar. Upstream hata: `events/fire_queued`,
var olmayan `events/internal/fire_deferred` fonksiyonunu kuyruğa ekler (`packweld doctor`).
