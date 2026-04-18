# CLAUDE.md — hakula.xyz-kiln

## Project Overview

hakula.xyz-kiln is the [kiln](https://github.com/hakula139/kiln) site source for [hakula.xyz](https://hakula.xyz), using the [IgnIt](https://github.com/hakula139/IgnIt) theme (git submodule at `themes/IgnIt/`).

Migrated from a Hugo + LoveIt stack. The original Hugo site lives at `../hakula.xyz/` for reference.

### Site Structure

All site-owned assets live under `static/`. Files and directories whose names start with `_` are private build inputs (kiln's `copy_static` skips them).

```text
.
├── config.toml                       # Site configuration
├── content/                          # Markdown content (posts, standalone pages)
├── static/                           # Shipped assets
│   ├── css/
│   │   ├── _src/                     # Tailwind sources (private, not shipped)
│   │   │   ├── main.css              # Entry: imports theme + site-level partials
│   │   │   └── components/
│   │   │       └── score-table.css
│   │   └── style.css                 # Compiled Tailwind output (shipped)
│   ├── js/
│   │   └── score-table.js            # JS source, shipped as-is
│   ├── images/                       # Article covers, avatars, background
│   ├── favicon.ico
│   ├── apple-touch-icon.png
│   ├── icon-192.png
│   ├── icon-512.png
│   └── manifest.webmanifest
├── templates/                        # Site-level template overrides
│   └── directives/
│       └── score-table.html
└── themes/
    └── IgnIt/                        # Theme (git submodule)
```

### Theme Submodule

IgnIt is pinned as a git submodule. After cloning, run `git submodule update --init`. To update the theme:

```bash
git submodule update --remote themes/IgnIt
git add themes/IgnIt
git commit -m "chore: update IgnIt submodule"
```

## Build

### Site build (kiln)

```bash
kiln build                   # Build site to public/
kiln serve --open            # Dev server with live reload
```

### Site-level CSS / JS

Site Tailwind sources live in `static/css/_src/`; the entry `main.css` `@import`s the theme's own `_src/main.css` plus any site-specific partials (e.g., `score-table`). Site JS lives in `static/js/` and is shipped as-is (no build step). **Run `pnpm build` before committing CSS changes** to keep `static/css/style.css` in sync with source.

```bash
pnpm build                   # One-shot Tailwind build to static/css/style.css
pnpm dev                     # Tailwind watch mode
```

Compression for both CSS and JS is handled at deploy time by `kiln build --minify`, so shipped files stay readable during development.

## Coding Conventions

### Content

- Frontmatter uses TOML (`+++` delimiters).
- Article covers go in `static/images/article-covers/`.
- Co-located assets (diagrams, data files) live alongside `index.md` in page bundles.

### Git Conventions

- Commit messages: `type(scope): description`
  - Types: `feat`, `fix`, `refactor`, `docs`, `ci`, `chore`, `style`
  - Scope: topic area (e.g., content file name without extension, `config`, `template`)
- PRs: assign to `hakula139`.

### Pre-commit

The husky pre-commit hook runs `lint-staged`, which auto-formats staged files with Prettier (including Tailwind class sorting in HTML attributes and CSS `@apply` via `prettier-plugin-tailwindcss`), lints Markdown with markdownlint, and spell-checks with cspell. The pre-push hook runs `pnpm build` and verifies `static/` is in sync.

### Spell Checking

- Config in `cspell.json`. Add project-specific words to `.cspell/words.txt` (one word per line, sorted alphabetically).

## Verification

Before pushing:

```bash
pnpm build                   # Compile site-level CSS / JS
kiln build                   # Full site build
```
