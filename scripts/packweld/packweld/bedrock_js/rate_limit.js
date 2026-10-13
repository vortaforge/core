// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { system } from "@minecraft/server";
import { register, findPlayer, need } from "./core.js";

const rules = new Map(), hits = new Map();
register("rate_limit", "config", (a) => { need(a, "key", "limit", "window_ticks"); rules.set(String(a.key), { limit: Number(a.limit), win: Number(a.window_ticks) }); return 1; });
register("rate_limit", "check", (a, c) => {
  need(a, "key");
  const r = rules.get(String(a.key));
  if (!r) throw new Error("no rule for " + a.key);
  const id = a.per_player ? `${a.key}|${findPlayer(a, c).name}` : String(a.key);
  const now = system.currentTick;
  const list = (hits.get(id) ?? []).filter((t) => now - t < r.win);
  if (list.length >= r.limit) { hits.set(id, list); return false; }   // denied, hit not recorded
  list.push(now); hits.set(id, list); return true;
});
register("rate_limit", "reset", (a) => { if (a.key) { for (const k of [...hits.keys()]) if (k === a.key || k.startsWith(a.key + "|")) hits.delete(k); } else hits.clear(); return 1; });
register("rate_limit", "list", () => [...rules.entries()].map(([k, v]) => ({ key: k, ...v })));
