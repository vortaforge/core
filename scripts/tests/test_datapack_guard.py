"""Regression tests for the datapack kill switch and its guard.

Everything here is offline: no git history is required, no network, no
Minecraft. The guard's wiring points (hooks, CI workflow, Gradle tasks) are
asserted too, because the previous datapack immutability lock in this
repository was removed for "enforcing nothing" - a policy that is not wired
into something that actually runs is documentation, not a guard.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
GUARD = ROOT / "scripts" / "datapack_guard.py"
SWITCH_TOOL = ROOT / "scripts" / "datapacks_disable.py"
CHECK_ARCHIVE = ROOT / "scripts" / "check_archive.py"
BLOCKLIST = ROOT / "blocklist" / "blocklist.json"

sys.path.insert(0, str(ROOT / "scripts"))
import datapack_guard  # noqa: E402


def run(script: Path, *args: str, cwd: Path = ROOT) -> subprocess.CompletedProcess:
    return subprocess.run([sys.executable, str(script), *args], cwd=cwd,
                          capture_output=True, text=True, check=False, timeout=120)


def guard_with_changes(changes: str) -> subprocess.CompletedProcess:
    """Run the guard against a synthetic change list."""
    handle = tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False, encoding="utf-8")
    try:
        handle.write(changes)
        handle.close()
        return run(GUARD, "--files-from", handle.name, "--protect", "--no-remote")
    finally:
        os.unlink(handle.name)


class DatapackClassification(unittest.TestCase):
    def test_mcfunction_and_pack_mcmeta_are_datapack_content(self):
        for path in ("packs/demo/data/demo/function/x.mcfunction",
                     "src/main/resources/data/demo/pack.mcmeta",
                     "whatever/pack.mcmeta"):
            with self.subTest(path=path):
                self.assertTrue(datapack_guard.is_datapack_path(path))

    def test_data_directories_for_every_registry_type_are_datapack_content(self):
        for directory in ("function", "functions", "advancement", "advancements",
                          "loot_table", "predicate", "item_modifier", "recipe",
                          "tags/function", "tags/functions", "worldgen"):
            with self.subTest(directory=directory):
                self.assertTrue(datapack_guard.is_datapack_path(
                    f"data/demo/{directory}/thing.json"))

    def test_java_and_docs_are_not_datapack_content(self):
        for path in ("mods/afk-manager/src/main/java/com/example/A.java",
                     "README.md", "archived/packs/DailyBonus/data/x/function/y.mcfunction",
                     "scripts/tests/fixtures/demo/pack.mcmeta"):
            with self.subTest(path=path):
                self.assertFalse(datapack_guard.is_datapack_path(path))


class GuardRules(unittest.TestCase):
    def test_new_pack_in_live_packs_tree_is_blocked(self):
        result = guard_with_changes("A\tpacks/NewPack/pack.mcmeta\n"
                                    "A\tpacks/NewPack/data/ns/function/run.mcfunction\n")
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("live-packs-tree", result.stdout)

    def test_new_datapack_outside_packs_is_blocked(self):
        result = guard_with_changes("A\tmods/x/src/main/resources/data/foo/function/a.mcfunction\n")
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("new-datapack", result.stdout)

    def test_archived_datapack_content_is_allowed(self):
        result = guard_with_changes("A\tarchived/packs/NewPack/data/ns/function/a.mcfunction\n")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertNotIn("new-datapack", result.stdout)

    def test_test_fixture_datapack_is_allowed(self):
        result = guard_with_changes("A\tscripts/tests/fixtures/demo/pack.mcmeta\n")
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_reviving_retired_tooling_is_blocked(self):
        for path in ("scripts/dpgen/builder.js", "scripts/ward_ci.sh",
                     "mods/datapack-blocker/build.gradle", ".github/workflows/ward.yml"):
            with self.subTest(path=path):
                result = guard_with_changes(f"A\t{path}\n")
                self.assertEqual(result.returncode, 1, result.stdout)
                self.assertIn("retired-tooling", result.stdout)

    def test_merge_manifest_cannot_reappear(self):
        result = guard_with_changes("A\tpacks/merge-manifest.json\n")
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("merge-manifest", result.stdout)

    def test_deleting_a_pack_is_only_a_warning(self):
        result = guard_with_changes("D\tpacks/OldPack/pack.mcmeta\n")
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn("live-packs-removal", result.stdout)

    def test_unknown_change_status_is_a_usage_error_not_a_pass(self):
        handle = tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False, encoding="utf-8")
        handle.write("Z\tpacks/x\n")
        handle.close()
        try:
            result = run(GUARD, "--files-from", handle.name, "--protect")
        finally:
            os.unlink(handle.name)
        self.assertEqual(result.returncode, 2, result.stdout + result.stderr)

    def test_normal_mod_change_passes(self):
        result = guard_with_changes("A\tmods/afk-manager/README.md\nM\tREADME.md\n")
        self.assertEqual(result.returncode, 0, result.stdout)


class Blocklist(unittest.TestCase):
    def setUp(self):
        self.blocklist = datapack_guard.Blocklist.load(BLOCKLIST)

    def test_blocklist_file_is_valid(self):
        data = json.loads(BLOCKLIST.read_text(encoding="utf-8"))
        self.assertEqual(data["schema_version"], 1)
        for entry in data["blocked"]:
            self.assertTrue(entry.get("reason"), "every blocked entry needs a reason")
            self.assertTrue(entry.get("added_on"))

    def test_known_datapack_developer_is_matched(self):
        hit = self.blocklist.matches("misode")
        self.assertIsNotNone(hit)
        self.assertEqual(hit["id"], "misode")

    def test_managed_accounts_are_exempt(self):
        for login in ("vortaforge", "vortaforge-maintenance", "github-actions"):
            with self.subTest(login=login):
                self.assertIsNone(self.blocklist.matches(login))

    def test_bot_suffix_rule(self):
        self.assertIsNotNone(self.blocklist.matches("some-helper[bot]"))
        self.assertIsNotNone(self.blocklist.matches("helpful-bot"))

    def test_ai_account_rule(self):
        self.assertIsNotNone(self.blocklist.matches("copilot-swe-agent"))
        self.assertIsNotNone(self.blocklist.matches("codex-agent"))

    def test_unrelated_account_is_not_matched(self):
        for login in ("octocat", "misode-fan-club"):
            with self.subTest(login=login):
                self.assertIsNone(self.blocklist.matches(login))

    def test_missing_blocklist_is_fail_closed(self):
        with self.assertRaises(datapack_guard.BlocklistError):
            datapack_guard.Blocklist.load(ROOT / "blocklist" / "does-not-exist.json")

    def test_pr_by_blocked_login_is_blocked(self):
        result = run(GUARD, "--pr", "--login", "misode", "--no-remote")
        self.assertEqual(result.returncode, 1, result.stdout)
        self.assertIn("blocklist-account", result.stdout)

    def test_pr_by_unblocked_login_passes(self):
        result = run(GUARD, "--pr", "--login", "octocat", "--no-remote")
        self.assertEqual(result.returncode, 0, result.stdout)


class KillSwitch(unittest.TestCase):
    def test_switch_file_says_disabled(self):
        data = json.loads((ROOT / "datapacks.disabled.json").read_text(encoding="utf-8"))
        self.assertIs(data["enabled"], False)
        self.assertTrue(data.get("reenable_token"))
        self.assertTrue(data.get("reason"))
        self.assertTrue(data.get("reason_tr"))

    def test_marker_exists(self):
        self.assertTrue((ROOT / "archived" / "datapacks.disabled").is_file())

    def test_verify_passes_on_this_tree(self):
        result = run(SWITCH_TOOL, "verify")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_enable_requires_the_token(self):
        result = run(SWITCH_TOOL, "enable", "--token", "wrong-token",
                     "--reason", "this should not be accepted at all")
        self.assertEqual(result.returncode, 2)

    def test_archive_registry_check_passes(self):
        result = run(CHECK_ARCHIVE, "--strict")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class Wiring(unittest.TestCase):
    """A guard nobody runs is not a guard."""

    def read(self, *parts: str) -> str:
        return ROOT.joinpath(*parts).read_text(encoding="utf-8")

    def test_git_hooks_exist_and_call_the_guard(self):
        for hook, flag in (("pre-commit", "--staged"), ("pre-push", "--base")):
            with self.subTest(hook=hook):
                text = self.read(".githooks", hook)
                self.assertIn("scripts/datapack_guard.py", text)
                self.assertIn(flag, text)
                self.assertIn("exit 1", text)  # fail-closed when the guard is missing

    def test_ci_runs_the_guard_before_verification(self):
        quality = self.read(".github", "workflows", "quality.yml")
        self.assertIn("datapack-guard:", quality)
        self.assertIn("scripts/datapack_guard.py", quality)
        self.assertIn("needs: [datapack-guard, verify, guigenmc-package]", quality)
        # The guard job must appear before the verify job in the file, so a
        # reader sees it first and the gate wiring is obvious.
        self.assertLess(quality.index("datapack-guard:"), quality.index("\n  verify:"))
        self.assertIn("scripts/datapacks_disable.py verify", quality)

    def test_gradle_wires_guard_and_switch(self):
        tasks = self.read("build-logic", "project-tasks.gradle")
        self.assertIn("tasks.register('guardArchives'", tasks)
        self.assertIn("scripts/datapack_guard.py", tasks)
        self.assertIn("dependsOn 'guardArchives', 'checkDatapackSwitch', 'checkArchive'", tasks)
        root = self.read("build.gradle")
        self.assertIn("tasks.register('checkDatapackSwitch')", root)
        self.assertIn("scripts/check_archive.py", root)

    def test_default_gradle_graph_has_no_pack_tasks(self):
        root = self.read("build.gradle")
        tasks = self.read("build-logic", "project-tasks.gradle")
        for gone in ("zipPacks", "mergeDatapacks", "checkPacks", "lintDatapacks",
                     "installDatapackLintDependencies", "testDpgen", "checkProvenance"):
            with self.subTest(task=gone):
                self.assertNotIn(f"tasks.register('{gone}'", root)
                self.assertNotIn(f"tasks.register('{gone}'", tasks)

    def test_weshould_not_have_a_ward_workflow(self):
        self.assertFalse((ROOT / ".github" / "workflows" / "ward.yml").exists())

    def test_readme_and_docs_point_at_the_switch(self):
        self.assertIn("datapacks.disabled.json", self.read("README.md"))
        self.assertTrue((ROOT / "docs" / "ARCHIVAL.md").is_file())


if __name__ == "__main__":
    unittest.main()
