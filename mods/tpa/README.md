# TPA

> [!NOTE]
> **Server-side only.** Nothing has to be installed on a player's client. A request never moves anyone until the target explicitly accepts it.

Server-side Fabric mod (Minecraft **1.21.1**, Java 21, dedicated server) with consent-based teleport requests.

## Commands

All commands are available to every player; there is no permission node.

| Command | Effect |
| --- | --- |
| `/tpa <player>` | Ask to teleport **to** that player. |
| `/tpaccept` | Accept the newest pending request addressed to you. The requester is teleported to where you stand. |
| `/tpdeny` | Refuse the newest pending request addressed to you. |
| `/tpcancel` | Withdraw your own pending request. |

## Behaviour

- One pending request per sender; a new `/tpa` replaces the previous one.
- Requests expire after `expirySeconds` (default 60). A sender must wait `cooldownSeconds` (default 10)
  between requests; a rejected attempt does not restart the cooldown.
- If several players asked you, `/tpaccept` and `/tpdeny` answer the newest first.
- Pending requests are dropped when either player disconnects.
- Timers run on server ticks, so a lagging server does not expire requests early.

## Config

`config/tpa.json` (created on first start; values are clamped, a broken file falls back to defaults):

```json
{
  "expirySeconds": 60,
  "cooldownSeconds": 10,
  "allowCrossDimension": true
}
```

With `allowCrossDimension` set to `false`, accepting a request from someone in another dimension is refused.

## Limits

- **There is no `/tpahere`**, no warm-up delay and no cancellation on damage or movement. A player can
  `/tpa` away from a fight once the target accepts.
- The teleport destination is the target's position at the moment they accept, not when the request was sent.
- It does not check whether the destination is protected by a claim or region mod; it only moves a player
  the target agreed to receive.
- Request state is memory-only and is reset on restart.

## Build / test

```bash
./gradlew :mods:tpa:build     # from the repo root
```

The unit tests cover the Minecraft-free classes (`RequestBook`, `TpaSettings`). The Fabric wiring in `TpaMod`
(commands, `ServerPlayerEntity#teleport`) can only be verified in a running server with two players.

See [CREDITS.md](../../CREDITS.md) for AI-assistance disclosure.
