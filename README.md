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

[Nix](https://nixos.org/download/) (with flakes) is the recommended path. `nix develop` supplies kiln, whose package carries its CSS processor and Pagefind, along with the Node tools for linting and deployment. Packages are pulled from the [`hakula` cachix cache](https://app.cachix.org/cache/hakula). Without Nix, follow [kiln's installation instructions](https://github.com/hakula139/kiln#installation), set up its [CSS processor](https://github.com/hakula139/kiln/blob/main/docs/assets.md#processor-setup), and install [Pagefind](https://pagefind.app/docs/installation/).

## Usage

```bash
kiln build         # Build to public/
kiln serve --open  # Preview with live reload
```

## Deploy

Pushes to `main` deploy to [hakula.xyz](https://hakula.xyz) in the `production` GitHub Environment, and pushes to `dev` deploy to [dev.hakula.xyz](https://dev.hakula.xyz) in the `development` environment, via [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml). Each environment accepts deploys only from its own branch. The workflow builds with `kiln build --minify` and ships `public/` to separate Cloudflare Workers configured in [`wrangler.toml`](wrangler.toml). Development builds keep links on the development origin.

Each PR from this repository gets a Worker Preview named `pr-<number>` through [`.github/workflows/preview.yml`](.github/workflows/preview.yml), deployed in the `preview` environment and linked from a PR comment. Its `workers.dev` URL serves the PR's latest build, and each push also gets a URL of its own. When the PR closes, the workflow deletes the Preview and marks its deployments inactive. Development and PR preview hosts are excluded from indexing with `X-Robots-Tag: noindex`.

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
├── assets/                   # Shared assets
│   ├── css/_src/             # Handwritten shared CSS
│   ├── images/
│   │   ├── article-covers/   # Featured images for posts (WebP)
│   │   └── bg.webp           # Background image (4K)
│   └── js/                   # Shared JavaScript
├── config.toml               # Site configuration
├── content/                  # Markdown content and page-owned assets
├── i18n/                     # Site translations (menu labels)
├── static/                   # Public files with fixed URLs
│   └── assets/
│       ├── images/
│       │   ├── hotlink-ok/   # Avatar images (publicly linkable)
│       │   └── social/       # Social link targets
│       └── owo/              # Comment emoji, listed by URL in index.json
├── templates/                # Site-level template overrides
├── themes/                   # Themes (git submodules)
│   └── IgnIt/                # Active theme
└── public/                   # Build output
```

See [kiln's assets guide](https://github.com/hakula139/kiln/blob/main/docs/assets.md) for CSS sources, publication rules, and live reload. `pnpm build` and `pnpm dev` alias kiln's build and serve commands.

## License

Copyright (c) 2026 [Hakula](https://hakula.xyz).\
Code is licensed under [GPL v3](LICENSE).\
Articles are licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0).
