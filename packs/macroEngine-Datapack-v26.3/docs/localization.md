# Localization (language support)

Every fixed message macroEngine shows to players or admins — chat
(`tellraw`), titles/action bars, the setup-warning Dialogs, and the names of
the pack's utility items — is a **translatable text component**, resolved by
each player's own client language. The server needs no language setting: two
players on the same server can read the same message in different languages.

The translations live in the resource pack:

```
packs/macroEngine-Resourcepack-v26.3/assets/macroengine/lang/en_us.json   (source)
packs/macroEngine-Resourcepack-v26.3/assets/macroengine/lang/tr_tr.json   (Turkish)
```

English (`en_us`) is the source language. Every translatable component in the
datapack also carries its English text as the component `fallback`, so a
player who does not use the resource pack — or whose language has no
translation yet — sees the English message instead of a raw key like
`macroengine.msg.permission_denied`.

## Adding a language

1. Copy `en_us.json` to `<language_code>.json` in the same folder (for
   example `de_de.json`). The code must match a Minecraft client language id.
2. Translate the **values**; never rename the keys.
3. Keep the `%s` placeholders: they are filled with live values (counts,
   names) when the message is shown. A translation may reorder them with the
   numbered forms `%1$s`, `%2$s`, but the count must stay the same.
4. Some keys are sentence **fragments** joined around a live value, so their
   leading/trailing spaces are significant — keep them.
5. Ship the file inside the resource pack. Nothing else changes: no config,
   no reload of the datapack.

`scripts/tests/test_localization.py` checks offline that both shipped
language files have identical key sets and placeholder counts, that every key
used by the datapack exists with a matching English fallback, and that no new
hard-coded English player text sneaks into functions, Dialogs, or item data.

## Key layout

| Prefix | Used for |
| --- | --- |
| `macroengine.msg.<area>.<name>` | Chat/title messages (`msg.gate.*`, `msg.settings.*`, `msg.cb.*`, …) |
| `macroengine.ui.*` | Short shared UI words (`ui.enabled`, `ui.on`, `ui.yes`, …) |
| `macroengine.dialog.setup_warning.*` | The two setup-warning Dialogs |
| `item.macroengine.*` | Pack item names and lore |
| `macroengine.subtitle.*` | Sound subtitles referenced from `sounds.json` |

Where vanilla already has the word, the vanilla key is reused (the Dialogs'
Cancel/yes/no buttons use `gui.cancel`, `gui.yes`, `gui.no`), which gives
those labels every client language for free.

## Rules for new player-facing text

- Never hard-code English prose in a `tellraw`/`title`, a Dialog label, or an
  item name. Add a key to `en_us.json` (and the same key to `tr_tr.json`),
  then reference it as
  `{"translate":"macroengine.msg.…","fallback":"<the English text>"}`.
- The `fallback` must be exactly the `en_us` value — the guard test enforces
  this, so the datapack stays readable without the resource pack.
- Dynamic values inside a sentence go through `with` + `%s` placeholders
  (see `api/settings/apply` or the prompt-injection report), not by
  concatenating untranslatable fragments, so word order can differ per
  language.

## What is deliberately not localized

Some surfaces are identifiers or caller-owned text rather than engine
messages, and a few cannot be translated by the client at all:

- **Caller-supplied text.** The title/announce/hover APIs and the `tui/`
  printers render whatever the calling pack passes in. Pack authors who need
  per-language templates can use the store module's own server-side
  multilingual templates (see [`store.md`](store.md)).
- **Identifiers and machine dumps.** Module names in the toggle list,
  `key=value` lines in `gate/status` and `api/settings/status`, storage
  paths, and command text stay as-is so they match the functions and config
  keys they refer to.
- **The writable settings book's pages.** Writable-book pages are raw text a
  player edits; the client cannot translate them, and the `Key: Value` lines
  are a config syntax, not prose.
- **Console output.** The `say` load line only fires when no player is
  online; the server console has no client language.
- **Pack metadata and documentation.** The `pack.mcmeta` descriptions,
  `INFO.md`, and these docs stay English per repository convention.
- **The `[MACROENGINE]` prefix** is a brand marker, like a log tag.

One visible consequence: the anvil input carrier's name is the translatable
`item.macroengine.anvil_input` component, and `macroengine:input
anvil.old_name` now copies that component (its `fallback` is the former
literal name, `Anvil Input`).
