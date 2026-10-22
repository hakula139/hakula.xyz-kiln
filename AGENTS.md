# AGENTS.md: hakula.xyz-kiln

Project-specific rules for any coding assistant working in this repository. `CLAUDE.md` is a symlink to this file. Follow the user's global instructions for communication, scope, comment, and commit doctrine.

This is the [kiln](https://github.com/hakula139/kiln) source for [hakula.xyz](https://hakula.xyz). This file is an index: it holds only what applies to every task, while anything needed for one kind of change lives in the page the table points to. Anything readable off `ls`, `flake.nix`, `package.json`, or `git log` is deliberately absent.

## Read before you edit

| Touching                                 | Read                                                             |
| ---------------------------------------- | ---------------------------------------------------------------- |
| Frontmatter, typography, Markdown        | [content/AGENTS.md](content/AGENTS.md)                           |
| Prose in an article                      | [content/posts/AGENTS.md](content/posts/AGENTS.md)               |
| Templates, assets, or the layout         | [docs/reference/architecture.md](docs/reference/architecture.md) |
| A workflow, a deploy, or a failing check | [docs/reference/ci.md](docs/reference/ci.md)                     |

## Source constraints

Images (`*.avif`, `*.gif`, `*.jpg`, `*.png`, `*.webp`) are Git LFS objects per `.gitattributes`, so a text pointer where an image should be means LFS is missing, as [README.md](README.md#setup) explains.

## Verification

Use the commands in [README.md](README.md#usage) for site builds and previews. `nix flake check` runs the Nix-side hooks.

Node-side pre-commit hooks no-op when `node_modules/` is absent, which is the case inside the Nix sandbox. Run `pnpm format`, `pnpm lint`, and `pnpm spellcheck` in the dev shell to cover them, as CI's `Site Check` job does, because a green `nix flake check` does not mean the Node hooks ran.

## Conventions

- Commit scope is the topic area: a content file name without its extension, or `config`, or `template`.
- Assign pull requests to `hakula139`.
- Add spell-check words to `.cspell/words.txt`, one per line, sorted alphabetically.

## Documentation maintenance

`README.md` is for a reader running or deploying the site, while `AGENTS.md`, `docs/`, and the nested `AGENTS.md` files are for whoever changes it. Give each fact one home and link to it from elsewhere.
