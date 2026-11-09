# Lag Report

> [!NOTE]
> **Read-only.** `/lag` changes nothing in the world. It is a first look at where a slow server spends its time, not a profiler.

Server-side Fabric mod (Minecraft **1.21.1**, Java 21, dedicated server). Nothing is needed on the client.

## Behaviour

`/lag` (permission level 2 by default) prints:

- the server's **average tick time** in ms and the TPS it implies (capped at 20), marked `OK` or `BEHIND`
  (above the 50 ms budget);
- for every dimension: how many entities are loaded, how many players are in it, and the most common entity
  types (default top 5, e.g. `412 x minecraft:item`).

## Config

`config/lag-report.json` (created on first start; values are clamped, a broken file falls back to defaults):

```json
{
  "topEntityTypes": 5,
  "permissionLevel": 2
}
```

`permissionLevel` is the vanilla level needed to run `/lag`: `0` everyone, `2` operators, `4` owners.

## Limits - read before relying on it

- **The tick time is the server's own rolling average**, as reported by the game. It says the server is
  slow, not *why*. Entity counts are a hint (a pile of items or one mob farm is a common cause); block
  entities, redstone, chunk generation and other mods are not shown.
- The entity walk runs on the server thread. On a world with hundreds of thousands of loaded entities the
  command itself can cost a visible hitch, which is why it defaults to operators.
- It does not remove, limit or alter anything. Acting on the numbers is up to you.
- It does not replace a sampling profiler such as spark when you need to find the actual hot code path.

## Build / test

```bash
./gradlew :mods:lag-report:build     # from the repo root
```

The unit tests cover the Minecraft-free classes (`Tps`, `EntityCensus`, `LagReportSettings`). The Fabric
wiring in `LagReportMod` can only be verified in a running server.

See [CREDITS.md](../../CREDITS.md) for AI-assistance disclosure.
