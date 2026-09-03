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

Names beginning with `_` are private build inputs, which kiln's `copy_static` skips.

## Two things that bite

**Run `pnpm build` after editing CSS.** Tailwind sources live in `static/css/_src/`, and the compiled `static/css/style.css` is committed. The sync gate is `git diff --exit-code static/` in CI's `check` job only, so a stale `style.css` commits cleanly on your machine and fails at PR time.

**Install Git LFS before cloning.** Image binaries (`*.avif`, `*.gif`, `*.jpg`, `*.png`, `*.webp`) are stored via LFS per `.gitattributes`, and without `git lfs install` you get pointer files where the images should be.

## Build

```bash
kiln build                   # build to public/
kiln serve --open            # dev server with live reload
pnpm build                   # compile static/css/style.css
pnpm dev                     # Tailwind watch
nix develop                  # dev shell, installs the pre-commit hook
nix flake check              # Nix-side hooks, also gated in CI
```

`direnv` activates the dev shell via `.envrc`. kiln and pagefind come prebuilt from the `hakula` cachix substituter, so first entry does not compile kiln from source. Minification happens at deploy time through `kiln build --minify`, leaving shipped files readable during development.

Node-side pre-commit hooks no-op when `node_modules/` is absent, which is the case inside the Nix sandbox. CI's `check` job runs the equivalent `pnpm` commands directly, so coverage is preserved and a green `nix flake check` does not mean the Node hooks ran.

## Deploy

Cloudflare Workers with a Static Assets binding, at [dev.hakula.xyz](https://dev.hakula.xyz). `wrangler.toml` pins the worker name, custom domain, and `not_found_handling`. The apex `hakula.xyz` is still served by the legacy Pages project.

`.github/workflows/build.yml` is a reusable `workflow_call` that enters the dev shell and runs `pnpm build` then `kiln build --minify`. Both `ci.yml` and `deploy.yml` call into it, so the build path is single-sourced. A manual deploy is `pnpm wrangler login` once, then `pnpm wrangler deploy`. CI needs the `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` repository secrets.

## Conventions

- Article covers go in `static/images/article-covers/`. Co-located assets such as diagrams and data files sit alongside `index.md` in the page bundle.
- Commit scope is the topic area: a content file name without its extension, or `config`, or `template`.
- Assign pull requests to `hakula139`.
- Add spell-check words to `.cspell/words.txt`, one per line, sorted alphabetically.
