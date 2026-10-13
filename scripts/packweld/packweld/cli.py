# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
from __future__ import annotations
import argparse, json, sys
from . import __version__
from .build import build
from .config import BuildConfig, ConfigError


def _fmt(s):
    return [int(x) for x in s.split(".")]


def _csv(s):
    return [x.strip() for x in s.split(",") if x.strip()]


def _parser():
    p = argparse.ArgumentParser(prog="packweld", description="Generate your own namespaced macroEngine + guikit library: Java datapack and Bedrock add-on.")
    p.add_argument("--version", action="version", version=f"packweld {__version__}")
    sub = p.add_subparsers(dest="cmd", required=True)

    b = sub.add_parser("build", help="generate packs")
    b.add_argument("--config", help="JSON config file (flags override it)")
    b.add_argument("--save-config", help="write the effective config to this file")
    b.add_argument("--name"); b.add_argument("--namespace"); b.add_argument("--gui-namespace"); b.add_argument("--gui-name")
    b.add_argument("--pack-version", dest="version"); b.add_argument("--description"); b.add_argument("--author")
    b.add_argument("--homepage"); b.add_argument("--notice", dest="extra_notice", help="extra text appended to NOTICE.md")
    b.add_argument("--modules", type=_csv, help="comma list of macroEngine modules (default: all). see 'packweld modules'")
    b.add_argument("--no-macroengine", action="store_true"); b.add_argument("--no-guikit", action="store_true")
    b.add_argument("--no-resourcepack", action="store_true"); b.add_argument("--no-docs", action="store_true")
    b.add_argument("--no-isolate-player-action", action="store_true")
    b.add_argument("--stamp-headers", action="store_true", help="add a one-line attribution comment to every .mcfunction")
    b.add_argument("--set", dest="sets", action="append", default=[], metavar="KEY=VALUE", help="runtime config override, repeatable (see 'packweld config-keys')")
    b.add_argument("--min-format", type=_fmt); b.add_argument("--max-format", type=_fmt)
    b.add_argument("--icon")
    b.add_argument("--target", dest="targets", type=_csv, help="java,bedrock")
    b.add_argument("--out", dest="output_dir"); b.add_argument("--no-zip", action="store_true"); b.add_argument("--no-dirs", action="store_true")
    b.add_argument("--bedrock-namespace"); b.add_argument("--bedrock-modules", type=_csv)
    b.add_argument("--bedrock-menus", help="JSON file with a list of menus"); b.add_argument("--gui-item"); b.add_argument("--gui-default-menu")
    b.add_argument("--dry-run", action="store_true", help="validate and report, write nothing")
    b.add_argument("--json", action="store_true", help="machine readable report")

    sub.add_parser("modules", help="list selectable modules").add_argument("--bedrock", action="store_true")
    sub.add_parser("config-keys", help="list runtime config keys with type/range/default")
    i = sub.add_parser("init", help="write a starter config"); i.add_argument("path", nargs="?", default="packweld.json")
    sub.add_parser("verify-vendor", help="prove the vendored upstream code is byte-identical to the shipped manifest")
    sub.add_parser("doctor", help="static findings about the upstream packs")
    u = sub.add_parser("ui", help="start the local web UI")
    u.add_argument("--port", type=int, default=8765); u.add_argument("--host", default="127.0.0.1"); u.add_argument("--no-browser", action="store_true")
    return p


def _cfg_from_args(a) -> BuildConfig:
    cfg = BuildConfig.load(a.config) if a.config else BuildConfig()
    for k in ("name", "namespace", "gui_namespace", "gui_name", "version", "description", "author", "homepage",
              "extra_notice", "modules", "min_format", "max_format", "icon", "targets", "output_dir"):
        v = getattr(a, k, None)
        if v is not None:
            setattr(cfg, k, v)
    if a.no_macroengine: cfg.include_macroengine = False
    if a.no_guikit: cfg.include_guikit = False
    if a.no_resourcepack: cfg.include_resourcepack = False
    if a.no_docs: cfg.include_docs = False
    if a.no_isolate_player_action: cfg.isolate_player_action = False
    if a.stamp_headers: cfg.stamp_headers = True
    if a.no_zip: cfg.make_zip = False
    if a.no_dirs: cfg.keep_dirs = False
    for s in a.sets:
        k, _, v = s.partition("=")
        if not _:
            raise ConfigError(f"--set expects KEY=VALUE, got {s!r}")
        cfg.config_overrides[k.strip()] = v.strip()
    bd = cfg.bedrock
    if a.bedrock_namespace: bd.namespace = a.bedrock_namespace
    if a.bedrock_modules is not None: bd.modules = a.bedrock_modules
    if a.bedrock_menus:
        with open(a.bedrock_menus, encoding="utf-8") as f:
            bd.menus = json.load(f)
    if a.gui_item: bd.gui_open_item = a.gui_item
    if a.gui_default_menu: bd.gui_default_menu = a.gui_default_menu
    return cfg


def main(argv=None) -> int:
    a = _parser().parse_args(argv)
    if a.cmd == "build":
        try:
            cfg = _cfg_from_args(a)
        except (ConfigError, OSError, ValueError) as e:
            print(f"error: {e}", file=sys.stderr); return 2
        if a.save_config:
            cfg.dump(a.save_config)
        rep = build(cfg, write=not a.dry_run)
        if a.json:
            print(json.dumps(rep.to_dict(), indent=2, ensure_ascii=False))
        else:
            for w in rep.warnings: print("warning:", w)
            for e in rep.errors: print("error:", e, file=sys.stderr)
            if rep.ok:
                j = rep.info.get("java")
                if j: print(f"java: {j['files']} files, {j['functions']} functions, {j['renames']} renames" + (f", kept modules: {len(j['kept_modules'])} (+pulled {j['pulled']})" if j['kept_modules'] else ""))
                if "bedrock" in rep.info: print("bedrock: modules " + ", ".join(rep.info["bedrock"]["modules"]))
                print("(dry run: nothing written)" if a.dry_run else "wrote:\n  " + "\n  ".join(rep.outputs))
        return 0 if rep.ok else 1
    if a.cmd == "modules":
        if a.bedrock:
            from .bedrock import MODULES
            for k, v in MODULES.items(): print(f"{k:12} {v}")
            return 0
        from .modules_info import list_modules
        for m in list_modules():
            print(f"{m['id']:30} {m['functions']:4} fn  closure +{m['closure']:<4} {m['desc']}")
        return 0
    if a.cmd == "config-keys":
        from .schema import config_schema
        for k, s in config_schema().items():
            rng = f" {s['min']}..{s['max']}" if s["min"] is not None else ""
            print(f"{k:24} {s['type']:5}{rng:12} default {s['default']}")
        return 0
    if a.cmd == "init":
        BuildConfig(name="My Library", namespace="mylib", author="you").dump(a.path)
        print("wrote", a.path); return 0
    if a.cmd == "verify-vendor":
        from .vendor_check import verify_vendor
        pr = verify_vendor()
        print("vendored upstream code is byte-identical to the manifest" if not pr else "\n".join(pr))
        return 0 if not pr else 1
    if a.cmd == "doctor":
        from .modules_info import doctor
        print(doctor()); return 0
    if a.cmd == "ui":
        from .ui_server import serve
        serve(a.host, a.port, not a.no_browser); return 0
    return 2


if __name__ == "__main__":
    sys.exit(main())
