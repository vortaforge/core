// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
import { __t } from "@minecraft/server";
await import("./scripts/main.js");
import assert from "node:assert/strict";
const steve = __t.players[0];
const last = () => __t.sent.at(-1);
const call = (id, args, src = steve) => { __t.sent.length = 0; __t.fire("zedq:" + id, args === undefined ? "" : JSON.stringify(args), src); return last() && last().at(-1); };
assert.equal(call("math.clamp", {value: 15, min: 0, max: 10}), "10");
assert.equal(call("math.gcd", {a: 12, b: 18}), "6");
assert.equal(call("string.pad_left", {value: "7", width: 3, fill: "0"}), "007");
assert.equal(call("string.progress_bar", {value: 5, max: 10, width: 4}), "██░░");
assert.equal(call("string.pluralize", {word: "box", count: 2, plural: "boxes"}), "boxes");
// store
call("store.set", {key: "k", value: {a: 1}}); assert.equal(call("store.get", {key: "k"}), '{"a":1}');
assert.equal(call("store.add", {key: "n", value: 2}), "2"); assert.equal(call("store.add", {key: "n", value: 3}), "5");
assert.equal(call("store.toggle", {key: "t", scope: "player"}), "true");
assert.match(call("store.set", {key: "bad key", value: 1}), /bad key/);
// rng determinism
call("rng.seed", {seed: 42}); const a = [call("rng.int", {min: 1, max: 100}), call("rng.int", {min: 1, max: 100})];
call("rng.seed", {seed: 42}); const b = [call("rng.int", {min: 1, max: 100}), call("rng.int", {min: 1, max: 100})];
assert.deepEqual(a, b);
// perm
assert.equal(call("perm.has", {perm: "fly"}), "false"); call("perm.grant", {perm: "fly"}); assert.equal(call("perm.has", {perm: "fly"}), "true");
assert.equal(call("perm.revoke", {perm: "fly"}), "1"); assert.match(call("perm.grant", {perm: "../x"}), /bad permission/);
steve.addTag("zedq.admin"); assert.equal(call("perm.has", {perm: "anything"}), "true");
// rate limit
call("rate_limit.config", {key: "r", limit: 2, window_ticks: 100});
assert.deepEqual([1, 2, 3].map(() => call("rate_limit.check", {key: "r"})), ["true", "true", "false"]);
__t.advance(101); assert.equal(call("rate_limit.check", {key: "r"}), "true");
// toggle disables a module
call("toggle.set", {module: "math", enabled: false}); assert.equal(call("math.clamp", {value: 1, min: 0, max: 2}), "0");
call("toggle.set", {module: "math", enabled: true}); assert.equal(call("math.clamp", {value: 1, min: 0, max: 2}), "1");
// cb: delayed command + cancel
const id = call("cb.run_delayed", {cmd: "say hi", ticks: 5}); assert.equal(steve.cmds.length, 0);
__t.advance(6); assert.deepEqual(steve.cmds, ["say hi"]);
const id2 = call("cb.run_delayed", {cmd: "say no", ticks: 5}); call("cb.cancel", {id: id2}); __t.advance(10); assert.equal(steve.cmds.length, 1);
// title tokens are plain substitution
call("title.render", {text: "Hi {player} at {x},{y},{z} s={score:coins} {unknown}"}); assert.equal(last().at(-1), "Hi Steve at 1,64,-4 s=5 {unknown}");
// hook runs the bound command when the event fires
call("hook.bind", {event: "break_block", cmd: "say broke"}); globalThis.__brk({player: steve}); assert.ok(steve.cmds.includes("say broke"));
assert.match(call("hook.bind", {event: "nope", cmd: "x"}), /unknown event/);
// gui
assert.equal(call("gui.list"), '["welcome"]');
// unknown / missing args produce an error message, not a throw
assert.match(call("math.clamp", {value: 1}), /missing argument: min/);
console.log("JS runtime tests passed");
