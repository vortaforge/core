# AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
import json, re, subprocess, sys, tempfile, unittest, zipfile
from pathlib import Path
from packweld.config import BuildConfig, ConfigError
from packweld.build import build
from packweld.java import build_datapack
from packweld.bedrock import build_bedrock, BedrockError
from packweld.paths import ME_DP, GUI_DP
from packweld.vendor_check import verify_vendor
from packweld.schema import config_schema, snbt_value

CFG = dict(name="Zed Lib", namespace="zedq")


def norm(s: str, token: str) -> str:
    return s.replace(token, "\0")


class VendorAndRename(unittest.TestCase):
    def test_vendor_untouched(self):
        self.assertEqual(verify_vendor(), [])

    def test_code_identical_after_rename(self):
        """Every upstream function equals the generated one once the new names are masked."""
        c = BuildConfig(**CFG, include_guikit=True); c.gui_namespace = "zedq_ui"; c.gui_name = "Zed UI"
        fs, _ = build_datapack(c)
        n = 0
        for root, ns, new, disp in ((ME_DP, "macroengine", "zedq", "Zed Lib"), (GUI_DP, "guikit", "zedq_ui", "Zed UI")):
            for p in (root / "data" / ns / "function").rglob("*.mcfunction"):
                up = p.read_text(encoding="utf-8")
                up = up.replace("vortacraftmc.packs.macroengine", "@@PACK").replace("vortacraftmc.archivedpacks.macroengine", "@@ARCH")
                up = up.replace("player_action", "@@PA")
                got_path = "data/%s/function/%s" % (new, p.relative_to(root / "data" / ns / "function").as_posix().replace(ns, new))
                got = fs[got_path].decode()
                got = got.replace("zedq.pack", "@@PACK").replace("zedq.archived", "@@ARCH").replace("zedq_pa", "@@PA")
                # mask names on both sides
                for a, b in ((ns, new), ):
                    pass
                up_m = re.sub(r"macroengine|guikit|MacroEngine|macroEngine|Macroengine|GUIKit|Guikit|GuiKit|MACROENGINE|GUIKIT", "\0", up)
                got_m = re.sub(r"zedq_ui|zedq|Zed Lib|Zed UI|ZEDQ_UI|ZEDQ", "\0", got)
                self.assertEqual(up_m, got_m, p.name)
                n += 1
        self.assertGreater(n, 1300)

    def test_no_leftovers_and_verify(self):
        c = BuildConfig(**CFG)
        rep = build(c, write=False)
        self.assertTrue(rep.ok, rep.errors)

    def test_namespace_validation(self):
        for bad in ("Bad", "a", "has-dash", "minecraft", "9x"):
            with self.assertRaises(ConfigError):
                BuildConfig(name="X", namespace=bad).validate()
        with self.assertRaises(ConfigError):
            BuildConfig(name="X", namespace="aa", gui_namespace="aa").validate()
        with self.assertRaises(ConfigError):
            BuildConfig(name='Bad"Name', namespace="aa").validate()

    def test_merged_tags_and_overrides(self):
        c = BuildConfig(**CFG, config_overrides={"hud_rate": 7, "module_cmd": False})
        fs, _ = build_datapack(c)
        load = json.loads(fs["data/minecraft/tags/function/load.json"])["values"]
        self.assertEqual(load, ["zedq:setup", "zedq_gui:core/load", "zedq:generated/apply_config"])
        txt = fs["data/zedq/function/generated/apply_config.mcfunction"].decode()
        self.assertIn('{key:"hud_rate",value:7}', txt); self.assertIn("value:0b", txt)

    def test_override_validation(self):
        s = config_schema()
        with self.assertRaises(KeyError): snbt_value("nope", 1, s)
        with self.assertRaises(ValueError): snbt_value("hud_rate", 99999, s)
        self.assertEqual(snbt_value("module_cb", "false", s), "0b")

    def test_module_selection_prunes_and_stays_consistent(self):
        full, _ = build_datapack(BuildConfig(**CFG, include_guikit=False))
        c = BuildConfig(**CFG, include_guikit=False, modules=["api/store", "systems/math"])
        part, info = build_datapack(c)
        self.assertLess(len(part), len(full) / 2)
        self.assertTrue(any("/function/api/store/" in p for p in part)); self.assertFalse(any("/function/api/cmd/" in p for p in part))
        rep = build(c, write=False); self.assertTrue(rep.ok, rep.errors)
        with self.assertRaises(KeyError): build_datapack(BuildConfig(**CFG, modules=["api/nope"]))

    def test_attribution_present(self):
        fs, _ = build_datapack(BuildConfig(**CFG, extra_notice="hello notice"))
        for p in ("LICENSE", "NOTICE.md", "README.md", "licenses/THIRD_PARTY_LICENSES.md", "licenses/macroEngine-LICENSE.txt", "licenses/guikit-LICENSE.txt"):
            self.assertIn(p, fs)
        self.assertIn(b"hello notice", fs["NOTICE.md"]); self.assertIn(b"PlayerAction", fs["NOTICE.md"])

    def test_reproducible_zip(self):
        c = BuildConfig(**CFG)
        a = build_datapack(c)[0].zip_bytes(); b = build_datapack(c)[0].zip_bytes()
        self.assertEqual(a, b)

    def test_stamp_headers(self):
        fs, _ = build_datapack(BuildConfig(**CFG, stamp_headers=True))
        self.assertTrue(fs["data/zedq/function/setup.mcfunction"].decode().startswith("# Zed Lib:"))


class Bedrock(unittest.TestCase):
    def test_manifest_and_modules(self):
        r = build_bedrock(BuildConfig(**CFG))
        m = json.loads(r["bp"]["manifest.json"])
        self.assertEqual(m["format_version"], 2)
        self.assertEqual([x["type"] for x in m["modules"]], ["data", "script"])
        self.assertIn("@minecraft/server-ui", [d.get("module_name") for d in m["dependencies"]])
        r2 = build_bedrock(BuildConfig(**CFG, bedrock=dict(modules=["math", "rng"]) and __import__("packweld.config", fromlist=["x"]).BedrockConfig(modules=["math", "rng"])))
        self.assertNotIn("scripts/gui.js", r2["bp"]); self.assertIn("scripts/rng.js", r2["bp"])
        m2 = json.loads(r2["bp"]["manifest.json"]); self.assertNotIn("@minecraft/server-ui", [d.get("module_name") for d in m2["dependencies"]])

    def test_menu_validation(self):
        from packweld.config import BedrockConfig
        bad = [{"id": "a", "buttons": [{"text": "x", "action": {"type": "rm_rf"}}]}]
        with self.assertRaises(BedrockError): build_bedrock(BuildConfig(**CFG, bedrock=BedrockConfig(menus=bad)))
        bad = [{"id": "a", "buttons": [{"text": "x", "action": {"type": "open", "menu": "zzz"}}]}]
        with self.assertRaises(BedrockError): build_bedrock(BuildConfig(**CFG, bedrock=BedrockConfig(menus=bad)))
        bad = [{"id": "a", "buttons": [{"text": "x", "action": {"type": "give", "item": "x; op @s"}}]}]
        with self.assertRaises(BedrockError): build_bedrock(BuildConfig(**CFG, bedrock=BedrockConfig(menus=bad)))

    def test_js_syntax_all_modules(self):
        r = build_bedrock(BuildConfig(**CFG))
        with tempfile.TemporaryDirectory() as td:
            for p, b in r["bp"].items():
                if p.endswith(".js"):
                    f = Path(td) / (p.replace("/", "_")[:-3] + ".mjs"); f.write_bytes(b)
                    res = subprocess.run(["node", "--check", str(f)], capture_output=True, text=True)
                    self.assertEqual(res.returncode, 0, p + res.stderr)


class Outputs(unittest.TestCase):
    def test_full_build_writes_artifacts(self):
        with tempfile.TemporaryDirectory() as td:
            rep = build(BuildConfig(**CFG, output_dir=td))
            self.assertTrue(rep.ok, rep.errors)
            names = [Path(o).name for o in rep.outputs]
            self.assertTrue(any(n.endswith(".mcaddon") for n in names))
            addon = [o for o in rep.outputs if o.endswith(".mcaddon")][0]
            with zipfile.ZipFile(addon) as z:
                self.assertTrue(any(n.endswith("BP/manifest.json") for n in z.namelist()))
                self.assertTrue(any(n.endswith("RP/manifest.json") for n in z.namelist()))


if __name__ == "__main__":
    unittest.main()
