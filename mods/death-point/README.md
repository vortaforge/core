# Death Point

> [!TIP]
> **Server-side only.** Nothing has to be installed on a player's client.

Server-side Fabric mod (Minecraft **1.21.1**, Java 21, dedicated server). When a player dies it tells them
where, and `/deathpos` shows that location again later.

## Behaviour

- On death the player gets a private message: `You died at 12, 64, -30 in the Overworld.`
- `/deathpos` (any player, no permission needed) repeats the **latest** death of the player who runs it.
- It never teleports anyone and never shows another player's death.
- Vanilla dimensions are named (`the Overworld`, `The Nether`, `The End`); modded dimensions show their id.

## Config

`config/death-point.json` (created on first start; a broken file falls back to defaults):

```json
{
  "announce": true,
  "enableCommand": true
}
```

## Limits

- **Memory only.** Death locations are forgotten on server restart; `/deathpos` then says nothing was
  recorded. Only the latest death is kept, and at most 4096 players (least recently used forgotten first).
- Vanilla has a related tool, the recovery compass, which points at the player's last death. This mod
  gives the coordinates as text instead, in chat and via a command.
- The position is the block the player was standing in when `AFTER_DEATH` fired. It can differ from where
  items landed (void deaths, lava, ender-pearl or fall damage) - treat it as a hint.

## Build / test

```bash
./gradlew :mods:death-point:build     # from the repo root
```

The unit tests cover the Minecraft-free classes (`DeathRecord`, `DeathBook`). The Fabric wiring in
`DeathPointMod` can only be verified in a running server: die once, then run `/deathpos`.

See [CREDITS.md](../../CREDITS.md) for AI-assistance disclosure.
