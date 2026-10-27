"""Offline regression tests for macroEngine's per-player setup warning Dialogs.

Nothing here starts, contacts, or needs a Minecraft server. The Dialog JSON
is parsed as data and the Gate 3 functions are checked statically.
"""

import json
import os
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
PACK = os.path.join(ROOT, "packs", "macroEngine-Datapack-v26.3")
DATA = os.path.join(PACK, "data", "macroengine")
FUNCTIONS = os.path.join(DATA, "function")
INFO_URL = (
    "https://github.com/vortaforge/core/blob/main/"
    "packs/macroEngine-Datapack-v26.3/INFO.md"
)


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def function(*parts):
    return read(os.path.join(FUNCTIONS, *parts))


def load_dialog(name):
    with open(os.path.join(DATA, "dialog", name), encoding="utf-8") as fh:
        return json.load(fh)


def component_text(component):
    """Collect visible-ish text/translate strings from a text component."""
    if isinstance(component, str):
        return component
    if isinstance(component, list):
        return " ".join(component_text(part) for part in component)
    if isinstance(component, dict):
        parts = []
        for key in ("text", "translate"):
            if isinstance(component.get(key), str):
                parts.append(component[key])
        for key in ("extra", "with"):
            if key in component:
                parts.append(component_text(component[key]))
        return " ".join(part for part in parts if part)
    return ""


def body_text(dialog):
    return " ".join(
        component_text(part.get("contents", "")) for part in dialog.get("body", [])
    )


def action_entries(value):
    """Yield every dialog button/action wrapper containing an action object."""
    if isinstance(value, dict):
        action = value.get("action")
        if isinstance(action, dict) and "type" in action:
            yield value
        for child in value.values():
            yield from action_entries(child)
    elif isinstance(value, list):
        for child in value:
            yield from action_entries(child)


def by_label(entries):
    return {component_text(entry.get("label", "")): entry for entry in entries}


class SetupWarningDialog(unittest.TestCase):
    def test_first_dialog_warns_and_has_the_three_choices(self):
        dialog = load_dialog("setup_warning.json")
        self.assertEqual("minecraft:multi_action", dialog["type"])

        body = body_text(dialog)
        for phrase in (
            "controlled by, the operator of this server or world",
            "Do not enter passwords, tokens",
            "sensitive information",
            "If you do not know or trust this server/world",
            "choose Cancel and leave",
            "does not grant consent by itself",
        ):
            self.assertIn(phrase, body)

        entries = by_label(dialog["actions"])
        self.assertEqual(
            {
                "type": "minecraft:show_dialog",
                "dialog": "macroengine:setup_warning_confirm",
            },
            entries["Continue"]["action"],
        )
        self.assertEqual(
            {"type": "minecraft:open_url", "url": INFO_URL},
            entries["More information"]["action"],
        )

        cancel = dialog["exit_action"]
        self.assertEqual("gui.cancel", component_text(cancel["label"]))
        self.assertEqual(
            "trigger macroengine.consent set 2", cancel["action"]["command"]
        )
        self.assertTrue(dialog["can_close_with_escape"])

        # Continue and More information cannot grant consent from screen one.
        commands = [
            entry["action"].get("command", "")
            for entry in action_entries(dialog)
        ]
        self.assertNotIn("trigger macroengine.consent set 4", commands)

    def test_second_dialog_is_per_player_yes_no(self):
        dialog = load_dialog("setup_warning_confirm.json")
        self.assertEqual("minecraft:confirmation", dialog["type"])

        body = body_text(dialog)
        self.assertIn("yes records consent for your player only", body)
        self.assertIn("no keeps macroEngine inactive for your player only", body)
        self.assertIn("Neither choice changes another player's setting", body)

        self.assertEqual("yes", component_text(dialog["yes"]["label"]))
        self.assertEqual(
            "trigger macroengine.consent set 4",
            dialog["yes"]["action"]["command"],
        )
        self.assertEqual("no", component_text(dialog["no"]["label"]))
        self.assertEqual(
            "trigger macroengine.consent set 3",
            dialog["no"]["action"]["command"],
        )
        self.assertTrue(dialog["can_close_with_escape"])

    def test_dialog_actions_are_fixed_and_player_safe(self):
        allowed = {
            "minecraft:run_command",
            "minecraft:open_url",
            "minecraft:show_dialog",
        }
        expected_commands = {
            "trigger macroengine.consent set 2",
            "trigger macroengine.consent set 3",
            "trigger macroengine.consent set 4",
        }
        seen_commands = set()
        for name in ("setup_warning.json", "setup_warning_confirm.json"):
            dialog = load_dialog(name)
            self.assertNotIn("inputs", dialog, f"{name}: consent flow takes no free text")
            for entry in action_entries(dialog):
                action = entry["action"]
                self.assertIn(action["type"], allowed)
                self.assertNotIn("dynamic", action["type"])
                self.assertNotIn("template", action)
                if action["type"] == "minecraft:run_command":
                    seen_commands.add(action["command"])
        self.assertEqual(expected_commands, seen_commands)

    def test_setup_and_join_paths_show_the_same_prompt(self):
        setup = function("setup.mcfunction")
        self.assertIn(
            "execute unless score #macroengine.gate.3 vortaforge.gate matches 0 "
            "as @a[tag=!macroengine.consented,tag=!macroengine.setup_warned] "
            "run function macroengine:gate/consent_prompt",
            setup,
        )

        prompt = function("gate", "consent_prompt.mcfunction")
        self.assertIn("tag @s add macroengine.setup_warned", prompt)
        self.assertIn("dialog show @s macroengine:setup_warning", prompt)
        self.assertLess(
            prompt.index("scoreboard players enable @s macroengine.consent"),
            prompt.index("dialog show @s macroengine:setup_warning"),
            "the trigger must be enabled before the Dialog can be clicked",
        )
        self.assertIn("/trigger macroengine.consent set 6", prompt)

        tick = function("gate", "consent_tick.mcfunction")
        self.assertIn(
            "execute if score @s macroengine.consent matches 2..3 "
            "run function macroengine:gate/setup_warning_deny",
            tick,
        )
        self.assertIn(
            "execute if score @s macroengine.consent matches 4 "
            "run function macroengine:gate/consent_grant",
            tick,
        )
        self.assertIn(
            "execute if entity @s[tag=!macroengine.consented,"
            "tag=!macroengine.setup_warned] "
            "run function macroengine:gate/consent_prompt",
            tick,
        )

    def test_cancel_no_and_yes_change_only_the_clicking_player(self):
        deny = function("gate", "setup_warning_deny.mcfunction")
        self.assertIn("tag @s add macroengine.setup_declined", deny)
        self.assertIn("tag @s remove macroengine.consented", deny)
        self.assertIn("macroEngine stays inactive for your player", deny)
        self.assertNotIn("@a", deny)
        self.assertNotIn("scoreboard players set #", deny)

        grant = function("gate", "consent_grant.mcfunction")
        self.assertIn("tag @s add macroengine.consented", grant)
        self.assertIn("tag @s remove macroengine.setup_declined", grant)
        self.assertNotIn("@a", grant)
        self.assertNotIn("scoreboard players set #", grant)

        reset = function("gate", "consent_reset.mcfunction")
        for tag in (
            "macroengine.consented",
            "macroengine.prompted",
            "macroengine.setup_warned",
            "macroengine.setup_declined",
        ):
            self.assertIn(f"tag @s remove {tag}", reset)

    def test_info_page_answers_the_warning(self):
        info = read(os.path.join(PACK, "INFO.md"))
        for phrase in (
            "controlled by, the\n  operator of the server or world",
            "Do not enter sensitive information",
            "If you do not know or trust the server/world, choose Cancel or `no`",
            "Every choice is **per player**",
            "/trigger macroengine.consent set 6",
            "/execute as <player> run function macroengine:gate/consent_reset",
        ):
            self.assertIn(phrase, info)

        readme = read(os.path.join(PACK, "README.md"))
        self.assertIn("[`INFO.md`](INFO.md)", readme)


if __name__ == "__main__":
    unittest.main()
