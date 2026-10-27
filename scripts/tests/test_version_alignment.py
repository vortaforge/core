"""Offline regression tests: macroEngine datapack + resource pack are aligned
to Minecraft Java 26.3 (release).

Run with:  python3 -m pytest scripts/tests   (or: python3 -m unittest discover scripts/tests)

Nothing here starts, contacts or needs a Minecraft server.

The pack was written against late 26.3 snapshots. These tests pin the
release formats and fail if any pre-release / pre-26.3 shape that Mojang
removed or renamed during the 26.3 cycle comes back - most of those fail
silently in game (the file loads, the behaviour is just gone), so the guard
is static. The full audit with per-change verdicts lives in
packs/macroEngine-Datapack-v26.3/docs/version_alignment.md; when bumping to
a newer Minecraft, update the pins here and add a section there.
"""

import json
import os
import re
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DP = os.path.join(ROOT, "packs", "macroEngine-Datapack-v26.3")
RP = os.path.join(ROOT, "packs", "macroEngine-Resourcepack-v26.3")
DP_DATA = os.path.join(DP, "data", "macroengine")

# Minecraft 26.3 release formats.
DP_FORMAT = [121, 0]
RP_FORMAT = [97, 1]

# Ids Mojang removed or renamed during the 26.3 cycle (see the audit doc).
BANNED_DP_TOKENS = (
    "minecraft:value_check",  # pre-1: split into int_/float_value_check (exact id)
    "minecraft:block_state_property",  # snapshot 4: replaced by match_block
    "minecraft:reference",  # snapshot 4: reference types removed, use an ID string
    "minecraft:swing_animation",  # snapshot 7: split into attack_/interact_animation
    "minecraft:map_color",  # snapshot 7: component + tint source removed
    "#minecraft:brewing_fuel",  # snapshot 4: item tag replaced by the component
    "on_woodland_explorer_maps",  # snapshot 10: explorer-map structure tags renamed
    "on_ocean_explorer_maps",
    "on_jungle_explorer_maps",
    "on_swamp_explorer_maps",
    "on_trial_explorer_map",
    "summands",  # snapshot 9: sum provider field renamed to operands (sum->add in pre-1)
)
BANNED_RP_TOKENS = (
    "trim_palette_replacements",  # snapshot 6: equipment assets use trim_overrides
    "filled_map_markings",  # snapshot 7: texture removed
    "map_color",  # snapshot 7: tint source removed
)

# Advancement trigger fields renamed in snapshot 4.
TRIGGER_RENAMED_FIELDS = {
    "minecraft:bee_nest_destroyed": {"block"},  # -> blocks
    "minecraft:enter_block": {"block"},  # -> blocks
    "minecraft:slide_down_block": {"block"},  # -> blocks
    "minecraft:player_generates_container_loot": {"loot_table"},  # -> loot_tables
    "minecraft:recipe_crafted": {"recipe_id"},  # -> recipes
    "minecraft:crafter_recipe_crafted": {"recipe_id"},  # -> recipes
    "minecraft:recipe_unlocked": {"recipe"},  # -> recipes
}
# Trigger fields that used to accept a bare entity predicate (or a condition
# list) must now be a loot condition; these composite/single types are the
# shapes this pack uses - extend deliberately.
ENTITY_CONDITION_TYPES = {
    "minecraft:entity_properties",
    "minecraft:all_of",
    "minecraft:any_of",
    "minecraft:inverted",
}


def files(base, suffixes):
    for dirpath, _dirs, names in os.walk(base):
        for name in names:
            if name.endswith(suffixes):
                yield os.path.join(dirpath, name)


def read(path):
    with open(path, encoding="utf-8", errors="replace") as fh:
        return fh.read()


def load_json(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def walk_dicts(node):
    if isinstance(node, dict):
        yield node
        for value in node.values():
            yield from walk_dicts(value)
    elif isinstance(node, list):
        for item in node:
            yield from walk_dicts(item)


class FormatPins(unittest.TestCase):
    def test_datapack_format_is_26_3_release(self):
        meta = load_json(os.path.join(DP, "pack.mcmeta"))["pack"]
        self.assertEqual(meta.get("min_format"), DP_FORMAT)
        self.assertEqual(meta.get("max_format"), DP_FORMAT)

    def test_resourcepack_format_is_26_3_release(self):
        meta = load_json(os.path.join(RP, "pack.mcmeta"))["pack"]
        self.assertEqual(meta.get("min_format"), RP_FORMAT)
        self.assertEqual(meta.get("max_format"), RP_FORMAT)


class RemovedAndRenamedIds(unittest.TestCase):
    def test_banned_tokens_absent_from_datapack(self):
        for path in files(DP_DATA, (".json", ".mcfunction")):
            text = read(path)
            for token in BANNED_DP_TOKENS:
                if token == "minecraft:value_check":
                    # int_value_check / float_value_check are the live ids.
                    self.assertIsNone(
                        re.search(r'"minecraft:value_check"', text),
                        f"{path}: removed condition minecraft:value_check",
                    )
                else:
                    self.assertNotIn(token, text, f"{path}: removed/renamed id {token!r}")

    def test_banned_tokens_absent_from_resourcepack(self):
        for path in files(RP, (".json",)):
            text = read(path)
            for token in BANNED_RP_TOKENS:
                self.assertNotIn(token, text, f"{path}: removed/renamed id {token!r}")

    def test_block_state_and_attribute_nbt_names(self):
        # Snapshot 7 renamed block-state Name/Properties -> id/properties;
        # entity attribute entries were renamed back in 1.21 (Attributes/Name/
        # Base -> attributes/id/base). Neither legacy shape may come back.
        for path in files(DP_DATA, (".mcfunction",)):
            text = read(path)
            self.assertNotIn("Properties:", text, f"{path}: capital-P block-state Properties")
            self.assertNotIn(
                "Attributes[{Name:",
                text,
                f"{path}: pre-1.21 Attributes[{{Name:...}}].Base path - use attributes[{{id:...}}].base",
            )
        for path in files(DP_DATA, (".json",)):
            text = read(path)
            self.assertNotIn('"Name":', text, f"{path}: block-state JSON still uses Name")
            self.assertNotIn('"Properties":', text, f"{path}: block-state JSON still uses Properties")


class LootFormats(unittest.TestCase):
    """Snapshot-4 loot/predicate/item-modifier overhaul + pre-1 providers."""

    def test_item_modifiers_use_type_and_condition(self):
        for path in files(os.path.join(DP_DATA, "item_modifier"), (".json",)):
            for node in walk_dicts(load_json(path)):
                self.assertNotIn("function", node, f"{path}: legacy item-modifier key 'function'")
                self.assertNotIn("conditions", node, f"{path}: legacy key 'conditions' (use 'condition')")

    def test_loot_tables_use_condition_and_modifier(self):
        for path in files(os.path.join(DP_DATA, "loot_table"), (".json",)):
            for node in walk_dicts(load_json(path)):
                self.assertNotIn("conditions", node, f"{path}: legacy pool key 'conditions'")
                self.assertNotIn("functions", node, f"{path}: legacy pool key 'functions' (use 'modifier')")
                if node.get("type") == "minecraft:tag":
                    self.assertNotIn(
                        "name", node, f"{path}: tag loot entry still uses 'name' (renamed to 'items')"
                    )

    def test_predicates_use_type_and_no_list_shorthand(self):
        for path in files(os.path.join(DP_DATA, "predicate"), (".json",)):
            doc = load_json(path)
            self.assertNotIsInstance(
                doc, list, f"{path}: predicate list shorthand was removed - wrap in all_of"
            )
            self.assertIsNone(
                re.search(r'"condition"\s*:\s*"minecraft:', read(path)),
                f"{path}: legacy 'condition' type key (renamed to 'type')",
            )

    def test_number_providers_carry_explicit_type(self):
        # {min,max} (uniform) and {n,p} (binomial) used to default their type;
        # since snapshot 4 the type field is mandatory. Limited to the loot
        # registries, where a bare {min,max} can only be a number provider
        # (predicate/advancement ranges like time_check are out of scope).
        for registry in ("loot_table", "item_modifier"):
            for path in files(os.path.join(DP_DATA, registry), (".json",)):
                for node in walk_dicts(load_json(path)):
                    keys = set(node)
                    self.assertNotEqual(
                        keys, {"min", "max"}, f"{path}: uniform number provider without explicit type"
                    )
                    self.assertNotEqual(
                        keys, {"n", "p"}, f"{path}: binomial number provider without explicit type"
                    )


class AdvancementTriggers(unittest.TestCase):
    def test_renamed_trigger_fields_stay_renamed(self):
        for path in files(os.path.join(DP_DATA, "advancement"), (".json",)):
            doc = load_json(path)
            if not isinstance(doc, dict):
                continue
            for name, criterion in doc.get("criteria", {}).items():
                trigger = criterion.get("trigger")
                conditions = criterion.get("conditions") or {}
                for banned in TRIGGER_RENAMED_FIELDS.get(trigger, set()):
                    self.assertNotIn(
                        banned,
                        conditions,
                        f"{path}: trigger {trigger} field {banned!r} was renamed in 26.3 snapshot 4",
                    )
                if trigger == "minecraft:brewed_potion" and "potion" in conditions:
                    self.assertIsInstance(
                        conditions["potion"],
                        dict,
                        f"{path}: brewed_potion 'potion' must be a potion_contents object",
                    )

    def test_trigger_entity_fields_are_loot_conditions(self):
        # Snapshot 4 removed the entity-predicate shorthand (and condition
        # lists) from trigger fields: they take a loot condition now.
        for path in files(os.path.join(DP_DATA, "advancement"), (".json",)):
            doc = load_json(path)
            if not isinstance(doc, dict):
                continue
            for name, criterion in doc.get("criteria", {}).items():
                conditions = criterion.get("conditions") or {}
                for field in ("entity", "player"):
                    value = conditions.get(field)
                    if value is None or isinstance(value, str):
                        continue  # absent, or a predicate ID reference
                    self.assertIsInstance(
                        value,
                        dict,
                        f"{path}: trigger field {field!r} must not be a condition list (use all_of)",
                    )
                    self.assertIn(
                        value.get("type"),
                        ENTITY_CONDITION_TYPES,
                        f"{path}: trigger field {field!r} looks like a bare entity predicate - "
                        "wrap it in minecraft:entity_properties",
                    )


if __name__ == "__main__":
    unittest.main()
