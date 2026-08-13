#!/usr/bin/env python3

import argparse
import json
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

CONTENT_KEYS = ("content", "rawContent", "body", "message", "text")


@dataclass(frozen=True)
class PlainTopic:
    topic_id: str
    title: str
    body: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Render one or more Kaggle topics-show JSON pages as raw Markdown."
    )
    parser.add_argument("inputs", nargs="*", type=Path, help="JSON page files; stdin when omitted")
    parser.add_argument("--competition", required=True)
    parser.add_argument("--topic-ref", required=True)
    parser.add_argument("--source-url", default="")
    parser.add_argument("--team", default="")
    parser.add_argument("--rank", type=int)
    parser.add_argument("--medal-band", choices=("gold", "silver-upper"))
    parser.add_argument("--retrieval-method", default="Kaggle CLI via uv")
    parser.add_argument("--retrieved-at", default="")
    parser.add_argument(
        "--topic-text-input",
        type=Path,
        help=(
            "Plain-text output from `competitions topics show` without `--format json`. "
            "Kaggle CLI JSON omits the original topic body."
        ),
    )
    parser.add_argument(
        "--topic-html-input",
        type=Path,
        help=(
            "Original HTML body returned by the Kaggle CLI package API. "
            "When supplied, this is preserved instead of the CLI plain-text rendering."
        ),
    )
    parser.add_argument(
        "--allow-missing-body",
        action="store_true",
        help="Record an unavailable body only after the non-JSON retrieval path was attempted.",
    )
    parser.add_argument("--output", type=Path)
    return parser.parse_args()


def load_leading_json(text: str, source: str) -> tuple[dict[str, Any], list[str]]:
    stripped = text.lstrip()
    try:
        value, end = json.JSONDecoder().raw_decode(stripped)
    except json.JSONDecodeError as exc:
        raise SystemExit(f"Invalid Kaggle JSON in {source}: {exc}") from exc
    if not isinstance(value, dict):
        raise SystemExit(f"Expected a JSON object from topics show in {source}")
    trailing = [line.strip() for line in stripped[end:].splitlines() if line.strip()]
    return value, trailing


def first_content(item: dict[str, Any]) -> str | None:
    for key in CONTENT_KEYS:
        value = item.get(key)
        if isinstance(value, str) and value:
            return value
    return None


def parse_plain_topic(text: str, source: str) -> PlainTopic:
    header = re.match(
        r"\A(?:Kaggle CLI[^\n]*\n)?Topic #(?P<id>\d+): (?P<title>[^\n]+)\n"
        r"  Author:[^\n]*\n"
        r"  Posted:[^\n]*\n"
        r"  Votes:[^\n]*\n\n",
        text,
    )
    if header is None:
        raise SystemExit(
            f"Invalid plain Kaggle topic output in {source}: expected the Topic/Author/Posted/Votes header"
        )

    body_and_comments = text[header.end() :]
    comments_marker = "\nComments:\n"
    if comments_marker in body_and_comments:
        body, _, _ = body_and_comments.rpartition(comments_marker)
    else:
        body = body_and_comments
    body = body.rstrip("\n")
    if not body.strip():
        raise SystemExit(f"Plain Kaggle topic output in {source} did not contain an original body")

    return PlainTopic(
        topic_id=header.group("id"),
        title=header.group("title"),
        body=body,
    )


def flatten_comments(items: list[Any]) -> list[dict[str, Any]]:
    result: list[dict[str, Any]] = []
    for value in items:
        if not isinstance(value, dict):
            continue
        result.append(value)
        for key in ("replies", "children", "comments"):
            nested = value.get(key)
            if isinstance(nested, list):
                result.extend(flatten_comments(nested))
    return result


def yaml_string(value: str) -> str:
    return json.dumps(value, ensure_ascii=False)


def comment_id(comment: dict[str, Any], index: int) -> str:
    value = comment.get("id")
    return str(value) if value is not None else f"unknown-{index}"


def metadata_line(label: str, value: Any) -> str:
    shown = "" if value is None else str(value)
    return f"- {label}: {shown}"


def render(
    args: argparse.Namespace,
    pages: list[dict[str, Any]],
    trailing: list[str],
    plain_topic: PlainTopic | None,
) -> str:
    topic: dict[str, Any] = {}
    comments: list[dict[str, Any]] = []
    seen_ids: set[str] = set()
    for page in pages:
        candidate = page.get("topic")
        if isinstance(candidate, dict):
            topic.update(candidate)
        page_comments = page.get("comments")
        if not isinstance(page_comments, list):
            continue
        for index, comment in enumerate(flatten_comments(page_comments), start=1):
            cid = comment_id(comment, index)
            if cid in seen_ids:
                continue
            seen_ids.add(cid)
            comments.append(comment)

    retrieved_at = args.retrieved_at or datetime.now(timezone.utc).isoformat()
    html_body = None
    if args.topic_html_input is not None:
        html_body = args.topic_html_input.read_text(encoding="utf-8")
        if not html_body.strip():
            raise SystemExit(f"HTML body input is empty: {args.topic_html_input}")
    body = html_body or (plain_topic.body if plain_topic is not None else first_content(topic))
    expected_topic_id = args.topic_ref.rsplit("/", maxsplit=1)[-1]
    if plain_topic is not None and plain_topic.topic_id != expected_topic_id:
        raise SystemExit(
            "Topic mismatch: "
            f"--topic-ref identifies {expected_topic_id}, but plain output contains {plain_topic.topic_id}"
        )
    if body is None and not args.allow_missing_body:
        raise SystemExit(
            "The Kaggle JSON response omitted the original topic body. "
            "Run `competitions topics show` again without `--format json` and pass that output "
            "with --topic-text-input. Use --allow-missing-body only after that retrieval path fails."
        )
    body_status = "retrieved" if body is not None else "unavailable"
    title = str(topic.get("title") or (plain_topic.title if plain_topic is not None else args.topic_ref))
    source_format = (
        "kaggle-cli-package-html-body-and-json-comments"
        if html_body is not None
        else "kaggle-cli-plain-text-body-and-json-comments"
    )
    lines = [
        "---",
        f"competition: {yaml_string(args.competition)}",
        f"final_rank: {args.rank if args.rank is not None else 'null'}",
        f"medal_band: {yaml_string(args.medal_band or '')}",
        f"team: {yaml_string(args.team)}",
        "topic_refs:",
        f"  - {yaml_string(args.topic_ref)}",
        f"retrieved_at: {yaml_string(retrieved_at)}",
        f"retrieval_method: {yaml_string(args.retrieval_method)}",
        f"source_format: {yaml_string(source_format)}",
        f"body_status: {yaml_string(body_status)}",
        f"comments_status: {yaml_string('retrieved-pages')}",
        "---",
        "",
        f"# Raw solution: {title}",
        "",
        "## Provenance",
        "",
        metadata_line("Topic ref", args.topic_ref),
        metadata_line("Official URL", args.source_url),
        metadata_line("Topic ID", topic.get("id")),
        metadata_line("Author", topic.get("authorName")),
        metadata_line("Posted", topic.get("postDate")),
        metadata_line("Votes", topic.get("votes")),
        metadata_line("Reported comment count", topic.get("commentCount")),
        metadata_line("Retrieved comment records", len(comments)),
        metadata_line("Retrieval method", args.retrieval_method),
        "",
        "## Original post",
        "",
    ]
    if body is None:
        lines.append("Not retrieved. The source response contained topic metadata but no original post body.")
    else:
        lines.extend(
            [
                "<!-- Verbatim source content begins. -->",
                body,
                "<!-- Verbatim source content ends. -->",
            ]
        )

    lines.extend(["", "## Comments", ""])
    if not comments:
        lines.append("No comments were returned in the supplied pages.")
    for index, comment in enumerate(comments, start=1):
        cid = comment_id(comment, index)
        parent = comment.get("parentId", comment.get("parent_id", ""))
        content = first_content(comment)
        lines.extend(
            [
                f"### Comment {cid}",
                "",
                metadata_line("Author", comment.get("authorName", comment.get("author"))),
                metadata_line("Posted", comment.get("postDate", comment.get("date"))),
                metadata_line("Votes", comment.get("votes")),
                metadata_line("Parent ID", parent),
                "",
            ]
        )
        if content is None:
            lines.append("Content was not present in the source response.")
        else:
            lines.extend(
                [
                    "<!-- Verbatim source content begins. -->",
                    content,
                    "<!-- Verbatim source content ends. -->",
                ]
            )
        lines.append("")

    next_tokens = []
    for item in trailing:
        match = re.match(r"Next Page Token\s*=\s*(.+)", item, flags=re.IGNORECASE)
        if match:
            next_tokens.append(match.group(1).strip())
    lines.extend(
        [
            "## Retrieval limitations",
            "",
            f"- Original post body: {body_status}",
            f"- Supplied JSON pages: {len(pages)}",
            f"- Plain-text topic output supplied: {'yes' if plain_topic is not None else 'no'}",
            f"- HTML topic body supplied: {'yes' if html_body is not None else 'no'}",
            f"- Trailing next-page tokens: {', '.join(next_tokens) if next_tokens else 'none observed'}",
        ]
    )
    if trailing:
        lines.append(f"- Other trailing CLI lines: {yaml_string(' | '.join(trailing))}")
    lines.extend(
        [
            "",
            "## Search log",
            "",
            "| time | method | query/ref | result |",
            "|---|---|---|---|",
            f"| {retrieved_at} | {args.retrieval_method} | {args.topic_ref} | supplied pages: {len(pages)} |",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    texts: list[tuple[str, str]] = []
    if args.inputs:
        for path in args.inputs:
            texts.append((str(path), path.read_text(encoding="utf-8")))
    else:
        texts.append(("stdin", sys.stdin.read()))

    pages: list[dict[str, Any]] = []
    trailing: list[str] = []
    for source, text in texts:
        page, extra = load_leading_json(text, source)
        pages.append(page)
        trailing.extend(extra)

    plain_topic = None
    if args.topic_text_input is not None:
        plain_topic = parse_plain_topic(
            args.topic_text_input.read_text(encoding="utf-8"),
            str(args.topic_text_input),
        )

    output = render(args, pages, trailing, plain_topic)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(output, encoding="utf-8")
    else:
        sys.stdout.write(output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
