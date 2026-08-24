#!/usr/bin/env python3
import argparse
import csv
import hashlib
import re
from pathlib import Path

REQUIRED_FILES = (
    "research/scope.md",
    "research/source-ledger.csv",
    "research/claim-ledger.csv",
    "synthesis/argument-map.md",
    "synthesis/slide-outline.md",
    "synthesis/terminology.md",
    "reviews/checkpoints.md",
    "reviews/prose-reconstruction.csv",
    "slides/theme.typ",
    "slides/slides.typ",
)
SOURCE_COLUMNS = (
    "source_id",
    "title",
    "url_or_path",
    "source_type",
    "inspected_scope",
    "supported_claims",
    "limitations",
    "retrieved_at",
)
CLAIM_COLUMNS = (
    "claim_id",
    "proposition",
    "scope_or_condition",
    "evidence_type",
    "supporting_source_ids",
    "counterevidence",
    "confidence_or_uncertainty",
    "primary_issue_id",
    "secondary_issue_ids",
    "destination",
    "exclusion_rationale",
)
PROSE_COLUMNS = (
    "group_id",
    "slide_ids",
    "expanded_proposition",
    "published_claim",
    "reconstructed_proposition",
    "ambiguity_found",
    "correction",
    "status",
)
CHECKPOINT_COLUMNS = (
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
REQUIRED_CHECKPOINTS = ("C1", "C2a", "C3", "C2b", "C4", "C5", "C6")
EVIDENCE_TYPES = {
    "directly-observed",
    "official-or-organizer",
    "author-reported",
    "organizer-confirmed",
    "participant-reported",
    "independently-reproduced",
    "inference",
    "unavailable",
}
SCAFFOLD_PATTERNS = (
    re.compile(r"\bTODO\b"),
    re.compile(r"TOPIC LEARNING SLIDES"),
    re.compile(r"\bIssue [A-Z]\b"),
    re.compile(r"\bbaseline\b", re.IGNORECASE),
    re.compile(r"\btrade-off\b", re.IGNORECASE),
    re.compile(r"\bnegative evidence\b", re.IGNORECASE),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate a topic-learning-slides workspace.")
    parser.add_argument("workspace", type=Path)
    parser.add_argument("--require-pdf", action="store_true")
    return parser.parse_args()


def nonempty(path: Path) -> bool:
    return path.is_file() and path.stat().st_size > 0


def split_ids(value: str) -> set[str]:
    return {item.strip() for item in value.split(";") if item.strip()}


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


def read_csv(path: Path, columns: tuple[str, ...], errors: list[str]) -> list[dict[str, str]]:
    if not nonempty(path):
        return []
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        actual = tuple(reader.fieldnames or ())
        if actual != columns:
            errors.append(
                f"{path.name}: header must be {','.join(columns)!r} ({','.join(actual)!r} found)"
            )
            return []
        return [{key: (value or "").strip() for key, value in row.items()} for row in reader]


def uncommented_typst(text: str) -> str:
    without_blocks = re.sub(r"/\*.*?\*/", "", text, flags=re.DOTALL)
    return "\n".join(
        line for line in without_blocks.splitlines() if not line.lstrip().startswith("//")
    )


def validate_scaffolding(workspace: Path, errors: list[str]) -> None:
    for path in sorted(workspace.rglob("*")):
        if not path.is_file() or path.suffix not in {".md", ".typ", ".csv"}:
            continue
        text = path.read_text(encoding="utf-8")
        if path.suffix == ".typ":
            text = uncommented_typst(text)
        patterns = SCAFFOLD_PATTERNS if (
            path.suffix == ".typ" or path.parent == workspace / "synthesis"
        ) else SCAFFOLD_PATTERNS[:1]
        for pattern in patterns:
            if pattern.search(text):
                errors.append(
                    f"{path.relative_to(workspace)}: unresolved scaffold text {pattern.pattern!r}"
                )


def validate_checkpoints(workspace: Path, errors: list[str]) -> None:
    path = workspace / "reviews/checkpoints.md"
    if not nonempty(path):
        return
    rows: list[dict[str, str]] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.lstrip().startswith("|"):
            continue
        values = [value.strip() for value in line.strip().strip("|").split("|")]
        if tuple(values) == CHECKPOINT_COLUMNS or all(set(value) <= {"-", ":"} for value in values):
            continue
        if len(values) != len(CHECKPOINT_COLUMNS):
            errors.append(f"reviews/checkpoints.md: checkpoint row needs {len(CHECKPOINT_COLUMNS)} columns")
            continue
        rows.append(dict(zip(CHECKPOINT_COLUMNS, values, strict=True)))

    seen_attempts: set[str] = set()
    latest: dict[str, tuple[int, dict[str, str]]] = {}
    previous_by_checkpoint: dict[str, str] = {}
    for index, row in enumerate(rows):
        attempt_id = row["attempt_id"]
        checkpoint = row["checkpoint"]
        if not re.fullmatch(r"A-[0-9]{3,}", attempt_id):
            errors.append(f"reviews/checkpoints.md: invalid attempt_id {attempt_id!r}")
        elif attempt_id in seen_attempts:
            errors.append(f"reviews/checkpoints.md: duplicate attempt_id {attempt_id!r}")
        seen_attempts.add(attempt_id)
        if checkpoint not in REQUIRED_CHECKPOINTS:
            errors.append(f"reviews/checkpoints.md: invalid checkpoint {checkpoint!r}")
            continue
        if row["status"] not in {"pass", "revise", "blocked"}:
            errors.append(f"reviews/checkpoints.md: invalid status {row['status']!r}")
        if not row["artifact"]:
            errors.append(f"reviews/checkpoints.md: {attempt_id} needs artifact paths")
        expected_supersedes = previous_by_checkpoint.get(checkpoint, "none")
        if row["supersedes"] != expected_supersedes:
            errors.append(
                f"reviews/checkpoints.md: {attempt_id} supersedes must be "
                f"{expected_supersedes!r}"
            )
        previous_by_checkpoint[checkpoint] = attempt_id
        invalidated = split_ids(row["invalidates"]) if row["invalidates"] != "none" else set()
        unknown_invalidated = invalidated - set(REQUIRED_CHECKPOINTS)
        if unknown_invalidated:
            errors.append(
                f"reviews/checkpoints.md: {attempt_id} invalidates unknown checkpoints "
                f"{sorted(unknown_invalidated)}"
            )
        checkpoint_position = REQUIRED_CHECKPOINTS.index(checkpoint)
        if any(REQUIRED_CHECKPOINTS.index(name) <= checkpoint_position for name in invalidated if name in REQUIRED_CHECKPOINTS):
            errors.append(
                f"reviews/checkpoints.md: {attempt_id} may invalidate only downstream checkpoints"
            )
        latest[checkpoint] = (index, row)

    missing = [checkpoint for checkpoint in REQUIRED_CHECKPOINTS if checkpoint not in latest]
    if missing:
        errors.append(f"reviews/checkpoints.md: missing current checkpoints {missing}")
        return
    indices = [latest[checkpoint][0] for checkpoint in REQUIRED_CHECKPOINTS]
    if indices != sorted(indices):
        errors.append("reviews/checkpoints.md: downstream checkpoints were not rerun after the latest upstream pass")
    for checkpoint in REQUIRED_CHECKPOINTS:
        index, row = latest[checkpoint]
        if row["status"] != "pass":
            errors.append(f"reviews/checkpoints.md: latest {checkpoint} status is not pass")
        try:
            expected = digest_artifacts(workspace, row["artifact"])
        except SystemExit as error:
            errors.append(f"reviews/checkpoints.md: {error}")
            expected = ""
        if expected and row["artifact_hash"] != expected:
            errors.append(
                f"reviews/checkpoints.md: {row['attempt_id']} has stale artifact_hash; "
                f"expected {expected}"
            )
        invalidated = split_ids(row["invalidates"]) if row["invalidates"] != "none" else set()
        for downstream in invalidated:
            if downstream in latest and latest[downstream][0] <= index:
                errors.append(
                    f"reviews/checkpoints.md: {downstream} was not rerun after "
                    f"{row['attempt_id']} invalidated it"
                )


def main() -> int:
    args = parse_args()
    workspace = args.workspace.expanduser().resolve()
    errors: list[str] = []
    if not workspace.is_dir():
        raise SystemExit(f"Workspace does not exist: {workspace}")

    for relative in REQUIRED_FILES:
        if not nonempty(workspace / relative):
            errors.append(f"missing or empty required file: {relative}")

    source_rows = read_csv(workspace / "research/source-ledger.csv", SOURCE_COLUMNS, errors)
    claim_rows = read_csv(workspace / "research/claim-ledger.csv", CLAIM_COLUMNS, errors)
    prose_rows = read_csv(workspace / "reviews/prose-reconstruction.csv", PROSE_COLUMNS, errors)

    source_ids: set[str] = set()
    for line_number, row in enumerate(source_rows, start=2):
        source_id = row["source_id"]
        if not re.fullmatch(r"S-[0-9]{3,}", source_id):
            errors.append(f"research/source-ledger.csv:{line_number}: invalid source_id {source_id!r}")
        elif source_id in source_ids:
            errors.append(f"research/source-ledger.csv:{line_number}: duplicate source_id {source_id!r}")
        source_ids.add(source_id)
        for field in ("title", "url_or_path", "source_type", "inspected_scope", "retrieved_at"):
            if not row[field]:
                errors.append(f"research/source-ledger.csv:{line_number}: {field} is required")

    argument_text = (workspace / "synthesis/argument-map.md").read_text(encoding="utf-8") if nonempty(workspace / "synthesis/argument-map.md") else ""
    issue_ids = set(re.findall(r"^##\s+(I-[0-9]{3,})\s*:", argument_text, re.MULTILINE))
    claim_ids: set[str] = set()
    primary_issue_ids: set[str] = set()
    for line_number, row in enumerate(claim_rows, start=2):
        claim_id = row["claim_id"]
        if not re.fullmatch(r"C-[0-9]{3,}", claim_id):
            errors.append(f"research/claim-ledger.csv:{line_number}: invalid claim_id {claim_id!r}")
        elif claim_id in claim_ids:
            errors.append(f"research/claim-ledger.csv:{line_number}: duplicate claim_id {claim_id!r}")
        claim_ids.add(claim_id)
        if row["evidence_type"] not in EVIDENCE_TYPES:
            errors.append(f"research/claim-ledger.csv:{line_number}: invalid evidence_type {row['evidence_type']!r}")
        unknown_sources = split_ids(row["supporting_source_ids"]) - source_ids
        if unknown_sources:
            errors.append(f"research/claim-ledger.csv:{line_number}: unknown source IDs {sorted(unknown_sources)}")
        if row["destination"] not in {"main", "detail", "excluded"}:
            errors.append(f"research/claim-ledger.csv:{line_number}: invalid destination {row['destination']!r}")
        if row["destination"] == "excluded" and not row["exclusion_rationale"]:
            errors.append(f"research/claim-ledger.csv:{line_number}: excluded claim needs a rationale")
        if row["destination"] in {"main", "detail"} and row["primary_issue_id"] not in issue_ids:
            errors.append(f"research/claim-ledger.csv:{line_number}: main/detail claim needs a valid primary issue")
        if row["destination"] in {"main", "detail"}:
            primary_issue_ids.add(row["primary_issue_id"])
        unknown_secondary = split_ids(row["secondary_issue_ids"]) - issue_ids
        if unknown_secondary:
            errors.append(f"research/claim-ledger.csv:{line_number}: unknown secondary issue IDs {sorted(unknown_secondary)}")
        for field in ("proposition", "scope_or_condition", "supporting_source_ids", "confidence_or_uncertainty"):
            if not row[field]:
                errors.append(f"research/claim-ledger.csv:{line_number}: {field} is required")

    for line_number, row in enumerate(source_rows, start=2):
        unknown_claims = split_ids(row["supported_claims"]) - claim_ids
        if unknown_claims:
            errors.append(
                f"research/source-ledger.csv:{line_number}: unknown supported claim IDs "
                f"{sorted(unknown_claims)}"
            )

    slides_text = (workspace / "slides/slides.typ").read_text(encoding="utf-8") if nonempty(workspace / "slides/slides.typ") else ""
    markers = set(re.findall(r'#source-mark\(\s*"(S-[0-9]{3,})"\s*\)', slides_text))
    entries = set(re.findall(r'#source-entry\(\s*"(S-[0-9]{3,})"\s*,', slides_text))
    if not markers:
        errors.append("slides/slides.typ: no source-mark IDs found")
    if markers - source_ids:
        errors.append(f"slides/slides.typ: source markers absent from source ledger {sorted(markers - source_ids)}")
    if markers - entries:
        errors.append(f"slides/slides.typ: source markers missing from source appendix {sorted(markers - entries)}")
    if "出典一覧" not in slides_text:
        errors.append("slides/slides.typ: missing visible 出典一覧 appendix")

    for line_number, row in enumerate(prose_rows, start=2):
        if row["ambiguity_found"] not in {"yes", "no"}:
            errors.append(f"reviews/prose-reconstruction.csv:{line_number}: ambiguity_found must be yes or no")
        if row["status"] != "pass":
            errors.append(f"reviews/prose-reconstruction.csv:{line_number}: status must be pass")
        if row["ambiguity_found"] == "yes" and not row["correction"]:
            errors.append(f"reviews/prose-reconstruction.csv:{line_number}: ambiguity needs a correction")
        for field in ("group_id", "slide_ids", "expanded_proposition", "published_claim", "reconstructed_proposition"):
            if not row[field]:
                errors.append(f"reviews/prose-reconstruction.csv:{line_number}: {field} is required")

    if args.require_pdf:
        validate_scaffolding(workspace, errors)
        validate_checkpoints(workspace, errors)
        if not source_rows:
            errors.append("research/source-ledger.csv: at least one source is required")
        if not claim_rows:
            errors.append("research/claim-ledger.csv: at least one consequential claim is required")
        if not issue_ids:
            errors.append("synthesis/argument-map.md: at least one stable issue ID is required")
        uncovered_issues = issue_ids - primary_issue_ids
        if uncovered_issues:
            errors.append(
                "synthesis/argument-map.md: issues without a primary claim or explicit "
                f"limitation claim {sorted(uncovered_issues)}"
            )
        if not prose_rows:
            errors.append("reviews/prose-reconstruction.csv: at least one checked slide group is required")
        if not nonempty(workspace / "slides/slides.pdf"):
            errors.append("missing final PDF: slides/slides.pdf")
        render_root = workspace / "reviews/renders"
        image_paths = [
            path for path in render_root.glob("**/*")
            if path.is_file() and path.suffix.lower() in {".png", ".jpg", ".jpeg", ".webp"}
        ] if render_root.is_dir() else []
        if not image_paths:
            errors.append("reviews/renders: no full-resolution page render found")
        if not any("contact" in path.name.lower() for path in image_paths):
            errors.append("reviews/renders: no contact sheet found")

    if errors:
        print("validation failed")
        for error in errors:
            print(f"- {error}")
        return 1
    print(f"validation ok: sources={len(source_rows)} claims={len(claim_rows)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
