# hakula.xyz

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-orange.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0)

My personal website, built with [kiln](https://github.com/hakula139/kiln) and the [IgnIt](https://github.com/hakula139/IgnIt) theme.

## Prerequisites

- [kiln](https://github.com/hakula139/kiln) binary (Rust 1.85+)

## Setup

```bash
git clone --recurse-submodules https://github.com/hakula139/hakula.xyz-kiln.git
cd hakula.xyz-kiln
```

## Usage

```bash
kiln build
```

Output is written to `public/`.

## Site Structure

```text
.
├── config.toml         # Site configuration
├── content/            # Markdown content (posts, standalone pages)
├── templates/          # Site-level template overrides
├── themes/             # Themes (git submodules)
│   └── IgnIt/          # Active theme
├── static/             # Static assets (favicons, images)
└── public/             # Build output
```

## License

Copyright (c) 2026 [Hakula](https://hakula.xyz).  
Code is licensed under [GPL v3](LICENSE).  
Articles are licensed under [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0).
