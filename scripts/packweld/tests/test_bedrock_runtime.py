# AI-assisted: written by Claude (Anthropic) for the packweld project (see CREDITS.md).
"""Runs the generated Bedrock scripts under Node with a *mocked* @minecraft/server.
This proves the module logic, not compatibility with the real game API."""
import shutil, subprocess, tempfile, unittest
from pathlib import Path
from packweld.bedrock import build_bedrock
from packweld.config import BuildConfig

HERE = Path(__file__).parent / "js"


@unittest.skipUnless(shutil.which("node"), "node not installed")
class BedrockRuntime(unittest.TestCase):
    def test_runtime(self):
        r = build_bedrock(BuildConfig(name="Zed", namespace="zedq"))
        with tempfile.TemporaryDirectory() as td:
            td = Path(td)
            for p, b in r["bp"].items():
                if p.endswith(".js"):
                    (td / p).parent.mkdir(parents=True, exist_ok=True); (td / p).write_bytes(b)
            (td / "package.json").write_text('{"type":"module"}')
            for pkg, src in (("server", "server_mock.js"), ("server-ui", "server_ui_mock.js")):
                d = td / "node_modules/@minecraft" / pkg; d.mkdir(parents=True)
                (d / "package.json").write_text('{"name":"@minecraft/%s","type":"module","main":"index.js"}' % pkg)
                shutil.copy(HERE / src, d / "index.js")
            shutil.copy(HERE / "runtime.test.mjs", td / "test.mjs")
            res = subprocess.run(["node", "test.mjs"], cwd=td, capture_output=True, text=True)
            self.assertEqual(res.returncode, 0, res.stdout + res.stderr)
            self.assertIn("passed", res.stdout)


if __name__ == "__main__":
    unittest.main()
