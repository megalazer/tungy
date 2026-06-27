from __future__ import annotations

from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from secrets import token_urlsafe
from typing import Any
from urllib.parse import parse_qs, urlparse
import json
import os

from .store import TranscriptRecord, TranscriptStore, TranscriptStoreError


DEFAULT_PORT = 7878


class BridgeConfig:
    def __init__(self, *, orca_root: Path, token: str, host: str = "0.0.0.0", port: int = DEFAULT_PORT) -> None:
        self.orca_root = orca_root
        self.token = token
        self.host = host
        self.port = port

    @classmethod
    def from_environment(cls) -> "BridgeConfig":
        home = Path.home()
        return cls(
            orca_root=Path(os.environ.get("ORCA_ROOT", home / "orca")),
            token=os.environ.get("ORCA_WATCH_TOKEN") or token_urlsafe(18),
            host=os.environ.get("ORCA_WATCH_HOST", "0.0.0.0"),
            port=int(os.environ.get("ORCA_WATCH_PORT", DEFAULT_PORT)),
        )


class WatchBridgeHandler(BaseHTTPRequestHandler):
    server_version = "OrcaWatchBridge/0.1"

    @property
    def transcript_store(self) -> TranscriptStore:
        return self.server.transcript_store  # type: ignore[attr-defined]

    @property
    def bridge_token(self) -> str:
        return self.server.bridge_token  # type: ignore[attr-defined]

    def do_GET(self) -> None:
        path, _ = self._path_and_query()
        if path == "/health":
            self._send_json(HTTPStatus.OK, {"ok": True, "service": "orca-watch-bridge"})
            return

        if not self._is_authorized():
            self._send_json(HTTPStatus.UNAUTHORIZED, {"error": "missing or invalid token"})
            return

        if path == "/projects":
            self._send_json(HTTPStatus.OK, {"projects": self.transcript_store.available_projects()})
            return

        self._send_json(HTTPStatus.NOT_FOUND, {"error": "not found"})

    def do_POST(self) -> None:
        path, _ = self._path_and_query()
        if not self._is_authorized():
            self._send_json(HTTPStatus.UNAUTHORIZED, {"error": "missing or invalid token"})
            return

        if path != "/transcripts":
            self._send_json(HTTPStatus.NOT_FOUND, {"error": "not found"})
            return

        try:
            payload = self._read_payload()
            text = payload.get("text") or payload.get("transcript")
            if not isinstance(text, str):
                self._send_json(HTTPStatus.BAD_REQUEST, {"error": "missing transcript text"})
                return
            source = payload.get("source") if isinstance(payload.get("source"), str) else "apple-watch"
            project = payload.get("project") if isinstance(payload.get("project"), str) else None
            stored = self.transcript_store.save(TranscriptRecord(text=text, project=project, source=source))
        except TranscriptStoreError as error:
            self._send_json(HTTPStatus.BAD_REQUEST, {"error": str(error)})
            return
        except json.JSONDecodeError:
            self._send_json(HTTPStatus.BAD_REQUEST, {"error": "malformed json"})
            return

        self._send_json(
            HTTPStatus.CREATED,
            {
                "id": str(stored.record.id),
                "project": stored.record.project or "inbox",
                "log": str(stored.log_path),
                "latest": str(stored.latest_path),
            },
        )

    def log_message(self, format: str, *args: Any) -> None:
        return

    def _is_authorized(self) -> bool:
        _, query = self._path_and_query()
        if query.get("token", [None])[0] == self.bridge_token:
            return True
        return self.headers.get("Authorization") == f"Bearer {self.bridge_token}"

    def _read_payload(self) -> dict[str, Any]:
        length = int(self.headers.get("Content-Length", "0"))
        body = self.rfile.read(length)
        content_type = self.headers.get("Content-Type", "")
        if "application/json" in content_type.lower():
            data = json.loads(body.decode("utf-8"))
            if not isinstance(data, dict):
                raise json.JSONDecodeError("JSON root must be an object", body.decode("utf-8", "ignore"), 0)
            return data
        return {"text": body.decode("utf-8")}

    def _path_and_query(self) -> tuple[str, dict[str, list[str]]]:
        parsed = urlparse(self.path)
        return parsed.path, parse_qs(parsed.query)

    def _send_json(self, status: HTTPStatus, body: dict[str, Any]) -> None:
        data = json.dumps(body, sort_keys=True, separators=(",", ":")).encode("utf-8")
        self.send_response(status.value)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)


class WatchBridgeServer(ThreadingHTTPServer):
    def __init__(self, config: BridgeConfig) -> None:
        super().__init__((config.host, config.port), WatchBridgeHandler)
        self.transcript_store = TranscriptStore(config.orca_root)
        self.bridge_token = config.token


def run(config: BridgeConfig) -> None:
    server = WatchBridgeServer(config)
    print(f"Orca Watch Bridge listening on http://127.0.0.1:{config.port}")
    print(f"Orca root: {config.orca_root}")
    print(f"Token: {config.token}")
    print(
        "Apple Watch Shortcut: Dictate Text -> Get Contents of URL -> "
        f"POST http://<mac-ip>:{config.port}/transcripts?token={config.token}"
    )
    server.serve_forever()


def main() -> None:
    run(BridgeConfig.from_environment())


if __name__ == "__main__":
    main()
