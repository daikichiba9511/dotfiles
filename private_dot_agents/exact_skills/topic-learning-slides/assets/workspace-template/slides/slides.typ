#import "@preview/polylux:0.4.0": *
#import "@preview/metropolis-polylux:0.1.0" as metropolis
#import "theme.typ": *

#show: metropolis.setup.with(
  footer: [TODO: トピック名],
  text-font: "BIZ UDPGothic",
  math-font: "New Computer Modern Math",
  code-font: "HackGen35 Console NFJ",
  text-size: 17pt,
)
#set text(lang: "ja")
#set par(leading: 0.66em)
#set list(spacing: 0.38em)

#slide[
  #set page(header: none, footer: none, margin: 3em, fill: ink)
  #set text(fill: white)
  #set align(left + horizon)
  #text(size: 10pt, weight: "bold", fill: accent.lighten(24%))[理解用スライド]
  #v(0.55em)
  #text(size: 28pt, weight: "bold")[TODO: トピック名]
  #v(0.45em)
  #text(size: 18pt)[TODO: このトピックで理解する中心的な問い]
  #v(0.8em)
  #line(length: 72%, stroke: 2pt + accent)
  #v(0.7em)
  #text(size: 10pt, fill: white.darken(20%))[TODO: 読者・調査範囲・取得日]
]

#explainer(
  [このトピックで答える問い],
  [TODO: 読了後に説明または判断できるようになること。],
  [
    TODO: トピックを具体例から導入する。

    TODO: 調査対象と対象外を説明する。
  ],
  source: [TODO: 問いと定義の一次情報。 #source-mark("S-001")],
  quiet: true,
)

#explainer(
  [まず使う単純な理解モデル],
  [TODO: 詳細を読む前に置く、最小限の構造または基準となる理解。],
  [
    TODO: 入力、処理、出力、または前提と結果を具体的に説明する。

    TODO: この単純化が見落とすものを示し、次の論点整理へつなぐ。
  ],
  representation: [
    #grid(
      columns: (1fr, 18pt, 1fr, 18pt, 1fr),
      gutter: 6pt,
      align: horizon,
      stage([入力・前提], [TODO]),
      align(center)[→],
      stage([処理・関係], [TODO]),
      align(center)[→],
      stage([出力・結果], [TODO], active: true),
    )
  ],
  source: [TODO: 基準となる理解または定義の出典。],
)

#explainer(
  [全体は三つの論点に分かれる],
  [TODO: 各論へ入る前に、論点同士の関係を示す。],
  [
    TODO: なぜこの三つが中心的な問いを分解するのか説明する。

    TODO: 前提、代替、組合せ、両立しない条件、反例などの関係を文章でも明示する。
  ],
  representation: [
    #grid(
      columns: (1fr, 1fr, 1fr),
      gutter: 10pt,
      stage([論点A], [TODO]),
      stage([論点B], [TODO], active: true),
      stage([論点C], [TODO]),
    )
  ],
  note: [TODO: 論点数は証拠に合わせて増減する。],
)

#explainer(
  [論点Aの仕組み],
  [TODO: 一つの機構または比較を、前提から結果まで説明する。],
  [
    TODO: 入力、操作または関係、条件、結果を自然な日本語で説明する。

    TODO: 根拠と、根拠からは判断できないことを分ける。
  ],
  source: [TODO: claim IDsと出典。],
  quiet: true,
)

#explainer(
  [反例が結論の範囲を限定する],
  [TODO: 主張が成立しない条件または別の説明を示す。],
  [
    TODO: どの条件を変えると結論が弱くなるか説明する。

    TODO: 元の主張を棄却するのか、範囲を狭めるのかを明示する。
  ],
  source: [TODO: 反例または否定的な結果。],
  quiet: true,
)

#explainer(
  [理解や検証を進める順序],
  [TODO: 何を確認してから次の詳細へ進むかを示す。],
  [
    TODO: 各段階の判断条件を文章で説明する。
  ],
  representation: [
    #quiet-step([1], [問いと前提を固定], [TODO])
    #v(0.28em)
    #quiet-step([2], [中心的な比較], [TODO])
    #v(0.28em)
    #quiet-step([3], [反例と限界を確認], [TODO])
    #v(0.28em)
    #quiet-step([4], [詳細な実装や事例へ進む], [TODO])
  ],
  quiet: true,
)

#explainer(
  [調査範囲と限界],
  [TODO: 結論をどの証拠と不確実性の範囲で読むべきか。],
  [
    TODO: 主要な情報源、未取得情報、時間的な制約を説明する。

    TODO: 次頁以降に詳細な事例や実装を置く場合、その役割を案内する。
  ],
  source: [TODO: source ledger。],
  quiet: true,
)

// Put detailed source-specific cases, implementations, papers, or appendices here.
#explainer(
  [詳細事例: TODO],
  [TODO: 前半のどの論点を具体化する事例か。],
  [
    TODO: 実際の入力、処理、出力、条件、結果、限界を説明する。
  ],
  source: [TODO: この事例の一次情報。],
  quiet: true,
)

#explainer(
  [出典一覧],
  [TODO: 本文中の出典IDから、確認した情報源とその制約を逆引きできる。],
  [
    #source-entry(
      "S-001",
      [TODO: 出典名],
      [TODO: 安定したURLまたはローカルパス],
      [TODO: 確認した章、ページ、節、ファイル],
      [TODO: 取得日],
      [TODO: この出典だけでは判断できないこと],
    )
  ],
  quiet: true,
)
