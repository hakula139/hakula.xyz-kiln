# Architecture

The site is built by [kiln](https://github.com/hakula139/kiln) with the [IgnIt](https://github.com/hakula139/IgnIt) theme, checked out as a submodule at `themes/IgnIt/`.

## Layout

```text
.
├── assets/       # Shared assets
├── config.toml   # Site configuration
├── content/      # Markdown content and page-owned assets
├── i18n/         # Site translations (menu labels)
├── scripts/      # Score-table PNG export
├── static/       # Public files with fixed URLs
├── templates/    # Site-level template overrides
├── themes/       # Themes (git submodules)
└── public/       # Build output
```

## Template overrides

A file under `templates/` shadows the same-path file in `themes/IgnIt/templates/`. A site-only directive at `templates/directives/<name>.html` is picked up by kiln's directive renderer with no further wiring, and an icon at `templates/_partials/icons/<slug>.svg` shadows the theme's bundle for that slug or adds a new one.

## Assets

[kiln's assets guide](https://github.com/hakula139/kiln/blob/main/docs/assets.md) documents CSS sources, asset publication rules, CSS contracts, and live reload.
