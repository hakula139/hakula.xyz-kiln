# AGENTS.md: hakula.xyz-kiln

This is the [hakula.xyz](https://hakula.xyz) blog, built with [kiln](https://github.com/hakula139/kiln).

## Read before you edit

| When the change touches              | Read                                           |
| ------------------------------------ | ---------------------------------------------- |
| Frontmatter, typography, or Markdown | [Format and typography](content/AGENTS.md)     |
| Prose in an article                  | [Writing style](content/posts/AGENTS.md)       |
| Templates, assets, or the layout     | [Architecture](docs/reference/architecture.md) |
| A deploy or a preview                | [Deployment](docs/reference/ci.md)             |

## Source constraints

Images (`*.avif`, `*.gif`, `*.jpg`, `*.png`, `*.webp`) are Git LFS objects per `.gitattributes`, so a text pointer where an image should be means LFS is missing. Install it as [README.md](README.md#setup) describes, then run `git lfs pull`.

## Verification

Run these before review:

```bash
nix develop -c run-hooks
nix develop -c kiln build
```

## Conventions

Commit scope is the topic area: a content file name without its extension, `config`, or `template`.

## Documentation maintenance

`README.md` is for a reader running or deploying the site, while `AGENTS.md`, `docs/`, and the nested `AGENTS.md` files are for whoever changes it. Give each fact one home and link to it from elsewhere.
