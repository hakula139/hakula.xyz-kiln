# hakula.xyz

[![CI](https://github.com/hakula139/hakula.xyz-kiln/actions/workflows/ci.yml/badge.svg)](https://github.com/hakula139/hakula.xyz-kiln/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-orange.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0)
![WakaTime coding time for hakula.xyz-kiln](https://wakatime.com/badge/user/f4a35a1f-0e29-4093-a647-e66aad164737/project/ab6e0cef-1d0d-4592-97cf-4948b9e1472c.svg)

My personal website, built with [kiln](https://github.com/hakula139/kiln) and the [IgnIt](https://github.com/hakula139/IgnIt) theme. The previous Hugo site is preserved at [old.hakula.xyz](https://old.hakula.xyz).

## Setup

```bash
git clone --recurse-submodules https://github.com/hakula139/hakula.xyz-kiln.git
cd hakula.xyz-kiln
```

[Nix](https://nixos.org/download/) (with flakes) is the recommended path. `nix develop` enters a shell with kiln, pagefind, Node, and pnpm preinstalled, all pulled from the [`hakula` cachix cache](https://app.cachix.org/cache/hakula). Without Nix, install [kiln](https://github.com/hakula139/kiln#installation) (Rust 1.85+) and [pagefind](https://pagefind.app/docs/installation/) yourself.

## Usage

```bash
kiln build
```

Output is written to `public/`.

## Deploy

Pushes to `main` deploy to [hakula.xyz](https://hakula.xyz), and pushes to `dev` deploy to [dev.hakula.xyz](https://dev.hakula.xyz), via [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml). The workflow builds with `kiln build --minify` and ships `public/` to separate Cloudflare Workers configured in [`wrangler.toml`](wrangler.toml). Development builds keep links on the development origin. Development and PR preview hosts are excluded from indexing with `X-Robots-Tag: noindex`.

For a manual deploy, run the workflow on the intended branch:

```bash
gh workflow run deploy.yml --ref main
gh workflow run deploy.yml --ref dev
```

CI deploys require two repository secrets:

- `CLOUDFLARE_API_TOKEN`, scoped to Account → Workers Scripts: Edit and Zone (`hakula.xyz`) → DNS: Edit + Workers Routes: Edit.
- `CLOUDFLARE_ACCOUNT_ID`.

## Site Structure

```text
.
├── config.toml                   # Site configuration
├── content/                      # Markdown content (posts, standalone pages)
├── static/                       # Shipped assets
│   ├── css/
│   │   ├── _src/                 # Tailwind sources (private, skipped by kiln)
│   │   └── style.generated.css   # Compiled shared output
│   ├── js/                       # JS sources, shipped as-is
│   └── images/
│       ├── article-covers/       # Featured images for posts (WebP)
│       ├── hotlink-ok/           # Avatar images (publicly linkable)
│       └── bg.webp               # Background image (4K)
├── templates/                    # Site-level template overrides
├── themes/                       # Themes (git submodules)
│   └── IgnIt/                    # Active theme
└── public/                       # Build output
```

Page CSS sources live at `content/<page>/assets/css/_src/style.css`. `pnpm build` compiles both the shared entry and all page entries, and `pnpm dev` watches their sources and imports. Generated `style.generated.css` files are committed and excluded from formatting. kiln keeps `_src` private and loads each page stylesheet only on its page.

## License

Copyright (c) 2026 [Hakula](https://hakula.xyz).\
Code is licensed under [GPL v3](LICENSE).\
Articles are licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0).
