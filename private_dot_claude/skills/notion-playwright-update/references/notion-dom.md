# Notion DOM & automation notes

Background for `notion-playwright-update`. Read this before changing the
script's strategy. Notion's web app is a React-controlled `contenteditable`
editor, so several "obvious" automations fail in non-obvious ways — each rule
here addresses one of those traps.

## Selectors that matter

| What | Selector | Notes |
|------|----------|-------|
| Page body container | `.notion-page-content` | Holds **only** the body blocks. The title is NOT inside it. `innerText.length` is a reliable progress signal. |
| A body block | `.notion-page-content [data-block-id]` | One per block. `querySelectorAll(...).length` ≈ block count. |
| An editable leaf | `[contenteditable="true"]` | Title and each text block are separate editable leaves. |
| **Page title** | `[contenteditable="true"][placeholder="New page"]` | The title element. `placeholder="New page"` persists even when the title is non-empty, which makes it a stable handle. Lives **above/outside** `.notion-page-content`. |
| Scroll container | `.notion-scroller` | Set `.scrollTop`; `window.scrollTo` does nothing because the body isn't the scroller. Note Notion virtualizes long pages, so `scrollTop` mid-page may not stick — prefer reading via the DOM over scrolling+screenshotting. |
| Tab title | `document.title` | `"<page title> | Notion"`. Cheap way to read the current title without a selector. |

## Failure modes and why the flow is shaped the way it is

### 1. Synthetic `Cmd+A` does not escalate to whole-page selection

In a real browser, the first `Cmd+A` in a block selects that block's text; a
second `Cmd+A` escalates to selecting **all blocks**. Through Playwright's
synthetic key events this escalation does **not** happen — you stay at
"current block's text." So the common "select all + Backspace" clears at most
one block (often the title, if the caret was there), leaving the body intact.

`Escape` → block-selection mode + `Shift+ArrowDown` to extend was also tried and
was unreliable through synthetic keys.

**What works:** build a real DOM `Range` with
`range.selectNodeContents(document.querySelector('.notion-page-content'))`, set
it as the selection, then press `Backspace`. Notion deletes the ranged blocks.
Because the Range is scoped to `.notion-page-content`, the title is structurally
excluded — it cannot be selected or deleted this way.

### 2. Deleting the last body block merges it into the title

When the body is down to its final block and that block is deleted, Notion
merges the block's text **upward into the title** (the title becomes
`"<real title><leftover block text>"`, and the URL slug changes to match). This
is why the flow **always rewrites the title at the end**: select the title
element's contents via Range and `page.keyboard.insertText('<correct title>')`
(insertText replaces the current selection and handles non-ASCII/Japanese
cleanly, unlike char-by-char `type`).

### 3. Clearing partially → stray block at the top

If you stop clearing while a residual block remains (e.g. break when
`bodyLen <= 30` and one short block survives), the subsequent paste lands
**after** that residual, leaving a stray line at the very top of the page. Two
ways to avoid it:

- **Preferred (what the generator does):** keep clearing until the body is
  truly empty (`bodyLen <= 5`; Notion always keeps one empty paragraph). The
  final deletion merges into the title, which the title-fix step then repairs.
- **Surgical cleanup:** if a stray survives anyway, select the first block's
  contents (Range), `Backspace` to empty it, then forward-`Delete` to pull the
  next (real first) block up into its place. This removes the empty stray
  without touching the title.

### 4. Pasting Markdown

Notion converts pasted Markdown into blocks on a real paste. Steps that make it
reliable:

- `page.context().grantPermissions(['clipboard-read','clipboard-write'], {origin})`
  and `page.bringToFront()` — without these, `navigator.clipboard` is often
  `undefined` (the "Cannot read properties of undefined (reading 'writeText')"
  symptom) because the page lacks clipboard permission / OS focus.
- `navigator.clipboard.writeText(markdown)` then `page.keyboard.press('Meta+v')`.
- **Focus the body via the DOM before pasting, not a coordinate click.** After a
  full clear the merged title can be several lines tall, pushing the body down;
  a fixed `(x, y)` click could land in the title and the paste would go to the
  wrong element. `content.querySelector('[contenteditable="true"]').focus()` +
  a collapsed Range is position-independent.
- Strip the Markdown's leading `# Heading` — the page title already shows it, so
  keeping it duplicates the H1 as the first body block.
- Give Notion time to parse (the paste isn't instant for large docs); the
  generator scales the wait with body length.

### 5. Running as a standalone Deno + Playwright script

The flow runs as a normal Deno process driving its own Chromium via
`npm:playwright` — not through any MCP "run code in the page" tool. That choice
matters:

- **Login is reused.** `chromium.launchPersistentContext(profileDir, …)` stores
  cookies/localStorage under `./.playwright-cli/notion-playwright-update/profile`,
  so you log into Notion once (interactively, on the first run) and later runs
  reuse the session. The script polls for the editor while you sign in.
- **The Markdown is read at runtime** with `node:fs` — no embedding, no size
  limits, no escaping games.
- **Clipboard works** because the context is launched with
  `permissions: ['clipboard-read','clipboard-write']`; `navigator.clipboard.
  writeText` then succeeds and a real `Cmd/Ctrl+V` pastes.
- **Paste modifier is platform-aware**: `Meta+v` on macOS, `Control+v`
  elsewhere.

### 6. Recovery & safety

- The script **always clears before pasting**, so re-running it fully replaces
  the body and re-fixes the title — it's self-correcting. If a run looks wrong,
  just run it again.
- Pass `--leave-open` to keep the window after finishing, then inspect or undo
  by hand (`Cmd+Z` reliably reaches Notion — the failures above are about
  selection semantics, not key delivery).
- Pass `--expect-contains "<substr>"` to abort unless the loaded page's current
  title contains the substring — cheap insurance against clobbering the wrong
  page.

## Verification signals

After an update, a healthy result looks like:

- `clipResult === 'clipboard'`
- `afterClear` ≤ ~5 (body was emptied before paste)
- `afterPaste` clearly larger than `afterClear` and near the Markdown's rendered
  length
- `titleAfter.titleText` exactly equals the intended title
- first body block is the intended intro, not a leftover line

## Known limitations

- **Mermaid/flowchart** fences paste as code blocks, not rendered diagrams.
  Rendering is a per-block manual toggle (block's top-right **Code / Split /
  Preview**). Automating the toggle is unreliable.
- Tables, callouts, quotes, headings, and inline code convert faithfully.
- This flow is **whole-body replacement**. Append/surgical edits need a
  different approach (target a specific block rather than clearing everything).
