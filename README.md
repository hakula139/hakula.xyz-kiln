# hakula.xyz

[![CI](https://github.com/hakula139/hakula.xyz-kiln/actions/workflows/ci.yml/badge.svg)](https://github.com/hakula139/hakula.xyz-kiln/actions/workflows/ci.yml)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-orange.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0)
![WakaTime coding time for hakula.xyz-kiln](https://wakatime.com/badge/user/f4a35a1f-0e29-4093-a647-e66aad164737/project/ab6e0cef-1d0d-4592-97cf-4948b9e1472c.svg)

My personal website, built with [kiln](https://github.com/hakula139/kiln) and the [IgnIt](https://github.com/hakula139/IgnIt) theme. The previous Hugo site is preserved at [old.hakula.xyz](https://old.hakula.xyz).

## Setup

Install [Git LFS](https://git-lfs.com/) and run `git lfs install` before cloning, since the images are stored in LFS.

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

`pnpm build` and `pnpm dev` run `kiln build` and `kiln serve`.

## Deploy

Pushes to `main` deploy to [hakula.xyz](https://hakula.xyz) in the `production` GitHub Environment, and pushes to `dev` deploy to [dev.hakula.xyz](https://dev.hakula.xyz) in the `development` environment. Each PR from this repository gets a preview URL in the `preview` environment, linked from a PR comment. The workflows and the secrets they need are described in [docs/reference/ci.md](docs/reference/ci.md#deploy).

For a manual deploy, run the workflow on the intended branch:

```bash
gh workflow run deploy.yml --ref main
gh workflow run deploy.yml --ref dev
```

## License

Copyright (c) 2026 [Hakula](https://hakula.xyz).\
Code is licensed under [GPL v3](LICENSE).\
Articles are licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0).
