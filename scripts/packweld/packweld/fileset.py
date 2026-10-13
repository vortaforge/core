# AI-assisted: this file was written by Claude (Anthropic) for the packweld project.
# See CREDITS.md. Vendored pack code under packweld/vendor/ is NOT AI-written.
from __future__ import annotations
import io, os, zipfile
from pathlib import Path

ZIP_TIME = (2026, 1, 1, 0, 0, 0)   # fixed timestamp -> reproducible zips


class FileSet(dict):
    """relative posix path -> bytes"""

    def put(self, path: str, data):
        if isinstance(data, str):
            data = data.encode("utf-8")
        self[path.replace(os.sep, "/")] = data

    def write_dir(self, dest: Path):
        for p, b in sorted(self.items()):
            f = Path(dest) / p
            f.parent.mkdir(parents=True, exist_ok=True)
            f.write_bytes(b)

    def zip_bytes(self) -> bytes:
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, "w", zipfile.ZIP_DEFLATED) as z:
            for p, b in sorted(self.items()):
                zi = zipfile.ZipInfo(p, ZIP_TIME)
                zi.compress_type = zipfile.ZIP_DEFLATED
                zi.external_attr = 0o644 << 16
                z.writestr(zi, b)
        return buf.getvalue()
