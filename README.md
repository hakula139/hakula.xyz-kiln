# hakula.xyz

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-orange.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0)

My personal website, built with [kiln](https://github.com/hakula139/kiln) and the [IgnIt](https://github.com/hakula139/IgnIt) theme.

## Setup

```bash
git clone --recurse-submodules https://github.com/hakula139/hakula.xyz-kiln.git
cd hakula.xyz-kiln
```

[Nix](https://nixos.org/download/) (with flakes) is the recommended path — `nix develop` enters a shell with kiln, pagefind, Node, and pnpm preinstalled, all pulled from the [`hakula` cachix cache](https://app.cachix.org/cache/hakula). Without Nix, install [kiln](https://github.com/hakula139/kiln#installation) (Rust 1.85+) and [pagefind](https://pagefind.app/docs/installation/) yourself.

## Usage

```bash
kiln build
```

Output is written to `public/`.

## Deploy

The site auto-deploys to [dev.hakula.xyz](https://dev.hakula.xyz) on every push to `main` via [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml). The workflow builds with `kiln build --minify` and ships `public/` to a Cloudflare Worker (config in [`wrangler.toml`](wrangler.toml)) using the static-assets binding.

For manual deploys (and one-time provisioning of the Worker + custom domain):

```bash
pnpm install
pnpm wrangler login           # one-time OAuth
pnpm wrangler deploy
```

CI deploys require two repository secrets:

- `CLOUDFLARE_API_TOKEN` — scoped to: Account → Workers Scripts: Edit; Zone (`hakula.xyz`) → DNS: Edit + Workers Routes: Edit.
- `CLOUDFLARE_ACCOUNT_ID`.

## Site Structure

```text
.
├── config.toml               # Site configuration
├── content/                  # Markdown content (posts, standalone pages)
├── static/                   # Shipped assets
│   ├── css/
│   │   ├── _src/             # Tailwind sources (private, skipped by kiln)
│   │   └── style.css         # Compiled Tailwind output
│   ├── js/                   # JS sources, shipped as-is
│   └── images/
│       ├── article-covers/   # Featured images for posts (WebP)
│       ├── hotlink-ok/       # Avatar images (publicly linkable)
│       └── bg.webp           # Background image (4K)
├── templates/                # Site-level template overrides
├── themes/                   # Themes (git submodules)
│   └── IgnIt/                # Active theme
└── public/                   # Build output
```

## License

Copyright (c) 2026 [Hakula](https://hakula.xyz).  
Code is licensed under [GPL v3](LICENSE).  
Articles are licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0).
