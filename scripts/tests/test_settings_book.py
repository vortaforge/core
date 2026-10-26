"""Offline invariants for the macroEngine settings book and the cmd_gate
kill-switch. These read .mcfunction text only - they prove the wiring the
reviewer cares about (admin guards, bypass placement, config revision
agreement) without pretending to execute anything in game.

Run with:  python3 -m unittest discover scripts/tests
Nothing here starts, contacts or needs a Minecraft server.
"""
import json
import os
import re
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ME = os.path.join(ROOT, "packs", "macroEngine-Datapack-v26.3",
                  "data", "macroengine", "function")


def read(*parts):
    with open(os.path.join(*parts), encoding="utf-8") as fh:
        return fh.read()


def fn(*parts):
    return read(ME, *parts)


class CmdGateDisable(unittest.TestCase):
    def test_bypass_sits_after_module_guard_before_permission(self):
        check = fn("systems", "cmd_gate", "check.mcfunction")
        module = check.index("modules{cmd:0b}")
        bypass = check.index("config{cmd_gate_disabled:1b}")
        dyn = check.index("config{dynamic_cmd:1b}")
        perm = check.index("function macroengine:api/perm/require")
        # module_cmd off must still deny; bypass must not resurrect a module.
        self.assertLess(module, bypass)
        self.assertLess(bypass, dyn)
        self.assertLess(bypass, perm)

    def test_disable_and_enable_are_admin_gated_and_audited(self):
        for name, action in (("disable", "cmd_gate.disabled"),
                             ("enable", "cmd_gate.enabled")):
            text = fn("systems", "cmd_gate", name + ".mcfunction")
            self.assertIn("tag=macroengine.admin", text, name)
            self.assertIn(action, text, name)
            # Both go through the validated config path, not a raw write.
            self.assertIn("macroengine:core/config/set", text, name)

    def test_tier2_runners_honour_the_kill_switch(self):
        combined = ("config{dynamic_cmd:1b} unless data storage "
                    "macroengine:engine config{cmd_gate_disabled:1b}")
        count = 0
        for base, _dirs, files in os.walk(ME):
            for name in files:
                if name.endswith(".mcfunction"):
                    count += read(base, name).count(combined)
        self.assertEqual(count, 11)

    def test_config_revision_agrees_everywhere(self):
        cfg = fn("config.mcfunction")
        rev = re.search(r"config_rev set value (\d+)", cfg).group(1)
        self.assertIn("cmd_gate_disabled:{t:\"bool\"}", cfg)
        self.assertIn("config.cmd_gate_disabled set value 0b", cfg)
        ensure = fn("core", "config", "ensure.mcfunction")
        self.assertIn("{config_rev:%s}" % rev, ensure)
        apply_ = fn("core", "config", "apply.mcfunction")
        self.assertIn("#cmd_gate_disabled macroengine.tick_flags", apply_)


class SettingsBook(unittest.TestCase):
    def test_listener_is_registered_in_the_input_tag(self):
        tag = read(ROOT, "packs", "macroEngine-Datapack-v26.3", "data",
                   "macroengine", "tags", "function", "input",
                   "writable_book.json")
        values = json.loads(tag)["values"]
        self.assertIn("macroengine:core/internal/api/settings/_on_book", values)
        # And the referenced function must exist.
        self.assertTrue(os.path.isfile(os.path.join(
            ME, "core", "internal", "api", "settings", "_on_book.mcfunction")))

    def test_apply_checks_admin_and_marker_before_any_write(self):
        apply_ = fn("api", "settings", "apply.mcfunction")
        admin = apply_.index("tag=macroengine.admin")
        marker = apply_.index("settings:1b")
        first_write = apply_.index("api/settings/_page_loop")
        self.assertLess(admin, first_write)
        self.assertLess(marker, first_write)
        # The give path is admin-only as well.
        book = fn("api", "settings", "book.mcfunction")
        self.assertIn("tag=macroengine.admin", book)

    def test_listener_is_quiet_for_non_admins(self):
        on_book = fn("core", "internal", "api", "settings",
                     "_on_book.mcfunction")
        # Returns before reaching apply, and never prints (tick context).
        self.assertIn("unless entity @s[tag=macroengine.admin] run return 0",
                      on_book)
        self.assertNotIn("tellraw", on_book)

    def test_book_text_never_reaches_a_macro_execution_line(self):
        # The parser must keep captured text as data: no internal settings
        # function may macro-execute a value read from the book.
        settings_dir = os.path.join(ME, "core", "internal", "api", "settings")
        for name in sorted(os.listdir(settings_dir)):
            text = read(settings_dir, name)
            for line in text.splitlines():
                stripped = line.strip()
                self.assertFalse(stripped.startswith("$$("),
                                 "%s: %s" % (name, stripped))
                self.assertNotIn("run $(value)", stripped, name)
                self.assertNotIn("run $(line)", stripped, name)
                self.assertNotIn("run $(key)", stripped, name)

    def test_dispatch_never_selects_a_function_dynamically(self):
        dispatch = fn("core", "internal", "api", "settings",
                      "_dispatch.mcfunction")
        self.assertNotIn("$function", dispatch)
        for gate in ("gate.1", "gate.2", "gate.3", "gate.4", "gate.5",
                     "gate.permit", "cmd_gate"):
            self.assertIn('"%s"' % gate, dispatch)

    def test_prefilled_book_uses_key_value_lines(self):
        give = fn("core", "internal", "api", "settings", "_give.mcfunction")
        for key in ("gate.1: ", "gate.5: ", "gate.permit: ", "cmd_gate: ",
                    "cfg.dynamic_cmd: ", "cfg.dynamic_cmd_max_len: ",
                    "#blocklist.add: ", "#blocklist.remove: "):
            self.assertIn(key, give)


if __name__ == "__main__":
    unittest.main()
