#!/usr/bin/env python3
from __future__ import annotations

import argparse
import colorsys
import csv
import re
from pathlib import Path


REQUIRED_COVERAGE_COLUMNS = {
    "rank",
    "team",
    "team_slug",
    "medal_band",
    "gold_group",
    "selected",
    "topic_refs",
    "raw_path",
    "summary_path",
    "status",
    "evidence_limit",
}
REQUIRED_SUMMARY_HEADINGS = (
    "## 概要",
    "## Solutionの全体像",
    "## Solutionのポイント",
    "## 理解を深めるための解説",
    "## 検証・評価・再現性",
    "## 根拠と不確実性",
    "## 参照",
)
REQUIRED_FILES = (
    "scope/scope.md",
    "scope/coverage.csv",
    "sources/competition.md",
    "sources/leaderboard.csv",
    "sources/evidence-ledger.md",
    "synthesis/comparison-matrix.md",
    "synthesis/common-elements.md",
    "synthesis/differentiators.md",
    "synthesis/task-grounded-analysis.md",
    "synthesis/strategy-retrospective.md",
    "report/main.typ",
    "slides/slides.typ",
)
LATEX_ONLY_PATTERN = re.compile(
    r"\\(?:[()[\]{}]|begin\b|end\b|frac\b|sum\b|prod\b|int\b|"
    r"mathrm\b|mathbf\b|mathit\b|text\b|hat\b|bar\b|tilde\b|vec\b|"
    r"lceil\b|rceil\b|lfloor\b|rfloor\b|left\b|right\b|ln\b|log\b|"
    r"exp\b|in\b|notin\b|mid\b|cdot\b|times\b|leq\b|geq\b|neq\b|"
    r"approx\b|dots\b)"
)
HEX_COLOR_PATTERN = re.compile(r'rgb\(\s*["\']#([0-9a-fA-F]{6})["\']\s*\)')


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate a Kaggle solution-report workspace.")
    parser.add_argument("workspace", type=Path)
    parser.add_argument("--require-pdf", action="store_true")
    return parser.parse_args()


def safe_path(workspace: Path, relative: str) -> Path | None:
    candidate = (workspace / relative).resolve()
    try:
        candidate.relative_to(workspace)
    except ValueError:
        return None
    return candidate


def nonempty(path: Path) -> bool:
    return path.is_file() and path.stat().st_size > 0


def validate_typst_math(workspace: Path, errors: list[str]) -> None:
    for root_name in ("report", "slides"):
        root = workspace / root_name
        if not root.is_dir():
            continue
        for path in sorted(root.rglob("*.typ")):
            relative = path.relative_to(workspace)
            for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
                match = LATEX_ONLY_PATTERN.search(line)
                if match:
                    errors.append(
                        f"{relative}:{line_number}: LaTeX-only syntax {match.group(0)!r}; "
                        "rewrite with native Typst math"
                    )


def validate_slide_palette(workspace: Path, errors: list[str]) -> None:
    slides_root = workspace / "slides"
    if not slides_root.is_dir():
        return

    saturated_colors: set[str] = set()
    for path in sorted(slides_root.rglob("*.typ")):
        text = path.read_text(encoding="utf-8")
        for match in HEX_COLOR_PATTERN.finditer(text):
            hex_color = match.group(1).lower()
            red = int(hex_color[0:2], 16) / 255
            green = int(hex_color[2:4], 16) / 255
            blue = int(hex_color[4:6], 16) / 255
            _, lightness, saturation = colorsys.rgb_to_hls(red, green, blue)
            if saturation >= 0.45 and 0.15 <= lightness <= 0.85:
                saturated_colors.add(f"#{hex_color}")

    if len(saturated_colors) > 2:
        colors = ", ".join(sorted(saturated_colors))
        errors.append(
            f"slides use {len(saturated_colors)} saturated colors ({colors}); "
            "use one primary accent and at most one alert color"
        )


def main() -> int:
    args = parse_args()
    workspace = args.workspace.expanduser().resolve()
    errors: list[str] = []

    if not workspace.is_dir():
        raise SystemExit(f"Workspace does not exist: {workspace}")

    for relative in REQUIRED_FILES:
        path = workspace / relative
        if not nonempty(path):
            errors.append(f"missing or empty required file: {relative}")

    validate_typst_math(workspace, errors)
    validate_slide_palette(workspace, errors)

    coverage_path = workspace / "scope/coverage.csv"
    rows: list[dict[str, str]] = []
    if nonempty(coverage_path):
        with coverage_path.open(newline="", encoding="utf-8") as handle:
            reader = csv.DictReader(handle)
            columns = set(reader.fieldnames or [])
            missing = REQUIRED_COVERAGE_COLUMNS - columns
            if missing:
                errors.append(f"coverage.csv missing columns: {', '.join(sorted(missing))}")
            rows = list(reader)

    selected_rows = [row for row in rows if row.get("selected", "").lower() == "true"]
    if not selected_rows:
        errors.append("coverage.csv has no selected rows")

    seen_rows: set[tuple[int, str]] = set()
    counts = {"complete": 0, "partial": 0, "unavailable": 0, "pending": 0}
    for line_number, row in enumerate(rows, start=2):
        if row.get("selected", "").lower() != "true":
            continue
        try:
            rank = int(row.get("rank", ""))
            if rank <= 0:
                raise ValueError
        except ValueError:
            errors.append(f"coverage.csv:{line_number}: rank must be a positive integer")
            continue
        slug = row.get("team_slug", "")
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", slug):
            errors.append(f"coverage.csv:{line_number}: invalid team_slug {slug!r}")
        row_key = (rank, slug)
        if row_key in seen_rows:
            errors.append(f"coverage.csv:{line_number}: duplicate selected rank/team {rank}/{slug}")
        seen_rows.add(row_key)
        medal = row.get("medal_band", "")
        if medal not in {"gold", "silver-upper"}:
            errors.append(f"coverage.csv:{line_number}: invalid medal_band {medal!r}")
        gold_group = row.get("gold_group", "")
        if medal == "gold" and gold_group not in {"top", "lower"}:
            errors.append(f"coverage.csv:{line_number}: gold row needs gold_group top or lower")
        if medal == "silver-upper" and gold_group:
            errors.append(f"coverage.csv:{line_number}: silver row must have empty gold_group")

        status = row.get("status", "")
        if status not in counts:
            errors.append(f"coverage.csv:{line_number}: invalid status {status!r}")
        else:
            counts[status] += 1
        if status == "pending":
            errors.append(f"coverage.csv:{line_number}: selected row is still pending")
        if status in {"partial", "unavailable"} and not row.get("evidence_limit", "").strip():
            errors.append(f"coverage.csv:{line_number}: {status} row needs evidence_limit")

        raw_relative = row.get("raw_path", "")
        summary_relative = row.get("summary_path", "")
        raw_path = safe_path(workspace, raw_relative)
        summary_path = safe_path(workspace, summary_relative)
        if raw_path is None or not nonempty(raw_path):
            errors.append(f"coverage.csv:{line_number}: missing/unsafe raw_path {raw_relative!r}")
        if summary_path is None or not nonempty(summary_path):
            errors.append(f"coverage.csv:{line_number}: missing/unsafe summary_path {summary_relative!r}")
        if raw_path is not None and nonempty(raw_path):
            raw_text = raw_path.read_text(encoding="utf-8")
            for heading in ("## Original post", "## Comments", "## Retrieval limitations", "## Search log"):
                if heading not in raw_text:
                    errors.append(f"{raw_relative}: missing heading {heading!r}")
        if summary_path is not None and nonempty(summary_path):
            summary_text = summary_path.read_text(encoding="utf-8")
            for heading in REQUIRED_SUMMARY_HEADINGS:
                if heading not in summary_text:
                    errors.append(f"{summary_relative}: missing heading {heading!r}")

    report_text = (workspace / "report/main.typ").read_text(encoding="utf-8") if nonempty(workspace / "report/main.typ") else ""
    if "outline(" not in report_text:
        errors.append("report/main.typ must contain an outline")
    if "counter(page).final()" not in report_text:
        errors.append("report/main.typ must show total-aware page numbering")

    slides_text = (workspace / "slides/slides.typ").read_text(encoding="utf-8") if nonempty(workspace / "slides/slides.typ") else ""
    for token in ("@preview/polylux:0.4.0", "@preview/metropolis-polylux:0.1.0"):
        if token not in slides_text:
            errors.append(f"slides/slides.typ missing {token}")
    if '#import "theme.typ"' not in slides_text:
        errors.append('slides/slides.typ must import the bundled "theme.typ" design system')

    if args.require_pdf:
        for relative in ("report/report.pdf", "slides/slides.pdf"):
            if not nonempty(workspace / relative):
                errors.append(f"missing final PDF: {relative}")

    if errors:
        print("validation failed")
        for error in errors:
            print(f"- {error}")
        return 1

    print(
        "validation ok: "
        f"selected={len(selected_rows)} "
        f"complete={counts['complete']} partial={counts['partial']} unavailable={counts['unavailable']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
