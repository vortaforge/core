// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { world, system } from "@minecraft/server";

export const NS = "__NS__";
export const handlers = new Map();   // "module.fn" -> impl(args, ctx)
export const api = {};               // api.module.fn(args) for other scripts
export const flags = {};             // module -> false when switched off

export function register(mod, fn, impl) {
  const guarded = (args = {}, ctx) => {
    if (mod !== "toggle" && flags[mod] === false) return 0;
    return impl(args, ctx);
  };
  handlers.set(`${mod}.${fn}`, guarded);
  (api[mod] ??= {})[fn] = guarded;
}

export function reply(ctx, msg) {
  const t = typeof msg === "string" ? msg : JSON.stringify(msg);
  const src = ctx && ctx.sourceEntity;
  if (src && typeof src.sendMessage === "function") src.sendMessage(t);
  else world.sendMessage(t);
}

export function findPlayer(args, ctx) {
  if (args && args.player) {
    const p = world.getPlayers({ name: String(args.player) })[0];
    if (!p) throw new Error("player not found: " + args.player);
    return p;
  }
  const s = ctx && ctx.sourceEntity;
  if (s && s.typeId === "minecraft:player") return s;
  throw new Error("no player: pass {\"player\":\"Name\"} or run via /execute as <player>");
}

export function need(args, ...keys) {
  for (const k of keys) if (args[k] === undefined) throw new Error("missing argument: " + k);
}

system.afterEvents.scriptEventReceive.subscribe((ev) => {
  const name = ev.id.slice(NS.length + 1);
  const h = handlers.get(name);
  if (!h) return;
  let args = {};
  const raw = (ev.message || "").trim();
  if (raw) { try { args = JSON.parse(raw); } catch { args = { value: raw }; } }
  try {
    const r = h(args, ev);
    if (r !== undefined) reply(ev, r);
  } catch (e) {
    reply(ev, `[${NS}] ${name}: ${e.message}`);
  }
}, { namespaces: [NS] });
