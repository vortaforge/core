# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
"""Local web UI: stdlib http.server + one static page. No dependencies, no network access needed."""
from __future__ import annotations
import json, secrets, tempfile, threading, webbrowser, zipfile, io
from dataclasses import asdict
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from . import __version__
from .bedrock import MODULES as BEDROCK_MODULES
from .build import build
from .config import BuildConfig
from .modules_info import list_modules
from .schema import config_schema

PAGE = Path(__file__).with_name("ui") / "index.html"
MAX_BODY = 1_000_000
_downloads: dict = {}


def _meta():
    return {"version": __version__, "modules": list_modules(),
            "bedrock_modules": [{"id": k, "desc": v} for k, v in BEDROCK_MODULES.items()],
            "config_keys": config_schema(), "defaults": BuildConfig().to_dict()}


def _bundle(cfg: BuildConfig):
    """Build into a temp dir and return (report, zip bytes of everything)."""
    with tempfile.TemporaryDirectory() as td:
        cfg.output_dir, cfg.keep_dirs, cfg.make_zip = td, False, True
        rep = build(cfg, write=True)
        if not rep.ok:
            return rep, None
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
            for f in sorted(Path(td).rglob("*")):
                if f.is_file():
                    z.write(f, f.relative_to(td).as_posix())
        rep.outputs = [Path(o).relative_to(td).as_posix() for o in rep.outputs]
        return rep, buf.getvalue()


class Handler(BaseHTTPRequestHandler):
    server_version = "packweld"

    def log_message(self, *a):
        pass

    def _local_only(self) -> bool:
        host = (self.headers.get("Host") or "").split(":")[0]
        if host not in ("127.0.0.1", "localhost", "[::1]", self.server.bound_host):
            return False
        origin = self.headers.get("Origin")
        return origin is None or origin.split("//", 1)[-1].split(":")[0] in ("127.0.0.1", "localhost", "[::1]", self.server.bound_host)

    def _send(self, code, body: bytes, ctype="application/json", extra=None):
        self.send_response(code)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.send_header("X-Content-Type-Options", "nosniff")
        for k, v in (extra or {}).items():
            self.send_header(k, v)
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        if not self._local_only():
            return self._send(403, b"{}")
        if self.path in ("/", "/index.html"):
            return self._send(200, PAGE.read_bytes(), "text/html; charset=utf-8")
        if self.path == "/api/meta":
            return self._send(200, json.dumps(_meta()).encode())
        if self.path.startswith("/download/"):
            data = _downloads.get(self.path.rsplit("/", 1)[-1])
            if data is None:
                return self._send(404, b"{}")
            return self._send(200, data, "application/zip", {"Content-Disposition": 'attachment; filename="packweld-output.zip"'})
        self._send(404, b"{}")

    def do_POST(self):
        if not self._local_only() or self.path not in ("/api/preview", "/api/build"):
            return self._send(403, b"{}")
        n = int(self.headers.get("Content-Length") or 0)
        if n > MAX_BODY:
            return self._send(413, b"{}")
        try:
            cfg = BuildConfig.from_dict(json.loads(self.rfile.read(n) or b"{}"))
        except Exception as e:                       # bad JSON / unknown keys
            return self._send(400, json.dumps({"ok": False, "errors": [str(e)], "warnings": [], "outputs": [], "info": {}}).encode())
        if self.path == "/api/preview":
            rep = build(cfg, write=False)
            return self._send(200, json.dumps(rep.to_dict()).encode())
        rep, data = _bundle(cfg)
        d = rep.to_dict()
        if data:
            tok = secrets.token_urlsafe(12)
            _downloads.clear(); _downloads[tok] = data
            d["download"] = f"/download/{tok}"
        self._send(200, json.dumps(d).encode())


def serve(host="127.0.0.1", port=8765, open_browser=True):
    srv = ThreadingHTTPServer((host, port), Handler)
    srv.bound_host = host
    url = f"http://{host}:{port}/"
    print(f"packweld UI on {url}  (Ctrl+C to stop)")
    if host not in ("127.0.0.1", "localhost", "::1"):
        print("warning: UI is reachable from the network and has no authentication")
    if open_browser:
        threading.Timer(0.4, lambda: webbrowser.open(url)).start()
    try:
        srv.serve_forever()
    except KeyboardInterrupt:
        pass
