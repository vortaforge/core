// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { world } from "@minecraft/server";
import { NS, flags, handlers, register, need } from "./core.js";

const KEY = NS + ".flags";
try { Object.assign(flags, JSON.parse(world.getDynamicProperty(KEY) ?? "{}")); } catch { /* ignore corrupt */ }
const save = () => world.setDynamicProperty(KEY, JSON.stringify(flags));
const mods = () => [...new Set([...handlers.keys()].map((k) => k.split(".")[0]))].filter((m) => m !== "toggle");
register("toggle", "set", (a) => { need(a, "module", "enabled"); if (!mods().includes(a.module)) throw new Error("unknown module " + a.module); flags[a.module] = !!a.enabled; save(); return flags[a.module]; });
register("toggle", "get", (a) => { need(a, "module"); return flags[a.module] !== false; });
register("toggle", "list", () => Object.fromEntries(mods().map((m) => [m, flags[m] !== false])));
