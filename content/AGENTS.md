# Format and Typography

Format and typography for everything under `content/`. Writing style lives in [content/posts/AGENTS.md](posts/AGENTS.md).

## Frontmatter

TOML with `+++` delimiters. `date` is a native TOML offset date-time in `+08:00`, and may be initialised to the current date and time.

```toml
+++
title = "文章标题"
date = 2025-01-15T20:30:00+08:00
tags = ["标签 1", "标签 2"]
license = "CC BY-NC-SA 4.0"

[featured_image]
src = "/images/article-covers/{pixiv_id}_p0.webp"

[featured_image.credit]
title = "作品标题"
author = "作者"
url = "https://www.pixiv.net/artworks/{pixiv_id}"
+++
```

`featured_image` is a TOML table holding `src`, an optional `position` (CSS `object-position`), and an optional `credit` subtable of `title`, `author`, and `url`.

## Article structure

```markdown
+++
[frontmatter]
+++

摘要（不超过 200 字）。

<!--more-->

## 二级标题

正文内容
```

The body starts at `##` and nests to six levels without skipping one. `<!--more-->` marks the summary break. A footnote definition follows the paragraph that references it.

Internal documents in a directory whose name starts with `_` take an H1 heading and carry no frontmatter, no summary, and no directives.

## Directives

```markdown
::: callout {type=quote title="标题"}

内容

:::
```

Types are `quote`, `note`, `info`, `warning`, and `tip`. A blank line is required above and below. Quote the title when it contains a space. Prefer `callout quote` over Markdown `>`.

## Typography

Based on [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines/blob/master/README.zh-Hans.md).

Paragraphs are not hard-wrapped. One paragraph is one line, and wrapping is the reader's job, so do not introduce 80-column breaks inside a paragraph.

### Spacing

- A space between Han characters and half-width characters such as Latin or digits: `在 LeanCloud 上`, `花了 5000 元`.
- A space between a number and its unit, excluding percent and degree signs: `10 Gbps`, `15%`, `90°`.
- A space on both sides of a link, excluding the side facing punctuation: `详情请查阅 [官方文档](url)。`
- A footnote takes no space on its left and one on its right, again excluding the punctuation side: `Rust[^rust] 是一种编程语言。`

### Punctuation

Chinese paragraphs use full-width punctuation and format quotations with corner brackets `「」`, nesting them as `『』`.

Work titles by tradition:

- ACGN works always take `「」`: 「少女终末旅行」、「EVA」
- Chinese classical works take `《》`: 《红楼梦》、《让子弹飞》
- Japanese classical works take `『』`: 『金閣寺』、『羅生門』
- English works take italics: _Ulysses_, _The Godfather_

Half-width exceptions:

- Parentheses go half-width when everything inside them is half-width: 拉康 (Jacques Lacan) 的理论
- A comma goes half-width when every item it separates is half-width: 123, text, `code`
- A colon goes half-width when both sides are half-width: GPU: NVIDIA GeForce RTX 5090
- A complete English sentence keeps half-width punctuation throughout: 「Stay hungry, stay foolish.」
- `/` is always half-width: 自然 / 文化、人类 / 机器

### Proper nouns

Keep capitalisation and spelling correct, and spell a name out in full on first use.

## Markdown

[markdownlint](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md) enforces list style, indentation, code fence style, code block languages, emphasis style, and the ban on bold text standing in for a subheading, all configured in `.markdownlint-cli2.jsonc`. Two conventions it does not cover:

- In Chinese prose a foreign term is embedded directly. Italics mark only a foreign work title.
- Headings do not end in `、；：`, which MD026 does not catch because it is configured only for the half-width `.,;:`.
