from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
from tempfile import TemporaryDirectory
from urllib.error import HTTPError
from urllib.request import Request, urlopen
from uuid import UUID
import json
import threading
import unittest

from orca_watch_bridge.server import BridgeConfig, WatchBridgeServer
from orca_watch_bridge.store import TranscriptRecord, TranscriptStore, TranscriptStoreError, normalize_transcript, validate_project_name


class TranscriptStoreTests(unittest.TestCase):
    def test_normalize_transcript_trims_and_removes_blank_lines(self) -> None:
        self.assertEqual(normalize_transcript("  ship PR  \n\n\tadd tests\n"), "ship PR\nadd tests")

    def test_validate_project_name_rejects_traversal(self) -> None:
        with self.assertRaises(TranscriptStoreError):
            validate_project_name("../orca")
        with self.assertRaises(TranscriptStoreError):
            validate_project_name("bad/name")

    def test_save_writes_project_scoped_jsonl_and_latest_transcript(self) -> None:
        with TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            project_root = root / "projects" / "tungy"
            project_root.mkdir(parents=True)
            store = TranscriptStore(root)

            stored = store.save(
                TranscriptRecord(
                    id=UUID("aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"),
                    created_at=datetime(2027, 1, 15, tzinfo=timezone.utc),
                    source="apple-watch-shortcut",
                    project="tungy",
                    text="  summarize login bug  ",
                )
            )

            self.assertEqual(stored.log_path, project_root / ".orca" / "watch" / "watch-transcripts.jsonl")
            line = stored.log_path.read_text(encoding="utf-8")
            self.assertIn('"project":"tungy"', line)
            self.assertIn('"text":"summarize login bug"', line)
            latest = stored.latest_path.read_text(encoding="utf-8")
            self.assertIn("Project: tungy", latest)
            self.assertIn("summarize login bug", latest)

    def test_unknown_project_uses_global_transcript_directory(self) -> None:
        with TemporaryDirectory() as directory:
            root = Path(directory).resolve()
            store = TranscriptStore(root)

            stored = store.save(TranscriptRecord(project="new-project", text="create note"))

            self.assertEqual(stored.log_path, root / "watch-transcripts" / "new-project" / "watch-transcripts.jsonl")

    def test_available_projects_combines_projects_and_workspaces(self) -> None:
        with TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "projects" / "tungy").mkdir(parents=True)
            (root / "workspaces" / "orca-ade").mkdir(parents=True)

            self.assertEqual(TranscriptStore(root).available_projects(), ["orca-ade", "tungy"])


class WatchBridgeServerTests(unittest.TestCase):
    def test_post_transcript_requires_token_and_writes_record(self) -> None:
        with TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "projects" / "tungy").mkdir(parents=True)
            server = WatchBridgeServer(BridgeConfig(orca_root=root, token="secret", host="127.0.0.1", port=0))
            thread = threading.Thread(target=server.serve_forever, daemon=True)
            thread.start()
            try:
                port = server.server_address[1]
                body = json.dumps({"text": "  check build logs  ", "project": "tungy"}).encode("utf-8")

                denied = Request(
                    f"http://127.0.0.1:{port}/transcripts",
                    data=body,
                    headers={"Content-Type": "application/json"},
                    method="POST",
                )
                with self.assertRaises(HTTPError) as denied_error:
                    urlopen(denied, timeout=5)
                self.assertEqual(denied_error.exception.code, 401)

                allowed = Request(
                    f"http://127.0.0.1:{port}/transcripts?token=secret",
                    data=body,
                    headers={"Content-Type": "application/json"},
                    method="POST",
                )
                with urlopen(allowed, timeout=5) as response:
                    self.assertEqual(response.status, 201)
                    payload = json.loads(response.read().decode("utf-8"))

                self.assertEqual(payload["project"], "tungy")
                latest = root / "projects" / "tungy" / ".orca" / "watch" / "watch-latest.txt"
                self.assertIn("check build logs", latest.read_text(encoding="utf-8"))
            finally:
                server.shutdown()
                server.server_close()
                thread.join(timeout=5)


if __name__ == "__main__":
    unittest.main()
