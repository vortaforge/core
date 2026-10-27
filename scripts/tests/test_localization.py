"""Offline guards for macroEngine localization.

Every fixed player/admin-facing message in the pack must be a translatable
text component whose key exists in the resource pack's en_us.json (with the
English text duplicated as the component fallback), and tr_tr.json must carry
the same keys with matching placeholder counts. Nothing here needs a
Minecraft server; see packs/macroEngine-Datapack-v26.3/docs/localization.md.
"""

import json
import os
import re
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
DPACK = os.path.join(ROOT, "packs", "macroEngine-Datapack-v26.3")
RPACK = os.path.join(ROOT, "packs", "macroEngine-Resourcepack-v26.3")
DATA = os.path.join(DPACK, "data", "macroengine")
FUNCTIONS = os.path.join(DATA, "function")
LANG_DIR = os.path.join(RPACK, "assets", "macroengine", "lang")

PLACEHOLDER = re.compile(r"%(\d+\$)?s")
TRANSLATE_RE = re.compile(
    r'"translate":"([^"]+)"(?:,"fallback":"((?:\\.|[^"\\])*)")?'
)
TEXT_RE = re.compile(r'"text":"((?:\\.|[^"\\])*)"')

# Literal fragments that may stay as "text": brand markers, machine labels,
# function-path labels, and the syntax samples of the text-components demo.
# Anything else alphabetic is player-facing prose and must be a key.
ALLOWED_LITERALS = {
    "[MACROENGINE] ",
    "[MACROENGINE]",
    "[MACROENGINE/cb] ",
    "[MACROENGINE/WARNING] ",
    "[i] ",
    "[x] ",
    "[ok] ",
    "interaction/list",
    "block/list",
    "lib/for_each_list ",
    "lib/repeat ",
    "gamerule/get ",
    "/function macroengine:core/internal/load/force",
    "  {storage,nbt}                    ",
    "  {storage,nbt,interpret:true}     ",
    "  {storage,nbt,interpret:false,",
    "                     plain:true}   ",
}
MODULE_IDS = {"hook", "interaction", "perm", "wand", "geo", "cb", "block", "container"}


def load_lang(name):
    with open(os.path.join(LANG_DIR, name), encoding="utf-8") as fh:
        return json.load(fh)


def walk_files(base, suffix):
    for dirpath, _dirs, files in os.walk(base):
        for name in files:
            if name.endswith(suffix):
                yield os.path.join(dirpath, name)


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


def unescape(raw):
    try:
        return json.loads('"' + raw + '"')
    except json.JSONDecodeError:
        return raw


def json_components(value):
    """Yield every dict in a parsed JSON tree (text components included)."""
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from json_components(child)
    elif isinstance(value, list):
        for child in value:
            yield from json_components(child)


class Localization(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.en = load_lang("en_us.json")
        cls.tr = load_lang("tr_tr.json")

    def test_language_files_have_identical_keys(self):
        self.assertEqual(set(self.en), set(self.tr))
        self.assertGreater(len(self.en), 100)

    def test_placeholders_match_between_languages(self):
        for key, en_text in self.en.items():
            self.assertEqual(
                len(PLACEHOLDER.findall(en_text)),
                len(PLACEHOLDER.findall(self.tr[key])),
                key,
            )
            # A stray % would break client formatting; every % must be a slot.
            for text in (en_text, self.tr[key]):
                self.assertEqual(text.count("%"), len(PLACEHOLDER.findall(text)), key)

    def _check_translate(self, key, fallback, where, used, problems):
        used.add(key)
        if key.startswith("gui."):
            return  # vanilla key: every client already ships it
        if not key.startswith(("macroengine.", "item.macroengine.")):
            problems.append(f"{where}: unexpected translate key {key}")
            return
        if key not in self.en:
            problems.append(f"{where}: key {key} missing from en_us.json")
        elif fallback is None:
            problems.append(f"{where}: key {key} has no fallback")
        elif fallback != self.en[key]:
            problems.append(f"{where}: fallback for {key} differs from en_us")

    def test_every_used_key_exists_with_matching_fallback(self):
        used, problems = set(), []

        for path in walk_files(FUNCTIONS, ".mcfunction"):
            rel = os.path.relpath(path, ROOT)
            for lineno, line in enumerate(read(path).splitlines(), 1):
                if line.lstrip().startswith("#"):
                    continue
                for key, raw_fallback in TRANSLATE_RE.findall(line):
                    fallback = unescape(raw_fallback) if raw_fallback else None
                    self._check_translate(key, fallback, f"{rel}:{lineno}", used, problems)

        for path in walk_files(DATA, ".json"):
            rel = os.path.relpath(path, ROOT)
            for comp in json_components(json.loads(read(path))):
                if "translate" in comp:
                    self._check_translate(
                        comp["translate"], comp.get("fallback"), rel, used, problems
                    )

        sounds = read(os.path.join(RPACK, "assets", "macroengine", "sounds.json"))
        for key in re.findall(r'"subtitle":\s*"([^"]+)"', sounds):
            used.add(key)
            self.assertIn(key, self.en)

        self.assertEqual([], problems)
        # No orphan translations: every shipped key is referenced somewhere.
        self.assertEqual(set(self.en) - used, set())

    def test_no_hardcoded_player_text_in_functions(self):
        violations = []
        for path in walk_files(FUNCTIONS, ".mcfunction"):
            rel = os.path.relpath(path, ROOT)
            for lineno, line in enumerate(read(path).splitlines(), 1):
                if line.lstrip().startswith("#"):
                    continue
                for raw in TEXT_RE.findall(line):
                    text = unescape(raw)
                    if not any(ch.isalpha() for ch in text):
                        continue  # separators, spaces, symbols
                    if "$(" in text:
                        continue  # caller-supplied / dynamic value
                    if text in ALLOWED_LITERALS or text.strip() in MODULE_IDS:
                        continue
                    if text.strip().endswith("="):
                        continue  # key=value machine dumps
                    violations.append(f"{rel}:{lineno}: {text!r}")
        self.assertEqual([], violations)

    def test_dialogs_are_fully_translatable(self):
        for name in ("setup_warning.json", "setup_warning_confirm.json"):
            dialog = json.loads(read(os.path.join(DATA, "dialog", name)))
            for comp in json_components(dialog):
                text = comp.get("text")
                if isinstance(text, str):
                    self.assertFalse(
                        any(ch.isalpha() for ch in text),
                        f"{name} still hard-codes {text!r}",
                    )
        first = read(os.path.join(DATA, "dialog", "setup_warning.json"))
        second = read(os.path.join(DATA, "dialog", "setup_warning_confirm.json"))
        for key in (
            "macroengine.dialog.setup_warning.title",
            "macroengine.dialog.setup_warning.body",
            "macroengine.dialog.setup_warning.continue",
            "macroengine.dialog.setup_warning.more_info",
            "gui.cancel",
        ):
            self.assertIn(key, first)
        for key in (
            "macroengine.dialog.setup_warning.confirm_title",
            "macroengine.dialog.setup_warning.confirm_body",
            "gui.yes",
            "gui.no",
        ):
            self.assertIn(key, second)

    def test_placeholder_messages_carry_two_slots(self):
        for key in (
            "macroengine.msg.settings.summary",
            "macroengine.msg.security.injection_detected",
        ):
            self.assertEqual(2, len(PLACEHOLDER.findall(self.en[key])), key)
        self.assertEqual(
            1, len(PLACEHOLDER.findall(self.en["macroengine.msg.cb.queue_entries"]))
        )

    def test_turkish_is_actually_translated(self):
        self.assertEqual("İzin reddedildi.", self.tr["macroengine.msg.permission_denied"])
        self.assertEqual(
            "macroEngine sunucu uyarısı",
            self.tr["macroengine.dialog.setup_warning.title"],
        )
        same = {k for k in self.en if self.en[k] == self.tr[k]}
        # Only a couple of universal labels may coincide (e.g. "hud: ").
        self.assertLessEqual(len(same), 3, same)

    def test_localization_doc_exists(self):
        doc = read(os.path.join(DPACK, "docs", "localization.md"))
        for phrase in ("fallback", "tr_tr.json", "Adding a language", "%s"):
            self.assertIn(phrase, doc)


if __name__ == "__main__":
    unittest.main()
