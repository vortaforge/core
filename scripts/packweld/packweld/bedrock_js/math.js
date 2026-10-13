// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { register, need } from "./core.js";

const n = (a, ...k) => { need(a, ...k); return k.map((x) => Number(a[x])); };
const rad = (d) => (d * Math.PI) / 180;
const vec = (a, k) => { need(a, k); const v = a[k]; if (!Array.isArray(v) || v.length !== 3) throw new Error(k + " must be [x,y,z]"); return v.map(Number); };

register("math", "clamp", (a) => { const [v, lo, hi] = n(a, "value", "min", "max"); return Math.min(hi, Math.max(lo, v)); });
register("math", "lerp", (a) => { const [x, y, t] = n(a, "a", "b", "t"); return x + (y - x) * t; });
register("math", "map_range", (a) => { const [v, i0, i1, o0, o1] = n(a, "value", "in_min", "in_max", "out_min", "out_max"); return o0 + ((v - i0) * (o1 - o0)) / (i1 - i0); });
const gcd = (x, y) => { x = Math.abs(x); y = Math.abs(y); while (y) [x, y] = [y, x % y]; return x; };
register("math", "gcd", (a) => { const [x, y] = n(a, "a", "b"); return gcd(x, y); });
register("math", "lcm", (a) => { const [x, y] = n(a, "a", "b"); return x && y ? Math.abs(x * y) / gcd(x, y) : 0; });
register("math", "sin", (a) => Math.sin(rad(n(a, "deg")[0])));
register("math", "cos", (a) => Math.cos(rad(n(a, "deg")[0])));
register("math", "vec_add", (a) => { const p = vec(a, "a"), q = vec(a, "b"); return p.map((x, i) => x + q[i]); });
register("math", "vec_sub", (a) => { const p = vec(a, "a"), q = vec(a, "b"); return p.map((x, i) => x - q[i]); });
register("math", "vec_dot", (a) => { const p = vec(a, "a"), q = vec(a, "b"); return p.reduce((s, x, i) => s + x * q[i], 0); });
register("math", "vec_cross", (a) => { const [a1, a2, a3] = vec(a, "a"), [b1, b2, b3] = vec(a, "b"); return [a2 * b3 - a3 * b2, a3 * b1 - a1 * b3, a1 * b2 - a2 * b1]; });
register("math", "vec_length", (a) => Math.hypot(...vec(a, "a")));
register("math", "vec_normalize", (a) => { const p = vec(a, "a"), l = Math.hypot(...p); return l ? p.map((x) => x / l) : p; });
register("math", "distance", (a) => { const p = vec(a, "a"), q = vec(a, "b"); return Math.hypot(...p.map((x, i) => x - q[i])); });
