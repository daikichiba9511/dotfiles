#!/usr/bin/env python3
import argparse
import shutil
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Initialize a Kaggle solution-report workspace from the bundled template."
    )
    parser.add_argument("--competition", required=True, help="Kaggle competition slug")
    parser.add_argument("--title", required=True, help="Human-readable competition title")
    parser.add_argument("--output", required=True, type=Path, help="New workspace directory")
    return parser.parse_args()


def replace_tokens(root: Path, competition: str, title: str) -> None:
    replacements = {
        "{{COMPETITION_SLUG}}": competition,
        "{{COMPETITION_TITLE}}": title,
    }
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8")
        for old, new in replacements.items():
            text = text.replace(old, new)
        path.write_text(text, encoding="utf-8")


def main() -> int:
    args = parse_args()
    output = args.output.expanduser().resolve()
    if output.exists():
        raise SystemExit(f"Refusing to overwrite existing path: {output}")

    template = Path(__file__).resolve().parent.parent / "assets" / "workspace-template"
    if not template.is_dir():
        raise SystemExit(f"Bundled workspace template is missing: {template}")

    shutil.copytree(template, output)
    for relative in (
        "sources/discussions",
        "solutions",
        "figures",
        "code",
        "reviews",
    ):
        (output / relative).mkdir(parents=True, exist_ok=True)
    replace_tokens(output, args.competition, args.title)
    print(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
