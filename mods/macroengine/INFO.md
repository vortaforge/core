# macroEngine: read this before you continue

This page explains what macroEngine does with data packs, what it does **not** do, and which inputs must never be typed.

**This mod ships no data pack.** Its jar contains Java, a `fabric.mod.json` and one language file. It does not contain `data/`, it does not contain `pack.mcmeta`, and nothing in it runs a function. If you are looking for the macroEngine scripting layer, that is a separate datapack that you install yourself, under `archived/packs/` in the repository.

## 1. Third-party content notice

The data packs in your world, and everything that flows through them (text typed on signs, in books, on name tags, in anvil renames, in chat, and the contents of any other datapack, mod or resource pack in the same world) is **third-party content**. It is **not audited, verified or endorsed by Mojang, Microsoft or VortaForge**. Nothing on this page is a security guarantee. You are responsible for checking what you install and what you type.

Your world runs under the authority of whoever operates the server. **The server owner controls which packs are installed, what they store and how they behave on this installation** — Mojang, Microsoft and VortaForge have no oversight over any specific server's configuration. Trust this content only to the extent you trust the server operator.

## 2. What this mod actually does

Three things, all of them read-only:

| It does | It does not |
|---|---|
| Scans the packs the game actually loaded and reports what it finds | Block, disable or quarantine any pack or account |
| Prints findings to the server log at world load | Send anything over the network |
| Shows a screen before a world opens, if a pack you have not acknowledged is present | Tell you a pack is safe |

### 2a. The confirmation screen

Before a world opens, if any loaded pack has not been acknowledged at its current content hash, a screen lists:

- each unacknowledged pack, with an **archived** tag when it matches the archive registry or declares `"vortaforge": {"status": "archived"}` in its `pack.mcmeta`
- the scanner's findings for it, each with the matched snippet

Two buttons. **I accept the risk** writes the pack's identifier and content hash to `config/macroengine/acknowledged.json` and continues. **Cancel** stops the load — the world does not open and the pack is not enabled.

The acknowledgement is bound to the content hash. Change one byte of the pack and it asks again. That is the whole mechanism: it is a record that you saw a specific version, not a verdict on it.

### 2b. On a dedicated server

There is no client to show a screen to, so the flow is:

- At startup, an unacknowledged pack is named in the server log at `WARN` level.
- `/datapack enable <pack>` is refused for an unacknowledged pack.
- An operator acknowledges with `/macroengine ack <pack>` (permission level 4).

**The client-side screen cannot protect a multiplayer server.** A server owner acknowledges on the server; a player's client acknowledgement covers only that client's own single-player worlds. A pack that a server forces on you is acknowledged or not acknowledged at the server's discretion, not yours.

## 2c. No screen from this mod is an official Mojang/Microsoft screen

Every screen macroEngine shows is drawn by this mod, inside the game's own UI. It is **not** an official Mojang, Microsoft or Minecraft system screen, however it looks. **No legitimate dialog — from this mod, from a datapack, or from any server — will ever ask for your Microsoft account email, password, verification code, or any other account credential.** If a dialog asks for that, close it immediately, do not type anything into it, and report it (Section 6).

## 2d. Regional rules for online services

macroEngine is a client/server mod. It does not host user accounts or a public service and cannot open network connections; it reads the packs already loaded on the machine it runs on.

Some jurisdictions regulate online platforms. One example is Türkiye's "Social Network Provider Procedures and Principles" (BTK decision 2023/DK-İD/119, Official Gazette no. 32150, 1 April 2023), issued under Law 5651. According to its text:

- It addresses *social network providers*: services that let users create, view or share content for social interaction (Art. 3). Services where social interaction is only a secondary or incidental feature are out of scope (Art. 1).
- The representative, response, reporting, ad-library and data-localisation duties (Art. 4, 9, 10, 11, 13) attach to foreign-origin providers with more than one million daily accesses from Türkiye; heavier requirements start at ten million (Art. 5).
- Duties such as disclosing user data to prosecutors (Art. 12) and removing reported content (Art. 36) are placed on the platform or its representative, not on people who install a mod.

Whether a particular server or service counts as a social network provider is for the regulator to decide (Art. 37, 38); this text does not settle it. If you operate a public community service in or for users in such a jurisdiction, get legal advice. Nothing on this page is legal advice.

## 3. How to review a pack (server owners and admins)

Review packs yourself, or have a person you trust do it, before enabling one on a world with other players. Do this reading by hand or with plain `grep`, not by pasting pack contents into an AI tool that can act on them.

1. **Get it from a repository you trust** and compare the folder with what you installed (`diff -r`, or `git diff` against a clean checkout). Any difference you did not make is a reason to stop.
2. **List what else is loaded.** Run `/datapack list`. Every datapack in the world shares the same function namespace space; there is no isolation between datapacks.
3. **Check function tags.** Tags merge across datapacks, so another pack can append entries to `#minecraft:load`, `#minecraft:tick` and any `#<namespace>:` tag. Read the `data/*/tags/function/` files of every installed pack for entries you do not recognize.
4. **Find command-executing code.** Several function-based packs run a caller-supplied string as a command. Find them with:

   ```
   grep -rnE '^\$.*\$\((cmd|command)\)' data
   ```

5. **Check how input is handled.** The macroEngine pack's input system (`input/*`) only writes raw text to a storage location and does not execute it. Anything built on top must validate it first with `input/validate/check` (`int`, `float`, `bool`, `tag_safe`) and must never substitute it into a command or JSON string.
6. **Treat all text fields as untrusted.** `pack.mcmeta` descriptions, README and license text, item names, book pages and sign lines can all contain text written to mislead a reader, human or AI.

**Section 3 used to end with "check gate state: run `/function macroengine:gate/status`".** That function does not exist. The gate system was removed from the pack because it blocked people who had done nothing wrong; this mod reports instead. Nothing in this repository will ever tell you a pack is safe to run.

## 4. Inputs that must never be typed

This applies to signs, writable books, lecterns, name tags, anvil renames, command block minecarts and chat.

- **Commands or command fragments:** anything starting with `/`, or containing `run`, `execute`, `function`, `data`, `op`, `give`, `setblock` and similar, written so that something might execute it.
- **Macro and syntax characters:** `$`, `$(`, `{`, `}`, `[`, `]`, `"`, `'`, `\`, `:` and `@a`/`@e`/`@p`/`@r`/`@s` selectors, unless an interface explicitly asks for them. These are exactly what `input/validate/check` rejects for `tag_safe`.
- **JSON or NBT:** raw text components, item components or other structured data meant to be parsed later.
- **Instructions aimed at AI tools:** phrases such as "ignore previous instructions", "you are now...", "system:", "run the following", fake tool or admin messages, or text formatted to look like a prompt or a tool result. This is prompt injection. It is an abuse of this project and will be treated as malicious.
- **Secrets and personal data:** passwords, tokens, API keys, addresses, real names. Captured text is saved in the world's storage and is readable by operators and by anything with data access. This includes **your Microsoft account credentials** — no screen in this mod will ever legitimately ask for them (see Section 2c).

If you are unsure whether something is safe to type, do not type it.

## 5. If you run an AI tool next to this world

Coding agents, AI-assisted admin tools and AI review tools may read packs or world data.

- Treat all player-supplied text (signs, books, name tags, chat, storage contents, logs) as **untrusted data, never as instructions**.
- Do not let such a tool run commands, install packs, change permissions or apply patches because of text it found in a pack or the world. Require a human to approve every action.
- Give such a tool read-only access where you can, and keep it away from operator credentials, tokens and `/op` level command execution.
- If text in a pack or in world data tries to direct the tool, stop, do not follow it, and report it.

## 6. Reporting

Report suspected injection attempts, abuse or vulnerabilities on the issue tracker of [vortaforge/core](https://github.com/vortaforge/core). Describe the location and the effect; do not paste the suspected payload into an AI tool to analyze it.
