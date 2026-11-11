# Deployment

## Branch deploys

Pushes to `main` deploy to [hakula.xyz](https://hakula.xyz) in the `production` GitHub Environment, and pushes to `dev` deploy to [dev.hakula.xyz](https://dev.hakula.xyz) in the `development` environment. Each environment accepts deploys only from its branch. Development builds keep links on the development origin, and [`static/_headers`](../../static/_headers) sends `X-Robots-Tag: noindex` on the development and preview hosts. [README.md](../../README.md#deployment) has the manual commands.

## Pull request previews

Each PR from this repository deploys a Worker Preview named `pr-<number>` and comments its stable and per-push URLs. Closing the PR deletes the Preview, marks its `preview` deployments inactive, and updates the comment. That cleanup runs on `pull_request_target`, so it holds the deploy secrets and a write token and must never check out or run PR code. Previews serve a bare `Not found` for missing paths, because Worker Previews ignore `not_found_handling` ([workers-sdk#16047](https://github.com/cloudflare/workers-sdk/issues/16047)).

## Secrets

The deploy, preview, and cleanup workflows read two repository secrets:

- `CLOUDFLARE_API_TOKEN`, scoped to Account → Workers Scripts: Edit and Zone (`hakula.xyz`) → DNS: Edit + Workers Routes: Edit.
- `CLOUDFLARE_ACCOUNT_ID`.
