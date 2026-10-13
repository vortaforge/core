// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { world } from "@minecraft/server";
import { NS, register, need } from "./core.js";

// mulberry32: small, fast, fully deterministic for a given seed.
const KEY = NS + ".rng";
let state = (() => { const v = world.getDynamicProperty(KEY); return typeof v === "number" ? v >>> 0 : (Date.now() >>> 0); })();
const save = () => world.setDynamicProperty(KEY, state);
function next() {
  state = (state + 0x6d2b79f5) >>> 0;
  let t = state;
  t = Math.imul(t ^ (t >>> 15), t | 1);
  t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
  const r = ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  save();
  return r;
}
register("rng", "seed", (a) => { need(a, "seed"); state = Number(a.seed) >>> 0; save(); return state; });
register("rng", "state", () => state);
register("rng", "next", () => next());
register("rng", "int", (a) => { need(a, "min", "max"); const lo = Math.ceil(a.min), hi = Math.floor(a.max); if (hi < lo) throw new Error("max < min"); return lo + Math.floor(next() * (hi - lo + 1)); });
register("rng", "chance", (a) => { need(a, "percent"); return next() * 100 < Number(a.percent); });
register("rng", "pick", (a) => { need(a, "list"); if (!Array.isArray(a.list) || !a.list.length) throw new Error("list must be non-empty"); return a.list[Math.floor(next() * a.list.length)]; });
register("rng", "weighted", (a) => {
  need(a, "items");
  const tot = a.items.reduce((s, i) => s + Math.max(0, Number(i.weight)), 0);
  if (!(tot > 0)) throw new Error("total weight must be > 0");
  let r = next() * tot;
  for (const i of a.items) { r -= Math.max(0, Number(i.weight)); if (r < 0) return i.value; }
  return a.items[a.items.length - 1].value;
});
