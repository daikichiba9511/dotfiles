#!/usr/bin/env python3
import argparse
import csv
import re
import shutil
from pathlib import Path

SCOPE_FRONTMATTER = """---
selection_mode: TODO # max-rank or team-count
selection_value: TODO
typst_version: TODO
---

"""
SCOPE_FIELDS = {
    "selection_mode": "TODO # max-rank or team-count",
    "selection_value": "TODO",
    "typst_version": "TODO",
}
FRONTMATTER_PATTERN = re.compile(r"\A---\s*\n(?P<body>.*?)\n---(?P<tail>\s*\n)", re.DOTALL)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Add current kaggle-solution-report schema scaffolding to an older workspace."
    )
    parser.add_argument("workspace", type=Path)
    return parser.parse_args()


def migrate_scope(workspace: Path, actions: list[str]) -> None:
    path = workspace / "scope/scope.md"
    text = path.read_text(encoding="utf-8")
    if not text.startswith("---\n"):
        path.write_text(SCOPE_FRONTMATTER + text, encoding="utf-8")
        actions.append("added machine-readable scope frontmatter with TODO values")
        return

    match = FRONTMATTER_PATTERN.match(text)
    if match is None:
        raise SystemExit(f"Malformed scope frontmatter: {path}")
    existing_fields = {
        line.partition(":")[0].strip()
        for line in match.group("body").splitlines()
        if ":" in line and not line.lstrip().startswith("#")
    }
    missing_fields = [field for field in SCOPE_FIELDS if field not in existing_fields]
    if not missing_fields:
        return
    additions = "\n".join(f"{field}: {SCOPE_FIELDS[field]}" for field in missing_fields)
    body = match.group("body").rstrip()
    replacement = f"---\n{body}\n{additions}\n---{match.group('tail')}"
    path.write_text(replacement + text[match.end():], encoding="utf-8")
    actions.append(f"added missing scope frontmatter fields: {', '.join(missing_fields)}")


def migrate_leaderboard(workspace: Path, actions: list[str]) -> None:
    path = workspace / "sources/leaderboard.csv"
    if not path.is_file():
        return
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        fieldnames = list(reader.fieldnames or [])
        rows = list(reader)
    if "final_order" in fieldnames:
        return
    fieldnames.insert(0, "final_order")
    for final_order, row in enumerate(rows, start=1):
        row["final_order"] = str(final_order)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    actions.append("added final_order from the preserved final-leaderboard row order")


def migrate_coverage(workspace: Path, actions: list[str]) -> None:
    path = workspace / "scope/coverage.csv"
    with path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        fieldnames = list(reader.fieldnames or [])
        rows = list(reader)
    if "method_status" in fieldnames:
        return

    status_index = fieldnames.index("status") if "status" in fieldnames else len(fieldnames) - 1
    fieldnames.insert(status_index + 1, "method_status")
    for row in rows:
        status = (row.get("status") or "").strip()
        row["method_status"] = "unavailable" if status == "unavailable" else "pending"
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    actions.append(
        "added method_status; complete/partial rows remain pending for evidence-based classification"
    )


def migrate_review_log(workspace: Path, skill_root: Path, actions: list[str]) -> None:
    destination = workspace / "reviews/release-review.md"
    required_gates = (
        "- [ ] Available-evidence saturation and artifact audit have no unresolved high/medium finding.",
        "- [ ] Topic-slide C1-C6 checkpoints are fresh and the Kaggle adapter check passed.",
    )
    if destination.exists():
        text = destination.read_text(encoding="utf-8")
        marker = "## Release gate\n"
        if marker not in text:
            raise SystemExit(f"Malformed release review without gate heading: {destination}")
        missing_gates = [gate for gate in required_gates if gate not in text]
        if not missing_gates:
            return
        inserted = "\n".join(missing_gates)
        destination.write_text(text.replace(marker, f"{marker}\n{inserted}\n", 1), encoding="utf-8")
        actions.append("added unchecked current release gates")
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    source = skill_root / "assets/workspace-template/reviews/release-review.md"
    shutil.copy2(source, destination)
    actions.append("added reviews/release-review.md")


def migrate_evidence_saturation_scaffolding(
    workspace: Path,
    skill_root: Path,
    actions: list[str],
) -> None:
    for relative in (
        "sources/artifact-ledger.csv",
        "synthesis/publication-evidence.csv",
    ):
        destination = workspace / relative
        if destination.exists():
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        source = skill_root / "assets/workspace-template" / relative
        shutil.copy2(source, destination)
        actions.append(f"added {relative}; populate it from retained evidence before validation")


def migrate_terminology(workspace: Path, actions: list[str]) -> None:
    old_path = workspace / "slides/terminology.md"
    destination = workspace / "synthesis/terminology.md"
    if old_path.exists() and destination.exists():
        raise SystemExit(
            "Both slides/terminology.md and synthesis/terminology.md exist. "
            "Merge them manually and keep only synthesis/terminology.md."
        )
    if old_path.exists():
        destination.parent.mkdir(parents=True, exist_ok=True)
        old_path.replace(destination)
        actions.append("moved slides/terminology.md to synthesis/terminology.md")


def migrate_topic_slide_scaffolding(
    workspace: Path,
    skill_root: Path,
    actions: list[str],
) -> None:
    for relative in (
        "synthesis/argument-map.md",
        "synthesis/slide-outline.md",
        "synthesis/terminology.md",
        "synthesis/slide-sources.csv",
        "reviews/topic-slide-checkpoints.md",
        "reviews/prose-reconstruction.csv",
        "reviews/renders/README.md",
    ):
        destination = workspace / relative
        if destination.exists():
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        source = skill_root / "assets/workspace-template" / relative
        shutil.copy2(source, destination)
        actions.append(f"added {relative}; resolve its scaffold before slide release")


def migrate_shared_figures(workspace: Path, actions: list[str]) -> None:
    destination = workspace / "figures/gold-pipelines.typ"
    old_path = workspace / "diagrams/gold-pipelines.typ"
    if destination.exists() or not old_path.exists():
        return
    destination.parent.mkdir(parents=True, exist_ok=True)
    old_path.replace(destination)
    actions.append(
        "moved diagrams/gold-pipelines.typ to figures/gold-pipelines.typ; update Typst imports manually"
    )


def main() -> int:
    args = parse_args()
    workspace = args.workspace.expanduser().resolve()
    if not workspace.is_dir():
        raise SystemExit(f"Workspace does not exist: {workspace}")
    for relative in ("scope/scope.md", "scope/coverage.csv"):
        if not (workspace / relative).is_file():
            raise SystemExit(f"Required legacy workspace file is missing: {relative}")

    skill_root = Path(__file__).resolve().parent.parent
    actions: list[str] = []
    migrate_scope(workspace, actions)
    migrate_coverage(workspace, actions)
    migrate_leaderboard(workspace, actions)
    migrate_review_log(workspace, skill_root, actions)
    migrate_evidence_saturation_scaffolding(workspace, skill_root, actions)
    migrate_terminology(workspace, actions)
    migrate_topic_slide_scaffolding(workspace, skill_root, actions)
    migrate_shared_figures(workspace, actions)

    if actions:
        for action in actions:
            print(f"- {action}")
    else:
        print("workspace already has the current migration scaffolding")
    print(
        "Next: resolve scope TODO values, classify pending method_status values from retained evidence, "
        "add matching organized frontmatter/topology records and 外部Artifactの監査 sections, "
        "populate the artifact and publication-evidence ledgers, resolve the topic-slide issue map, "
        "source appendix, terminology, prose reconstruction, and checkpoint scaffolds, rename "
        "rank-only pipeline functions with their team slugs, update moved imports, and rerun any "
        "method-unavailable discovery gate before validation."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
