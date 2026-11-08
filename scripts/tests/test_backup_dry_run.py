#!/usr/bin/env python3
"""Tests for scripts/ops/backup-org.sh, run as a shell script, offline.

The audit on 2026-11-08 ran `--dry-run` and found three things the documentation
said could not happen:

  * it created the backup directory, the output directory and a log file, so
    "change nothing" was false;
  * it printed `[dry-run] <command>` verbatim, and the command carries `-t
    <token>`, so the preview wrote the credential to the terminal and to that
    log;
  * with a github-backup build that lacks `file://` token support, a real run
    put the token in argv, where every local user can read it from
    /proc/<pid>/cmdline for the hours a backup takes - and the script only
    warned.

None of these needs a GitHub token, a network or a real backup to reproduce:
`--dry-run` is enough for the first two, and the third is a decision the script
makes before it runs anything.

Run:  python3 scripts/tests/test_backup_dry_run.py
"""
from __future__ import annotations

import os
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "scripts" / "ops" / "backup-org.sh"

# Shaped like a real token, obviously fake, and long enough to be matched by the
# redaction patterns rather than by its exact value alone.
FAKE_TOKEN = "ghp_" + "0123456789abcdefghij0123456789abcd"


def run_dry(directory: Path, *extra: str, token: str | None = FAKE_TOKEN) -> subprocess.CompletedProcess:
    env = {k: v for k, v in os.environ.items() if k not in ("VC_TOKEN", "GH_TOKEN")}
    if token:
        env["VC_TOKEN"] = token
    return subprocess.run(
        ["bash", str(SCRIPT), "--dry-run", "--org", "vortaforge",
         "--backup-dir", str(directory / "backup"), "--out-dir", str(directory / "out"),
         *extra],
        capture_output=True, text=True, env=env, timeout=120, cwd=directory)


class DryRun(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self._tmp.name)

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def test_a_dry_run_writes_nothing(self):
        """The claim in the script's own header, asserted against the filesystem.

        It used to `mkdir -p` three directories and fork `tee -a` to append to a
        log. `--dry-run` is documented as "show what would run, change nothing",
        and a preview that leaves state behind fails on a read-only filesystem
        and makes a backup directory look like evidence a backup happened.
        """
        result = run_dry(self.dir)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

        leftovers = sorted(p for p in self.dir.rglob("*"))
        self.assertEqual(
            leftovers, [],
            "a dry run left these behind: " + ", ".join(str(p.relative_to(self.dir))
                                                        for p in leftovers))

    def test_a_dry_run_never_prints_the_token(self):
        """The regression the audit found by reading its own output.

        `run()` echoed the command it would have run, and that command is
        `github-backup ... -t <token>`. The dry run is the one path that does not
        need the token, so writing it out is pure loss.
        """
        result = run_dry(self.dir)
        combined = result.stdout + result.stderr
        self.assertNotIn(FAKE_TOKEN, combined,
                         "the dry run printed the token")
        self.assertIn("REDACTED", combined,
                      "the token should be replaced, not merely absent by accident")

    def test_redaction_survives_a_token_that_is_only_in_the_command(self):
        """A token from the environment is the documented path, but not the only one.

        If someone exports GH_TOKEN, the redaction still has to work - the
        assertion above would pass on a script that printed nothing at all.
        """
        result = run_dry(self.dir)
        combined = result.stdout + result.stderr
        self.assertIn("[dry-run] github-backup", combined,
                      "the dry run must still show what it would have run")
        self.assertNotIn(FAKE_TOKEN, combined)

    def test_no_log_file_is_created(self):
        """A log is the artefact of a real backup; a preview inside one reads as real."""
        run_dry(self.dir)
        self.assertEqual(list(self.dir.rglob("backup-*.log")), [])

    def test_missing_token_fails_before_anything_is_written(self):
        result = run_dry(self.dir, token=None)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(list(self.dir.rglob("*")), [])


class TokenNeverReachesArgv(unittest.TestCase):
    """The `-t` argument must be a file:// path or the run must not start."""

    def setUp(self) -> None:
        self.source = SCRIPT.read_text(encoding="utf-8")

    def test_the_argv_fallback_is_a_refusal_not_a_warning(self):
        """Old behaviour: warn, then put the token in argv anyway.

        A token in argv is readable by every local user via
        /proc/<pid>/cmdline, is inherited by anything the tool spawns, and stays
        readable for the whole run. Warning and proceeding meant the guarantee in
        the comment was conditional on a pip package's version.
        """
        self.assertRegex(
            self.source,
            r"else\s*\n\s*#.*\n(\s*#.*\n)*\s*die \"github-backup \$\{GHBK_VERSION\} has no file:// token support",
            "the no-file:// branch must refuse, not warn")
        self.assertNotRegex(
            self.source,
            r'warn "this github-backup has no file:// token support',
            "the warn-and-continue path is back")

    def test_the_dry_run_says_a_real_run_would_refuse(self):
        self.assertIn("a real run would refuse", self.source)

    def test_the_token_file_is_removed_by_a_trap(self):
        self.assertRegex(self.source, r"trap cleanup EXIT")
        self.assertRegex(self.source, r'rm -f -- "\$TOKEN_FILE"')

    def test_the_script_is_syntactically_valid(self):
        result = subprocess.run(["bash", "-n", str(SCRIPT)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
