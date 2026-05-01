#!/usr/bin/env npx tsx
/**
 * Attach local files to a GitHub comment draft and return hosted URLs.
 *
 * GitHub does not expose a public API for uploading file attachments to
 * issue / PR comments. This script works around that limitation by driving
 * a real Chromium browser via Playwright, pasting files into the comment
 * composer, and scraping the resulting attachment URLs from the textarea.
 *
 * The comment is **never submitted** — the browser is closed (or left open
 * with `--leave-open`) once all URLs have been collected.
 *
 * @example
 * ```bash
 * # Direct URL
 * npx tsx attach_comment_files.ts \
 *   --url https://github.com/OWNER/REPO/pull/123 \
 *   screenshot.png report.pdf
 *
 * # Resolve via gh CLI
 * npx tsx attach_comment_files.ts \
 *   --repo OWNER/REPO --pr 123 \
 *   screenshot.png report.pdf
 * ```
 *
 * @see https://zenn.dev/shunk031/articles/gh-comment-attach-files-skill
 * @see https://github.com/shunk031/dotfiles/tree/master/home/dot_config/agents/skills/gh-comment-attach-files
 */

import { chromium, type BrowserContext, type Page } from "playwright";
import { execFileSync } from "node:child_process";
import { copyFileSync, existsSync, mkdirSync, rmSync, statSync } from "node:fs";
import { createHash } from "node:crypto";
import { basename, extname, join, resolve } from "node:path";

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

/**
 * CSS selectors for locating GitHub's comment textarea.
 * Multiple selectors are tried in order because GitHub uses different
 * markup across issue pages, PR pages, and review comment forms.
 */
const TEXTAREA_SELECTORS = [
  "textarea#new_comment_field",
  "textarea#pull_request_review_body",
  "textarea[name='comment[body]']",
  "textarea[name='pull_request_review[body]']",
  "textarea.js-comment-field",
];

/**
 * CSS selectors for locating the hidden `<input type="file">` element
 * that GitHub uses to receive drag-and-drop / paste file uploads.
 */
const FILE_INPUT_SELECTORS = [
  "file-attachment input[type='file']",
  "input.js-upload-markdown-image[type='file']",
  "input[type='file'][data-upload-policy-url]",
  "input[type='file'][multiple]",
];

/**
 * URL path fragments that identify GitHub-hosted attachment URLs.
 * Used to distinguish attachment links from ordinary links in the
 * textarea content and the page HTML.
 */
const ATTACHMENT_URL_HINTS = ["/user-attachments/", "/attachments/"];

/** Matches Markdown image/link syntax: `![label](url)` or `[label](url)` */
const MARKDOWN_LINK_RE =
  /!?\[(?<label>[^\]]*)\]\((?<url>https?:\/\/[^)\s]+)\)/g;

/**
 * Matches HTML `<img src="...">` tags.
 * GitHub's current UI inserts `<img>` tags instead of Markdown links
 * for uploaded images, so both formats must be handled.
 */
const HTML_IMG_RE =
  /<img\s[^>]*\bsrc="(?<url>https?:\/\/[^"]+)"[^>]*\/?>/g;

/**
 * Custom data attribute used to mark the textarea and file input elements
 * found by {@link findCommentComposer}. Subsequent operations
 * ({@link performUpload}, {@link getComposerMarkdown}) locate these
 * marked elements by this attribute instead of re-running the full
 * selector search.
 */
const ATTR_KEY = "data-gh-comment-attach";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

/**
 * A local file that has been copied into the run-specific uploads directory.
 * The staged copy has a unique name derived from the original path's SHA-1
 * hash, which prevents collisions when multiple files share the same basename.
 */
interface StagedFile {
  /** Absolute path to the original source file. */
  readonly sourcePath: string;
  /** Absolute path to the staged copy inside the uploads directory. */
  readonly stagedPath: string;
  /** Basename of the staged copy (e.g. `chart--e5b6d4a1.png`). */
  readonly stagedName: string;
}

/** Target specified as a direct GitHub URL. */
interface UrlTarget {
  readonly kind: "url";
  readonly url: string;
}

/** Target specified as a `owner/repo` + issue number combination. */
interface RepoIssueTarget {
  readonly kind: "issue";
  readonly repo: string;
  readonly issue: number;
}

/** Target specified as a `owner/repo` + PR number combination. */
interface RepoPrTarget {
  readonly kind: "pr";
  readonly repo: string;
  readonly pr: number;
}

/**
 * Discriminated union representing how the target page is specified.
 * The `kind` field determines which variant is active and guarantees
 * type-safe access to variant-specific fields (e.g. `repo` is always
 * present when `kind` is `"issue"` or `"pr"`).
 */
type Target = UrlTarget | RepoIssueTarget | RepoPrTarget;

/** Validated and normalized CLI arguments. */
interface CliArgs {
  /** Where to open the browser — either a direct URL or a repo + number. */
  readonly target: Target;
  /** Playwright browser channel override (e.g. `"chrome"`, `"msedge"`). */
  readonly browser?: string;
  /** Directory for the persistent Playwright browser profile (cookies, etc.). */
  readonly profileDir: string;
  /** Maximum seconds to wait for the comment composer to appear. */
  readonly readyTimeout: number;
  /** Seconds between polling attempts for the comment composer. */
  readonly pollInterval: number;
  /** If true, keep the browser window open after collecting URLs. */
  readonly leaveOpen: boolean;
  /** If true, keep the staged uploads directory after completion. */
  readonly keepRunDir: boolean;
  /** Positional arguments — paths to the files to upload. */
  readonly files: string[];
}

/**
 * A single attachment link extracted from text (Markdown or HTML).
 * For Markdown links, `label` is the link text; for HTML `<img>` tags,
 * `label` is empty because the `alt` attribute may not include the
 * file extension.
 */
interface AttachmentLink {
  readonly label: string;
  readonly url: string;
}

// ---------------------------------------------------------------------------
// CLI Argument Parsing
// ---------------------------------------------------------------------------

/**
 * Intermediate representation of CLI arguments before validation.
 * All fields are optional or have defaults; {@link buildTarget} and
 * {@link parseArgs} perform the validation and narrowing into {@link CliArgs}.
 */
interface RawArgs {
  url?: string;
  repo?: string;
  issue?: number;
  pr?: number;
  browser?: string;
  profileDir: string;
  readyTimeout: number;
  pollInterval: number;
  leaveOpen: boolean;
  keepRunDir: boolean;
  files: string[];
}

/**
 * Parse `process.argv` into a loosely-typed {@link RawArgs} object.
 * No cross-field validation is performed here; that is deferred to
 * {@link buildTarget} and {@link parseArgs}.
 *
 * @param argv - Typically `process.argv` (first two entries are skipped).
 * @throws {Error} On unrecognized `--option` flags.
 */
function parseRawArgs(argv: string[]): RawArgs {
  const args = argv.slice(2);
  const raw: RawArgs = {
    profileDir: ".playwright-cli/gh-comment-attach-files/profile",
    readyTimeout: 180,
    pollInterval: 2.0,
    leaveOpen: false,
    keepRunDir: false,
    files: [],
  };

  let i = 0;
  while (i < args.length) {
    const arg = args[i];
    switch (arg) {
      case "--url":
        raw.url = args[++i];
        break;
      case "--repo":
        raw.repo = args[++i];
        break;
      case "--issue":
        raw.issue = parseInt(args[++i], 10);
        break;
      case "--pr":
        raw.pr = parseInt(args[++i], 10);
        break;
      case "--browser":
        raw.browser = args[++i];
        break;
      case "--profile-dir":
        raw.profileDir = args[++i];
        break;
      case "--ready-timeout":
        raw.readyTimeout = parseInt(args[++i], 10);
        break;
      case "--poll-interval":
        raw.pollInterval = parseFloat(args[++i]);
        break;
      case "--leave-open":
        raw.leaveOpen = true;
        break;
      case "--keep-run-dir":
        raw.keepRunDir = true;
        break;
      case "--help":
      case "-h":
        printUsage();
        process.exit(0);
        break;
      default:
        if (arg.startsWith("-")) {
          throw new Error(`Unknown option: ${arg}`);
        }
        raw.files.push(arg);
    }
    i++;
  }

  return raw;
}

/**
 * Validate the target-related fields of {@link RawArgs} and narrow
 * them into a {@link Target} discriminated union.
 *
 * @throws {Error} If the combination of `--url`, `--repo`, `--issue`,
 *   and `--pr` flags is invalid.
 */
function buildTarget(raw: RawArgs): Target {
  if (!raw.repo && (raw.issue != null || raw.pr != null)) {
    throw new Error("--issue/--pr requires --repo");
  }

  if (raw.url) return { kind: "url", url: raw.url };
  if (!raw.repo) throw new Error("Either --url or --repo is required");

  if (raw.issue != null) return { kind: "issue", repo: raw.repo, issue: raw.issue };
  if (raw.pr != null) return { kind: "pr", repo: raw.repo, pr: raw.pr };
  throw new Error("--repo requires either --issue or --pr");
}

/**
 * Parse and validate CLI arguments into a fully typed {@link CliArgs}.
 *
 * This is the main entry point for argument handling and composes
 * {@link parseRawArgs} (lexical parsing) and {@link buildTarget}
 * (semantic validation).
 *
 * @param argv - Typically `process.argv`.
 * @throws {Error} On any validation failure (missing required args, etc.).
 */
function parseArgs(argv: string[]): CliArgs {
  const raw = parseRawArgs(argv);
  const target = buildTarget(raw);

  if (raw.files.length === 0) {
    throw new Error("At least one file is required");
  }

  return {
    target,
    browser: raw.browser,
    profileDir: raw.profileDir,
    readyTimeout: raw.readyTimeout,
    pollInterval: raw.pollInterval,
    leaveOpen: raw.leaveOpen,
    keepRunDir: raw.keepRunDir,
    files: raw.files,
  };
}

function printUsage(): void {
  console.log(`Usage: attach_comment_files.ts [options] <files...>

Options:
  --url <url>              Direct issue or pull request URL
  --repo <owner/repo>      GitHub repo (requires --issue or --pr)
  --issue <number>         Issue number
  --pr <number>            Pull request number
  --browser <name>         Browser channel (chrome, firefox, webkit, msedge)
  --profile-dir <path>     Persistent browser profile directory
  --ready-timeout <secs>   Timeout for comment composer detection (default: 180)
  --poll-interval <secs>   Poll interval for readiness checks (default: 2.0)
  --leave-open             Keep browser open after collecting URLs
  --keep-run-dir           Keep the staged run directory
  -h, --help               Show this help`);
}

// ---------------------------------------------------------------------------
// URL Resolution
// ---------------------------------------------------------------------------

/**
 * Resolve the {@link Target} to a full GitHub URL.
 *
 * - For {@link UrlTarget}, the URL is returned as-is.
 * - For {@link RepoIssueTarget} / {@link RepoPrTarget}, the `gh` CLI is
 *   invoked to look up the canonical URL. This requires `gh auth login`
 *   to have been completed beforehand.
 *
 * @param target - The target to resolve.
 * @returns The full GitHub issue or PR page URL.
 */
function resolveTargetUrl(target: Target): string {
  if (target.kind === "url") return target.url;

  const number = target.kind === "issue" ? target.issue : target.pr;
  const output = execFileSync(
    "gh",
    [target.kind, "view", String(number), "--repo", target.repo, "--json", "url", "--jq", ".url"],
    { encoding: "utf-8" },
  );
  return output.trim();
}

// ---------------------------------------------------------------------------
// File Staging
// ---------------------------------------------------------------------------

/**
 * Copy source files into the uploads directory with collision-safe names.
 *
 * Each file is validated (must exist and be a regular file), then copied
 * with a name generated by {@link buildStagedName}. The staged copy is
 * what Playwright will actually upload to GitHub.
 *
 * @param sourcePaths - Paths to the files to stage (may be relative).
 * @param uploadsDir  - Destination directory for staged copies.
 * @returns An array of {@link StagedFile} descriptors in the same order
 *   as `sourcePaths`.
 * @throws {Error} If any source path does not exist or is not a file.
 */
function stageFiles(sourcePaths: string[], uploadsDir: string): StagedFile[] {
  const usedNames = new Set<string>();
  return sourcePaths.map((sourcePath) => {
    const resolved = resolve(sourcePath);
    if (!existsSync(resolved)) {
      throw new Error(`File not found: ${resolved}`);
    }
    if (!statSync(resolved).isFile()) {
      throw new Error(`Not a file: ${resolved}`);
    }
    const stagedName = buildStagedName(resolved, usedNames);
    const stagedPath = join(uploadsDir, stagedName);
    copyFileSync(resolved, stagedPath);
    return { sourcePath: resolved, stagedPath, stagedName };
  });
}

/**
 * Generate a unique staged filename from the source path.
 *
 * The name is composed of `{sanitized_stem}--{sha1_prefix}{ext}`.
 * If the resulting name collides with a previously used name, a numeric
 * suffix is appended (e.g. `chart--e5b6d4a1-2.png`).
 *
 * @param sourcePath - Absolute path to the source file.
 * @param usedNames  - Set of names already assigned in this batch.
 *   **Mutated**: the chosen name is added to the set.
 * @returns A unique filename safe for use as a GitHub attachment name.
 */
function buildStagedName(sourcePath: string, usedNames: Set<string>): string {
  const ext = extname(sourcePath);
  const stem = sanitizeComponent(basename(sourcePath, ext)) || "attachment";
  const digest = createHash("sha1").update(sourcePath).digest("hex").slice(0, 8);
  let candidate = `${stem}--${digest}${ext}`;
  let counter = 2;
  while (usedNames.has(candidate)) {
    candidate = `${stem}--${digest}-${counter}${ext}`;
    counter++;
  }
  usedNames.add(candidate);
  return candidate;
}

/**
 * Remove characters unsafe for filenames and trim leading/trailing
 * punctuation. The result is truncated to 80 characters.
 */
function sanitizeComponent(value: string): string {
  return value.replace(/[^A-Za-z0-9._-]+/g, "-").replace(/^[-._]+|[-._]+$/g, "").slice(0, 80);
}

// ---------------------------------------------------------------------------
// Browser Management
// ---------------------------------------------------------------------------

/**
 * Launch a persistent Chromium browser context.
 *
 * A persistent context stores cookies, localStorage, etc. across runs,
 * so the user only needs to log into GitHub once. Subsequent launches
 * reuse the session automatically.
 *
 * @param profileDir - Directory for the persistent browser profile.
 * @param channel    - Optional Playwright browser channel (`"chrome"`, `"msedge"`).
 * @returns A Playwright {@link BrowserContext} with an open window.
 */
async function launchBrowser(
  profileDir: string,
  channel?: string,
): Promise<BrowserContext> {
  mkdirSync(profileDir, { recursive: true });
  return chromium.launchPersistentContext(profileDir, {
    headless: false,
    channel: channel as "chrome" | "msedge" | undefined,
  });
}

// ---------------------------------------------------------------------------
// Comment Composer Detection
// ---------------------------------------------------------------------------

/**
 * Result of a comment composer search on the current page.
 * `pageTitle` and `pageUrl` are captured for diagnostic messages
 * (e.g. when the composer is not found after a timeout).
 */
interface ComposerResult {
  /** Whether a usable textarea + file input pair was found. */
  readonly found: boolean;
  readonly pageTitle: string;
  readonly pageUrl: string;
}

/**
 * Search the current page for a GitHub comment composer (textarea +
 * hidden file input pair) and mark the found elements with
 * {@link ATTR_KEY} data attributes.
 *
 * This function runs entirely inside the browser via `page.evaluate`.
 * It tries each combination of {@link TEXTAREA_SELECTORS} and
 * {@link FILE_INPUT_SELECTORS}, walking up the DOM from each textarea
 * to find the nearest file input within the same form or comment block.
 *
 * @param page - The Playwright page to search.
 * @returns A {@link ComposerResult} indicating whether the composer was found.
 */
async function findCommentComposer(page: Page): Promise<ComposerResult> {
  return page.evaluate(
    ({ textareaSelectors, inputSelectors, attrKey }) => {
      const visible = (el: Element | null): el is HTMLElement => {
        if (!el) return false;
        const style = window.getComputedStyle(el);
        if (style.visibility === "hidden" || style.display === "none") return false;
        const htmlEl = el as HTMLElement;
        return htmlEl.offsetWidth > 0 || htmlEl.offsetHeight > 0 || el.getClientRects().length > 0;
      };

      // Clear previous markers
      for (const el of document.querySelectorAll(`[${attrKey}]`)) {
        el.removeAttribute(attrKey);
      }

      // Collect unique visible textareas
      const seen = new Set<Element>();
      const textareas: HTMLTextAreaElement[] = [];
      for (const sel of textareaSelectors) {
        for (const el of document.querySelectorAll(sel)) {
          if (!seen.has(el) && visible(el)) {
            seen.add(el);
            textareas.push(el as HTMLTextAreaElement);
          }
        }
      }

      // Find matching textarea + file input pair
      for (const textarea of textareas) {
        const roots = [
          textarea.closest("form"),
          textarea.closest(".previewable-comment-form"),
          textarea.closest(".js-previewable-comment-form"),
          document,
        ].filter(Boolean) as ParentNode[];

        let input: HTMLInputElement | null = null;
        for (const root of roots) {
          for (const sel of inputSelectors) {
            const found = Array.from(root.querySelectorAll(sel)).find(
              (el): el is HTMLInputElement => el instanceof HTMLInputElement,
            );
            if (found) {
              input = found;
              break;
            }
          }
          if (input) break;
        }
        if (!input) continue;

        textarea.setAttribute(attrKey, "textarea");
        input.setAttribute(attrKey, "input");
        textarea.scrollIntoView({ block: "center" });
        return { found: true, pageTitle: document.title, pageUrl: window.location.href };
      }

      return { found: false, pageTitle: document.title, pageUrl: window.location.href };
    },
    { textareaSelectors: TEXTAREA_SELECTORS, inputSelectors: FILE_INPUT_SELECTORS, attrKey: ATTR_KEY },
  );
}

/**
 * Poll until a comment composer is found or the timeout expires.
 *
 * Errors from {@link findCommentComposer} (e.g. navigation-induced
 * context destruction during login redirects or SSO) are silently
 * caught and retried.
 *
 * @param page             - The Playwright page to monitor.
 * @param timeoutSecs      - Maximum seconds to wait.
 * @param pollIntervalSecs - Seconds between polling attempts.
 * @throws {Error} If no composer is found within the timeout.
 */
async function waitForCommentComposer(
  page: Page,
  timeoutSecs: number,
  pollIntervalSecs: number,
): Promise<void> {
  const deadline = Date.now() + timeoutSecs * 1000;
  while (true) {
    try {
      const result = await findCommentComposer(page);
      if (result.found) return;
    } catch {
      // Page may be navigating (login redirect, SSO, etc.) — retry
    }
    if (Date.now() >= deadline) {
      throw new Error("Timed out waiting for a GitHub comment composer");
    }
    await new Promise((r) => setTimeout(r, pollIntervalSecs * 1000));
  }
}

// ---------------------------------------------------------------------------
// File Upload
// ---------------------------------------------------------------------------

/**
 * Upload a single staged file to the comment composer and wait for
 * the attachment URL to appear in the textarea.
 *
 * Workflow:
 * 1. Re-discover the composer (page state may have changed since the
 *    last upload).
 * 2. Capture the textarea's current value (`before`).
 * 3. Set the file on the hidden `<input type="file">` element.
 * 4. Wait until the textarea value contains an attachment URL hint
 *    (e.g. `/user-attachments/`). The intermediate "Uploading..." placeholder
 *    (`![Uploading file…]()`) is intentionally ignored.
 * 5. Capture and return the textarea's new value (`after`).
 *
 * @param page      - The Playwright page with a marked composer.
 * @param staged    - The staged file to upload.
 * @param timeoutMs - Maximum milliseconds to wait for the upload.
 * @returns The textarea content before and after the upload.
 * @throws {Error} If the composer is not found or the upload times out.
 */
async function performUpload(
  page: Page,
  staged: StagedFile,
  timeoutMs: number,
): Promise<{ before: string; after: string }> {
  const result = await findCommentComposer(page);
  if (!result.found) {
    throw new Error("Comment composer not found during upload");
  }

  const textarea = page.locator(`[${ATTR_KEY}='textarea']`).first();
  const input = page.locator(`[${ATTR_KEY}='input']`).first();
  const before = await textarea.inputValue();

  await input.setInputFiles(staged.stagedPath);

  await page.waitForFunction(
    ({ selector, previous, urlHints }) => {
      const el = document.querySelector(selector);
      if (!(el instanceof HTMLTextAreaElement)) return false;
      const value = el.value || "";
      if (value === previous) return false;
      // Wait for actual URL, not the "Uploading..." placeholder
      return urlHints.some((hint) => value.includes(hint));
    },
    {
      selector: `[${ATTR_KEY}='textarea']`,
      previous: before,
      urlHints: ATTACHMENT_URL_HINTS,
    },
    { timeout: timeoutMs },
  );

  const after = await textarea.inputValue();
  return { before, after };
}

/** Read the current Markdown content of the marked comment composer textarea. */
async function getComposerMarkdown(page: Page): Promise<string> {
  const textarea = page.locator(`[${ATTR_KEY}='textarea']`).first();
  if ((await textarea.count()) === 0) return "";
  return textarea.inputValue();
}

// ---------------------------------------------------------------------------
// Attachment URL Extraction
// ---------------------------------------------------------------------------

/**
 * Extract GitHub attachment links from a text that may contain
 * Markdown links (`![label](url)`) and/or HTML `<img>` tags.
 *
 * Only links whose URL contains one of the {@link ATTACHMENT_URL_HINTS}
 * are returned. Ordinary links (e.g. to other issues) are ignored.
 *
 * @param text - Raw textarea content or page HTML to scan.
 * @returns Extracted attachment links. For HTML `<img>` tags, `label`
 *   is empty because the `alt` attribute may omit the file extension.
 */
function extractAttachmentLinks(text: string): AttachmentLink[] {
  const fromMarkdown = [...text.matchAll(MARKDOWN_LINK_RE)].flatMap((match) => {
    const url = match.groups?.url;
    const label = match.groups?.label;
    if (url == null || label == null) return [];
    if (!ATTACHMENT_URL_HINTS.some((hint) => url.includes(hint))) return [];
    return [{ label, url }];
  });

  const fromHtml = [...text.matchAll(HTML_IMG_RE)].flatMap((match) => {
    const url = match.groups?.url;
    if (url == null) return [];
    if (!ATTACHMENT_URL_HINTS.some((hint) => url.includes(hint))) return [];
    // alt attribute may omit the file extension, use URL as label fallback
    return [{ label: "", url }];
  });

  return [...fromMarkdown, ...fromHtml];
}

/**
 * Determine the attachment URL for a specific uploaded file by comparing
 * the textarea / page content before and after the upload.
 *
 * Three strategies are tried in order:
 * 1. **Exact match** — a new link whose label matches `stagedName`.
 * 2. **Any new URL** — any attachment URL that wasn't present before
 *    (takes the last one, which is typically the most recent upload).
 * 3. **Fallback** — any existing link whose label matches `stagedName`.
 *
 * @param stagedName  - The staged filename to look for in link labels.
 * @param beforeTexts - Textarea content and page HTML captured before upload.
 * @param afterTexts  - Textarea content and page HTML captured after upload.
 * @returns The attachment URL, or `undefined` if none was found.
 */
function findAttachmentUrl(
  stagedName: string,
  beforeTexts: string[],
  afterTexts: string[],
): string | undefined {
  const beforeLinks = extractAttachmentLinks(beforeTexts.join("\n"));
  const afterLinks = extractAttachmentLinks(afterTexts.join("\n"));

  const beforePairs = new Set(beforeLinks.map((l) => `${l.label}\0${l.url}`));

  // Exact match by staged name (new link)
  for (const link of afterLinks) {
    if (link.label === stagedName && !beforePairs.has(`${link.label}\0${link.url}`)) {
      return link.url;
    }
  }

  // Any new URL
  const beforeUrls = new Set(beforeLinks.map((l) => l.url));
  const newUrls = afterLinks.filter((l) => !beforeUrls.has(l.url));
  if (newUrls.length > 0) return newUrls[newUrls.length - 1].url;

  // Fallback: any link matching staged name
  return afterLinks.find((l) => l.label === stagedName)?.url;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

/**
 * Entry point: parse CLI args, launch browser, upload files, and print
 * the resulting attachment URLs as JSON to stdout.
 *
 * Output format:
 * ```json
 * {
 *   "target_url": "https://github.com/OWNER/REPO/pull/123",
 *   "attachments": [
 *     {
 *       "source_path": "/abs/path/to/file.png",
 *       "staged_name": "file--a1b2c3d4.png",
 *       "attachment_url": "https://github.com/user-attachments/assets/..."
 *     }
 *   ]
 * }
 * ```
 */
async function main(): Promise<void> {
  const args = parseArgs(process.argv);
  const targetUrl = resolveTargetUrl(args.target);

  const now = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
  const baseDir = join(process.cwd(), ".playwright-cli", "gh-comment-attach-files");
  const runDir = join(baseDir, `run-${now}`);
  const uploadsDir = join(runDir, "uploads");
  const profileDir = resolve(args.profileDir);

  mkdirSync(uploadsDir, { recursive: true });
  const stagedFiles = stageFiles(args.files, uploadsDir);

  let context: BrowserContext | undefined;
  try {
    context = await launchBrowser(profileDir, args.browser);
    const page = context.pages()[0] ?? (await context.newPage());
    // esbuild (via tsx) injects __name helper calls that don't exist in browser context
    await page.addInitScript("globalThis.__name = globalThis.__name || ((fn, _) => fn)");
    await page.goto(targetUrl, { waitUntil: "domcontentloaded" });
    await waitForCommentComposer(page, args.readyTimeout, args.pollInterval);

    const attachments: { source_path: string; staged_name: string; attachment_url: string }[] = [];

    for (const staged of stagedFiles) {
      const composerBefore = await getComposerMarkdown(page);
      const snapshotBefore = await page.content();
      const uploadResult = await performUpload(page, staged, args.readyTimeout * 1000);
      const snapshotAfter = await page.content();

      const attachmentUrl = findAttachmentUrl(
        staged.stagedName,
        [composerBefore, snapshotBefore],
        [uploadResult.after, snapshotAfter],
      );
      if (!attachmentUrl) {
        throw new Error(`Failed to find attachment URL for: ${staged.stagedName}`);
      }
      attachments.push({
        source_path: staged.sourcePath,
        staged_name: staged.stagedName,
        attachment_url: attachmentUrl,
      });
    }

    console.log(JSON.stringify({ target_url: targetUrl, attachments }, null, 2));
  } finally {
    if (!args.leaveOpen && context) {
      await context.close();
    }
    if (!args.keepRunDir && !args.leaveOpen) {
      rmSync(runDir, { recursive: true, force: true });
    }
  }
}

main().catch((err) => {
  console.error(err instanceof Error ? err.message : String(err));
  process.exit(1);
});
