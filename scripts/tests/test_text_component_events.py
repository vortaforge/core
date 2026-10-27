"""Offline regression tests: text-component click/hover event format in macroEngine.

Run with:  python3 -m pytest scripts/tests   (or: python3 -m unittest discover scripts/tests)

Nothing here starts, contacts or needs a Minecraft server.

Scope is macroEngine only, on purpose (see
packs/macroEngine-Datapack-v26.3/docs/text_components.md):

- The pre-1.21.5 field names `clickEvent` / `hoverEvent` are out of use. Since
  25w02a (1.21.5) the fields are `click_event` / `hover_event` and the payload
  key per action changed (`value` -> `command` / `url` / `path` / `page`;
  hover `contents` was removed/inlined). A legacy name does not fail loudly in
  game - it is silently ignored - so this is guarded statically instead.
- 26.3 Snapshot 4 (data pack 111.0): signs no longer execute click events in
  sign text by default (`allow_op_features` restores it per sign). macroEngine's
  sign input only *reads* front_text, and the pack never writes click-bearing
  sign text; these tests keep it that way unless someone changes them on purpose.
- Since 25w20a (1.21.6) a `run_command` click whose command needs permission
  level > 0 shows a client confirmation. Prompts shown to every player (gate
  consent/permit) therefore click through `/trigger`, never `/function`.

TunnelScript keeps `clickEvent` on purpose: that pack is the Minecraft 1.19.2
build (pack_format 10), where the legacy names are the only valid syntax. Do
not widen this test's scope without porting that pack first.
"""

import os
import re
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ME_DATA = os.path.join(ROOT, "packs", "macroEngine-Datapack-v26.3", "data")

# Post-1.21.5 payload key that must be present for each click action.
CLICK_PAYLOAD = {
    "run_command": "command",
    "suggest_command": "command",
    "open_url": "url",
    "open_file": "path",
    "copy_to_clipboard": "value",  # unchanged by the rename
    "change_page": "page",  # must additionally be an integer, not a string
    "show_dialog": "dialog",
    "custom": "id",
}
# Actions whose legacy payload key was `value`; it must not reappear.
CLICK_VALUE_RENAMED = {"run_command", "suggest_command", "open_url", "open_file", "change_page"}

HOVER_PAYLOAD = {
    "show_text": "value",
    "show_item": "id",
    "show_entity": "id",  # entity type; `uuid` is required as well
}


def pack_files():
    for dirpath, _dirnames, filenames in os.walk(ME_DATA):
        for name in filenames:
            if name.endswith((".mcfunction", ".json")):
                yield os.path.join(dirpath, name)


def read(path):
    with open(path, encoding="utf-8", errors="replace") as fh:
        # Normalize escaped quotes so components embedded in SNBT strings are
        # scanned with the same rules as plain JSON-style components.
        return fh.read().replace('\\"', '"')


def event_objects(text, field):
    """Yield the brace-balanced object literal after each `"field":` in text."""
    for match in re.finditer(r'"%s"\s*:\s*' % field, text):
        start = text.find("{", match.end())
        if start < 0:
            continue
        depth = 0
        in_str = False
        escaped = False
        for pos in range(start, len(text)):
            char = text[pos]
            if in_str:
                if escaped:
                    escaped = False
                elif char == "\\":
                    escaped = True
                elif char == '"':
                    in_str = False
                continue
            if char == '"':
                in_str = True
            elif char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
                if depth == 0:
                    yield text[start : pos + 1]
                    break


def action_of(obj):
    match = re.search(r'"action"\s*:\s*"([^"]+)"', obj)
    return match.group(1) if match else None


def has_key(obj, key):
    return re.search(r'"%s"\s*:' % key, obj) is not None


class MacroEngineTextEvents(unittest.TestCase):
    def test_no_legacy_event_field_names(self):
        for path in pack_files():
            text = read(path)
            for name in ("clickEvent", "hoverEvent"):
                self.assertIsNone(
                    re.search(r"(?<![A-Za-z_])%s(?![A-Za-z_])" % name, text),
                    f"{path}: legacy {name} (pre-1.21.5) - use the snake_case field instead",
                )

    def test_click_event_payloads(self):
        seen = 0
        for path in pack_files():
            for obj in event_objects(read(path), "click_event"):
                seen += 1
                action = action_of(obj)
                self.assertIsNotNone(action, f"{path}: click_event without an action: {obj[:120]}")
                if "$(" in action:
                    continue  # macro-templated action; nothing static to check
                self.assertIn(
                    action,
                    CLICK_PAYLOAD,
                    f"{path}: unknown click action {action!r} - extend CLICK_PAYLOAD on purpose",
                )
                expected = CLICK_PAYLOAD[action]
                self.assertTrue(
                    has_key(obj, expected),
                    f"{path}: click action {action} needs a {expected!r} payload key: {obj[:160]}",
                )
                if action in CLICK_VALUE_RENAMED:
                    self.assertFalse(
                        has_key(obj, "value"),
                        f"{path}: click action {action} must not use the legacy 'value' key: {obj[:160]}",
                    )
                if action == "change_page":
                    self.assertIsNotNone(
                        re.search(r'"page"\s*:\s*\d', obj),
                        f"{path}: change_page needs an integer page since 1.21.5: {obj[:160]}",
                    )
        self.assertGreater(seen, 0, "scan found no click_event objects - scanner or scope is broken")

    def test_hover_event_payloads(self):
        for path in pack_files():
            for obj in event_objects(read(path), "hover_event"):
                self.assertFalse(
                    has_key(obj, "contents"),
                    f"{path}: hover_event still uses the removed 'contents' key: {obj[:160]}",
                )
                action = action_of(obj)
                self.assertIsNotNone(action, f"{path}: hover_event without an action: {obj[:120]}")
                if "$(" in action:
                    continue
                self.assertIn(
                    action,
                    HOVER_PAYLOAD,
                    f"{path}: unknown hover action {action!r} - extend HOVER_PAYLOAD on purpose",
                )
                self.assertTrue(
                    has_key(obj, HOVER_PAYLOAD[action]),
                    f"{path}: hover action {action} needs a {HOVER_PAYLOAD[action]!r} key: {obj[:160]}",
                )
                if action == "show_entity":
                    self.assertTrue(
                        has_key(obj, "uuid"),
                        f"{path}: show_entity needs a 'uuid' key since 1.21.5: {obj[:160]}",
                    )

    def test_sign_input_never_relies_on_sign_click_events(self):
        # 26.3 Snapshot 4: sign text click events no longer execute by default.
        # macroEngine's sign input reads front_text only; keep any click event
        # out of sign text unless allow_op_features is handled deliberately.
        for path in pack_files():
            text = read(path)
            if "click_event" not in text:
                continue
            for sign_field in ("front_text", "back_text", "sign_text_front", "sign_text_back"):
                self.assertNotIn(
                    sign_field,
                    text,
                    f"{path}: mixes {sign_field} with click_event - 26.3 signs do not run "
                    "click events unless allow_op_features is set; update "
                    "docs/text_components.md and this test if that becomes intended",
                )

    def test_gate_prompts_click_through_trigger(self):
        # The consent/permit prompts are shown to every player. A /function
        # click would dead-end non-operators and, since 1.21.6, show operators
        # a confirmation screen; /trigger is the prompt-safe path.
        for rel in (
            "data/macroengine/function/gate/consent_prompt.mcfunction",
            "data/macroengine/function/gate/permit_prompt.mcfunction",
        ):
            path = os.path.join(ROOT, "packs", "macroEngine-Datapack-v26.3", *rel.split("/"))
            for obj in event_objects(read(path), "click_event"):
                if action_of(obj) != "run_command":
                    continue
                match = re.search(r'"command"\s*:\s*"([^"]*)"', obj)
                self.assertIsNotNone(match, f"{path}: run_command without a command key")
                self.assertTrue(
                    match.group(1).lstrip("/").startswith("trigger "),
                    f"{path}: gate prompt click must use /trigger, not {match.group(1)!r}",
                )


if __name__ == "__main__":
    unittest.main()
