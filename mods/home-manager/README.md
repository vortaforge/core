# Home Manager

> [!NOTE]
> **Server-side only.** Nothing has to be installed on a player's client. Homes are private to the player who set them.

Server-side Fabric mod (Minecraft **1.21.1**, Java 21, dedicated server) with named homes.

## Commands

All commands are available to every player; there is no permission node.

| Command | Effect |
| --- | --- |
| `/sethome [name]` | Save your current position (and facing) as a home. Default name: `home`. Reusing a name moves it. |
| `/home [name]` | Teleport to a home. Default name: `home`. |
| `/delhome <name>` | Delete a home. |
| `/homes` | List your homes and how many slots you use. |

Names are case-insensitive, 1-16 characters of `a-z`, `0-9`, `_` and `-`.

## Config

`config/home-manager.json` (created on first start; values are clamped, a broken file falls back to defaults):

```json
{
  "maxHomes": 3
}
```

Lowering `maxHomes` later only blocks *new* homes; nobody loses homes they already have.

## Storage

Homes are saved to `<world>/homes.json` after every change and when the server stops, written through a
temporary file so a crash cannot leave half a file. They belong to the world, so copying or deleting the world
folder takes them along.

If `homes.json` exists but cannot be parsed at startup, the mod logs an error, keeps homes **in memory only**
for that session and leaves the file untouched, so it can be repaired by hand instead of being overwritten.

## Limits

- **No cooldown, warm-up or combat check.** `/home` is instant, so it can be used to leave a fight. Add a
  cooldown yourself if that matters on your server.
- It does not check whether a home is inside a protected area or still safe: a block placed or removed since
  `/sethome` can leave the player inside a wall or above lava.
- A home in a dimension that has since been removed cannot be used; the player is told so and the home is kept.
- Homes of deleted or renamed accounts are not cleaned up.

## Build / test

```bash
./gradlew :mods:home-manager:build     # from the repo root
```

The unit tests cover the Minecraft-free classes (`HomeBook`, `HomeSettings`). `HomeFile` (Gson, file I/O) and the
Fabric wiring in `HomeManagerMod` can only be verified in a running server: `/sethome`, restart, `/home`.

See [CREDITS.md](../../CREDITS.md) for AI-assistance disclosure.
