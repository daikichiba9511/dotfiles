#!/usr/bin/env python3
import argparse
import shutil
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Initialize a topic-learning-slides workspace from the bundled template."
    )
    parser.add_argument("workspace", type=Path)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    workspace = args.workspace.expanduser().resolve()
    if workspace.exists() and any(workspace.iterdir()):
        raise SystemExit(f"Refusing to overwrite non-empty destination: {workspace}")

    template = Path(__file__).resolve().parent.parent / "assets" / "workspace-template"
    if not template.is_dir():
        raise SystemExit(f"Bundled workspace template is missing: {template}")

    if workspace.exists():
        shutil.copytree(template, workspace, dirs_exist_ok=True)
    else:
        shutil.copytree(template, workspace)
    print(workspace)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
