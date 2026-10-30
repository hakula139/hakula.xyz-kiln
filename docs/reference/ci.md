# CI

## Checks

[`ci.yml`](../../.github/workflows/ci.yml) runs on pushes and pull requests to `main` and `dev`. `Nix Flake Check` runs `nix flake check`, and `Site Check` runs the `pnpm` checks that [verification](../../AGENTS.md#verification) lists.

The flake also tests the PNG exporter and renders both score tables with its packaged fonts.

[`build.yml`](../../.github/workflows/build.yml) is a reusable `workflow_call` that enters the dev shell and runs `kiln build --minify`, including CSS compilation. `ci.yml`, `deploy.yml`, and `preview.yml` call into it, so the build path is single-sourced.

## Deploy

[`deploy.yml`](../../.github/workflows/deploy.yml) ships the build's `public/` to the Cloudflare Workers in [`wrangler.toml`](../../wrangler.toml), the top-level Worker from `main` and `[env.dev]` from `dev`. The `production` and `development` environments accept deploys only from those branches. Development builds keep links on the development origin, and [`static/_headers`](../../static/_headers) sends `X-Robots-Tag: noindex` on the development and preview hosts. [README.md](../../README.md#deploy) lists the manual deploy commands.

[`preview.yml`](../../.github/workflows/preview.yml) deploys each PR from this repository as a Worker Preview named `pr-<number>` and comments its stable and per-push URLs. When the PR closes, [`preview-cleanup.yml`](../../.github/workflows/preview-cleanup.yml) deletes the Preview, marks the PR's `preview` deployments inactive, and updates the comment. It runs on `pull_request_target`, which also fires for PRs with merge conflicts and runs `main`'s copy of the workflow, so a change to it takes effect only once merged. It holds the deploy secrets and a write token, so it must never check out or run PR code. Both workflows share the concurrency group `preview-<number>`, so closing a PR cancels its in-flight deploy. Previews serve a bare `Not found` for missing paths, because Worker Previews ignore `not_found_handling` ([workers-sdk#16047](https://github.com/cloudflare/workers-sdk/issues/16047)).

The deploy, preview, and preview cleanup workflows read two repository secrets:

- `CLOUDFLARE_API_TOKEN`, scoped to Account → Workers Scripts: Edit and Zone (`hakula.xyz`) → DNS: Edit + Workers Routes: Edit.
- `CLOUDFLARE_ACCOUNT_ID`.
