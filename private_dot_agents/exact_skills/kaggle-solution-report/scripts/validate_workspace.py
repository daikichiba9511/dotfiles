#!/usr/bin/env python3
import argparse
import colorsys
import csv
import hashlib
import html
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
    "## 外部Artifactの監査",
)
REQUIRED_FILES = (
    "scope/scope.md",
    "scope/coverage.csv",
    "sources/competition.md",
    "sources/leaderboard.csv",
    "sources/evidence-ledger.md",
    "sources/artifact-ledger.csv",
    "synthesis/comparison-matrix.md",
    "synthesis/common-elements.md",
    "synthesis/differentiators.md",
    "synthesis/task-grounded-analysis.md",
    "synthesis/strategy-retrospective.md",
    "synthesis/publication-evidence.csv",
    "synthesis/argument-map.md",
    "synthesis/slide-outline.md",
    "synthesis/terminology.md",
    "synthesis/slide-sources.csv",
    "reviews/release-review.md",
    "reviews/topic-slide-checkpoints.md",
    "reviews/prose-reconstruction.csv",
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
    "- [x] Available-evidence saturation and artifact audit have no unresolved high/medium finding.",
    "- [x] Evidence and technical accuracy review has no unresolved high/medium finding.",
    "- [x] Japanese terminology and explanation review has no unresolved high/medium finding.",
    "- [x] Rendered geometry review has no unresolved high/medium finding.",
    "- [x] Report/slide parity review has no unresolved high/medium finding.",
    "- [x] Topic-slide C1-C6 checkpoints are fresh and the Kaggle adapter check passed.",
    "- [x] Validation, compilation, and full rerender passed after the final accepted correction.",
)
ARTIFACT_COLUMNS = (
    "artifact_id",
    "rank",
    "team",
    "artifact_type",
    "url",
    "discovered_in",
    "materiality",
    "status",
    "local_path",
    "evidence_ids",
    "evidence_limit",
)
PUBLICATION_EVIDENCE_COLUMNS = (
    "evidence_id",
    "rank",
    "team",
    "medal_band",
    "category",
    "summary",
    "source_refs",
    "importance",
    "report_disposition",
    "report_location",
    "slide_disposition",
    "slide_location",
    "exclusion_reason",
)
SLIDE_SOURCE_COLUMNS = (
    "source_id",
    "title",
    "url_or_path",
    "inspected_scope",
    "retrieved_at",
    "limitations",
    "evidence_refs",
)
PROSE_RECONSTRUCTION_COLUMNS = (
    "group_id",
    "slide_ids",
    "expanded_proposition",
    "published_claim",
    "reconstructed_proposition",
    "ambiguity_found",
    "correction",
    "status",
)
TOPIC_CHECKPOINT_COLUMNS = (
    "attempt_id",
    "checkpoint",
    "artifact",
    "artifact_hash",
    "status",
    "finding",
    "action",
    "invalidates",
    "supersedes",
)
REQUIRED_TOPIC_CHECKPOINTS = ("C1", "C2a", "C3", "C2b", "C4", "C5", "C6")
MATERIAL_ARTIFACT_URL_PATTERN = re.compile(
    r"https?://(?:www\.)?(?:"
    r"github\.com/[^\s<>\"']+|"
    r"gitlab\.com/[^\s<>\"']+|"
    r"kaggle\.com/(?:code|datasets|models)/[^\s<>\"']+|"
    r"kaggle\.com/competitions/[^\s<>\"']+/(?:discussion|writeups)/[^\s<>\"']+|"
    r"kaggle\.com/writeups/[^\s<>\"']+|"
    r"huggingface\.co/(?:datasets/)?[^\s<>\"']+|"
    r"arxiv\.org/(?:abs|pdf|html)/[^\s<>\"']+|"
    r"researchgate\.net/publication/[^\s<>\"']+|"
    r"doi\.org/[^\s<>\"']+|"
    r"zenodo\.org/[^\s<>\"']+|"
    r"drive\.google\.com/[^\s<>\"']+|"
    r"colab\.research\.google\.com/[^\s<>\"']+|"
    r"(?:www\.)?googleapis\.com/download/storage/v1/b/"
    r"kaggle-(?:user-content|forum-message-attachments)/[^\s<>\"']+"
    r")",
    re.IGNORECASE,
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


def read_csv_rows(
    path: Path,
    required_columns: tuple[str, ...],
    errors: list[str],
) -> list[dict[str, str | None]]:
    if not nonempty(path):
        return []
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        actual_columns = tuple(reader.fieldnames or ())
        if actual_columns != required_columns:
            errors.append(
                f"{path.name}: header must be {','.join(required_columns)!r} "
                f"({','.join(actual_columns)!r} found)"
            )
            return []
        return list(reader)


def normalize_artifact_url(url: str) -> str:
    decoded = html.unescape(url).rstrip(".,);]}")
    decoded = re.sub(r"[?#].*$", "", decoded)
    return decoded.rstrip("/").lower()


def extract_candidate_artifact_urls(raw_text: str) -> set[str]:
    return {
        normalize_artifact_url(match.group(0))
        for match in MATERIAL_ARTIFACT_URL_PATTERN.finditer(html.unescape(raw_text))
    }


def extract_named_kaggle_dependencies(path: Path) -> set[str]:
    if path.name != "kernel-metadata.json":
        return set()
    try:
        metadata = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return set()
    dependency_urls: set[str] = set()
    for source in metadata.get("dataset_sources", []):
        if source:
            dependency_urls.add(f"https://www.kaggle.com/datasets/{source}")
    for source in metadata.get("kernel_sources", []):
        if source:
            dependency_urls.add(f"https://www.kaggle.com/code/{source}")
    for source in metadata.get("model_sources", []):
        if source:
            dependency_urls.add(f"https://www.kaggle.com/models/{source}")
    return {normalize_artifact_url(url) for url in dependency_urls}


def split_ids(value: str) -> set[str]:
    return {item.strip() for item in value.split(";") if item.strip()}


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
        workspace / "synthesis/terminology.md",
        workspace / "reviews/release-review.md",
        workspace / "reviews/topic-slide-checkpoints.md",
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

    for path in (
        workspace / "synthesis/slide-sources.csv",
        workspace / "reviews/prose-reconstruction.csv",
    ):
        if nonempty(path) and re.search(r"\bTODO\b", path.read_text(encoding="utf-8")):
            errors.append(f"{path.relative_to(workspace)}: unresolved TODO")


def digest_checkpoint_artifacts(workspace: Path, artifact_field: str) -> str:
    digest = hashlib.sha256()
    for relative in (item.strip() for item in artifact_field.split(";")):
        if not relative:
            continue
        path = safe_path(workspace, relative)
        if path is None or not path.is_file():
            raise ValueError(f"artifact is missing or unsafe: {relative}")
        digest.update(relative.encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()


def validate_topic_slide_contract(workspace: Path, errors: list[str]) -> None:
    evidence_ledger_text = (
        (workspace / "sources/evidence-ledger.md").read_text(encoding="utf-8")
        if nonempty(workspace / "sources/evidence-ledger.md")
        else ""
    )
    publication_text = (
        (workspace / "synthesis/publication-evidence.csv").read_text(encoding="utf-8")
        if nonempty(workspace / "synthesis/publication-evidence.csv")
        else ""
    )
    artifact_text = (
        (workspace / "sources/artifact-ledger.csv").read_text(encoding="utf-8")
        if nonempty(workspace / "sources/artifact-ledger.csv")
        else ""
    )
    known_evidence_ids = set(
        re.findall(
            r"\b[CPA]-[0-9]{3,}\b",
            f"{evidence_ledger_text}\n{publication_text}\n{artifact_text}",
        )
    )

    source_rows = read_csv_rows(
        workspace / "synthesis/slide-sources.csv",
        SLIDE_SOURCE_COLUMNS,
        errors,
    )
    source_ids: set[str] = set()
    for line_number, row in enumerate(source_rows, start=2):
        source_id = cell(row, "source_id")
        if not re.fullmatch(r"S-[0-9]{3,}", source_id):
            errors.append(
                f"synthesis/slide-sources.csv:{line_number}: invalid source_id {source_id!r}"
            )
        elif source_id in source_ids:
            errors.append(
                f"synthesis/slide-sources.csv:{line_number}: duplicate source_id {source_id!r}"
            )
        source_ids.add(source_id)
        for field in ("title", "url_or_path", "inspected_scope", "retrieved_at", "evidence_refs"):
            if not cell(row, field):
                errors.append(
                    f"synthesis/slide-sources.csv:{line_number}: {field} is required"
                )
        unknown_evidence = split_ids(cell(row, "evidence_refs")) - known_evidence_ids
        if unknown_evidence:
            errors.append(
                f"synthesis/slide-sources.csv:{line_number}: unknown evidence_refs "
                f"{sorted(unknown_evidence)}"
            )

    if not source_rows:
        errors.append("synthesis/slide-sources.csv: at least one public source is required")

    argument_path = workspace / "synthesis/argument-map.md"
    argument_text = argument_path.read_text(encoding="utf-8") if nonempty(argument_path) else ""
    issue_matches = list(re.finditer(r"^##\s+(I-[0-9]{3,})\s*:", argument_text, re.MULTILINE))
    if not issue_matches:
        errors.append("synthesis/argument-map.md: at least one stable issue ID is required")
    for position, match in enumerate(issue_matches):
        section_end = issue_matches[position + 1].start() if position + 1 < len(issue_matches) else len(argument_text)
        section = argument_text[match.end():section_end]
        if not set(re.findall(r"\b[CP]-[0-9]{3,}\b", section)):
            errors.append(
                f"synthesis/argument-map.md: {match.group(1)} needs a primary claim or "
                "explicit limitation claim ID"
            )
    mapped_ids = set(re.findall(r"\b[CP]-[0-9]{3,}\b", argument_text))
    unknown_mapped = mapped_ids - known_evidence_ids
    if unknown_mapped:
        errors.append(
            f"synthesis/argument-map.md: unknown claim IDs {sorted(unknown_mapped)}"
        )

    outline_path = workspace / "synthesis/slide-outline.md"
    outline_text = outline_path.read_text(encoding="utf-8") if nonempty(outline_path) else ""
    outline_ids = set(re.findall(r"\b[CP]-[0-9]{3,}\b", outline_text))
    unknown_outline = outline_ids - known_evidence_ids
    if unknown_outline:
        errors.append(
            f"synthesis/slide-outline.md: unknown evidence IDs {sorted(unknown_outline)}"
        )

    slides_path = workspace / "slides/slides.typ"
    slides_text = slides_path.read_text(encoding="utf-8") if nonempty(slides_path) else ""
    markers = set(re.findall(r'#source-mark\(\s*"(S-[0-9]{3,})"\s*\)', slides_text))
    entries = set(re.findall(r'#source-entry\(\s*"(S-[0-9]{3,})"\s*,', slides_text))
    if not markers:
        errors.append("slides/slides.typ: no source-mark IDs found")
    if markers - source_ids:
        errors.append(
            f"slides/slides.typ: source markers absent from slide-sources.csv {sorted(markers - source_ids)}"
        )
    if markers - entries:
        errors.append(
            f"slides/slides.typ: source markers missing from 出典一覧 {sorted(markers - entries)}"
        )
    if "出典一覧" not in slides_text:
        errors.append("slides/slides.typ: missing visible 出典一覧")

    prose_rows = read_csv_rows(
        workspace / "reviews/prose-reconstruction.csv",
        PROSE_RECONSTRUCTION_COLUMNS,
        errors,
    )
    if not prose_rows:
        errors.append("reviews/prose-reconstruction.csv: at least one checked slide group is required")
    for line_number, row in enumerate(prose_rows, start=2):
        if cell(row, "ambiguity_found") not in {"yes", "no"}:
            errors.append(
                f"reviews/prose-reconstruction.csv:{line_number}: ambiguity_found must be yes or no"
            )
        if cell(row, "status") != "pass":
            errors.append(
                f"reviews/prose-reconstruction.csv:{line_number}: status must be pass"
            )
        if cell(row, "ambiguity_found") == "yes" and not cell(row, "correction"):
            errors.append(
                f"reviews/prose-reconstruction.csv:{line_number}: ambiguity needs a correction"
            )
        for field in (
            "group_id",
            "slide_ids",
            "expanded_proposition",
            "published_claim",
            "reconstructed_proposition",
        ):
            if not cell(row, field):
                errors.append(
                    f"reviews/prose-reconstruction.csv:{line_number}: {field} is required"
                )

    checkpoint_path = workspace / "reviews/topic-slide-checkpoints.md"
    if not nonempty(checkpoint_path):
        return
    checkpoint_text = checkpoint_path.read_text(encoding="utf-8")
    for token in (
        "scope_artifact",
        "source_ledger",
        "claim_ledger",
        "evidence_packet",
        "checkpoint_log",
        "terminology_ledger",
        "prose_reconstruction",
        "organizer-confirmed",
        "participant-reported",
    ):
        if token not in checkpoint_text:
            errors.append(f"reviews/topic-slide-checkpoints.md: missing mapping token {token!r}")

    checkpoint_rows: list[dict[str, str]] = []
    for line in checkpoint_text.splitlines():
        if not line.lstrip().startswith("|"):
            continue
        values = [value.strip() for value in line.strip().strip("|").split("|")]
        if tuple(values) == TOPIC_CHECKPOINT_COLUMNS or all(
            set(value) <= {"-", ":"} for value in values
        ):
            continue
        if len(values) != len(TOPIC_CHECKPOINT_COLUMNS):
            continue
        checkpoint_rows.append(
            dict(zip(TOPIC_CHECKPOINT_COLUMNS, values, strict=True))
        )

    latest: dict[str, tuple[int, dict[str, str]]] = {}
    seen_attempts: set[str] = set()
    previous_by_checkpoint: dict[str, str] = {}
    for index, row in enumerate(checkpoint_rows):
        attempt_id = row["attempt_id"]
        checkpoint = row["checkpoint"]
        if not re.fullmatch(r"A-[0-9]{3,}", attempt_id):
            errors.append(
                f"reviews/topic-slide-checkpoints.md: invalid attempt_id {attempt_id!r}"
            )
        elif attempt_id in seen_attempts:
            errors.append(
                f"reviews/topic-slide-checkpoints.md: duplicate attempt_id {attempt_id!r}"
            )
        seen_attempts.add(attempt_id)
        if checkpoint not in REQUIRED_TOPIC_CHECKPOINTS:
            errors.append(
                f"reviews/topic-slide-checkpoints.md: invalid checkpoint {checkpoint!r}"
            )
            continue
        if row["status"] not in {"pass", "revise", "blocked"}:
            errors.append(
                f"reviews/topic-slide-checkpoints.md: invalid status {row['status']!r}"
            )
        if not row["artifact"]:
            errors.append(
                f"reviews/topic-slide-checkpoints.md: {attempt_id} needs artifact paths"
            )
        expected_supersedes = previous_by_checkpoint.get(checkpoint, "none")
        if row["supersedes"] != expected_supersedes:
            errors.append(
                f"reviews/topic-slide-checkpoints.md: {attempt_id} supersedes must be "
                f"{expected_supersedes!r}"
            )
        previous_by_checkpoint[checkpoint] = attempt_id
        invalidated = split_ids(row["invalidates"]) if row["invalidates"] != "none" else set()
        unknown_invalidated = invalidated - set(REQUIRED_TOPIC_CHECKPOINTS)
        if unknown_invalidated:
            errors.append(
                f"reviews/topic-slide-checkpoints.md: {attempt_id} invalidates unknown "
                f"checkpoints {sorted(unknown_invalidated)}"
            )
        checkpoint_position = REQUIRED_TOPIC_CHECKPOINTS.index(checkpoint)
        if any(
            REQUIRED_TOPIC_CHECKPOINTS.index(name) <= checkpoint_position
            for name in invalidated
            if name in REQUIRED_TOPIC_CHECKPOINTS
        ):
            errors.append(
                f"reviews/topic-slide-checkpoints.md: {attempt_id} may invalidate only "
                "downstream checkpoints"
            )
        latest[checkpoint] = (index, row)

    missing = [name for name in REQUIRED_TOPIC_CHECKPOINTS if name not in latest]
    if missing:
        errors.append(
            f"reviews/topic-slide-checkpoints.md: missing current checkpoints {missing}"
        )
    else:
        indices = [latest[name][0] for name in REQUIRED_TOPIC_CHECKPOINTS]
        if indices != sorted(indices):
            errors.append(
                "reviews/topic-slide-checkpoints.md: downstream checkpoints were not rerun "
                "after the latest upstream pass"
            )
        for name in REQUIRED_TOPIC_CHECKPOINTS:
            index, row = latest[name]
            if row["status"] != "pass":
                errors.append(
                    f"reviews/topic-slide-checkpoints.md: latest {name} status is not pass"
                )
            try:
                expected_hash = digest_checkpoint_artifacts(workspace, row["artifact"])
            except ValueError as error:
                errors.append(f"reviews/topic-slide-checkpoints.md: {error}")
                expected_hash = ""
            if expected_hash and row["artifact_hash"] != expected_hash:
                errors.append(
                    f"reviews/topic-slide-checkpoints.md: {row['attempt_id']} has stale "
                    f"artifact_hash; expected {expected_hash}"
                )
            invalidated = split_ids(row["invalidates"]) if row["invalidates"] != "none" else set()
            for downstream in invalidated:
                if downstream in latest and latest[downstream][0] <= index:
                    errors.append(
                        f"reviews/topic-slide-checkpoints.md: {downstream} was not rerun after "
                        f"{row['attempt_id']} invalidated it"
                    )

    render_root = workspace / "reviews/renders"
    images = [
        path
        for path in render_root.glob("**/*")
        if path.is_file() and path.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"}
    ] if render_root.is_dir() else []
    if not images:
        errors.append("reviews/renders: no full-resolution page render found")
    if not any("contact" in path.name.lower() for path in images):
        errors.append("reviews/renders: no contact sheet found")


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


def validate_artifact_ledger(
    workspace: Path,
    selected_rows: list[dict[str, str]],
    errors: list[str],
) -> set[str]:
    ledger_path = workspace / "sources/artifact-ledger.csv"
    ledger_rows = read_csv_rows(ledger_path, ARTIFACT_COLUMNS, errors)
    selected_identities = {
        (cell(row, "rank"), cell(row, "team"))
        for row in selected_rows
    }
    evidence_ids: set[str] = set()
    seen_ids: set[str] = set()
    ledger_urls_by_source: dict[str, set[str]] = {}

    for line_number, row in enumerate(ledger_rows, start=2):
        artifact_id = cell(row, "artifact_id")
        if not re.fullmatch(r"A-[0-9]{3,}", artifact_id):
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: invalid artifact_id {artifact_id!r}"
            )
        elif artifact_id in seen_ids:
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: duplicate artifact_id {artifact_id!r}"
            )
        seen_ids.add(artifact_id)

        identity = (cell(row, "rank"), cell(row, "team"))
        if identity != ("0", "competition-context") and identity not in selected_identities:
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: unknown scoped identity {identity!r}"
            )

        artifact_type = cell(row, "artifact_type")
        if artifact_type not in {
            "notebook",
            "repository",
            "paper",
            "dataset",
            "model",
            "attachment",
            "external-writeup",
        }:
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: invalid artifact_type "
                f"{artifact_type!r}"
            )
        materiality = cell(row, "materiality")
        status = cell(row, "status")
        if materiality not in {"material", "not-material"}:
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: invalid materiality {materiality!r}"
            )
        if status not in {"pending", "inspected", "unavailable", "not-material"}:
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: invalid status {status!r}"
            )
        if status == "pending":
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: artifact audit is still pending"
            )
        if (materiality == "not-material") != (status == "not-material"):
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: not-material materiality and status "
                "must be paired"
            )
        if status in {"unavailable", "not-material"} and not cell(row, "evidence_limit"):
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: {status} row needs evidence_limit"
            )

        url = cell(row, "url")
        if not re.match(r"https?://", url):
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: url must be an HTTP(S) reference"
            )
        discovered_in = cell(row, "discovered_in")
        discovered_path = safe_path(workspace, discovered_in)
        if discovered_path is None or not nonempty(discovered_path):
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: missing/unsafe discovered_in "
                f"{discovered_in!r}"
            )
        if discovered_in and url:
            ledger_urls_by_source.setdefault(discovered_in, set()).add(
                normalize_artifact_url(url)
            )

        local_relative = cell(row, "local_path")
        if status == "inspected":
            local_path = safe_path(workspace, local_relative)
            if not local_relative or local_path is None or not local_path.exists():
                errors.append(
                    f"sources/artifact-ledger.csv:{line_number}: inspected artifact needs an "
                    "existing workspace-relative local_path"
                )
            if not cell(row, "evidence_ids") and not cell(row, "evidence_limit"):
                errors.append(
                    f"sources/artifact-ledger.csv:{line_number}: inspected artifact without "
                    "evidence_ids needs evidence_limit explaining why it changed no claim"
                )
        elif local_relative:
            errors.append(
                f"sources/artifact-ledger.csv:{line_number}: {status} row must not set local_path"
            )
        evidence_ids.update(split_ids(cell(row, "evidence_ids")))

    for row in selected_rows:
        raw_relative = cell(row, "raw_path")
        raw_path = safe_path(workspace, raw_relative)
        if raw_path is None or not nonempty(raw_path):
            continue
        candidate_urls = extract_candidate_artifact_urls(
            raw_path.read_text(encoding="utf-8")
        )
        official_url_match = re.search(
            r"^- Official URL:\s*(https?://\S+)",
            raw_path.read_text(encoding="utf-8"),
            re.MULTILINE,
        )
        primary_urls = {
            normalize_artifact_url(official_url_match.group(1))
        } if official_url_match else set()
        candidate_urls -= primary_urls
        missing_urls = sorted(candidate_urls - ledger_urls_by_source.get(raw_relative, set()))
        for url in missing_urls:
            errors.append(
                f"{raw_relative}: candidate technical artifact missing from "
                f"sources/artifact-ledger.csv: {url}"
            )

    artifacts_root = workspace / "sources/artifacts"
    if artifacts_root.is_dir():
        for metadata_path in sorted(artifacts_root.rglob("kernel-metadata.json")):
            metadata_relative = str(metadata_path.relative_to(workspace))
            candidate_urls = extract_named_kaggle_dependencies(metadata_path)
            missing_urls = sorted(
                candidate_urls - ledger_urls_by_source.get(metadata_relative, set())
            )
            for url in missing_urls:
                errors.append(
                    f"{metadata_relative}: named Kaggle dependency missing from "
                    f"sources/artifact-ledger.csv: {url}"
                )
    return evidence_ids


def validate_publication_evidence(
    workspace: Path,
    selected_rows: list[dict[str, str]],
    artifact_evidence_ids: set[str],
    errors: list[str],
) -> None:
    evidence_path = workspace / "synthesis/publication-evidence.csv"
    evidence_rows = read_csv_rows(
        evidence_path,
        PUBLICATION_EVIDENCE_COLUMNS,
        errors,
    )
    selected_by_identity = {
        (cell(row, "rank"), cell(row, "team")): row
        for row in selected_rows
    }
    report_text = "\n".join(
        path.read_text(encoding="utf-8")
        for path in sorted((workspace / "report").rglob("*.typ"))
    )
    slides_path = workspace / "slides/slides.typ"
    slides_text = slides_path.read_text(encoding="utf-8") if nonempty(slides_path) else ""
    seen_ids: set[str] = set()
    rows_by_identity: dict[tuple[str, str], list[dict[str, str | None]]] = {}

    for line_number, row in enumerate(evidence_rows, start=2):
        evidence_id = cell(row, "evidence_id")
        if not re.fullmatch(r"P-[0-9]{3,}", evidence_id):
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: invalid evidence_id "
                f"{evidence_id!r}"
            )
        elif evidence_id in seen_ids:
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: duplicate evidence_id "
                f"{evidence_id!r}"
            )
        seen_ids.add(evidence_id)

        identity = (cell(row, "rank"), cell(row, "team"))
        coverage_row = selected_by_identity.get(identity)
        if coverage_row is None:
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: unknown scoped identity "
                f"{identity!r}"
            )
        elif cell(row, "medal_band") != cell(coverage_row, "medal_band"):
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: medal_band does not "
                "match coverage.csv"
            )
        rows_by_identity.setdefault(identity, []).append(row)

        category = cell(row, "category")
        if category not in {
            "pipeline",
            "mechanism",
            "validation",
            "result",
            "negative-result",
            "reasoning-turn",
            "reproducibility",
            "limitation",
        }:
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: invalid category "
                f"{category!r}"
            )
        if not cell(row, "summary") or not cell(row, "source_refs"):
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: summary and source_refs "
                "are required"
            )
        importance = cell(row, "importance")
        if importance not in {"core", "supporting", "context"}:
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: invalid importance "
                f"{importance!r}"
            )

        report_disposition = cell(row, "report_disposition")
        slide_disposition = cell(row, "slide_disposition")
        if report_disposition not in {"included", "excluded"}:
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: invalid "
                f"report_disposition {report_disposition!r}"
            )
        if slide_disposition not in {"included", "factor-only", "excluded"}:
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: invalid slide_disposition "
                f"{slide_disposition!r}"
            )
        report_location = cell(row, "report_location")
        slide_location = cell(row, "slide_location")
        if report_disposition == "included":
            if not report_location or report_location not in report_text:
                errors.append(
                    f"synthesis/publication-evidence.csv:{line_number}: included report_location "
                    f"must appear literally in report Typst: {report_location!r}"
                )
        elif report_location:
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: excluded report row must "
                "not set report_location"
            )
        if slide_disposition in {"included", "factor-only"}:
            if not slide_location or slide_location not in slides_text:
                errors.append(
                    f"synthesis/publication-evidence.csv:{line_number}: included slide_location "
                    f"must appear literally in slides Typst: {slide_location!r}"
                )
        elif slide_location:
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: excluded slide row must "
                "not set slide_location"
            )
        if (
            report_disposition == "excluded" or slide_disposition == "excluded"
        ) and not cell(row, "exclusion_reason"):
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: excluded disposition "
                "needs exclusion_reason"
            )
        if (
            importance == "core"
            and coverage_row is not None
            and cell(coverage_row, "medal_band") == "gold"
            and (report_disposition != "included" or slide_disposition != "included")
        ):
            errors.append(
                f"synthesis/publication-evidence.csv:{line_number}: core Gold evidence must be "
                "included in report and slides"
            )

    missing_artifact_evidence = sorted(artifact_evidence_ids - seen_ids)
    if missing_artifact_evidence:
        errors.append(
            "sources/artifact-ledger.csv references unknown publication evidence IDs: "
            f"{missing_artifact_evidence}"
        )

    trust_categories = {"result", "negative-result", "reproducibility", "limitation"}
    for identity, coverage_row in selected_by_identity.items():
        if (
            cell(coverage_row, "medal_band") != "gold"
            or cell(coverage_row, "method_status") != "documented"
        ):
            continue
        team_rows = rows_by_identity.get(identity, [])
        categories = {cell(row, "category") for row in team_rows}
        if "pipeline" not in categories:
            errors.append(
                f"publication evidence missing pipeline for documented Gold {identity!r}"
            )
        if "mechanism" not in categories:
            errors.append(
                f"publication evidence missing central mechanism for documented Gold {identity!r}"
            )
        if not categories.intersection(trust_categories):
            errors.append(
                f"publication evidence missing result/negative/reproducibility/limitation "
                f"for documented Gold {identity!r}"
            )


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
    if (workspace / "slides/terminology.md").exists():
        errors.append(
            "slides/terminology.md is obsolete; merge it into synthesis/terminology.md and remove it"
        )

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

    artifact_evidence_ids = validate_artifact_ledger(workspace, selected_rows, errors)
    validate_publication_evidence(
        workspace,
        selected_rows,
        artifact_evidence_ids,
        errors,
    )
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
        validate_topic_slide_contract(workspace, errors)
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
