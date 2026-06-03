---
name: spec-behavior
description: "Author and review behavior specifications using tables and Mermaid extended state machines. Use for write mode when the user wants a behavior spec, state machine, state transition diagram, Mermaid spec, or says '振る舞い仕様を書きたい', '状態機械を書きたい', 'Mermaidで仕様', '状態遷移図'. Use for review mode when the user wants to lint or check a behavior/state spec, or says 'この仕様レビューして', '振る舞い仕様チェック', 'Mermaid仕様をlint'. Trigger whenever the user is authoring or reviewing software behavior/state specs, even if spec-behavior is not explicitly named."
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Spec Behavior

振る舞い仕様の作成・レビューを支援する。変換系は表、リアクティブ系は Mermaid 拡張状態機械で書き分ける。

Always read `references/behavior-spec-guide.md` before writing or reviewing a spec.
If the spec involves multiple subsystems, refinement, or separation from implementation details, also read `references/multi-entity-composition.md`.

## Mode

Choose one mode first.

- **write**: user says they want to write, create, draft, or produce a behavior spec.
- **review**: user asks for review, check, lint, or provides only a file path.
- If unclear, ask one concise question before proceeding.

## Write Workflow

1. Identify the target behavior, domain boundary, and granularity.
2. Classify the system:
   - conversion: output is determined only by input, so use a table.
   - reactive: history, mode, state, or parallelism matters, so use Mermaid `stateDiagram-v2`.
   - mixed: include both and state the boundary in design notes.
3. Draft using the guide:
   - UML transition label convention: `event [guard] / action`
   - Harel subset: hierarchy, orthogonal regions, and same-name-event broadcast
   - product-breakdown patterns: forbidden state, transition restriction, mode dependence
   - abnormal paths: cancel, reject, fail, timeout, recovery
4. Add the design notes section from the guide.
5. Run the guide's self-check before writing.
6. If the user gave an explicit save path, write there. Otherwise ask for the save path before writing.

## Review Workflow

1. Read the target file. If no target is provided, ask for one.
2. Run the guide's mechanical checks first.
3. Run the guide's semantic checks next.
4. Report findings by severity: error, warning, info.
5. For every finding, include the line number, current issue, and concrete fix suggestion.
6. In review mode, do not edit the file unless the user explicitly asks for fixes.

## Rules

- Prefer a table for stateless input-output conversion.
- Prefer Mermaid `stateDiagram-v2` for behavior with state, history, modes, or parallel regions.
- Use same-name events in orthogonal regions to express broadcast.
- Do not write the full Cartesian product of states when product-breakdown patterns are enough.
- Treat completeness as either defined state-event coverage or an explicit default such as "undefined events are ignored".
- Keep middleware and infrastructure names out of behavior specs when abstract communication properties are enough.
- When uncertain whether a case is conversion or reactive, include both and explain the boundary in design notes.

$ARGUMENTS
