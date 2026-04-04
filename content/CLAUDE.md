# 文章格式与排版规范

本文档规定 `content/` 目录下文章的格式与排版规范。写作风格另见 `content/posts/CLAUDE.md`。

## 1. Frontmatter

使用 TOML frontmatter（`+++` 分隔符），日期为 TOML 原生偏移日期时间格式（`+08:00`）。

```toml
+++
title = "文章标题"
date = 2025-01-15T20:30:00+08:00
featured_image = "/images/article-covers/{pixiv_id}_p0.webp"
tags = ["标签 1", "标签 2"]
license = "CC BY-NC-SA 4.0"
+++
```

- `date`：ISO 8601，时区 `+08:00`，可初始化为当前日期和时间。
- 路径含 `_` 开头目录的内部文档无需 frontmatter。

## 2. 文章结构

```markdown
+++
[frontmatter]
+++

摘要（不超过 200 字）。

<!--more-->

::: callout { type=info title="封面出处" }
[Title - @Author](https://www.pixiv.net/artworks/{image-id})
:::

## 二级标题

正文内容
```

- 正文从二级标题（`##`）开始，最多六级，不跳级。
- `<!--more-->` 标记摘要分隔点。
- 脚注定义紧跟引用它的段落之后。
- 路径含 `_` 开头目录的内部文档使用一级标题，不使用 frontmatter、摘要、directives。

## 3. Directives

```markdown
::: callout { type=quote title="标题" }

内容

:::
```

可用类型：`quote`、`note`、`info`、`warning`、`tip`。上下两侧须有空行。标题含空格时用引号包裹。通常用 `callout quote` 替代 Markdown `>`。

## 4. 排版

基于 [中文文案排版指北](https://github.com/sparanoid/chinese-copywriting-guidelines/blob/master/README.zh-Hans.md)。

### 4.1 空格

- 中文与英文、数字等半角字符之间添加空格：`在 LeanCloud 上`、`花了 5000 元`。
- 数字与单位之间添加空格（百分号、度数除外）：`10 Gbps`、`15%`、`90°`。
- 链接两侧添加空格（标点侧除外）：`详情请查阅 [官方文档](url)。`
- 脚注左侧不加空格、右侧加空格（标点侧除外）：`Rust[^rust] 是一种编程语言。`

### 4.2 标点

中文段落使用全角标点。引号用直角引号 `「」`（内层 `『』`）。

**作品名标记**：

- ACGN 作品一律用 `「」`：「少女终末旅行」、「EVA」
- 中文传统作品用 `《》`：《红楼梦》、《让子弹飞》
- 日文传统作品用 `『』`：『金閣寺』、『羅生門』
- 英文作品用斜体：_Ulysses_, _The Godfather_

**半角例外**：

- 括号内全为半角字符时用半角括号：拉康 (Jacques Lacan) 的理论
- 并列项全为半角字符时用半角逗号：123, text, `code`
- 冒号前后均为半角字符时用半角冒号：GPU: NVIDIA GeForce RTX 5090
- 完整英文句子内用半角标点：「Stay hungry, stay foolish.」
- 始终用半角 `/`：自然 / 文化、人类 / 机器

### 4.3 专有名词

保持正确大小写和拼写，首次出现不用缩写。

## 5. Markdown

遵循 [markdownlint](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)。要点：

- 无序列表用 `-`，子项缩进 2 格；有序列表子项缩进 3 格。
- 代码块须指定语言标识符（无语言概念时用 `text`）。
- 加粗 `**文本**`，斜体 `_文本_`（中文行文中外语术语直接嵌入，斜体仅用于标注外语作品名称）。
- 禁止用粗体短句代替小标题。
- 标题结尾不含逗号、顿号、分号、冒号。
