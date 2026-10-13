// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { system, world } from "@minecraft/server";
import { ActionFormData } from "@minecraft/server-ui";
import { NS, api, register, findPlayer } from "./core.js";
import { MENUS, OPEN_ITEM, DEFAULT_MENU } from "./menus.js";

// guikit-style menus rendered as Bedrock forms. Menus come from the generator config (menus.js).
const ITEM = /^[a-z0-9_.]+:[a-z0-9_./]+$/;
const byId = new Map(MENUS.map((m) => [m.id, m]));

async function show(player, id, tries = 0) {
  const m = byId.get(id);
  if (!m) throw new Error("unknown menu " + id);
  const f = new ActionFormData().title(m.title ?? id);
  if (m.body) f.body(m.body);
  for (const b of m.buttons) f.button(b.text, b.icon);
  const r = await f.show(player);
  if (r.canceled) {
    if (r.cancelationReason === "UserBusy" && tries < 10) { system.runTimeout(() => show(player, id, tries + 1), 20); }
    return;
  }
  const act = m.buttons[r.selection].action ?? { type: "close" };
  await run(player, act, id);
}

async function run(p, a, current) {
  switch (a.type) {
    case "close": return;
    case "message": p.sendMessage(String(a.text)); return;
    case "open": system.run(() => show(p, a.menu)); return;
    case "sound": p.playSound(String(a.id)); return;
    case "command": p.runCommand(String(a.cmd).replace(/^\//, "")); return;
    case "give":
      if (!ITEM.test(a.item)) throw new Error("bad item id");
      p.runCommand(`give @s ${a.item} ${Math.max(1, Math.min(64, Number(a.count ?? 1)))}`); return;
    case "toggle": { const v = api.store ? api.store.toggle({ key: "gui." + a.key, scope: "player" }, { sourceEntity: p }) : null; p.sendMessage(`${a.key}: ${v ? "ON" : "OFF"}`); return; }
    case "counter": { const v = api.store ? api.store.add({ key: "gui." + a.key, value: 1, scope: "player" }, { sourceEntity: p }) : 0; p.sendMessage(`${a.key}: ${v}`); return; }
    default: throw new Error("unknown action " + a.type);
  }
}

register("gui", "open", (a, c) => { const p = findPlayer(a, c); const id = a.menu || DEFAULT_MENU; system.run(() => show(p, id).catch((e) => p.sendMessage(`[${NS}] ${e.message}`))); return 1; });
register("gui", "list", () => MENUS.map((m) => m.id));
if (OPEN_ITEM) {
  world.afterEvents.itemUse.subscribe((e) => { if (e.itemStack.typeId === OPEN_ITEM && e.source.isSneaking) system.run(() => show(e.source, DEFAULT_MENU).catch(() => {})); });
}
