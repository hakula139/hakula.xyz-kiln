# CLAUDE.md — hakula.xyz-kiln

## Project Overview

hakula.xyz-kiln is the [kiln](https://github.com/hakula139/kiln) site source for [hakula.xyz](https://hakula.xyz), using the [IgnIt](https://github.com/hakula139/IgnIt) theme (git submodule at `themes/IgnIt/`).

Migrated from a Hugo + LoveIt stack. The original Hugo site lives at `../hakula.xyz/` for reference.

### Site Structure

```text
.
├── assets/                           # Site-level CSS / JS source (overrides theme)
│   ├── css/
│   │   ├── main.css                  # Entry: imports theme + site-level partials
│   │   └── components/
│   │       └── score-table.css
│   └── js/
│       └── score-table.js
├── config.toml                       # Site configuration
├── content/                          # Markdown content (posts, standalone pages)
├── static/                           # Static files copied to output root
│   ├── css/style.min.css             # Compiled site-level CSS
│   ├── js/score-table.min.js
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

The site has its own CSS / JS assets (e.g., `score-table`) compiled separately from the theme. **Run `pnpm build` before committing** to keep `static/css/style.min.css` and `static/js/*.min.js` in sync with source.

```bash
pnpm build                   # Compile CSS + JS
pnpm build:css               # CSS only (Tailwind)
pnpm build:js                # JS only (esbuild)
pnpm dev:css                 # Watch mode for CSS
```

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

The husky pre-commit hook runs `lint-staged`, which auto-formats staged files with Prettier, lints Markdown with markdownlint, and spell-checks with cspell. The pre-push hook runs `pnpm build` and verifies `static/` is in sync.

### Spell Checking

- Config in `cspell.json`. Add project-specific words to `.cspell/words.txt` (one word per line, sorted alphabetically).

## Verification

Before pushing:

```bash
pnpm build                   # Compile site-level CSS / JS
kiln build                   # Full site build
```
