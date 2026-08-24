#!/usr/bin/env python3
import argparse
import hashlib
from pathlib import Path


def digest_artifacts(workspace: Path, artifact_field: str) -> str:
    digest = hashlib.sha256()
    for relative in (item.strip() for item in artifact_field.split(";")):
        if not relative:
            continue
        path = (workspace / relative).resolve()
        try:
            path.relative_to(workspace)
        except ValueError as error:
            raise SystemExit(f"Unsafe artifact path: {relative}") from error
        if not path.is_file():
            raise SystemExit(f"Artifact is missing or not a file: {relative}")
        digest.update(relative.encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Hash checkpoint artifacts in recorded order.")
    parser.add_argument("workspace", type=Path)
    parser.add_argument("artifacts", help="Semicolon-separated workspace-relative files")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    workspace = args.workspace.expanduser().resolve()
    if not workspace.is_dir():
        raise SystemExit(f"Workspace does not exist: {workspace}")
    print(digest_artifacts(workspace, args.artifacts))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
