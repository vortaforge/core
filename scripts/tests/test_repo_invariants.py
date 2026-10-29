"""Offline regression tests for repository-level invariants.

Run with:  python3 -m pytest scripts/tests   (or: python3 -m unittest discover scripts/tests)

Nothing here starts, contacts or needs a Minecraft server.
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
SCRIPT = os.path.join(ROOT, "scripts", "origin_watermarks.py")


def run_watermarks(script, *args):
    return subprocess.run(
        [sys.executable, script, *args], capture_output=True, text=True, check=False
    )


class RealTreeWatermarks(unittest.TestCase):
    def test_every_datapack_has_a_valid_watermark(self):
        # Regression: commit 5f2a74b deleted the macroEngine watermark, which
        # made the first CI step (--check) fail on main.
        result = run_watermarks(SCRIPT, "--check")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class WatermarkCheckerBehaviour(unittest.TestCase):
    """Negative controls on a throw-away copy of the layout the tool expects."""

    def setUp(self):
        self.tmp = tempfile.mkdtemp(prefix="wm-test-")
        self.addCleanup(shutil.rmtree, self.tmp, ignore_errors=True)
        os.makedirs(os.path.join(self.tmp, "scripts"))
        shutil.copy(SCRIPT, os.path.join(self.tmp, "scripts", "origin_watermarks.py"))
        open(os.path.join(self.tmp, "build.gradle"), "w").close()
        fn = os.path.join(self.tmp, "packs", "demo", "data", "demo", "function")
        os.makedirs(fn)
        with open(os.path.join(self.tmp, "packs", "demo", "pack.mcmeta"), "w") as fh:
            fh.write('{"pack": {"description": "x", "min_format": 1, "max_format": 1}}')
        with open(os.path.join(fn, "a.mcfunction"), "w") as fh:
            fh.write("say hi\n")
        self.script = os.path.join(self.tmp, "scripts", "origin_watermarks.py")
        self.mark = os.path.join(fn, "_vc_origin.mcfunction")

    def test_missing_watermark_fails_then_write_fixes_it(self):
        self.assertEqual(run_watermarks(self.script, "--check").returncode, 1)
        self.assertEqual(run_watermarks(self.script, "--write").returncode, 0)
        self.assertTrue(os.path.isfile(self.mark))
        self.assertEqual(run_watermarks(self.script, "--check").returncode, 0)

    def test_executable_line_in_watermark_is_rejected(self):
        run_watermarks(self.script, "--write")
        with open(self.mark, "a", encoding="utf-8") as fh:
            fh.write("say injected\n")
        result = run_watermarks(self.script, "--check")
        self.assertEqual(result.returncode, 1)
        self.assertIn("executable line", result.stdout + result.stderr)


class WorkflowPinning(unittest.TestCase):
    USES = re.compile(r"^\s*-?\s*uses:\s*(\S+)")
    SHA = re.compile(r"@[0-9a-f]{40}$")

    def test_all_actions_are_pinned_by_commit_sha(self):
        # CLAUDE.md: "Actions are pinned by commit SHA; keep it that way."
        wf_dir = os.path.join(ROOT, ".github", "workflows")
        unpinned = []
        for name in sorted(os.listdir(wf_dir)):
            if not name.endswith((".yml", ".yaml")):
                continue
            with open(os.path.join(wf_dir, name), encoding="utf-8") as fh:
                for no, line in enumerate(fh, 1):
                    m = self.USES.match(line)  # comment lines never match
                    if m and not m.group(1).startswith("./") and not self.SHA.search(m.group(1)):
                        unpinned.append(f"{name}:{no}: {m.group(1)}")
        self.assertEqual(unpinned, [], "actions not pinned by SHA")


class ReusableQualityWorkflowInvariants(unittest.TestCase):
    """Keep the CI trust boundary explicit when workflows are edited later."""

    def test_read_only_quality_and_artifact_only_publish_are_separated(self):
        workflows = os.path.join(ROOT, ".github", "workflows")
        with open(os.path.join(workflows, "build.yml"), encoding="utf-8") as fh:
            build = fh.read()
        with open(os.path.join(workflows, "quality.yml"), encoding="utf-8") as fh:
            quality = fh.read()

        self.assertIn("workflow_call:", quality)
        self.assertIn("contents: read", quality)
        self.assertIn("./gradlew ci -PconfirmZip=yes", quality)
        self.assertIn("SHA256SUMS", quality)
        self.assertNotIn("softprops/action-gh-release", quality)

        self.assertIn("uses: ./.github/workflows/quality.yml", build)
        self.assertIn("needs: quality", build)
        self.assertIn("contents: write", build)
        self.assertIn("actions/download-artifact@", build)
        self.assertIn("SHA256SUMS", build)
        self.assertNotIn("actions/checkout@", build)


class WardServerSafetyInvariants(unittest.TestCase):
    """The Ward job is the one place that starts a Minecraft server. These tests
    stop later edits from quietly loosening its isolation or dropping its warnings."""

    WARNED_FILES = ["CLAUDE.md", "AGENT.md", "README.md", "CONTRIBUTING.md", "NOTICE.md",
                    "SECURITY.md", "scripts/README.md", ".github/workflows/ward.yml",
                    "scripts/ward_ci.sh", "scripts/ward_guard.py"]

    def read(self, rel):
        with open(os.path.join(ROOT, rel), encoding="utf-8") as fh:
            return fh.read()

    def test_every_documented_place_carries_the_warning(self):
        def warned(text):
            # one paragraph must carry both the word "warning" and a reference to Ward
            return any("warning" in para.lower() and "ward" in para.lower()
                       for para in re.split(r"\n\s*\n", text))
        missing = [f for f in self.WARNED_FILES if not warned(self.read(f))]
        self.assertEqual(missing, [])

    def test_workflow_stays_isolated(self):
        wf = self.read(".github/workflows/ward.yml")
        runners = re.findall(r"(?m)^\s*runs-on:\s*(\S+)", wf)
        self.assertEqual(runners, ["ubuntu-latest"], "only GitHub-hosted runners")
        self.assertRegex(wf, r"(?m)^permissions:\n  contents: read$")
        self.assertNotIn("secrets.", wf)
        self.assertNotIn("environment:", wf)
        self.assertRegex(wf, r"(?s)Verify cleanup.*if: always\(\)")
        self.assertIn('"mcward==${MCWARD_VERSION}"', wf)
        self.assertRegex(wf, r'MCWARD_VERSION: "1\.4\.0"')

    def test_script_keeps_guards_verification_and_cleanup(self):
        sh = self.read("scripts/ward_ci.sh")
        for needle in ("trap cleanup EXIT", "ward_guard.py", 'verify "$ENV_DIR"', '$GUARD seed "$ENV_DIR"',
                       'GITHUB_ACTIONS:-}" != "true"'):
            self.assertIn(needle, sh)
        # verification must happen before the tests start
        self.assertLess(sh.index('$GUARD verify "$ENV_DIR"'), sh.index("mcward test"))
        self.assertLess(sh.index('$GUARD seed "$ENV_DIR"'), sh.index("mcward start"))

    def test_locked_properties_cannot_be_loosened(self):
        sys.path.insert(0, os.path.join(ROOT, "scripts"))
        import ward_guard
        locked = ward_guard.LOCKED_PROPERTIES
        self.assertEqual(locked["server-ip"], "127.0.0.1")
        for key in ("online-mode", "white-list", "enforce-whitelist"):
            self.assertEqual(locked[key], "true")
        for key in ("enable-rcon", "enable-query", "enable-status"):
            self.assertEqual(locked[key], "false")


class DailyBonusFirstClaim(unittest.TestCase):
    """Static guard for the unset-score defect (the behavioural proof is the Ward test
    packs/DailyBonus/data/dailybonus/test/first_login_is_granted.mcfunction, run in CI)."""

    def test_players_without_a_score_are_granted_before_the_comparison(self):
        base = os.path.join(ROOT, "packs", "DailyBonus", "data", "dailybonus")
        with open(os.path.join(base, "function", "tick.mcfunction"), encoding="utf-8") as fh:
            lines = [l.strip() for l in fh if l.strip() and not l.startswith("#")]
        unset = [i for i, l in enumerate(lines) if "unless score @s db_last_day matches" in l and l.endswith("function dailybonus:grant")]
        compare = [i for i, l in enumerate(lines) if "if score @s db_last_day < #day db_gameday" in l]
        self.assertTrue(unset and compare, lines)
        self.assertLess(unset[0], compare[0], "unset-score grant must run first to avoid a double grant")
        self.assertTrue(os.path.isfile(os.path.join(base, "test", "first_login_is_granted.mcfunction")))


class DownloadPageFallback(unittest.TestCase):
    """The static page must not advertise packs the build cannot produce."""

    def test_fallback_zip_names_match_pack_mcmeta_directories(self):
        packs_root = os.path.join(ROOT, "packs")
        expected = []
        for current, _dirs, files in os.walk(packs_root):
            if "pack.mcmeta" not in files:
                continue
            relative = os.path.relpath(current, packs_root)
            expected.append(relative.replace(os.sep, "-") + ".zip")

        with open(os.path.join(ROOT, "index.html"), encoding="utf-8") as fh:
            listed = re.findall(r'zip: "([^"]+\.zip)"', fh.read())

        self.assertEqual(sorted(listed), sorted(expected))


class AIAgentToolPolicy(unittest.TestCase):
    """Keep the Actions AI agent from regaining shell-equivalent tools."""

    def test_only_fixed_tools_and_manual_dispatch_writes_remain(self):
        with open(os.path.join(ROOT, ".github", "scripts", "ai-agent.js"),
                  encoding="utf-8") as fh:
            source = fh.read()

        self.assertIn('const ALLOW_WRITES = EVENT === "workflow_dispatch";', source)
        for protected in ('".git/"', '".github/"', '"build.gradle"',
                          '"scripts/audit_repo.py"', '"scripts/lint_datapacks.sh"'):
            self.assertIn(protected, source)

        for removed in ("run_python", "run_node", "run_command", "web_search", "fetch_url"):
            self.assertNotRegex(source, rf"(?m)^\s+(?:async\s+)?{removed}\s*\(")
            self.assertNotIn(f'{{"tool":"{removed}"', source)


class AuditFullRobustness(unittest.TestCase):
    """A GitHub API failure must become an audit finding, not a traceback."""

    @classmethod
    def setUpClass(cls):
        sys.path.insert(0, os.path.join(ROOT, "scripts"))
        import audit_full
        cls.audit_full = audit_full

    def setUp(self):
        self.original_get = self.audit_full.get
        self.audit_full.FINDINGS.clear()
        self.addCleanup(setattr, self.audit_full, "get", self.original_get)
        self.addCleanup(self.audit_full.FINDINGS.clear)

    def test_list_endpoint_error_is_reported_without_raising(self):
        self.audit_full.get = lambda path: {"_error": "HTTP 403 rate limit"}
        self.audit_full.audit_prs_issues("vortaforge/core")
        ids = {finding["id"] for finding in self.audit_full.FINDINGS}
        self.assertEqual(ids, {"prs.unreadable", "issues.unreadable"})

    def test_missing_local_clone_is_reported_without_raising(self):
        with tempfile.TemporaryDirectory() as workdir:
            self.audit_full.audit_local("vortaforge/core", workdir)
        self.assertEqual(
            [finding["id"] for finding in self.audit_full.FINDINGS],
            ["local.not-cloned"],
        )


if __name__ == "__main__":
    unittest.main()
