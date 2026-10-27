# macroEngine player safety information

This page explains the warning Dialog that macroEngine shows to a player who
has not yet agreed to use the pack on a server or in a world.

## The short version

- This copy of macroEngine was installed by, and is controlled by, the
  operator of the server or world you joined. The macroEngine developers do
  not run that server or world for you.
- The operator controls the pack files, its settings, the world, and data
  stored by the server. An operator can also inspect, change, disable, or
  remove datapack code and data.
- **Do not enter sensitive information.** Never put passwords, session or
  authentication tokens, verification codes, payment details, private
  messages, addresses, or other personal/sensitive information into chat,
  books, signs, name tags, anvils, item names, or other in-game inputs.
- **If you do not know or trust the server/world, choose Cancel or `no`, then
  disconnect or leave the world.** Do not continue just because a Dialog or
  a player asks you to.

No legitimate macroEngine consent screen asks for a password, token, code, or
other sensitive information.

## What each button does

Every choice is **per player**. One player's choice does not enable or disable
macroEngine for another player.

| Button | Result |
|---|---|
| **Cancel** (or Escape on the first screen) | Records a decline only for the player who clicked it. macroEngine's player-facing Gate 3 consent is not granted to that player. Other players are unaffected. |
| **Continue** | Opens a second Dialog screen. It does **not** grant consent by itself. |
| **More information** | Opens this page. It does not grant or deny consent. The chat message left by the prompt can reopen the warning. |
| **`yes`** on the second screen | Records Gate 3 consent only for that player and allows pack functions to run as that player, subject to the pack's other gates and settings. |
| **`no`** on the second screen (or Escape there) | Records a decline only for that player. Gate 3 consent is not granted. |

The setup load path shows the warning to unconsented players who are already
online, and the normal Gate 3 tick path shows it to unconsented players who
join later. A player sees it once until they reopen it or an operator resets
their consent state.

## If the Dialog closes or you change your mind

Use the **[Open warning again]** chat button, or type:

```text
/trigger macroengine.consent set 6
```

That reopens the warning only for you. Choosing `yes` afterwards enables the
pack for your player; choosing Cancel or `no` keeps it disabled for your
player.

An operator can withdraw a player's consent and make the warning eligible to
show again with:

```text
/execute as <player> run function macroengine:gate/consent_reset
```

## Why operator trust still matters

A datapack is not a sandbox. Datapack functions run with server-side command
authority, and the server/world operator chooses which packs, mods, plugins,
settings, and modifications are present. macroEngine's gates are safeguards
inside this pack, not authentication and not a security boundary against the
operator or other server software.

Depending on which features an operator uses, macroEngine may process normal
gameplay data such as player identity/UUID, scores, positions, actions,
settings, and text deliberately entered into its book, sign, lectern,
name-tag, or anvil inputs. The operator also controls server logs, world
files, backups, and any retention outside this pack. Ask the operator how
they handle that data if it matters to you.

Player text is handled as data, not as a command or instruction, and text
captures receive the pack's prompt-injection screening. See
[`docs/prompt_injection.md`](docs/prompt_injection.md). That screening is a
heuristic tripwire, not a reason to enter secrets.

## For server and world operators

- Keep Gate 3 enabled if you want this consent flow to control player-facing
  functions. If you disable Gate 3 or modify the pack, the choices above no
  longer describe your installation.
- Do not ask players to enter passwords, tokens, codes, or sensitive personal
  information through Minecraft text inputs.
- Tell players, outside the game if necessary, what server software you run
  and how logs/world data/backups are retained.
- Treat all player-supplied text as untrusted data, never as instructions to
  people, automation, or AI tools.

## Reporting a security problem

Do not publish a working exploit or sensitive data in a public issue. Use the
private reporting process in the repository
[`SECURITY.md`](../../SECURITY.md).
