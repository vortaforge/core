// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { world } from "@minecraft/server";
import { NS, api, register, findPlayer, need } from "./core.js";

// Tokens are plain string substitution: nothing is ever executed from the text.
function render(text, p) {
  return String(text).replace(/\{([a-z_]+)(?::([A-Za-z0-9_.-]+))?\}/g, (m, k, arg) => {
    switch (k) {
      case "player": return p.name;
      case "x": return String(Math.floor(p.location.x));
      case "y": return String(Math.floor(p.location.y));
      case "z": return String(Math.floor(p.location.z));
      case "dimension": return p.dimension.id.replace("minecraft:", "");
      case "health": { const h = p.getComponent("minecraft:health"); return h ? String(Math.round(h.currentValue)) : "?"; }
      case "score": { const o = world.scoreboard.getObjective(arg || ""); const v = o && o.getScore(p); return v === undefined || v === null ? "0" : String(v); }
      case "store": { const s = api.store; if (!s) return m; const v = s.get({ key: arg }); return v === null ? "" : String(v); }
      default: return m;
    }
  });
}
const targets = (a, c) => (a.all ? world.getAllPlayers() : [findPlayer(a, c)]);
register("title", "title", (a, c) => {
  need(a, "text");
  for (const p of targets(a, c)) p.onScreenDisplay.setTitle(render(a.text, p), {
    subtitle: a.subtitle === undefined ? undefined : render(a.subtitle, p),
    fadeInDuration: a.fade_in ?? 10, stayDuration: a.stay ?? 60, fadeOutDuration: a.fade_out ?? 10 });
  return 1;
});
register("title", "actionbar", (a, c) => { need(a, "text"); for (const p of targets(a, c)) p.onScreenDisplay.setActionBar(render(a.text, p)); return 1; });
register("title", "clear", (a, c) => { for (const p of targets(a, c)) p.onScreenDisplay.clearTitle?.(); return 1; });
register("title", "render", (a, c) => { need(a, "text"); return render(a.text, findPlayer(a, c)); });
