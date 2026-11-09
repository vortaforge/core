# Chat Guard

> [!NOTE]
> **Server-side only.** Nothing has to be installed on a player's client. This is spam control, not moderation: it does not read or judge what is said.

Server-side Fabric mod (Minecraft **1.21.1**, Java 21, dedicated server) that drops public chat messages
before they are broadcast when a player is flooding the chat.

## Behaviour

- **Rate limit:** at most `maxMessages` accepted messages per `windowSeconds` (default 5 per 6 s). Over the
  limit, the message is dropped and the sender gets a private notice.
- **Repeat filter:** the same message again within `duplicateSeconds` (default 30 s) is dropped. Case,
  repeated spaces and surrounding spaces are ignored when comparing. `0` turns this off.
- **Length limit:** messages longer than `maxLength` characters (default 256, vanilla's own cap) are dropped.
- Only accepted messages count towards the window, so a flood does not extend its own penalty: the sender is
  free again one window after their last accepted message.
- Operators are exempt unless `exemptOperators` is `false`.
- Timers run on server ticks, so a lagging server does not make everyone look "quiet".

## Config

`config/chat-guard.json` (created on first start; values are clamped, a broken file falls back to defaults):

```json
{
  "maxMessages": 5,
  "windowSeconds": 6,
  "duplicateSeconds": 30,
  "maxLength": 256,
  "exemptOperators": true,
  "tooFastMessage": "You are chatting too fast.",
  "duplicateMessage": "Please do not repeat the same message.",
  "tooLongMessage": "That message is too long."
}
```

## Limits - read before relying on it

- **Only public chat is covered.** `/msg`, `/tell`, `/me`, `/say` and team chat go through other paths and
  are not limited.
- It looks at the text only. Someone who varies each message slightly passes the repeat filter; the rate
  limit is the part that still applies to them.
- Per-player only. It does not detect many accounts sending the same text.
- Limiter state is memory-only (4096 players at most, least recently seen forgotten first) and is reset on restart.

## Build / test

```bash
./gradlew :mods:chat-guard:build     # from the repo root
```

The unit tests cover the Minecraft-free classes (`ChatLimiter`, `ChatGuardSettings`). The Fabric wiring in
`ChatGuardMod` can only be verified in a running server: send more than `maxMessages` lines quickly, then
repeat one line.

See [CREDITS.md](../../CREDITS.md) for AI-assistance disclosure.
