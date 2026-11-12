# Architecture

The site is built by [kiln](https://github.com/hakula139/kiln) with the [IgnIt](https://github.com/hakula139/IgnIt) theme, checked out as a submodule at `themes/IgnIt/`.

## Layout

```text
.
├── assets/       # Shared assets
├── config.toml   # Site configuration
├── content/      # Markdown content and page-owned assets
├── docs/         # Contributor documentation
├── i18n/         # Site translations (menu labels)
├── scripts/      # Score-table PNG export
├── static/       # Public files with fixed URLs
├── templates/    # Site-level template overrides
├── themes/       # Themes (git submodules)
└── public/       # Build output
```

## Template overrides

Template, directive, and icon overrides are covered by [kiln's override model](https://github.com/hakula139/kiln/blob/main/docs/themes.md#override-model) and [IgnIt's customization guide](https://github.com/hakula139/IgnIt/blob/main/docs/customization.md).

## Assets

[kiln's assets guide](https://github.com/hakula139/kiln/blob/main/docs/assets.md) documents CSS sources, asset publication rules, CSS contracts, and live reload.
