// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { register, need } from "./core.js";

const s = (a) => { need(a, "value"); return String(a.value); };
const fill = (a) => { const f = a.fill === undefined ? " " : String(a.fill); return f.length ? f : " "; };
register("string", "pad_left", (a) => s(a).padStart(Number(a.width ?? 0), fill(a)));
register("string", "pad_right", (a) => s(a).padEnd(Number(a.width ?? 0), fill(a)));
register("string", "truncate", (a) => { const t = s(a), m = Number(a.max ?? 32); return t.length > m ? t.slice(0, Math.max(0, m - 1)) + "…" : t; });
register("string", "title_case", (a) => s(a).replace(/\w\S*/g, (w) => w[0].toUpperCase() + w.slice(1).toLowerCase()));
register("string", "pluralize", (a) => { need(a, "word", "count"); return Number(a.count) === 1 ? a.word : (a.plural ?? a.word + "s"); });
register("string", "format_coords", (a) => { need(a, "x", "y", "z"); const r = (v) => Math.round(Number(v)); return `${r(a.x)}, ${r(a.y)}, ${r(a.z)}`; });
register("string", "progress_bar", (a) => {
  need(a, "value", "max");
  const w = Number(a.width ?? 10), f = Math.max(0, Math.min(w, Math.round((Number(a.value) / Number(a.max)) * w)));
  return String(a.fill ?? "█").repeat(f) + String(a.empty ?? "░").repeat(w - f);
});
