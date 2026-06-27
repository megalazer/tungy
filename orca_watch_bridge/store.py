from __future__ import annotations

from dataclasses import dataclass, replace
from datetime import datetime, timezone
from pathlib import Path
from re import fullmatch
from typing import Optional
from uuid import UUID, uuid4
import json


class TranscriptStoreError(ValueError):
    """Raised when a transcript cannot be stored safely."""


@dataclass(frozen=True)
class TranscriptRecord:
    text: str
    project: Optional[str] = None
    source: str = "apple-watch"
    created_at: Optional[datetime] = None
    id: Optional[UUID] = None

    def normalized(self) -> "TranscriptRecord":
        text = normalize_transcript(self.text)
        if not text:
            raise TranscriptStoreError("empty transcript")
        project = validate_project_name(self.project) if self.project is not None else None
        source = self.source.strip() or "apple-watch"
        created_at = self.created_at or datetime.now(timezone.utc)
        record_id = self.id or uuid4()
        return replace(self, text=text, project=project, source=source, created_at=created_at, id=record_id)


@dataclass(frozen=True)
class StoredTranscript:
    record: TranscriptRecord
    log_path: Path
    latest_path: Path


class TranscriptStore:
    def __init__(self, orca_root: Path) -> None:
        self.orca_root = orca_root.expanduser().resolve()

    def save(self, record: TranscriptRecord) -> StoredTranscript:
        normalized = record.normalized()
        directory = self._transcript_directory(normalized.project)
        directory.mkdir(parents=True, exist_ok=True)

        log_path = directory / "watch-transcripts.jsonl"
        latest_path = directory / "watch-latest.txt"
        with log_path.open("a", encoding="utf-8") as log_file:
            log_file.write(json.dumps(_record_to_json(normalized), sort_keys=True, separators=(",", ":")))
            log_file.write("\n")

        latest_path.write_text(_latest_text(normalized), encoding="utf-8")
        return StoredTranscript(record=normalized, log_path=log_path, latest_path=latest_path)

    def available_projects(self) -> list:
        names = set()
        for root in (self.orca_root / "projects", self.orca_root / "workspaces"):
            if not root.is_dir():
                continue
            for child in root.iterdir():
                if child.is_dir() and not child.name.startswith("."):
                    names.add(child.name)
        return sorted(names)

    def _transcript_directory(self, project: Optional[str]) -> Path:
        if project is None:
            return self.orca_root / "watch-transcripts" / "inbox"

        for root_name in ("projects", "workspaces"):
            project_root = self.orca_root / root_name / project
            if project_root.is_dir():
                return project_root / ".orca" / "watch"

        return self.orca_root / "watch-transcripts" / project


def normalize_transcript(text: str) -> str:
    lines = (line.strip() for line in text.splitlines())
    return "\n".join(line for line in lines if line).strip()


def validate_project_name(project: Optional[str]) -> Optional[str]:
    if project is None:
        return None
    value = project.strip()
    if not value:
        return None
    if ".." in value or "/" in value or "\\" in value or not fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]{0,79}", value):
        raise TranscriptStoreError(f"invalid project name: {project}")
    return value


def _record_to_json(record: TranscriptRecord) -> dict:
    assert record.id is not None
    assert record.created_at is not None
    return {
        "id": str(record.id),
        "created_at": record.created_at.astimezone(timezone.utc).isoformat().replace("+00:00", "Z"),
        "source": record.source,
        "project": record.project or "inbox",
        "text": record.text,
    }


def _latest_text(record: TranscriptRecord) -> str:
    data = _record_to_json(record)
    return f"Source: {data['source']}\nProject: {data['project']}\nCreated: {data['created_at']}\n\n{data['text']}\n"
