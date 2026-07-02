---
allowed-tools: Bash(deno:*), Read, Write, Glob
description: "Replace the body of an existing Notion page with local Markdown by driving a real browser with Playwright (a standalone Deno script), then fix the page title. Use this whenever you need to update or sync a Notion page from a Markdown file (or freshly generated Markdown) by driving the browser rather than the Notion API. Trigger on requests like 'update this Notion page', 'sync my markdown into Notion', 'reflect this doc in Notion', 'write this into the Notion page via the browser/Playwright', even when the user doesn't say 'Playwright' explicitly, as long as direct browser automation (not the Notion API) is the intended path. Do NOT use for Notion API/SDK work, for reading Notion, or for non-Notion web automation."
---

# Notion page update via Playwright

Replace a Notion page's **body** with local Markdown and reset its **title**,
by driving a real Chromium browser with Playwright. The whole flow is one
standalone Deno + TypeScript script that works through the browser rather than
the Notion API.

The script (`scripts/update_notion_page.ts`) launches a **persistent** browser
profile, so you log into Notion once and the session is reused on later runs —
the same model as the `gh-comment-attach-files` skill.

## When to use

- "Update / sync / reflect this Markdown into the Notion page <url>"
- You want to update through the browser rather than the Notion API.
- You are replacing the **whole body** of an existing page (and setting its
  title). For append-only or surgical edits, this isn't the right tool — the
  script clears the body wholesale before pasting.

Not for: Notion API/SDK tasks, merely reading a page, or non-Notion automation.

## Prerequisites

- `deno` installed.
- Playwright's Chromium installed once: `deno run -A npm:playwright install chromium`.
- The Markdown body exists as a local file (write it first if you generated it).
- **First run logs in interactively.** The script opens a real browser window;
  if Notion shows a login / SSO screen, finish signing in there while the script
  polls for the editor (up to `--ready-timeout`, default 180 s). The persistent
  profile (`./.playwright-cli/notion-playwright-update/profile`) keeps the
  session for subsequent runs.

## Run it

```bash
deno run -A ~/.claude/skills/notion-playwright-update/scripts/update_notion_page.ts \
  --url "<notion page url>" \
  --md  "<path/to/body.md>" \
  --title "<page title>"
```

Useful options:

- `--no-strip-h1` — keep a leading `# Heading` (by default it's stripped, since
  the page title already shows the H1 and keeping it duplicates the heading as
  the first body block).
- `--expect-contains "<substr>"` — safety guard: abort unless the loaded page's
  current title contains `<substr>`, so you can't clobber the wrong page.
- `--leave-open` — keep the browser open after finishing, e.g. to eyeball the
  result or undo by hand.
- `--profile-dir <path>` — use a different persistent profile.

The script prints a JSON result. Verify it:

- `clip_result` == `"clipboard"` (clipboard write succeeded; anything else means
  the paste used the best-effort synthetic fallback — see Troubleshooting).
- `after_clear` is small (≤ ~5). If the script threw "Body did not clear", the
  page wasn't modified destructively past the clear attempt — retry.
- `after_paste` is clearly larger than `after_clear` and roughly the rendered
  length of your Markdown.
- `title_after` equals the title you passed.
- `title_before` is a sanity check that you hit the page you meant to.

If anything looks off, just **re-run** — the script always clears before
pasting, so re-running fully replaces the body and re-fixes the title (it's
self-correcting). Use `--leave-open` if you want to inspect or `Cmd+Z` manually.

## Why this is non-trivial — read before changing the script's strategy

Notion's editor is a React-controlled `contenteditable`. These failure modes
shaped the script; respect them or you'll silently corrupt pages. Full detail in
`references/notion-dom.md`.

- **Synthetic `Cmd+A` does not "select all blocks."** In a real browser the 2nd
  `Cmd+A` escalates from "this block" to "every block"; through Playwright's
  synthetic keys it does not. So the script clears by deleting a real DOM
  **`Range`** over `.notion-page-content` instead.
- **The title is OUTSIDE `.notion-page-content`.** That's the safety property: a
  Range over the body can't select the title. The title is its own element,
  `[contenteditable="true"][placeholder="New page"]`.
- **Deleting the last body block merges its text into the title.** So after
  pasting, the script always rewrites the title (`insertText`, which handles
  non-ASCII cleanly).
- **Clearing can leave a residual block.** The script loops the Range-delete
  until the body is truly empty, which avoids a stray block surviving at the top
  and the paste landing after it.
- **Paste needs clipboard permission + focus.** The persistent context is
  launched with clipboard permissions; the script focuses the body by element
  (not fixed coordinates) so the paste can't land in a grown title.
- **Mermaid/flowchart fences paste as code blocks, not rendered diagrams.**
  Content is faithful; rendering is a manual per-block toggle (see Notes).

## Troubleshooting

- **`clip_result: "no-clipboard"` / `clip-err:…`** — the page lacked clipboard
  access; the script fell back to a synthetic `paste` event, which Notion may
  ignore. Re-run; if it persists, confirm the browser launched with clipboard
  permissions (it does by default here).
- **"Timed out waiting for the Notion editor"** — login wasn't completed in the
  window within `--ready-timeout`. Re-run and sign in promptly, or raise the
  timeout.
- **"Body did not clear"** — the Range delete didn't take (page still loading,
  or an unexpected layout). Re-run; if it keeps failing, open with `--leave-open`
  and inspect the DOM against `references/notion-dom.md`.
- **Title still polluted** — re-run; the title-fix step runs every time. (A
  pollution can only happen mid-run; a completed run always ends by setting the
  title.)
- **Diagrams show as code** — expected. To render, open each Mermaid/flowchart
  code block in Notion and use its top-right **Code / Split / Preview** toggle.
  This is a manual per-block step; automating it is unreliable.

## Reference

`references/notion-dom.md` — the DOM selectors this relies on, why each failure
mode happens, and the reasoning behind the clear / paste / title-fix sequence.
Read it before changing the script's strategy.
