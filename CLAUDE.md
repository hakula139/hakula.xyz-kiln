# CLAUDE.md — hakula.xyz-kiln

## Project Overview

hakula.xyz-kiln is the [kiln](https://github.com/hakula139/kiln) site source for [hakula.xyz](https://hakula.xyz), using the [IgnIt](https://github.com/hakula139/IgnIt) theme (git submodule at `themes/IgnIt/`). Migrated from a Hugo + LoveIt stack.

### Site Structure

```text
.
├── config.toml                       # Site configuration
├── content/                          # Markdown content (posts, standalone pages)
├── i18n/                             # Translation overrides (merged on top of theme keys)
├── static/                           # Shipped assets
│   ├── css/
│   │   ├── _src/                     # Tailwind sources (private, not shipped)
│   │   │   ├── main.css              # Entry: imports theme + site-level partials
│   │   │   └── components/           # Site-only Tailwind partials
│   │   └── style.css                 # Compiled Tailwind output (shipped)
│   ├── js/                           # Site-only JS, shipped as-is (no build step)
│   └── images/                       # Article covers, hotlink-ok mirrors, background
├── templates/                        # Site-only directives & template overrides
│   └── directives/
└── themes/
    └── IgnIt/                        # Theme (git submodule)
```

Files under `templates/` override the same-path file in `themes/IgnIt/templates/`. Site-only directives live in `templates/directives/<name>.html` and are picked up by kiln's directive renderer without further wiring. Files and directories whose names start with `_` are private build inputs (kiln's `copy_static` skips them).

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

Tailwind sources live in `static/css/_src/`; the entry `main.css` imports the theme's own `_src/main.css` plus any site-specific partials. Site JS ships as-is. The pre-push hook fails if `static/css/style.css` is out of sync with source — run `pnpm build` after editing CSS.

```bash
pnpm build                   # Compile to static/css/style.css
pnpm dev                     # Tailwind watch mode
```

Minification for both CSS and JS happens at deploy time via `kiln build --minify`, so shipped files stay readable during development.

## Deploy

The site is hosted on Cloudflare Workers (Static Assets binding) at [dev.hakula.xyz](https://dev.hakula.xyz) — `wrangler.toml` at the repo root pins the worker name, custom domain, and `not_found_handling`. The apex `hakula.xyz` is still served by the legacy Pages project; cutover is planned later by appending the apex pattern to `wrangler.toml`'s `routes` array and removing it from Pages.

`.github/workflows/build.yml` is a reusable workflow (`workflow_call`) that installs the kiln binary at the version pinned in `KILN_VERSION` (currently `0.1.0`) from <https://github.com/hakula139/kiln/releases>, runs `pnpm build` (Tailwind) + `kiln build --minify`, and optionally uploads `public/` as a CI artifact. Both `ci.yml` (PR validation) and `deploy.yml` (push to main → Cloudflare) call into it, keeping the build path single-sourced.

Local manual deploy: `pnpm wrangler login` once, then `pnpm wrangler deploy`. CI deploy needs `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` secrets configured at the repository level.

## Coding Conventions

### Content

- Frontmatter uses TOML (`+++` delimiters).
- Article covers go in `static/images/article-covers/`.
- Co-located assets (diagrams, data files) live alongside `index.md` in page bundles.

### Git Conventions

- Commit messages: `type(scope): description`
  - Types: `feat`, `fix`, `refactor`, `docs`, `test`, `ci`, `chore`, `style`, `perf`
  - Scope: topic area (e.g., content file name without extension, `config`, `template`)
- PRs: assign to `hakula139`.

### Git hooks

The husky pre-commit hook runs `lint-staged`, which auto-formats staged files with Prettier (including Tailwind class sorting in HTML attributes and CSS `@apply` via `prettier-plugin-tailwindcss`), lints Markdown with markdownlint, and spell-checks with cspell. The pre-push hook runs `pnpm build` and verifies `static/css/style.css` is in sync with its Tailwind source.

### Git LFS

Image binaries (`*.avif`, `*.gif`, `*.jpg`, `*.png`, `*.webp`) are stored via Git LFS — see `.gitattributes`. Install Git LFS (`git lfs install`) before cloning, otherwise pointer files are checked out instead of real images.

### Spell Checking

- Config in `cspell.json`. Add project-specific words to `.cspell/words.txt` (one word per line, sorted alphabetically).

## Verification

```bash
kiln build                   # Full site build smoke test
```

The dev server (`kiln serve`) catches most local errors during development.
