// AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
// This is a Bedrock re-implementation, NOT a conversion of the Java macroEngine/guikit datapacks.
import { NS, register, findPlayer, need } from "./core.js";

const P = (name) => { if (!/^[A-Za-z0-9_.-]{1,48}$/.test(name)) throw new Error("bad permission name"); return `${NS}.perm.${name}`; };
const ADMIN = NS + ".admin";
const has = (p, perm) => p.hasTag(ADMIN) || p.hasTag(P(perm));
register("perm", "grant", (a, c) => { need(a, "perm"); findPlayer(a, c).addTag(P(a.perm)); return 1; });
register("perm", "revoke", (a, c) => { need(a, "perm"); return findPlayer(a, c).removeTag(P(a.perm)) ? 1 : 0; });
register("perm", "has", (a, c) => { need(a, "perm"); return has(findPlayer(a, c), a.perm); });
register("perm", "check", (a, c) => { need(a, "perm"); return has(findPlayer(a, c), a.perm) ? 1 : 0; });
register("perm", "list", (a, c) => findPlayer(a, c).getTags().filter((t) => t.startsWith(NS + ".perm.")).map((t) => t.slice(NS.length + 6)));
register("perm", "clear", (a, c) => { const p = findPlayer(a, c); let n = 0; for (const t of p.getTags()) if (t.startsWith(NS + ".perm.")) { p.removeTag(t); n++; } return n; });
register("perm", "make_admin", (a, c) => { findPlayer(a, c).addTag(ADMIN); return 1; });
