#!/usr/bin/env npx tsx
/**
 * Attach local files to a GitHub comment draft and return hosted URLs.
 *
 * Ref:
 * - https://zenn.dev/shunk031/articles/gh-comment-attach-files-skill
 * - https://github.com/shunk031/dotfiles/tree/master/home/dot_config/agents/skills/gh-comment-attach-files
 */

import { chromium, type BrowserContext, type Page } from "playwright";
import { execFileSync } from "node:child_process";
import { copyFileSync, mkdirSync, rmSync } from "node:fs";
import { createHash } from "node:crypto";
import { basename, extname, join, resolve } from "node:path";
import { existsSync, statSync } from "node:fs";

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const TEXTAREA_SELECTORS = [
  "textarea#new_comment_field",
  "textarea#pull_request_review_body",
  "textarea[name='comment[body]']",
  "textarea[name='pull_request_review[body]']",
  "textarea.js-comment-field",
];

const FILE_INPUT_SELECTORS = [
  "file-attachment input[type='file']",
  "input.js-upload-markdown-image[type='file']",
  "input[type='file'][data-upload-policy-url]",
  "input[type='file'][multiple]",
];

const ATTACHMENT_URL_HINTS = ["/user-attachments/", "/attachments/"];
const MARKDOWN_LINK_RE =
  /!?\[(?<label>[^\]]*)\]\((?<url>https?:\/\/[^)\s]+)\)/g;

const ATTR_KEY = "data-gh-comment-attach";

// ---------------------------------------------------------------------------
// Types
// ---------------------------------------------------------------------------

interface StagedFile {
  readonly sourcePath: string;
  readonly stagedPath: string;
  readonly stagedName: string;
}

interface CliArgs {
  readonly url?: string;
  readonly repo?: string;
  readonly issue?: number;
  readonly pr?: number;
  readonly browser?: string;
  readonly profileDir: string;
  readonly readyTimeout: number;
  readonly pollInterval: number;
  readonly leaveOpen: boolean;
  readonly keepRunDir: boolean;
  readonly files: string[];
}

interface AttachmentLink {
  readonly label: string;
  readonly url: string;
}

// ---------------------------------------------------------------------------
// CLI Argument Parsing
// ---------------------------------------------------------------------------

function parseArgs(argv: string[]): CliArgs {
  const args = argv.slice(2);
  const result: Record<string, string | number | boolean | string[]> = {
    profileDir: ".playwright-cli/gh-comment-attach-files/profile",
    readyTimeout: 180,
    pollInterval: 2.0,
    leaveOpen: false,
    keepRunDir: false,
    files: [],
  };

  const files: string[] = [];
  let i = 0;
  while (i < args.length) {
    const arg = args[i];
    switch (arg) {
      case "--url":
        result.url = args[++i];
        break;
      case "--repo":
        result.repo = args[++i];
        break;
      case "--issue":
        result.issue = parseInt(args[++i], 10);
        break;
      case "--pr":
        result.pr = parseInt(args[++i], 10);
        break;
      case "--browser":
        result.browser = args[++i];
        break;
      case "--profile-dir":
        result.profileDir = args[++i];
        break;
      case "--ready-timeout":
        result.readyTimeout = parseInt(args[++i], 10);
        break;
      case "--poll-interval":
        result.pollInterval = parseFloat(args[++i]);
        break;
      case "--leave-open":
        result.leaveOpen = true;
        break;
      case "--keep-run-dir":
        result.keepRunDir = true;
        break;
      case "--help":
      case "-h":
        printUsage();
        process.exit(0);
        break;
      default:
        if (arg.startsWith("-")) {
          console.error(`Unknown option: ${arg}`);
          process.exit(1);
        }
        files.push(arg);
    }
    i++;
  }
  result.files = files;

  if (!result.url && !result.repo) {
    console.error("Either --url or --repo is required");
    process.exit(1);
  }
  if (result.repo && !result.issue && !result.pr) {
    console.error("--repo requires either --issue or --pr");
    process.exit(1);
  }
  if (!result.repo && (result.issue || result.pr)) {
    console.error("--issue/--pr requires --repo");
    process.exit(1);
  }
  if (files.length === 0) {
    console.error("At least one file is required");
    process.exit(1);
  }

  return result as unknown as CliArgs;
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

function resolveTargetUrl(args: CliArgs): string {
  if (args.url) return args.url;

  const type = args.issue ? "issue" : "pr";
  const number = args.issue ?? args.pr;
  const output = execFileSync(
    "gh",
    [type, "view", String(number), "--repo", args.repo!, "--json", "url", "--jq", ".url"],
    { encoding: "utf-8" },
  );
  return output.trim();
}

// ---------------------------------------------------------------------------
// File Staging
// ---------------------------------------------------------------------------

function stageFiles(sourcePaths: string[], uploadsDir: string): StagedFile[] {
  const usedNames = new Set<string>();
  return sourcePaths.map((sourcePath) => {
    const resolved = resolve(sourcePath);
    if (!existsSync(resolved)) {
      console.error(`File not found: ${resolved}`);
      process.exit(1);
    }
    if (!statSync(resolved).isFile()) {
      console.error(`Not a file: ${resolved}`);
      process.exit(1);
    }
    const stagedName = buildStagedName(resolved, usedNames);
    const stagedPath = join(uploadsDir, stagedName);
    copyFileSync(resolved, stagedPath);
    return { sourcePath: resolved, stagedPath, stagedName };
  });
}

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

function sanitizeComponent(value: string): string {
  return value.replace(/[^A-Za-z0-9._-]+/g, "-").replace(/^[-._]+|[-._]+$/g, "").slice(0, 80);
}

// ---------------------------------------------------------------------------
// Browser Management
// ---------------------------------------------------------------------------

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
// Comment Composer Detection (unified — resolves prior duplication)
// ---------------------------------------------------------------------------

interface ComposerResult {
  readonly found: boolean;
  readonly pageTitle: string;
  readonly pageUrl: string;
}

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

async function waitForCommentComposer(
  page: Page,
  timeoutSecs: number,
  pollIntervalSecs: number,
): Promise<void> {
  const deadline = Date.now() + timeoutSecs * 1000;
  while (true) {
    const result = await findCommentComposer(page);
    if (result.found) return;
    if (Date.now() >= deadline) {
      throw new Error(
        `Timed out waiting for a GitHub comment composer. Last page: ${result.pageTitle} ${result.pageUrl}`,
      );
    }
    await new Promise((r) => setTimeout(r, pollIntervalSecs * 1000));
  }
}

// ---------------------------------------------------------------------------
// File Upload
// ---------------------------------------------------------------------------

async function performUpload(
  page: Page,
  staged: StagedFile,
  timeoutMs: number,
): Promise<{ before: string; after: string }> {
  // Re-discover composer (page state may have changed)
  const result = await findCommentComposer(page);
  if (!result.found) {
    throw new Error("Comment composer not found during upload");
  }

  const textarea = page.locator(`[${ATTR_KEY}='textarea']`).first();
  const input = page.locator(`[${ATTR_KEY}='input']`).first();
  const before = await textarea.inputValue();

  await input.setInputFiles(staged.stagedPath);

  await page.waitForFunction(
    ({ selector, previous, stagedName, urlHints }) => {
      const el = document.querySelector(selector);
      if (!(el instanceof HTMLTextAreaElement)) return false;
      const value = el.value || "";
      if (value === previous) return false;
      return value.includes(stagedName) || urlHints.some((hint) => value.includes(hint));
    },
    {
      selector: `[${ATTR_KEY}='textarea']`,
      previous: before,
      stagedName: staged.stagedName,
      urlHints: ATTACHMENT_URL_HINTS,
    },
    { timeout: timeoutMs },
  );

  const after = await textarea.inputValue();
  return { before, after };
}

async function getComposerMarkdown(page: Page): Promise<string> {
  const textarea = page.locator(`[${ATTR_KEY}='textarea']`).first();
  if ((await textarea.count()) === 0) return "";
  return textarea.inputValue();
}

// ---------------------------------------------------------------------------
// Attachment URL Extraction
// ---------------------------------------------------------------------------

function extractAttachmentLinks(text: string): AttachmentLink[] {
  const links: AttachmentLink[] = [];
  for (const match of text.matchAll(MARKDOWN_LINK_RE)) {
    const url = match.groups!.url;
    if (ATTACHMENT_URL_HINTS.some((hint) => url.includes(hint))) {
      links.push({ label: match.groups!.label, url });
    }
  }
  return links;
}

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
  const fallback = afterLinks.find((l) => l.label === stagedName);
  return fallback?.url;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------

async function main(): Promise<void> {
  const args = parseArgs(process.argv);
  const targetUrl = resolveTargetUrl(args);

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
