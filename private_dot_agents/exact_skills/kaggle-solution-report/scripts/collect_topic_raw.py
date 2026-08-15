#!/usr/bin/env python3

import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Retrieve one Kaggle discussion topic through both CLI representations and "
            "render an evidence-preserving raw Markdown file."
        )
    )
    parser.add_argument("--competition", required=True)
    parser.add_argument("--topic-id", required=True)
    parser.add_argument("--team", required=True)
    parser.add_argument("--rank", required=True, type=int)
    parser.add_argument("--medal-band", required=True, choices=("gold", "silver-upper"))
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--page-size", type=int, default=200)
    return parser.parse_args()


def kaggle_wrapper() -> Path:
    scripts_dir = Path(__file__).resolve().parent
    for name in ("kaggle_uv", "executable_kaggle_uv"):
        candidate = scripts_dir / name
        if candidate.is_file():
            return candidate
    raise SystemExit(f"Kaggle uv wrapper was not found under {scripts_dir}")


def run_text(command: list[str]) -> str:
    completed = subprocess.run(
        command,
        check=True,
        capture_output=True,
        text=True,
    )
    return completed.stdout


def next_page_token(text: str) -> str | None:
    stripped = text.lstrip()
    try:
        _, end = json.JSONDecoder().raw_decode(stripped)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Kaggle CLI returned invalid JSON: {exc}") from exc

    trailing = stripped[end:]
    match = re.search(r"^Next Page Token\s*=\s*(.+)$", trailing, flags=re.MULTILINE)
    return match.group(1).strip() if match is not None else None


def collect_json_pages(
    wrapper: Path,
    topic_ref: str,
    page_size: int,
) -> list[str]:
    pages: list[str] = []
    page_token = None
    while True:
        command = [
            str(wrapper),
            "competitions",
            "topics",
            "show",
            topic_ref,
            "--page-size",
            str(page_size),
            "--format",
            "json",
            "--quiet",
        ]
        if page_token is not None:
            command.extend(("--page-token", page_token))
        page = run_text(command)
        pages.append(page)
        page_token = next_page_token(page)
        if page_token is None:
            return pages


def main() -> int:
    args = parse_args()
    wrapper = kaggle_wrapper()
    topic_ref = f"{args.competition}/{args.topic_id}"
    source_url = (
        f"https://www.kaggle.com/competitions/{args.competition}/discussion/{args.topic_id}"
    )
    version = run_text([str(wrapper), "--version"]).strip()
    version_number_match = re.search(r"(\d+\.\d+\.\d+)", version)
    if version_number_match is None:
        raise SystemExit(f"Could not parse Kaggle CLI version from: {version}")
    version_number = version_number_match.group(1)
    retrieval_method = (
        f"{version} via uv; package HTML body, plain verification, and JSON metadata/comments"
    )

    plain_output = run_text(
        [
            str(wrapper),
            "competitions",
            "topics",
            "show",
            topic_ref,
            "--page-size",
            str(args.page_size),
            "--quiet",
        ]
    )
    deleted_topic = bool(
        re.search(r"^Topic\s+#\d+:\s+\[Deleted Topic\]\s*$", plain_output, flags=re.MULTILINE)
    )
    json_pages = collect_json_pages(wrapper, topic_ref, args.page_size)
    body_fetcher = Path(__file__).resolve().with_name("fetch_topic_body.py")
    try:
        html_output = run_text(
            [
                "uv",
                "run",
                "--python",
                "3.12",
                "--with",
                f"kaggle=={version_number}",
                "python",
                str(body_fetcher),
                "--topic-id",
                args.topic_id,
            ]
        )
    except subprocess.CalledProcessError:
        html_output = None
        if deleted_topic:
            retrieval_method = (
                f"{version} via uv; original post deleted, "
                "JSON metadata/comments preserved"
            )
        else:
            retrieval_method = (
                f"{version} via uv; package HTML body unavailable, "
                "plain body and JSON metadata/comments preserved"
            )

    renderer = Path(__file__).resolve().with_name("render_topic_raw.py")
    with tempfile.TemporaryDirectory(prefix="kaggle-topic-") as temporary_directory:
        temporary = Path(temporary_directory)
        plain_path = temporary / "topic.txt"
        plain_path.write_text(plain_output, encoding="utf-8")
        html_path = temporary / "topic.html"
        if html_output is not None:
            html_path.write_text(html_output, encoding="utf-8")
        json_paths: list[Path] = []
        for index, page in enumerate(json_pages, start=1):
            page_path = temporary / f"comments-{index:03d}.json"
            page_path.write_text(page, encoding="utf-8")
            json_paths.append(page_path)

        command = [
            sys.executable,
            str(renderer),
            *(str(path) for path in json_paths),
            "--competition",
            args.competition,
            "--topic-ref",
            topic_ref,
            "--source-url",
            source_url,
            "--team",
            args.team,
            "--rank",
            str(args.rank),
            "--medal-band",
            args.medal_band,
            "--retrieval-method",
            retrieval_method,
            "--output",
            str(args.output),
        ]
        if not deleted_topic:
            command.extend(("--topic-text-input", str(plain_path)))
        else:
            command.append("--allow-missing-body")
        if html_output is not None:
            command.extend(("--topic-html-input", str(html_path)))
        subprocess.run(command, check=True)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
