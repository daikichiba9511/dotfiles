#!/usr/bin/env python3

import argparse
import re
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class RawTopicFile:
    path: Path
    frontmatter: str
    document: str
    topic_refs: tuple[str, ...]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Combine separately retrieved topics into one team-level raw Markdown file."
    )
    parser.add_argument("primary", type=Path)
    parser.add_argument("additional", nargs="+", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    return parser.parse_args()


def load_raw_topic(path: Path) -> RawTopicFile:
    text = path.read_text(encoding="utf-8")
    match = re.match(r"\A---\n(?P<frontmatter>.*?)\n---\n\n(?P<document>.*)\Z", text, re.DOTALL)
    if match is None:
        raise SystemExit(f"Raw topic file does not have the expected frontmatter: {path}")
    frontmatter = match.group("frontmatter")
    topic_refs = tuple(
        re.findall(r'^  - "([^"]+)"$', frontmatter, flags=re.MULTILINE)
    )
    if not topic_refs:
        raise SystemExit(f"Raw topic file does not contain topic_refs: {path}")
    return RawTopicFile(
        path=path,
        frontmatter=frontmatter,
        document=match.group("document"),
        topic_refs=topic_refs,
    )


def replace_topic_refs(frontmatter: str, topic_refs: tuple[str, ...]) -> str:
    replacement = "topic_refs:\n" + "\n".join(f'  - "{topic_ref}"' for topic_ref in topic_refs)
    updated, count = re.subn(
        r"topic_refs:\n(?:  - .*\n?)+",
        replacement + "\n",
        frontmatter,
        count=1,
    )
    if count != 1:
        raise SystemExit("Could not replace topic_refs in primary frontmatter")
    return updated.rstrip("\n")


def demote_document_title(document: str, index: int) -> str:
    updated, count = re.subn(
        r"\A# Raw solution: (.+)$",
        rf"# Additional raw solution topic {index}: \1",
        document,
        count=1,
        flags=re.MULTILINE,
    )
    if count != 1:
        raise SystemExit("Additional raw topic is missing its document title")
    return updated


def main() -> int:
    args = parse_args()
    primary = load_raw_topic(args.primary)
    additional = tuple(load_raw_topic(path) for path in args.additional)
    topic_refs = tuple(
        dict.fromkeys(topic_ref for item in (primary, *additional) for topic_ref in item.topic_refs)
    )
    frontmatter = replace_topic_refs(primary.frontmatter, topic_refs)
    sections = [primary.document.rstrip("\n")]
    for index, topic in enumerate(additional, start=2):
        sections.append(demote_document_title(topic.document.rstrip("\n"), index))

    output = f"---\n{frontmatter}\n---\n\n" + "\n\n<hr>\n\n".join(sections) + "\n"
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(output, encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
