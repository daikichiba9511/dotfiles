#!/usr/bin/env bun
// Pattern sets adapted from yomiyasu (MIT, nanaism): https://github.com/nanaism/yomiyasu
// Findings are review hints only; they never decide whether meaning or readability is preserved.
import { readFileSync } from "node:fs";

type Severity = "warn" | "info";

type Finding = {
  readonly line: number;
  readonly rule: string;
  readonly severity: Severity;
  readonly message: string;
  readonly excerpt: string;
};

type ProseLine = { readonly number: number; readonly text: string };

type Sentence = { readonly line: number; readonly paragraph: number; readonly text: string };

type Paragraph = { readonly line: number; readonly text: string };

type PatternRule = {
  readonly rule: string;
  readonly severity: Severity;
  readonly pattern: RegExp;
  readonly message: string;
};

type Risk = {
  readonly kind: string;
  readonly detail: string;
  readonly line: number;
  readonly before: string;
  readonly after: string;
};

const SEE = "references/ai-slop.md";

const rule = (name: string, severity: Severity, pattern: RegExp, message: string): PatternRule => ({
  rule: name,
  severity,
  pattern,
  message,
});

const metaphor = (pattern: RegExp, label: string): PatternRule =>
  rule("metaphor_verb", "warn", pattern, `比喩動詞${label}。何がどう変わったかを書くか、ふだんの言い方にする。文字どおりの意味なら残す（${SEE} 2章）。`);

const vocabulary = (pattern: RegExp, label: string): PatternRule =>
  rule("slop_vocabulary", "warn", pattern, `大げさな名詞${label}。実際の役割の語に直す。正式な名称や定着した用語なら残す（${SEE} 3章）。`);

const filler = (pattern: RegExp, label: string): PatternRule =>
  rule("meta_filler", "warn", pattern, `決まり文句${label}。予告や言い直しだけなら削るか続く文とまとめる。そこにしかない情報があれば残す（${SEE} 4章）。`);

const SENTENCE_RULES: readonly PatternRule[] = [
  metaphor(/地味に効|効いてく[るき]|じわじわ効/, "「効く」"),
  metaphor(/(データ|仕様|設計|環境|ビルド|システム|整合性)が(静かに)?壊れ/, "「壊れる」"),
  metaphor(/静かに(壊れ|落ち|失敗|沈黙)/, "「静かに壊れる」（silently fail の直訳）"),
  metaphor(/黙って(無視|捨て|スキップ|破棄)/, "「黙って〜」（silently の直訳）"),
  metaphor(/側に倒[すしせさ]/, "「〜側に倒す」"),
  metaphor(/時間[をが]溶[かけ]/, "「時間を溶かす」"),
  metaphor(/(1つ|一つ|ひとつ)ずつ潰/, "「潰す」"),
  metaphor(/(実装|詳細|コード|設計|内部|仕組み|領域|本質)(に|まで|へ)踏み込/, "「踏み込む」"),
  metaphor(/(議論|意見|結論|方向性|価格|話題|検討)が[^。！？]*?収斂/, "「収斂する」"),
  metaphor(/した瞬間/, "「〜した瞬間」（the moment の直訳）"),
  metaphor(/(前提|基盤)[がも]崩れ/, "「前提が崩れる」"),
  vocabulary(/(?<![ァ-ヴー])(?<!搭乗|改札)ゲート(?!ウ[ェエ]イ|ボール|キーパー)/, "「ゲート」"),
  vocabulary(/(?<!資産|会計|会計の|住民基本|行政の|課税|土地|家屋|備品|登記)台帳/, "「台帳」"),
  vocabulary(/(思考|意思決定|仕事|人生|組織|チーム|学習|経営)の?OS(?![A-Za-z])/, "「〜のOS」"),
  vocabulary(/正本/, "「正本」"),
  vocabulary(/本質を突/, "「本質を突く」"),
  vocabulary(/解像度が(上が|高ま|一段)/, "「解像度が上がる」"),
  rule("translated_term", "info", /(この|その|新しい|古い|最新の|前の|次の|今の)版(では|で|に|から|を|が)/, `直訳語「版」（version）。技術文書なら「バージョン」と書く（${SEE} 3章）。`),
  rule("translated_term", "info", /(?<!原点|平均|線形)回帰(が|を)(出|発生|起こ|起き|生じ)/, `直訳語「回帰」（regression）。「リグレッション」か、何が動かなくなったかを書く（${SEE} 3章）。`),
  filler(/^(まず|ここで)?(重要|大切|大事)なのは、?/, "「重要なのは」"),
  filler(/^結論から(言|い|申し上げ)/, "「結論から言うと」"),
  filler(/^(正直|本音)を?に?言うと/, "「正直に言うと」"),
  filler(/^ポイントは、/, "「ポイントは、」"),
  filler(/見落とされがち|面白いのはここ|まさにそこがポイント/, "（自己ラベル）"),
  filler(/いかがでした(でしょうか|か)?[？?。]?$/, "「いかがでしたでしょうか」"),
  filler(/ぜひ(参考にして|試して|活用して)(みて)?ください/, "「ぜひ〜してみてください」"),
  filler(/参考に(なれ|な)ば幸い|お役に立て(れ)?ば幸い/, "「参考になれば幸いです」"),
  filler(/に(他|ほか)なりません/, "「〜に他なりません」"),
  filler(/見ていきましょう[。！!]?$|深掘りしていきます/, "「見ていきましょう」"),
  filler(/(言|い)っても過言(では|じゃ)(ない|ありません)/, "「〜と言っても過言ではない」"),
  rule("summary_restatement", "info", /^(まとめると|総じて)、/, `言い直しの締め。本文の繰り返しだけなら削る（${SEE} 4章）。`),
  rule("meta_intro", "info", /^本(記事|稿|章)では/, `予告の文。続く本文と同じ内容の予告だけなら削る（${SEE} 4章）。`),
  rule("count_declaration", "info", /(ポイント|理由|観点|コツ|方法)は[2-5二三四五２-５]つ(です|あります)/, `数の予告。数と続く項目が合うときだけ中身とまとめる（${SEE} 4章）。`),
  rule("negative_parallelism", "info", /ではなく/, `否定対比。Aを外しても主張が変わらないか、言い直しテストで確かめる（${SEE} 4章）。`),
  rule("short_mochiron", "info", /^もちろん、[^。！？]{1,10}[。！？]$/, `数語だけの「もちろん、〜。」。「もちろん、」を外せるか確かめる（${SEE} 4章）。`),
  rule("pause_comma", "info", /^[^、。「」（）\s]{1,4}(は|も|には|では|が|を)、/, `短い主題や目的語のすぐあとの読点。間を作るだけなら外す（${SEE} 6章）。`),
];

const LINE_RULES: readonly PatternRule[] = [
  rule("bold_label_list", "warn", /^\s*(?:[-*+]|\d+[.)])\s+\*\*[^*]+\*\*\s*[:：]/, `箇条書きの太字ラベルとコロン。ラベルが説明をまとめただけなら文に入れる（${SEE} 5章）。`),
  rule("emoji", "warn", /(?![©®™])\p{Extended_Pictographic}/u, `絵文字。外す（${SEE} 5章）。`),
  rule("heading_colon", "info", /^#{1,6}\s+\S.*[:：]/, `見出しの中のコロン。節で扱うことが分かる短い項目名にする（${SEE} 5章）。`),
  rule("trailing_colon", "info", /^(?!\s*#)(?!\s*(?:[-*+]|\d+[.)])\s+\*\*).*[^\s:：][:：]\s*$/, `文末のコロン。文で終えるか、ラベルと値の形かを確かめる（${SEE} 5章）。`),
];

const DASH = /[—―─━]/;
const DIAGRAM = /[│┃├┣└┗┌┏┐┓┘┛┬┴┼]|^\s*[─━]{3,}\s*$/;
const BOLD_SPAN = /\*\*[^*\n]+\*\*/g;
const MARKDOWN_PREFIX = /^\s*(?:>\s*)*(?:#{1,6}\s+|[-*+]\s+|\d+[.)]\s+)?/;
const NEGATIVE_SENTENCE_END = /(ではない|ではありません|じゃない)[。]$/;
const EXCESS_BOLD_THRESHOLD = 5;

const stripInlineNoise = (text: string): string =>
  text
    .replace(/`[^`]*`/g, "")
    .replace(/\]\([^)]*\)/g, "]")
    .replace(/https?:\/\/\S+/g, "");

const toProseLines = (source: string): readonly ProseLine[] => {
  const lines = source.split(/\r?\n/);
  const frontMatterEnd = lines[0] === "---" ? lines.indexOf("---", 1) : -1;
  return lines.reduce<{ readonly inFence: boolean; readonly out: readonly ProseLine[] }>(
    (state, raw, index) => {
      if (index <= frontMatterEnd) return state;
      if (/^\s*(```|~~~)/.test(raw)) return { inFence: !state.inFence, out: state.out };
      if (state.inFence) return state;
      return { inFence: false, out: [...state.out, { number: index + 1, text: stripInlineNoise(raw) }] };
    },
    { inFence: false, out: [] },
  ).out;
};

const toParagraphs = (lines: readonly ProseLine[]): readonly Paragraph[] =>
  lines.reduce<readonly Paragraph[]>((paragraphs, { number, text }, index) => {
    if (text.trim() === "") return paragraphs;
    const continues = index > 0 && lines[index - 1].text.trim() !== "" && lines[index - 1].number === number - 1;
    if (!continues || paragraphs.length === 0) return [...paragraphs, { line: number, text: text.trim() }];
    const last = paragraphs[paragraphs.length - 1];
    return [...paragraphs.slice(0, -1), { line: last.line, text: last.text + text.trim() }];
  }, []);

const toSentences = (lines: readonly ProseLine[]): readonly Sentence[] => {
  const paragraphStarts = new Set(toParagraphs(lines).map((p) => p.line));
  return lines.reduce<{ readonly paragraph: number; readonly out: readonly Sentence[] }>(
    (state, { number, text }) => {
      const paragraph = paragraphStarts.has(number) ? state.paragraph + 1 : state.paragraph;
      const pieces = text
        .replace(MARKDOWN_PREFIX, "")
        .split(/(?<=[。！？!?])/)
        .map((s) => s.trim())
        .filter((s) => s !== "");
      return { paragraph, out: [...state.out, ...pieces.map((s) => ({ line: number, paragraph, text: s }))] };
    },
    { paragraph: 0, out: [] },
  ).out;
};

const finding = (line: number, r: PatternRule, excerpt: string): Finding => ({
  line,
  rule: r.rule,
  severity: r.severity,
  message: r.message,
  excerpt: excerpt.trim(),
});

const lineFindings = (lines: readonly ProseLine[]): readonly Finding[] =>
  lines.flatMap(({ number, text }) => [
    ...LINE_RULES.filter((r) => r.pattern.test(text)).map((r) => finding(number, r, text)),
    ...(DASH.test(text) && !DIAGRAM.test(text)
      ? [finding(number, rule("dash", "warn", DASH, `地の文のダッシュ。外して句読点や助詞でつなぐか、2文にする（${SEE} 5章）。`), text)]
      : []),
  ]);

const sentenceFindings = (sentences: readonly Sentence[]): readonly Finding[] =>
  sentences.flatMap((s, index) => {
    const next = sentences[index + 1];
    const splitNegation =
      NEGATIVE_SENTENCE_END.test(s.text) && next !== undefined && next.paragraph === s.paragraph
        ? [finding(s.line, rule("negative_parallelism_split", "info", NEGATIVE_SENTENCE_END, `否定のあとに文が続く。否定と肯定を2文に分けた対比なら、否定を残して1文にまとめる（${SEE} 4章）。`), `${s.text}${next.text}`)]
        : [];
    return [...SENTENCE_RULES.filter((r) => r.pattern.test(s.text)).map((r) => finding(s.line, r, s.text)), ...splitNegation];
  });

const boldFindings = (lines: readonly ProseLine[]): readonly Finding[] => {
  const count = lines.reduce((n, { text }) => n + (text.match(BOLD_SPAN)?.length ?? 0), 0);
  return count >= EXCESS_BOLD_THRESHOLD
    ? [finding(0, rule("excess_bold", "info", BOLD_SPAN, `太字が${count}か所ある。外すと読み違える所だけに残す（${SEE} 5章）。`), "")]
    : [];
};

const lint = (source: string): readonly Finding[] => {
  const lines = toProseLines(source);
  return [...lineFindings(lines), ...sentenceFindings(toSentences(lines)), ...boldFindings(lines)].sort(
    (a, b) => a.line - b.line,
  );
};

const MODALITY: Readonly<Record<string, RegExp>> = {
  伝聞: /そうだ|そうです|とのこと|らしい|と言われ|といわれ/g,
  推量: /だろう(?!か)|でしょう(?!か)|かもしれ|と思われ|とみられ|と考えられ|可能性が/g,
  義務: /なければならない|なければなりません|なくてはならない|必要がある|必要があります|べき|必須/g,
  保証: /必ず|確実に|保証/g,
  許可: /てもよい|てもいい|ても構わない|てもかまわない|てよい/g,
  能力: /できる|できます|できない|できません|可能/g,
};
// 「気づかないうちに」「目立たないながら」are the rewrites ai-slop.md recommends for 静かに/地味に, not new negations.
const NEGATION = /(?<![少危幼汚切])(?:ない(?!うちに|ながら)|なく|なかっ|ません|ず(?=[、。にとも]))/g;
const NUMBER = /\d+(?:[.,]\d+)*(?:%|[A-Za-z]+|[一-龥ぁ-んァ-ヴー])?/g;

const count = (text: string, pattern: RegExp): number => text.match(pattern)?.length ?? 0;

const multisetMinus = (from: readonly string[], remove: readonly string[]): readonly string[] =>
  remove.reduce<readonly string[]>((rest, item) => {
    const at = rest.indexOf(item);
    return at === -1 ? rest : [...rest.slice(0, at), ...rest.slice(at + 1)];
  }, from);

const risksBetween = (line: number, before: string, after: string): readonly Risk[] => {
  const [b, a] = [before.normalize("NFKC"), after.normalize("NFKC")];
  const risk = (kind: string, detail: string): Risk => ({ kind, detail, line, before, after });
  const numbersBefore = b.match(NUMBER) ?? [];
  const numbersAfter = a.match(NUMBER) ?? [];
  const removed = multisetMinus(numbersBefore, numbersAfter);
  const added = multisetMinus(numbersAfter, numbersBefore);
  const [negB, negA] = [count(b, NEGATION), count(a, NEGATION)];
  return [
    ...(removed.length + added.length > 0
      ? [risk("数値が変わった", `消えた: ${removed.join("、") || "なし"} / 増えた: ${added.join("、") || "なし"}`)]
      : []),
    ...(negB !== negA ? [risk("否定の数が変わった", `${negB} → ${negA}`)] : []),
    ...Object.entries(MODALITY).flatMap(([name, pattern]) => {
      const [mb, ma] = [count(b, pattern), count(a, pattern)];
      return mb !== ma ? [risk(`言い切りの強さ（${name}）が変わった`, `${mb} → ${ma}`)] : [];
    }),
  ];
};

const diff = (before: string, after: string): { readonly aligned: boolean; readonly risks: readonly Risk[] } => {
  const [pb, pa] = [toParagraphs(toProseLines(before)), toParagraphs(toProseLines(after))];
  if (pb.length !== pa.length) {
    const whole = (ps: readonly Paragraph[]) => ps.map((p) => p.text).join("");
    return { aligned: false, risks: risksBetween(0, whole(pb), whole(pa)) };
  }
  return { aligned: true, risks: pb.flatMap((p, i) => (p.text === pa[i].text ? [] : risksBetween(pa[i].line, p.text, pa[i].text))) };
};

const shorten = (text: string, max = 80): string => (text.length > max ? `${text.slice(0, max)}…` : text);

const printLint = (findings: readonly Finding[]): void => {
  const warn = findings.filter((f) => f.severity === "warn").length;
  console.log(`見直し候補: ${findings.length}件（warn ${warn}、info ${findings.length - warn}）。候補は手がかりで、直す合図ではない。0件でも型を探す。`);
  findings.forEach((f) => {
    console.log(`\nL${f.line} [${f.severity}] ${f.rule}: ${f.message}`);
    if (f.excerpt !== "") console.log(`  > ${shorten(f.excerpt)}`);
  });
};

const printDiff = ({ aligned, risks }: ReturnType<typeof diff>): void => {
  console.log(`意味が変わる恐れ: ${risks.length}件。出なかった箇所も原文と読み比べる。`);
  if (!aligned) console.log("段落の数が変わったので、文書全体でまとめて比べた（場所は出せない）。");
  risks.forEach((r) => {
    console.log(`\n- ${r.kind}${r.line > 0 ? `（L${r.line}の段落）` : ""}: ${r.detail}`);
    if (aligned) console.log(`  元: ${shorten(r.before)}\n  後: ${shorten(r.after)}`);
  });
};

const usage = (): never => {
  console.error("usage: bun jp-readability.ts lint <file> [--json]\n       bun jp-readability.ts diff <before> <after> [--json]");
  process.exit(2);
};

const main = (argv: readonly string[]): void => {
  const json = argv.includes("--json");
  const [command, ...paths] = argv.filter((a) => a !== "--json");
  const read = (path: string): string => readFileSync(path === "-" ? 0 : path, "utf8");
  if (command === "lint" && paths.length === 1) {
    const findings = lint(read(paths[0]));
    json ? console.log(JSON.stringify(findings, null, 2)) : printLint(findings);
    return;
  }
  if (command === "diff" && paths.length === 2) {
    const result = diff(read(paths[0]), read(paths[1]));
    json ? console.log(JSON.stringify(result, null, 2)) : printDiff(result);
    return;
  }
  usage();
};

main(process.argv.slice(2));
