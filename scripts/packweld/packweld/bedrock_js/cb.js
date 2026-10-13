// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { world, system } from "@minecraft/server";
import { register, findPlayer, need } from "./core.js";

// Callback queue. Commands run with the trust of whoever can call /scriptevent (op / command block).
let seq = 0;
const pending = new Map();   // id -> runId[]

function exec(a, c, cmd) {
  const who = a.player || (c && c.sourceEntity && c.sourceEntity.typeId === "minecraft:player") ? findPlayer(a, c) : null;
  const target = who || world.getDimension(a.dimension || "overworld");
  return target.runCommand(String(cmd).replace(/^\//, ""));
}
function schedule(a, c, steps) {
  const id = ++seq, ids = [];
  let at = 0;
  for (const s of steps) {
    at += Math.max(0, Number(s.delay ?? 0));
    ids.push(system.runTimeout(() => { try { exec(a, c, s.cmd); } catch (e) { world.sendMessage("[cb] " + e.message); } }, Math.max(1, at)));
  }
  pending.set(id, ids);
  system.runTimeout(() => pending.delete(id), at + 2);
  return id;
}
register("cb", "run", (a, c) => { need(a, "cmd"); return exec(a, c, a.cmd).successCount; });
register("cb", "run_delayed", (a, c) => { need(a, "cmd", "ticks"); return schedule(a, c, [{ cmd: a.cmd, delay: a.ticks }]); });
register("cb", "run_sequence", (a, c) => { need(a, "steps"); return schedule(a, c, a.steps); });
register("cb", "cancel", (a) => { need(a, "id"); const ids = pending.get(Number(a.id)); if (!ids) return 0; ids.forEach((r) => system.clearRun(r)); pending.delete(Number(a.id)); return 1; });
register("cb", "list", () => [...pending.keys()]);
register("cb", "queue_size", () => pending.size);
