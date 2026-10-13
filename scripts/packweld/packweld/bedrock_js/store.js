// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { world } from "@minecraft/server";
import { NS, register, findPlayer, need } from "./core.js";

const KEY = /^[A-Za-z0-9_.-]{1,64}$/;
const pfx = (scope) => `${NS}.${scope}.`;
const holder = (args, ctx) => (args.scope === "player" ? findPlayer(args, ctx) : world);
const scope = (args) => (args.scope === "player" ? "p" : "w");

function rd(h, s, key) {
  const raw = h.getDynamicProperty(pfx(s) + key);
  return raw === undefined ? undefined : JSON.parse(raw);
}
function wr(h, s, key, v) {
  if (!KEY.test(key)) throw new Error("bad key: " + key);
  h.setDynamicProperty(pfx(s) + key, v === undefined ? undefined : JSON.stringify(v));
}

register("store", "set", (a, c) => { need(a, "key", "value"); wr(holder(a, c), scope(a), a.key, a.value); return 1; });
register("store", "get", (a, c) => { need(a, "key"); const v = rd(holder(a, c), scope(a), a.key); return v === undefined ? (a.default ?? null) : v; });
register("store", "delete", (a, c) => { need(a, "key"); wr(holder(a, c), scope(a), a.key, undefined); return 1; });
register("store", "exists", (a, c) => { need(a, "key"); return rd(holder(a, c), scope(a), a.key) !== undefined; });
register("store", "add", (a, c) => { need(a, "key", "value"); const h = holder(a, c); const v = (rd(h, scope(a), a.key) ?? 0) + Number(a.value); wr(h, scope(a), a.key, v); return v; });
register("store", "toggle", (a, c) => { need(a, "key"); const h = holder(a, c); const v = !rd(h, scope(a), a.key); wr(h, scope(a), a.key, v); return v; });
register("store", "append", (a, c) => { need(a, "key", "value"); const h = holder(a, c); const l = rd(h, scope(a), a.key) ?? []; if (!Array.isArray(l)) throw new Error("not a list"); l.push(a.value); wr(h, scope(a), a.key, l); return l.length; });
register("store", "list", (a, c) => {
  const h = holder(a, c), p = pfx(scope(a));
  return h.getDynamicPropertyIds().filter((i) => i.startsWith(p)).map((i) => i.slice(p.length));
});
