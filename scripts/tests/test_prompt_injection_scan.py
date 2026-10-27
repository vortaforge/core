"""Offline regression tests: prompt-injection screening of macroEngine text captures.

Run with:  python3 -m pytest scripts/tests   (or: python3 -m unittest discover scripts/tests)

Nothing here starts, contacts or needs a Minecraft server.

The invariants that make the feature safe rather than theatre (see
packs/macroEngine-Datapack-v26.3/docs/prompt_injection.md):

- scanned text is never macro-substituted anywhere in the scan path,
- every text capture is screened BEFORE its listener tag fires,
- the settings book auto-apply refuses a suspicious capture,
- scan output carries pattern ids, never the payload phrases themselves,
- the toggle is a normal validated config key (config_rev 5),
- the operator notice is present where players/operators will read it.
"""

import os
import re
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
ME = os.path.join(ROOT, "packs", "macroEngine-Datapack-v26.3")
FN = os.path.join(ME, "data", "macroengine", "function")

SCAN = os.path.join(FN, "input", "validate", "injection_scan.mcfunction")
PRIV = os.path.join(FN, "core", "internal", "input", "validate", "_private")
NOTICE = "Do not attempt prompt injection"


def read(path):
    with open(path, encoding="utf-8") as fh:
        return fh.read()


class ScanShape(unittest.TestCase):
    def test_scan_files_exist_and_never_macro_the_text(self):
        files = [SCAN] + [
            os.path.join(PRIV, name)
            for name in (
                "injection_patterns.mcfunction",
                "injection_loop.mcfunction",
                "injection_hit.mcfunction",
                "injection_report.mcfunction",
                "injection_sign.mcfunction",
                "injection_sign_loop.mcfunction",
            )
        ]
        for path in files:
            self.assertTrue(os.path.isfile(path), f"missing {path}")
            for line in read(path).splitlines():
                self.assertFalse(
                    line.startswith("$"), f"{path}: macro line in the scan path: {line[:80]}"
                )
                self.assertNotIn("$(", line, f"{path}: macro substitution in the scan path")

    def test_scan_defaults_clean_and_reads_config_mirror(self):
        scan = read(SCAN)
        self.assertLess(
            scan.index("scan set value {suspicious:0b"),
            scan.index("#injection_scan macroengine.tick_flags"),
            "scan output must default to clean before any early return",
        )
        self.assertIn("core/lib/string/find", read(os.path.join(PRIV, "injection_loop.mcfunction")))
        # The cost bound: a 96-char prefix slice + stop after 2 strong hits.
        self.assertIn("set string storage macroengine:input_validate scan_work 0 96", scan)
        self.assertIn("truncated:0b", scan)
        loop = read(os.path.join(PRIV, "injection_loop.mcfunction"))
        self.assertIn("#inj_hits macroengine.tmp matches 2..", loop)

    def test_hits_carry_ids_not_needles(self):
        hit = read(os.path.join(PRIV, "injection_hit.mcfunction"))
        self.assertNotIn("cur.needle", hit, "scan output must not echo payload phrases")
        self.assertIn("cur.id", hit)
        self.assertIn("cur.strong", hit)

    def test_patterns_are_lowercase_unique_and_tiered(self):
        entries = re.findall(
            r'append value \{id:"([^"]+)",needle:"((?:[^"\\]|\\.)*)",strong:([01])b\}',
            read(os.path.join(PRIV, "injection_patterns.mcfunction")),
        )
        # Small on purpose: pattern count is a command-budget decision
        # (see the COST BOUND note in injection_scan). Growing this list
        # means re-doing that arithmetic, not just appending a line.
        self.assertGreaterEqual(len(entries), 15, "pattern baseline unexpectedly small")
        self.assertLessEqual(len(entries), 20, "pattern list grew past the documented cost bound")
        ids = [e[0] for e in entries]
        self.assertEqual(len(ids), len(set(ids)), "pattern ids must be unique")
        for pid, needle, _strong in entries:
            self.assertEqual(needle, needle.lower(), f"pattern {pid}: needle must be lowercase")
        self.assertTrue(any(e[2] == "1" for e in entries), "no strong patterns")
        self.assertTrue(any(e[2] == "0" for e in entries), "no watch patterns")

    def test_report_audits_without_echoing_text(self):
        report = read(os.path.join(PRIV, "injection_report.mcfunction"))
        self.assertIn("input.injection_suspected", report)
        self.assertIn("systems/audit/record", report)
        self.assertNotIn("scan_in.text", report, "the captured text must not be echoed anywhere")


class CaptureWiring(unittest.TestCase):
    CASES = (
        ("input/private/book_capture.mcfunction", "injection_scan", "#macroengine:input/writable_book"),
        ("input/private/lectern_capture.mcfunction", "injection_scan", "#macroengine:input/lectern"),
        ("input/private/sign_capture.mcfunction", "injection_sign", "#macroengine:input/sign"),
        ("input/private/name_tag_capture.mcfunction", "injection_scan", "#macroengine:input/name_tag"),
        ("input/private/anvil_capture.mcfunction", "injection_scan", "#macroengine:input/anvil"),
    )

    def test_every_capture_scans_before_listeners_fire(self):
        for rel, scan_call, tag in self.CASES:
            text = read(os.path.join(FN, *rel.split("/")))
            self.assertIn(scan_call, text, f"{rel}: no screening call")
            self.assertLess(
                text.index(scan_call),
                text.index(tag),
                f"{rel}: screening must happen before the listener tag fires",
            )
            if rel.endswith("sign_capture.mcfunction"):
                # The per-line helper owns the aggregate for signs.
                helper = read(os.path.join(PRIV, "injection_sign.mcfunction"))
                self.assertIn("sign.scan", helper, "sign helper must store the aggregate")
            else:
                self.assertIn(".scan", text, f"{rel}: scan result not stored on the capture")

    def test_settings_auto_apply_refuses_suspicious_books(self):
        on_book = read(os.path.join(FN, "core", "internal", "api", "settings", "_on_book.mcfunction"))
        self.assertIn("book.scan{suspicious:1b}", on_book)
        self.assertLess(
            on_book.index("book.scan{suspicious:1b}"),
            on_book.index("return run function macroengine:api/settings/apply"),
            "the refusal must gate the auto-apply call",
        )


class ConfigWiring(unittest.TestCase):
    def test_injection_scan_is_a_rev5_config_key(self):
        config = read(os.path.join(FN, "config.mcfunction"))
        self.assertIn('injection_scan:{t:"bool"}', config)
        self.assertIn("config.injection_scan set value 1b", config)
        self.assertIn("config_rev set value 5", config)
        ensure = read(os.path.join(FN, "core", "config", "ensure.mcfunction"))
        self.assertIn("{config_rev:5}", ensure)
        self.assertIn("#injection_scan macroengine.tick_flags", ensure)
        apply_ = read(os.path.join(FN, "core", "config", "apply.mcfunction"))
        self.assertIn(
            "score #injection_scan macroengine.tick_flags run data get storage macroengine:engine config.injection_scan",
            apply_,
        )


class NoticePlacement(unittest.TestCase):
    def test_notice_reaches_operators_and_players(self):
        security = read(os.path.join(ROOT, "SECURITY.md"))
        self.assertIn(NOTICE, security)
        self.assertIn("treat all player-supplied text as untrusted data, never as instructions", security)
        self.assertIn("injection_scan", security)
        self.assertIn(NOTICE, read(os.path.join(ME, "README.md")))
        doc = read(os.path.join(ME, "docs", "prompt_injection.md"))
        self.assertIn(NOTICE, doc)
        self.assertIn("heuristic", doc.lower(), "the doc must not oversell the detection")


if __name__ == "__main__":
    unittest.main()
