#!/usr/bin/env -S deno run -A
// The page.evaluate() callbacks below run inside the browser, so they use DOM
// globals (document, window, HTMLElement). Pull in the DOM lib so `deno check`
// type-checks them; this does not affect the Deno-side code.
/// <reference lib="dom" />
/// <reference lib="dom.iterable" />
/**
 * Replace the body of an existing Notion page with local Markdown and reset
 * the page title, by driving a real Chromium browser via Playwright.
 *
 * This drives the browser rather than the Notion API, which is useful when
 * browser automation is the intended path (e.g. the API isn't available or set
 * up). It launches a persistent Chromium profile (so login is reused across
 * runs), opens the target page, clears the existing body, pastes the Markdown
 * (Notion converts it to blocks on paste), and rewrites the title.
 *
 * Notion's editor is a React-controlled `contenteditable`, which breaks naive
 * automation. The approach here is deliberately specific — see the inline notes
 * and `references/notion-dom.md`:
 *   - The body is cleared by deleting a DOM `Range` over `.notion-page-content`,
 *     NOT via Cmd+A (synthetic Cmd+A does not escalate to whole-page selection).
 *   - The title lives OUTSIDE `.notion-page-content`, so the Range can never
 *     touch it — but deleting the last body block merges its text into the
 *     title, so the title is always rewritten afterwards.
 *
 * @example
 * ```bash
 * deno run -A update_notion_page.ts \
 *   --url https://www.notion.so/workspace/Page-abc123 \
 *   --md docs/body.md \
 *   --title "My Page Title"
 * ```
 *
 * First run: if Notion shows a login/SSO screen, finish signing in inside the
 * opened window while the script polls for the editor. The persistent profile
 * keeps the session for later runs.
 */

import { chromium, type BrowserContext, type Page } from "npm:playwright";
import { existsSync, mkdirSync, readFileSync, statSync } from "node:fs";
import { resolve } from "node:path";
import process from "node:process";

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/** The page body container. Holds ONLY body blocks — the title is outside it. */
const BODY_SEL = ".notion-page-content";

/**
 * The page title element. `placeholder="New page"` persists even when the
 * title is non-empty, which makes it a stable handle. It lives above/outside
 * {@link BODY_SEL}, which is the property that makes body-clearing title-safe.
 */
const TITLE_SEL = '[contenteditable="true"][placeholder="New page"]';

/** Notion's scroll container. `window.scrollTo` does nothing; this does. */
const SCROLLER_SEL = ".notion-scroller";

/** Body innerText length at/below which the body is considered empty. */
const EMPTY_LEN = 5;
/** If the body still has more than this after clearing, treat clearing as failed. */
const CLEAR_FAIL_LEN = 80;
/** Max clear passes before giving up (guards against spinning). */
const MAX_CLEAR_PASSES = 8;

/** Notion needs time to parse a pasted Markdown blob into blocks. */
const MIN_PASTE_WAIT_MS = 6000;
const MAX_PASTE_WAIT_MS = 16000;

/** Platform-appropriate paste modifier. */
const PASTE_MODIFIER = process.platform === "darwin" ? "Meta" : "Control";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

/** Validated and normalized CLI arguments. */
interface CliArgs {
  /** Target Notion page URL. */
  readonly url: string;
  /** Path to the Markdown file whose content becomes the new body. */
  readonly mdPath: string;
  /** Title to set on the page after pasting (also repairs any title pollution). */
  readonly title: string;
  /** Directory for the persistent Playwright browser profile (keeps login). */
  readonly profileDir: string;
  /** Optional Playwright browser channel override (e.g. `"chrome"`). */
  readonly browser?: string;
  /** Max seconds to wait for the editor to be ready (covers interactive login). */
  readonly readyTimeout: number;
  /** Seconds between readiness polls. */
  readonly pollInterval: number;
  /** Strip a leading `# Heading` from the Markdown (the title holds the H1). */
  readonly stripH1: boolean;
  /** Optional guard: abort if the loaded page title does not contain this. */
  readonly expectContains?: string;
  /** Keep the browser open after finishing (for inspection / manual undo). */
  readonly leaveOpen: boolean;
}

/** Diagnostics printed as JSON on success. */
interface UpdateResult {
  readonly target_url: string;
  readonly title_before: string | null;
  readonly title_after: string | null;
  readonly before_len: number;
  readonly clear_passes: number[];
  readonly after_clear: number;
  readonly clip_result: string;
  readonly after_paste: number;
}

// ---------------------------------------------------------------------------
// CLI Argument Parsing
// ---------------------------------------------------------------------------

function printUsage(): void {
  console.log(`Usage: update_notion_page.ts [options]

Required:
  --url <url>              Target Notion page URL
  --md <path>              Markdown file to paste as the new body
  --title <text>           Title to set on the page

Options:
  --profile-dir <path>     Persistent browser profile dir
                           (default: .playwright-cli/notion-playwright-update/profile)
  --browser <name>         Browser channel (chrome, msedge)
  --ready-timeout <secs>   Wait for editor / login (default: 180)
  --poll-interval <secs>   Readiness poll interval (default: 2.0)
  --expect-contains <str>  Abort unless the loaded page title contains <str>
  --no-strip-h1            Keep a leading '# Heading' line (default: strip it)
  --leave-open             Keep the browser open after finishing
  -h, --help               Show this help`);
}

/**
 * Parse `process.argv` into validated {@link CliArgs}.
 * @throws {Error} on unknown flags or missing required arguments.
 */
function parseArgs(argv: string[]): CliArgs {
  const args = argv.slice(2);
  let url: string | undefined;
  let mdPath: string | undefined;
  let title: string | undefined;
  let profileDir = ".playwright-cli/notion-playwright-update/profile";
  let browser: string | undefined;
  let readyTimeout = 180;
  let pollInterval = 2.0;
  let stripH1 = true;
  let expectContains: string | undefined;
  let leaveOpen = false;

  let i = 0;
  while (i < args.length) {
    const arg = args[i];
    switch (arg) {
      case "--url": url = args[++i]; break;
      case "--md": mdPath = args[++i]; break;
      case "--title": title = args[++i]; break;
      case "--profile-dir": profileDir = args[++i]; break;
      case "--browser": browser = args[++i]; break;
      case "--ready-timeout": readyTimeout = parseInt(args[++i], 10); break;
      case "--poll-interval": pollInterval = parseFloat(args[++i]); break;
      case "--expect-contains": expectContains = args[++i]; break;
      case "--no-strip-h1": stripH1 = false; break;
      case "--leave-open": leaveOpen = true; break;
      case "-h":
      case "--help": printUsage(); process.exit(0); break;
      default:
        throw new Error(`Unknown option: ${arg}`);
    }
    i++;
  }

  if (!url) throw new Error("--url is required");
  if (!mdPath) throw new Error("--md is required");
  if (!title) throw new Error("--title is required");

  return {
    url, mdPath, title, profileDir, browser,
    readyTimeout, pollInterval, stripH1, expectContains, leaveOpen,
  };
}

// ---------------------------------------------------------------------------
// Markdown preparation
// ---------------------------------------------------------------------------

/**
 * Drop a leading `# Heading` line (and following blank lines).
 * The Notion page title already holds the H1, so keeping the Markdown's
 * leading `#` would duplicate it as the first body block.
 */
function stripLeadingH1(text: string): string {
  const lines = text.split("\n");
  if (lines[0]?.startsWith("# ")) {
    lines.shift();
    while (lines.length > 0 && lines[0].trim() === "") lines.shift();
  }
  return lines.join("\n");
}

function pasteWaitMs(bodyLen: number): number {
  return Math.max(MIN_PASTE_WAIT_MS, Math.min(MAX_PASTE_WAIT_MS, Math.floor(bodyLen / 3) + 4000));
}

// ---------------------------------------------------------------------------
// Browser management
// ---------------------------------------------------------------------------

/**
 * Launch a persistent Chromium context. The persistent profile keeps the
 * Notion login across runs; clipboard permission is granted up front so
 * `navigator.clipboard.writeText` works during the paste.
 */
async function launchBrowser(profileDir: string, channel?: string): Promise<BrowserContext> {
  mkdirSync(profileDir, { recursive: true });
  return chromium.launchPersistentContext(profileDir, {
    headless: false,
    channel: channel as "chrome" | "msedge" | undefined,
    permissions: ["clipboard-read", "clipboard-write"],
  });
}

// ---------------------------------------------------------------------------
// Page helpers (run inside the browser via page.evaluate)
// ---------------------------------------------------------------------------

/** Body innerText length, or -1 if the body container isn't present yet. */
async function bodyLen(page: Page): Promise<number> {
  return page.evaluate((sel) => {
    const el = document.querySelector(sel);
    return el ? (el as HTMLElement).innerText.length : -1;
  }, BODY_SEL);
}

/** Current title text, or null if the title element isn't present. */
async function titleText(page: Page): Promise<string | null> {
  return page.evaluate((sel) => {
    const t = document.querySelector(sel);
    return t ? (t as HTMLElement).innerText : null;
  }, TITLE_SEL);
}

/**
 * Poll until the editor is rendered (both body and title elements present).
 * While not ready, the user may be completing a login / SSO redirect, so
 * navigation errors are swallowed and retried.
 */
async function waitForEditor(page: Page, timeoutSecs: number, pollSecs: number): Promise<void> {
  const deadline = Date.now() + timeoutSecs * 1000;
  while (true) {
    try {
      const ready = await page.evaluate(
        ({ body, title }) => !!document.querySelector(body) && !!document.querySelector(title),
        { body: BODY_SEL, title: TITLE_SEL },
      );
      if (ready) return;
    } catch {
      // Page is navigating (login redirect / SSO) — retry.
    }
    if (Date.now() >= deadline) {
      throw new Error("Timed out waiting for the Notion editor (login not completed?)");
    }
    await new Promise((r) => setTimeout(r, pollSecs * 1000));
  }
}

/**
 * Select ALL of the body via a DOM Range and focus its editable leaf.
 * Scoping the Range to {@link BODY_SEL} guarantees the title is excluded.
 */
async function selectAllBody(page: Page): Promise<void> {
  await page.evaluate((sel) => {
    const content = document.querySelector(sel);
    if (!content) return;
    const inner = content.querySelector('[contenteditable="true"]') as HTMLElement | null;
    if (inner) inner.focus();
    const range = document.createRange();
    range.selectNodeContents(content);
    const selection = window.getSelection();
    selection?.removeAllRanges();
    selection?.addRange(range);
  }, BODY_SEL);
}

/**
 * Clear the body. Loops because a single Range-delete can leave a residual
 * block; keeps going until the body is empty (Notion always keeps one empty
 * paragraph, hence {@link EMPTY_LEN}) or a pass stops making progress.
 *
 * @returns The body length observed after each pass (diagnostics).
 */
async function clearBody(page: Page): Promise<number[]> {
  const passes: number[] = [];
  let prev = Infinity;
  for (let i = 0; i < MAX_CLEAR_PASSES; i++) {
    await page.locator(BODY_SEL).click();
    await page.waitForTimeout(200);
    await selectAllBody(page);
    await page.waitForTimeout(180);
    await page.keyboard.press("Backspace");
    await page.waitForTimeout(800);
    const len = await bodyLen(page);
    passes.push(len);
    if (len <= EMPTY_LEN) break;
    if (len >= prev) break; // no progress — bail to caller's guard
    prev = len;
  }
  return passes;
}

/**
 * Put the Markdown on the clipboard and paste it. Focusing the body via a
 * locator click (not fixed coordinates) keeps the paste targeted at the body
 * even when a merged-in title has grown tall after clearing.
 *
 * @returns `"clipboard"` on the normal path, or a diagnostic string if the
 *   clipboard API was unavailable and the synthetic-paste fallback was used.
 */
async function pasteMarkdown(page: Page, markdown: string): Promise<string> {
  await page.locator(BODY_SEL).click();
  await page.waitForTimeout(250);

  const clipResult = await page.evaluate(async (text) => {
    if (navigator.clipboard?.writeText) {
      try {
        await navigator.clipboard.writeText(text);
        return "clipboard";
      } catch (e) {
        return "clip-err:" + (e as Error).message;
      }
    }
    return "no-clipboard";
  }, markdown);

  if (clipResult === "clipboard") {
    await page.keyboard.press(`${PASTE_MODIFIER}+v`);
  } else {
    // Fallback: dispatch a synthetic paste event carrying the text. Notion may
    // ignore untrusted events, so this is best-effort only.
    await page.evaluate((text) => {
      const dt = new DataTransfer();
      dt.setData("text/plain", text);
      const ev = new ClipboardEvent("paste", { clipboardData: dt, bubbles: true, cancelable: true });
      (document.activeElement ?? document.body).dispatchEvent(ev);
    }, markdown);
  }
  return clipResult;
}

/**
 * Reset the title. Deleting the last body block merges its text into the
 * title, so this always runs. The selection is scoped to the title element,
 * and `insertText` replaces it (handles non-ASCII cleanly, unlike `type`).
 */
async function fixTitle(page: Page, title: string): Promise<void> {
  await page.locator(TITLE_SEL).first().click();
  await page.waitForTimeout(250);
  await page.evaluate((sel) => {
    const t = document.querySelector(sel);
    if (!t) return;
    const range = document.createRange();
    range.selectNodeContents(t);
    const selection = window.getSelection();
    selection?.removeAllRanges();
    selection?.addRange(range);
  }, TITLE_SEL);
  await page.waitForTimeout(180);
  await page.keyboard.insertText(title);
  await page.waitForTimeout(500);
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main(): Promise<void> {
  const args = parseArgs(process.argv);

  const mdResolved = resolve(args.mdPath);
  if (!existsSync(mdResolved) || !statSync(mdResolved).isFile()) {
    throw new Error(`Markdown file not found: ${mdResolved}`);
  }
  const raw = readFileSync(mdResolved, "utf-8");
  const body = args.stripH1 ? stripLeadingH1(raw) : raw;

  const profileDir = resolve(args.profileDir);
  let context: BrowserContext | undefined;
  try {
    context = await launchBrowser(profileDir, args.browser);
    const page = context.pages()[0] ?? (await context.newPage());

    await page.goto(args.url, { waitUntil: "domcontentloaded" });
    await waitForEditor(page, args.readyTimeout, args.pollInterval);

    const titleBefore = await titleText(page);
    if (args.expectContains && !(titleBefore ?? "").includes(args.expectContains)) {
      throw new Error(
        `Title guard failed: page title ${JSON.stringify(titleBefore)} does not contain ${JSON.stringify(args.expectContains)}`,
      );
    }

    await page.evaluate((sel) => {
      const s = document.querySelector(sel) as HTMLElement | null;
      if (s) s.scrollTop = 0;
    }, SCROLLER_SEL);
    await page.waitForTimeout(300);

    const beforeLen = await bodyLen(page);
    const clearPasses = await clearBody(page);
    const afterClear = await bodyLen(page);
    if (afterClear > CLEAR_FAIL_LEN) {
      throw new Error(`Body did not clear (len=${afterClear} after ${clearPasses.length} passes): ${JSON.stringify(clearPasses)}`);
    }

    const clipResult = await pasteMarkdown(page, body);
    await page.waitForTimeout(pasteWaitMs(body.length));
    const afterPaste = await bodyLen(page);

    await fixTitle(page, args.title);
    const titleAfter = await titleText(page);

    const result: UpdateResult = {
      target_url: args.url,
      title_before: titleBefore,
      title_after: titleAfter,
      before_len: beforeLen,
      clear_passes: clearPasses,
      after_clear: afterClear,
      clip_result: clipResult,
      after_paste: afterPaste,
    };
    console.log(JSON.stringify(result, null, 2));
  } finally {
    if (!args.leaveOpen && context) {
      await context.close();
    }
  }
}

main().catch((err) => {
  console.error(err instanceof Error ? err.message : String(err));
  process.exit(1);
});
