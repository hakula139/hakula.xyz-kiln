# AGENTS.md: hakula.xyz-kiln

Project-specific rules for any coding assistant working in this repository. `CLAUDE.md` is a symlink to this file. Follow the user's global instructions for communication, scope, comment, and commit doctrine.

This is the [kiln](https://github.com/hakula139/kiln) source for [hakula.xyz](https://hakula.xyz), using the [IgnIt](https://github.com/hakula139/IgnIt) theme as a submodule at `themes/IgnIt/`. This file holds only what the repository cannot show you directly, so anything readable off `ls`, `flake.nix`, `package.json`, or `git log` is deliberately absent.

## Read before you edit

| Touching                          | Read                                               |
| --------------------------------- | -------------------------------------------------- |
| Frontmatter, typography, Markdown | [content/AGENTS.md](content/AGENTS.md)             |
| Prose in an article               | [content/posts/AGENTS.md](content/posts/AGENTS.md) |

## Override precedence

A file under `templates/` shadows the same-path file in `themes/IgnIt/templates/`. A site-only directive at `templates/directives/<name>.html` is picked up by kiln's directive renderer with no further wiring, and an icon at `templates/_partials/icons/<slug>.svg` shadows the theme's bundle for that slug or adds a new one.

Asset publication and CSS contracts are documented in [kiln's assets guide](https://github.com/hakula139/kiln/blob/main/docs/assets.md).

## Source constraints

**Install Git LFS before cloning.** Image binaries (`*.avif`, `*.gif`, `*.jpg`, `*.png`, `*.webp`) are stored via LFS per `.gitattributes`, and without `git lfs install` you get pointer files where the images should be.

## Build

Use the commands in [README.md](README.md#usage) for site builds and previews. `nix flake check` runs the Nix-side hooks.

Node-side pre-commit hooks no-op when `node_modules/` is absent, which is the case inside the Nix sandbox. CI's `check` job runs the equivalent `pnpm` commands directly, so coverage is preserved and a green `nix flake check` does not mean the Node hooks ran.

## Deploy

Deployment commands and branch behavior are documented in [README.md](README.md#deploy).

`.github/workflows/build.yml` is a reusable `workflow_call` that enters the dev shell and runs `kiln build --minify`, including CSS compilation. Both `ci.yml` and `deploy.yml` call into it, so the build path is single-sourced.

## Conventions

- Article covers go in `assets/images/article-covers/`. Co-located assets such as diagrams and data files sit alongside `index.md` in the page bundle.
- Commit scope is the topic area: a content file name without its extension, or `config`, or `template`.
- Assign pull requests to `hakula139`.
- Add spell-check words to `.cspell/words.txt`, one per line, sorted alphabetically.
