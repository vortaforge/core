// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { world } from "@minecraft/server";
import { register, need } from "./core.js";

// Bind a command (or a JS callback via api.hook.on) to a game event.
const listeners = new Map();   // event -> [{cmd?, fn?}]
const EVENTS = {
  break_block:      (s) => world.afterEvents.playerBreakBlock.subscribe(s),
  place_block:      (s) => world.afterEvents.playerPlaceBlock.subscribe(s),
  dimension_change: (s) => world.afterEvents.playerDimensionChange.subscribe(s),
  join:             (s) => world.afterEvents.playerSpawn.subscribe((e) => { if (e.initialSpawn) s(e); }),
  item_use:         (s) => world.afterEvents.itemUse.subscribe((e) => s({ ...e, player: e.source })),
  entity_die:       (s) => world.afterEvents.entityDie.subscribe((e) => s({ ...e, player: e.damageSource && e.damageSource.damagingEntity })),
};
const wired = new Set();
function wire(ev) {
  if (wired.has(ev)) return;
  wired.add(ev);
  EVENTS[ev]((e) => {
    for (const l of listeners.get(ev) ?? []) {
      try {
        if (l.fn) l.fn(e);
        else if (l.cmd && e.player && typeof e.player.runCommand === "function") e.player.runCommand(l.cmd);
      } catch (err) { world.sendMessage("[hook] " + ev + ": " + err.message); }
    }
  });
}
function add(ev, l) {
  if (!EVENTS[ev]) throw new Error("unknown event " + ev + " (" + Object.keys(EVENTS).join(", ") + ")");
  (listeners.get(ev) ?? listeners.set(ev, []).get(ev)).push(l);
  wire(ev);
  return listeners.get(ev).length;
}
register("hook", "bind", (a) => { need(a, "event", "cmd"); return add(a.event, { cmd: String(a.cmd).replace(/^\//, "") }); });
register("hook", "on", (a) => { need(a, "event", "fn"); return add(a.event, { fn: a.fn }); });     // JS only
register("hook", "unbind", (a) => { need(a, "event"); const n = (listeners.get(a.event) ?? []).length; listeners.set(a.event, []); return n; });
register("hook", "events", () => Object.keys(EVENTS));
