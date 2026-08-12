#!/usr/bin/env python3
import argparse
import colorsys
import csv
import json
import re
import shutil
import subprocess
from collections import Counter
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
    "method_status",
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
    "reviews/release-review.md",
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
FRONTMATTER_PATTERN = re.compile(r"\A---\s*\n(?P<body>.*?)\n---\s*\n", re.DOTALL)
TYPST_CONTROL_FLOW_PATTERN = re.compile(r"#\s*(?:if|for|while)\b")
SEARCH_COMPLETION_ITEMS = (
    "- [x] All selected Kaggle topic orderings and result pages were exhausted.",
    "- [x] The exact team name and every known member handle were searched.",
    "- [x] Rank/medal phrases and solution/write-up synonyms were searched.",
    "- [x] Linked artifacts and cross-forum candidates were checked.",
)
RELEASE_REVIEW_ITEMS = (
    "- [x] Evidence and technical accuracy review has no unresolved high/medium finding.",
    "- [x] Japanese terminology and explanation review has no unresolved high/medium finding.",
    "- [x] Rendered geometry review has no unresolved high/medium finding.",
    "- [x] Report/slide parity review has no unresolved high/medium finding.",
    "- [x] Validation, compilation, and full rerender passed after the final accepted correction.",
)


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
    for path in sorted(workspace.rglob("*.typ")):
        relative = path.relative_to(workspace)
        for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            match = LATEX_ONLY_PATTERN.search(line)
            if match:
                errors.append(
                    f"{relative}:{line_number}: LaTeX-only syntax {match.group(0)!r}; "
                    "rewrite with native Typst math"
                )


def validate_slide_palette(workspace: Path, errors: list[str]) -> None:
    saturated_colors: set[str] = set()
    for root_name in ("slides", "figures", "diagrams"):
        root = workspace / root_name
        if not root.is_dir():
            continue
        for path in sorted(root.rglob("*.typ")):
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


def uncommented_typst_lines(text: str) -> str:
    without_blocks = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    return "\n".join(
        line for line in without_blocks.splitlines() if not line.lstrip().startswith("//")
    )


def imported_typst_symbols(text: str, source_path: str) -> set[str]:
    pattern = re.compile(
        rf'^\s*#import\s+"{re.escape(source_path)}"\s*:\s*(?P<symbols>[^\n]+)',
        re.MULTILINE,
    )
    symbols: set[str] = set()
    for match in pattern.finditer(text):
        symbols.update(symbol.strip() for symbol in match.group("symbols").split(","))
    return symbols


def find_matching_parenthesis(text: str, open_index: int) -> int | None:
    depth = 0
    in_string = False
    escaped = False
    for index in range(open_index, len(text)):
        character = text[index]
        if in_string:
            if escaped:
                escaped = False
            elif character == "\\":
                escaped = True
            elif character == '"':
                in_string = False
            continue
        if character == '"':
            in_string = True
        elif character == "(":
            depth += 1
        elif character == ")":
            depth -= 1
            if depth == 0:
                return index
    return None


def rendered_pipeline_wrapper_calls(text: str, function_name: str) -> list[str]:
    starts = re.finditer(r"#rendered-gold-pipeline\s*\(", text)
    calls: list[str] = []
    for start in starts:
        open_index = text.find("(", start.start())
        close_index = find_matching_parenthesis(text, open_index)
        if close_index is None:
            continue
        call = text[start.start():close_index + 1]
        if re.search(
            rf'^#rendered-gold-pipeline\s*\(\s*"{re.escape(function_name)}"\s*,\s*'
            rf'<{re.escape(function_name)}>\s*,\s*{re.escape(function_name)}\s*\(',
            call,
            re.DOTALL,
        ):
            calls.append(call)
    return calls


def rendered_unavailable_wrapper_calls(text: str, marker: str) -> list[str]:
    starts = re.finditer(r"#rendered-gold-unavailable\s*\(", text)
    calls: list[str] = []
    for start in starts:
        open_index = text.find("(", start.start())
        close_index = find_matching_parenthesis(text, open_index)
        if close_index is None:
            continue
        call = text[start.start():close_index + 1]
        if re.search(
            rf'^#rendered-gold-unavailable\s*\(\s*"{re.escape(marker)}"\s*,\s*'
            rf'<{re.escape(marker)}>\s*,',
            call,
            re.DOTALL,
        ):
            calls.append(call)
    return calls


def cell(row: dict[str, str | None], key: str) -> str:
    return (row.get(key) or "").strip()


def parse_simple_frontmatter(path: Path, errors: list[str]) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    match = FRONTMATTER_PATTERN.match(text)
    if match is None:
        errors.append(f"{path.name}: missing YAML frontmatter")
        return {}
    result: dict[str, str] = {}
    for line_number, line in enumerate(match.group("body").splitlines(), start=2):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        key, separator, value = stripped.partition(":")
        if not separator:
            errors.append(f"{path.name}:{line_number}: invalid frontmatter line")
            continue
        result[key.strip()] = value.split("#", maxsplit=1)[0].strip().strip('"\'')
    return result


def parse_scalar_frontmatter(path: Path, errors: list[str]) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    match = FRONTMATTER_PATTERN.match(text)
    if match is None:
        errors.append(f"{path.name}: missing YAML frontmatter")
        return {}
    result: dict[str, str] = {}
    for line in match.group("body").splitlines():
        if not line or line[0].isspace() or line.startswith("-") or line.startswith("#"):
            continue
        key, separator, value = line.partition(":")
        if separator:
            result[key.strip()] = value.strip().strip('"\'')
    return result


def validate_frontmatter_identity(
    relative: str,
    frontmatter: dict[str, str],
    expected: dict[str, str],
    errors: list[str],
) -> None:
    for field, expected_value in expected.items():
        actual_value = frontmatter.get(field)
        if actual_value is None:
            errors.append(f"{relative}: frontmatter missing {field}")
        elif actual_value != expected_value:
            errors.append(
                f"{relative}: frontmatter {field} does not match coverage.csv "
                f"({actual_value!r} != {expected_value!r})"
            )


def validate_no_release_todos(
    workspace: Path,
    summary_paths: set[Path],
    errors: list[str],
) -> None:
    for path in sorted(workspace.rglob("*.typ")):
        visible_text = uncommented_typst_lines(path.read_text(encoding="utf-8"))
        if re.search(r"\bTODO\b", visible_text):
            errors.append(f"{path.relative_to(workspace)}: unresolved visible TODO")

    markdown_paths = {
        workspace / "scope/scope.md",
        workspace / "sources/competition.md",
        workspace / "sources/evidence-ledger.md",
        workspace / "slides/terminology.md",
        workspace / "reviews/release-review.md",
        *summary_paths,
        *(workspace / "synthesis").glob("*.md"),
    }
    for path in sorted(markdown_paths):
        if not nonempty(path):
            continue
        visible_text = re.sub(
            r"<!--.*?-->",
            "",
            path.read_text(encoding="utf-8"),
            flags=re.DOTALL,
        )
        if re.search(r"\bTODO\b", visible_text):
            errors.append(f"{path.relative_to(workspace)}: unresolved TODO")


def query_rendered_markers(
    workspace: Path,
    entrypoint: Path,
    errors: list[str],
) -> set[str]:
    mise = shutil.which("mise")
    if mise is None:
        errors.append("mise is required to query final Typst render markers")
        return set()
    command = [
        mise,
        "exec",
        "--",
        "typst",
        "eval",
        "query(metadata)",
        "--in",
        str(entrypoint),
        "--root",
        str(workspace),
    ]
    result = subprocess.run(command, capture_output=True, text=True, check=False)
    if result.returncode != 0:
        detail = result.stderr.strip().splitlines()
        message = detail[-1] if detail else "unknown Typst query failure"
        errors.append(f"{entrypoint.relative_to(workspace)}: render-marker query failed: {message}")
        return set()
    try:
        values = json.loads(result.stdout)
    except json.JSONDecodeError:
        errors.append(f"{entrypoint.relative_to(workspace)}: invalid render-marker query output")
        return set()
    return {
        item["value"]
        for item in values
        if isinstance(item, dict) and isinstance(item.get("value"), str)
    }


def ordinal(rank: int) -> str:
    if 10 <= rank % 100 <= 20:
        suffix = "th"
    else:
        suffix = {1: "st", 2: "nd", 3: "rd"}.get(rank % 10, "th")
    return f"{rank}{suffix}"


def validate_topology_record(
    summary_relative: str,
    summary_text: str,
    errors: list[str],
) -> tuple[dict[str, str], Counter[tuple[str, str, str]]] | None:
    marker = "### Topology record"
    if marker not in summary_text:
        errors.append(f"{summary_relative}: documented method missing {marker!r}")
        return None
    section = summary_text.split(marker, maxsplit=1)[1]
    section = re.split(r"\n#{2,3}\s", section, maxsplit=1)[0]
    rows: list[dict[str, str]] = []
    for line in section.splitlines():
        if not line.lstrip().startswith("|"):
            continue
        values = [value.strip() for value in line.strip().strip("|").split("|")]
        if values[:2] == ["id", "kind"] or all(set(value) <= {"-", ":"} for value in values):
            continue
        if len(values) != 8:
            errors.append(f"{summary_relative}: topology row needs 8 columns: {line.strip()}")
            continue
        rows.append(dict(zip(
            ("id", "kind", "label", "from", "to", "condition", "source_ref", "uncertainty"),
            values,
            strict=True,
        )))
    identifiers = [row["id"] for row in rows]
    for row in rows:
        if not row["id"]:
            errors.append(f"{summary_relative}: every topology row needs a non-empty id")
        if row["kind"] not in {"node", "edge"}:
            errors.append(
                f"{summary_relative}: topology {row['id'] or '<missing-id>'} "
                "kind must be node or edge"
            )
    duplicate_ids = sorted(
        identifier
        for identifier, count in Counter(identifiers).items()
        if identifier and count > 1
    )
    if duplicate_ids:
        errors.append(f"{summary_relative}: topology IDs must be unique: {duplicate_ids}")

    node_rows = [row for row in rows if row["kind"] == "node"]
    node_ids = {row["id"] for row in node_rows if row["id"]}
    edge_rows = [row for row in rows if row["kind"] == "edge"]
    if len(node_ids) < 2:
        errors.append(f"{summary_relative}: topology record needs at least two distinct nodes")
    if not edge_rows or all(row["from"] == row["to"] for row in edge_rows):
        errors.append(f"{summary_relative}: topology record needs at least one non-self edge")
    for row in node_rows:
        if not row["label"]:
            errors.append(
                f"{summary_relative}: topology node {row['id'] or '<missing-id>'} needs a label"
            )
    for row in rows:
        if not row["source_ref"]:
            errors.append(f"{summary_relative}: topology {row['id'] or '<missing-id>'} needs source_ref")
    for row in edge_rows:
        if row["from"] not in node_ids or row["to"] not in node_ids:
            errors.append(
                f"{summary_relative}: topology edge {row['id'] or '<missing-id>'} "
                "must reference existing node IDs"
            )
    node_labels = {row["id"]: row["label"] for row in node_rows if row["id"]}
    edge_specs = Counter(
        (row["from"], row["to"], row["condition"])
        for row in edge_rows
    )
    return node_labels, edge_specs


def validate_mermaid_topology(
    summary_relative: str,
    summary_text: str,
    topology: tuple[dict[str, str], Counter[tuple[str, str, str]]] | None,
    errors: list[str],
) -> None:
    overview_match = re.search(
        r"^## Solutionの全体像\s*$\n(?P<body>.*?)(?=^##\s|\Z)",
        summary_text,
        re.MULTILINE | re.DOTALL,
    )
    if overview_match is None:
        return
    mermaid_matches = list(re.finditer(
        r"^```mermaid\s*$\n(?P<body>.*?)^```\s*$",
        overview_match.group("body"),
        re.MULTILINE | re.DOTALL,
    ))
    if len(mermaid_matches) != 1:
        errors.append(
            f"{summary_relative}: Solutionの全体像 needs exactly one closed Mermaid block"
        )
        return
    body = mermaid_matches[0].group("body")
    if re.search(r"^\s*(?:flowchart|graph)\s+(?:LR|RL|TB|BT|TD)\b", body, re.MULTILINE) is None:
        errors.append(f"{summary_relative}: Mermaid block needs a flowchart/graph declaration")
        return
    mermaid_nodes = {
        match.group("id"): match.group("label").strip()
        for match in re.finditer(
            r"^\s*(?P<id>[A-Za-z][A-Za-z0-9_-]*)\s*\[(?P<label>[^\]\n]+)\]\s*$",
            body,
            re.MULTILINE,
        )
    }
    mermaid_edges = Counter(
        (
            match.group("from"),
            match.group("to"),
            (match.group("condition") or "").strip(),
        )
        for match in re.finditer(
            r"^\s*(?P<from>[A-Za-z][A-Za-z0-9_-]*)\s*-->"
            r"\s*(?:\|(?P<condition>[^|\n]+)\|\s*)?"
            r"(?P<to>[A-Za-z][A-Za-z0-9_-]*)\s*$",
            body,
            re.MULTILINE,
        )
    )
    if topology is None:
        return
    topology_nodes, topology_edges = topology
    if mermaid_nodes != topology_nodes:
        errors.append(
            f"{summary_relative}: Mermaid node IDs and labels must equal the Topology record "
            f"({mermaid_nodes} != {topology_nodes})"
        )
    if mermaid_edges != topology_edges:
        errors.append(
            f"{summary_relative}: Mermaid edges must equal the Topology record "
            f"({dict(mermaid_edges)} != {dict(topology_edges)})"
        )


def validate_leaderboard_scope(
    workspace: Path,
    selected_rows: list[dict[str, str]],
    errors: list[str],
    require_pdf: bool,
) -> None:
    leaderboard_path = workspace / "sources/leaderboard.csv"
    if not nonempty(leaderboard_path):
        return

    with leaderboard_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        required_columns = {"final_order", "rank", "team", "score", "medal_band"}
        missing_columns = required_columns - set(reader.fieldnames or [])
        if missing_columns:
            errors.append(
                "sources/leaderboard.csv missing columns: "
                f"{', '.join(sorted(missing_columns))}"
            )
            return
        leaderboard_rows = list(reader)
    scope_path = workspace / "scope/scope.md"
    frontmatter = parse_simple_frontmatter(scope_path, errors) if nonempty(scope_path) else {}
    selection_mode = frontmatter.get("selection_mode", "")
    if require_pdf and re.fullmatch(r"\d+\.\d+\.\d+", frontmatter.get("typst_version", "")) is None:
        errors.append("scope/scope.md typst_version must record the selected semantic version")
    try:
        selection_value = int(frontmatter.get("selection_value", ""))
        if selection_value <= 0:
            raise ValueError
    except ValueError:
        errors.append("scope/scope.md selection_value must be a positive integer")
        return

    ranked_rows: list[tuple[int, int, dict[str, str | None]]] = []
    seen_orders: set[int] = set()
    for index, row in enumerate(leaderboard_rows):
        try:
            rank = int(cell(row, "rank"))
            final_order = int(cell(row, "final_order"))
        except ValueError:
            errors.append(
                f"sources/leaderboard.csv:{index + 2}: final_order and rank must be integers"
            )
            continue
        if final_order <= 0 or final_order in seen_orders:
            errors.append(
                f"sources/leaderboard.csv:{index + 2}: final_order must be positive and unique"
            )
            continue
        seen_orders.add(final_order)
        if not cell(row, "team"):
            errors.append(f"sources/leaderboard.csv:{index + 2}: team is required")
            continue
        ranked_rows.append((rank, final_order, row))

    ordered_final_positions = sorted(final_order for _, final_order, _ in ranked_rows)
    expected_final_positions = list(range(1, len(ranked_rows) + 1))
    if ordered_final_positions != expected_final_positions:
        errors.append(
            "sources/leaderboard.csv final_order must be the complete consecutive source order"
        )
        return
    ordered_ranked_rows = sorted(ranked_rows, key=lambda item: item[1])
    ranks_in_source_order = [rank for rank, _, _ in ordered_ranked_rows]
    if ranks_in_source_order != sorted(ranks_in_source_order):
        errors.append("sources/leaderboard.csv rank must be nondecreasing by final_order")
        return
    for position, (rank, _, _) in enumerate(ordered_ranked_rows, start=1):
        if position == 1 and rank != 1:
            errors.append("sources/leaderboard.csv must start at rank 1")
            return
        if position > 1 and rank != ranks_in_source_order[position - 2] and rank != position:
            errors.append(
                "sources/leaderboard.csv ranks must follow source order; a new tied-rank "
                "group must start at its final_order"
            )
            return

    if selection_mode == "max-rank":
        if not ranked_rows or max(rank for rank, _, _ in ranked_rows) < selection_value:
            errors.append(
                f"sources/leaderboard.csv does not reach selected max rank {selection_value}"
            )
            return
        selected_leaderboard_rows = [
            row for rank, _, row in ordered_ranked_rows if rank <= selection_value
        ]
        if len(selected_leaderboard_rows) < selection_value:
            errors.append(
                "sources/leaderboard.csv has too few teams to be a complete prefix through "
                f"rank {selection_value}: found {len(selected_leaderboard_rows)}"
            )
            return
    elif selection_mode == "team-count":
        if len(ordered_ranked_rows) < selection_value:
            errors.append(
                f"sources/leaderboard.csv has {len(ordered_ranked_rows)} teams; "
                f"selection requires {selection_value}"
            )
            return
        selected_leaderboard_rows = [row for _, _, row in ordered_ranked_rows[:selection_value]]
    else:
        errors.append("scope/scope.md selection_mode must be max-rank or team-count")
        return

    selected_teams = [cell(row, "team") for row in selected_leaderboard_rows]
    duplicate_teams = sorted({team for team in selected_teams if selected_teams.count(team) > 1})
    if duplicate_teams:
        errors.append(f"sources/leaderboard.csv has duplicate scoped teams: {duplicate_teams}")

    expected = Counter(
        (cell(row, "rank"), cell(row, "team"), cell(row, "medal_band"))
        for row in selected_leaderboard_rows
    )
    actual = Counter(
        (cell(row, "rank"), cell(row, "team"), cell(row, "medal_band"))
        for row in selected_rows
    )
    missing = sorted((expected - actual).elements())
    extra = sorted((actual - expected).elements())
    if missing:
        errors.append(f"coverage.csv omits scoped leaderboard rows: {missing}")
    if extra:
        errors.append(f"coverage.csv has selected rows absent from scoped leaderboard: {extra}")


def validate_gold_pipelines(
    workspace: Path,
    selected_rows: list[dict[str, str]],
    errors: list[str],
    require_pdf: bool,
) -> None:
    all_gold_rows = [row for row in selected_rows if cell(row, "medal_band") == "gold"]
    gold_rows = [
        row
        for row in selected_rows
        if cell(row, "medal_band") == "gold" and cell(row, "method_status") == "documented"
    ]
    pipeline_path = workspace / "figures/gold-pipelines.typ"
    if gold_rows and not nonempty(pipeline_path):
        errors.append("workspace must have the shared rendering source figures/gold-pipelines.typ")
        return

    duplicate_paths = [
        path
        for path in workspace.rglob("gold-pipelines.typ")
        if not pipeline_path.exists() or path.resolve() != pipeline_path.resolve()
    ]
    if duplicate_paths:
        shown = ", ".join(str(path.relative_to(workspace)) for path in duplicate_paths)
        errors.append(f"duplicate gold-pipelines.typ outside figures/: {shown}")

    appendix_path = workspace / "report/sections/08-gold-appendix.typ"
    slides_path = workspace / "slides/slides.typ"
    if not nonempty(appendix_path):
        errors.append("missing report/sections/08-gold-appendix.typ")
        return
    if not nonempty(slides_path):
        errors.append("missing slides/slides.typ")
        return
    report_text = uncommented_typst_lines(appendix_path.read_text(encoding="utf-8"))
    slides_text = uncommented_typst_lines(slides_path.read_text(encoding="utf-8"))
    main_path = workspace / "report/main.typ"
    main_text = (
        uncommented_typst_lines(main_path.read_text(encoding="utf-8"))
        if nonempty(main_path)
        else ""
    )
    slides_preamble = slides_text.partition("#show:")[0]
    slides_body = slides_text.partition("#slide[")[2]
    report_rendered_markers = (
        query_rendered_markers(workspace, workspace / "report/main.typ", errors)
        if require_pdf and all_gold_rows
        else set()
    )
    slide_rendered_markers = (
        query_rendered_markers(workspace, workspace / "slides/slides.typ", errors)
        if require_pdf and gold_rows
        else set()
    )
    for artifact, text in (("report", report_text), ("slides", slides_text)):
        if re.search(r"#\s*if\s+false\b", text):
            errors.append(f"{artifact} contains disabled #if false content; remove it before release")
        if "#gold-pipeline-placeholder(" in text:
            errors.append(f"{artifact} still renders gold-pipeline-placeholder")
        if re.search(r"^\s*#let\s+gold-pipeline-\d+\s*\(", text, re.MULTILINE):
            errors.append(f"{artifact} locally redefines a gold pipeline instead of importing the shared rendering")
        if re.search(r"#\s*metadata\s*\(", text):
            errors.append(f"{artifact} must not emit metadata directly; use the canonical wrappers")
    if TYPST_CONTROL_FLOW_PATTERN.search(report_text):
        errors.append("report appendix must not conditionally hide gold-team content")
    if TYPST_CONTROL_FLOW_PATTERN.search(slides_preamble):
        errors.append("slides import preamble must not use control flow")
    if TYPST_CONTROL_FLOW_PATTERN.search(slides_body):
        errors.append("slides must not conditionally hide required deck content after the first slide")

    pipeline_text = (
        uncommented_typst_lines(pipeline_path.read_text(encoding="utf-8"))
        if nonempty(pipeline_path)
        else ""
    )
    if "gold-pipeline-placeholder" in pipeline_text:
        errors.append("figures/gold-pipelines.typ still contains gold-pipeline-placeholder")
    wrapper_definition = re.search(
        r"#let\s+rendered-gold-pipeline\s*\(\s*marker\s*,\s*label\s*,\s*visual\s*\)"
        r"\s*=\s*block\s*\[\s*#metadata\(marker\)\s*#label\s*#visual\s*\]",
        pipeline_text,
        re.DOTALL,
    )
    if gold_rows and wrapper_definition is None:
        errors.append("figures/gold-pipelines.typ must keep the fixed rendered-gold-pipeline wrapper")
    unavailable_wrapper_definition = re.search(
        r"#let\s+rendered-gold-unavailable\s*\(\s*marker\s*,\s*label\s*,\s*body\s*\)"
        r"\s*=\s*block\s*\[\s*#metadata\(marker\)\s*#label\s*#body\s*\]",
        pipeline_text,
        re.DOTALL,
    )
    if all_gold_rows and unavailable_wrapper_definition is None:
        errors.append(
            "figures/gold-pipelines.typ must keep the fixed rendered-gold-unavailable wrapper"
        )
    if all_gold_rows and len(re.findall(r"\bmetadata\b", pipeline_text)) != 2:
        errors.append(
            "figures/gold-pipelines.typ may reference metadata only in the two fixed wrappers"
        )
    for source_path in sorted(workspace.rglob("*.typ")):
        if source_path.resolve() == pipeline_path.resolve():
            continue
        source_text = uncommented_typst_lines(source_path.read_text(encoding="utf-8"))
        relative = source_path.relative_to(workspace)
        if re.search(r"\bmetadata\b", source_text):
            errors.append(f"{relative} must not reference metadata outside the canonical wrappers")
        if re.search(
            r"^\s*#let\s+rendered-gold-(?:pipeline|unavailable)\b",
            source_text,
            re.MULTILINE,
        ):
            errors.append(f"{relative} must not redefine a canonical gold rendering wrapper")
        for import_line in re.findall(r"^\s*#import[^\n]+", source_text, re.MULTILINE):
            if (
                "rendered-gold-pipeline" in import_line
                or "rendered-gold-unavailable" in import_line
            ) and "figures/gold-pipelines.typ" not in import_line:
                errors.append(f"{relative} imports a gold rendering wrapper from a noncanonical source")

    report_symbols = imported_typst_symbols(
        report_text,
        "../../figures/gold-pipelines.typ",
    )
    slide_symbols = imported_typst_symbols(
        slides_preamble,
        "../figures/gold-pipelines.typ",
    )

    if all_gold_rows:
        if TYPST_CONTROL_FLOW_PATTERN.search(main_text):
            errors.append("report/main.typ must not conditionally include required report sections")
        if re.search(
            r'^#include\s+"sections/08-gold-appendix\.typ"\s*$',
            main_text,
            re.MULTILINE,
        ) is None:
            errors.append("report/main.typ must include sections/08-gold-appendix.typ")
    for row in all_gold_rows:
        rank_text = cell(row, "rank")
        team = cell(row, "team")
        slug = cell(row, "team_slug")
        heading = f"== {rank_text}位：{team}"
        if heading not in report_text:
            errors.append(f"report appendix missing team-specific heading for {rank_text}/{team}")
            continue
        if cell(row, "method_status") == "unavailable":
            marker = f"gold-unavailable-{rank_text}-{slug}"
            section = report_text.split(heading, maxsplit=1)[1]
            section = re.split(r"^==\s", section, maxsplit=1, flags=re.MULTILINE)[0]
            if "=== 公開情報の限界" not in section:
                errors.append(
                    f"report appendix must explain 公開情報の限界 for {rank_text}/{team}"
                )
            unavailable_calls = rendered_unavailable_wrapper_calls(section, marker)
            if len(unavailable_calls) != 1:
                errors.append(
                    f"report appendix must render {marker} through the fixed unavailable wrapper"
                )
            elif require_pdf and marker not in report_rendered_markers:
                errors.append(f"report PDF source does not render marker <{marker}>")
            if "*" not in report_symbols and "rendered-gold-unavailable" not in report_symbols:
                errors.append(
                    "report appendix must import rendered-gold-unavailable from the shared figure"
                )

    if not gold_rows:
        return

    for row in gold_rows:
        try:
            rank = int(cell(row, "rank"))
        except ValueError:
            continue
        team = cell(row, "team")
        slug = cell(row, "team_slug")
        function_name = f"gold-pipeline-{rank}-{slug}"
        report_wrapper_calls = rendered_pipeline_wrapper_calls(report_text, function_name)
        slide_wrapper_calls = rendered_pipeline_wrapper_calls(slides_text, function_name)
        if len(report_wrapper_calls) != 1:
            errors.append(f"report appendix must render {function_name} through the fixed wrapper")
        if len(slide_wrapper_calls) != 1:
            errors.append(f"slides/slides.typ must render {function_name} through the fixed wrapper")
        report_without_wrapper = report_text
        for call in report_wrapper_calls:
            report_without_wrapper = report_without_wrapper.replace(call, "", 1)
        slides_without_wrapper = slides_text
        for call in slide_wrapper_calls:
            slides_without_wrapper = slides_without_wrapper.replace(call, "", 1)
        naked_call_pattern = re.compile(rf"(?<![A-Za-z0-9_-]){re.escape(function_name)}\s*\(")
        if naked_call_pattern.search(report_without_wrapper):
            errors.append(f"report appendix contains a naked {function_name} call")
        if naked_call_pattern.search(slides_without_wrapper):
            errors.append(f"slides/slides.typ contains a naked {function_name} call")
        if "*" not in report_symbols and function_name not in report_symbols:
            errors.append(f"report appendix must import {function_name} from the shared figure")
        if "*" not in slide_symbols and function_name not in slide_symbols:
            errors.append(f"slides/slides.typ must import {function_name} from the shared figure")
        if "*" not in report_symbols and "rendered-gold-pipeline" not in report_symbols:
            errors.append(
                "report appendix must import rendered-gold-pipeline from the shared figure"
            )
        if "*" not in slide_symbols and "rendered-gold-pipeline" not in slide_symbols:
            errors.append(
                "slides/slides.typ must import rendered-gold-pipeline from the shared figure"
            )
        for source_path in sorted(workspace.rglob("*.typ")):
            if source_path.resolve() == pipeline_path.resolve():
                continue
            source_text = uncommented_typst_lines(source_path.read_text(encoding="utf-8"))
            relative = source_path.relative_to(workspace)
            if re.search(
                rf"^\s*#let\s+{re.escape(function_name)}\s*\(",
                source_text,
                re.MULTILINE,
            ):
                errors.append(
                    f"{relative} redefines {function_name}; use figures/gold-pipelines.typ"
                )
            for import_line in re.findall(r"^\s*#import[^\n]+", source_text, re.MULTILINE):
                if function_name in import_line and "figures/gold-pipelines.typ" not in import_line:
                    errors.append(
                        f"{relative} imports {function_name} from a noncanonical source"
                    )
        definition = re.search(
            rf"^\s*#let\s+{re.escape(function_name)}\s*\((?P<args>.*?)\)\s*=\s*",
            pipeline_text,
            re.MULTILINE | re.DOTALL,
        )
        if definition is None:
            errors.append(f"figures/gold-pipelines.typ missing {function_name}")
        else:
            body_tail = pipeline_text[definition.end():]
            if re.match(
                r"(?:none\b|\[\s*\]|\{\s*\}|gold-pipeline-placeholder\b)",
                body_tail,
                re.DOTALL,
            ):
                errors.append(f"figures/gold-pipelines.typ has empty/placeholder {function_name}")
        if re.search(
            rf"{re.escape(ordinal(rank))}\s+solution:[^\n]*{re.escape(team)}",
            slides_text,
        ) is None:
            errors.append(f"slides missing team-specific overview heading for {rank}/{team}")
        if require_pdf:
            if function_name not in report_rendered_markers:
                errors.append(f"report PDF source does not render marker <{function_name}>")
            if function_name not in slide_rendered_markers:
                errors.append(f"slide PDF source does not render marker <{function_name}>")


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

    selected_rows = [row for row in rows if cell(row, "selected").lower() == "true"]
    if not selected_rows:
        errors.append("coverage.csv has no selected rows")
    validate_leaderboard_scope(workspace, selected_rows, errors, args.require_pdf)

    seen_rows: set[tuple[int, str]] = set()
    seen_team_identities: set[tuple[int, str]] = set()
    seen_raw_paths: set[str] = set()
    seen_summary_paths: set[str] = set()
    counts = {"complete": 0, "partial": 0, "unavailable": 0, "pending": 0}
    for line_number, row in enumerate(rows, start=2):
        if cell(row, "selected").lower() != "true":
            continue
        try:
            rank = int(cell(row, "rank"))
            if rank <= 0:
                raise ValueError
        except ValueError:
            errors.append(f"coverage.csv:{line_number}: rank must be a positive integer")
            continue
        slug = cell(row, "team_slug")
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", slug):
            errors.append(f"coverage.csv:{line_number}: invalid team_slug {slug!r}")
        row_key = (rank, slug)
        if row_key in seen_rows:
            errors.append(f"coverage.csv:{line_number}: duplicate selected rank/team {rank}/{slug}")
        seen_rows.add(row_key)
        team_identity = (rank, cell(row, "team"))
        if team_identity in seen_team_identities:
            errors.append(
                f"coverage.csv:{line_number}: duplicate selected rank/team identity "
                f"{rank}/{team_identity[1]}"
            )
        seen_team_identities.add(team_identity)
        medal = cell(row, "medal_band")
        if medal not in {"gold", "silver-upper"}:
            errors.append(f"coverage.csv:{line_number}: invalid medal_band {medal!r}")
        gold_group = cell(row, "gold_group")
        if medal == "gold" and gold_group not in {"top", "lower"}:
            errors.append(f"coverage.csv:{line_number}: gold row needs gold_group top or lower")
        if medal == "silver-upper" and gold_group:
            errors.append(f"coverage.csv:{line_number}: silver row must have empty gold_group")

        status = cell(row, "status")
        if status not in counts:
            errors.append(f"coverage.csv:{line_number}: invalid status {status!r}")
        else:
            counts[status] += 1
        if status == "pending":
            errors.append(f"coverage.csv:{line_number}: selected row is still pending")
        method_status = cell(row, "method_status")
        if method_status not in {"pending", "documented", "unavailable"}:
            errors.append(f"coverage.csv:{line_number}: invalid method_status {method_status!r}")
        if (
            status in {"partial", "unavailable"} or method_status == "unavailable"
        ) and not cell(row, "evidence_limit"):
            errors.append(
                f"coverage.csv:{line_number}: {status}/{method_status} row needs evidence_limit"
            )
        valid_state_pairs = {
            ("pending", "pending"),
            ("complete", "documented"),
            ("complete", "unavailable"),
            ("partial", "documented"),
            ("partial", "unavailable"),
            ("unavailable", "unavailable"),
        }
        if (status, method_status) not in valid_state_pairs:
            errors.append(
                f"coverage.csv:{line_number}: invalid status/method_status pair "
                f"{status!r}/{method_status!r}"
            )

        raw_relative = cell(row, "raw_path")
        summary_relative = cell(row, "summary_path")
        expected_raw_relative = f"solutions/rank-{rank:03d}-{slug}-raw.md"
        expected_summary_relative = f"solutions/rank-{rank:03d}-{slug}.md"
        if raw_relative != expected_raw_relative:
            errors.append(
                f"coverage.csv:{line_number}: raw_path must be {expected_raw_relative!r}"
            )
        if summary_relative != expected_summary_relative:
            errors.append(
                f"coverage.csv:{line_number}: summary_path must be {expected_summary_relative!r}"
            )
        if raw_relative == summary_relative:
            errors.append(f"coverage.csv:{line_number}: raw_path and summary_path must differ")
        if raw_relative in seen_raw_paths:
            errors.append(f"coverage.csv:{line_number}: duplicate selected raw_path {raw_relative!r}")
        if summary_relative in seen_summary_paths:
            errors.append(
                f"coverage.csv:{line_number}: duplicate selected summary_path {summary_relative!r}"
            )
        seen_raw_paths.add(raw_relative)
        seen_summary_paths.add(summary_relative)
        raw_path = safe_path(workspace, raw_relative)
        summary_path = safe_path(workspace, summary_relative)
        raw_frontmatter: dict[str, str] = {}
        if raw_path is None or not nonempty(raw_path):
            errors.append(f"coverage.csv:{line_number}: missing/unsafe raw_path {raw_relative!r}")
        if summary_path is None or not nonempty(summary_path):
            errors.append(f"coverage.csv:{line_number}: missing/unsafe summary_path {summary_relative!r}")
        if raw_path is not None and nonempty(raw_path):
            raw_text = raw_path.read_text(encoding="utf-8")
            raw_frontmatter = parse_scalar_frontmatter(raw_path, errors)
            validate_frontmatter_identity(
                raw_relative,
                raw_frontmatter,
                {
                    "final_rank": str(rank),
                    "medal_band": medal,
                    "team": cell(row, "team"),
                },
                errors,
            )
            if not raw_frontmatter.get("competition"):
                errors.append(f"{raw_relative}: frontmatter missing competition")
            for heading in ("## Original post", "## Comments", "## Retrieval limitations", "## Search log"):
                if heading not in raw_text:
                    errors.append(f"{raw_relative}: missing heading {heading!r}")
            if method_status == "unavailable":
                for item in SEARCH_COMPLETION_ITEMS:
                    if item not in raw_text:
                        errors.append(f"{raw_relative}: unavailable row missing completed search gate {item!r}")
        if summary_path is not None and nonempty(summary_path):
            summary_text = summary_path.read_text(encoding="utf-8")
            summary_frontmatter = parse_scalar_frontmatter(summary_path, errors)
            validate_frontmatter_identity(
                summary_relative,
                summary_frontmatter,
                {
                    "final_rank": str(rank),
                    "medal_band": medal,
                    "team": cell(row, "team"),
                    "source_raw": raw_relative,
                    "status": status,
                    "method_status": method_status,
                },
                errors,
            )
            raw_competition = raw_frontmatter.get("competition", "")
            summary_competition = summary_frontmatter.get("competition", "")
            if not summary_competition:
                errors.append(f"{summary_relative}: frontmatter missing competition")
            elif raw_competition and summary_competition != raw_competition:
                errors.append(
                    f"{summary_relative}: competition does not match paired raw file "
                    f"({summary_competition!r} != {raw_competition!r})"
                )
            for heading in REQUIRED_SUMMARY_HEADINGS:
                if heading not in summary_text:
                    errors.append(f"{summary_relative}: missing heading {heading!r}")
            if method_status == "documented":
                topology = validate_topology_record(summary_relative, summary_text, errors)
                validate_mermaid_topology(summary_relative, summary_text, topology, errors)

    validate_gold_pipelines(workspace, selected_rows, errors, args.require_pdf)

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

    explainer_count = slides_text.count("#explainer(")
    if explainer_count == 0:
        errors.append(
            "slides/slides.typ must use explainer slides with title, claim, "
            "two-to-four-paragraph explanation, and optional supporting content"
        )

    if "#takeaway" in slides_text or "Implication" in slides_text:
        errors.append(
            "slides must not use a repeated takeaway/Implication field; "
            "put the conclusion in the explainer claim"
        )

    if args.require_pdf:
        valid_summary_paths = {
            path
            for row in selected_rows
            if (path := safe_path(workspace, cell(row, "summary_path"))) is not None
        }
        validate_no_release_todos(workspace, valid_summary_paths, errors)
        review_path = workspace / "reviews/release-review.md"
        if nonempty(review_path):
            review_text = review_path.read_text(encoding="utf-8")
            for item in RELEASE_REVIEW_ITEMS:
                if item not in review_text:
                    errors.append(f"reviews/release-review.md: incomplete release gate {item!r}")
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
