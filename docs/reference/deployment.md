# Deployment

## Branch deploys

Pushes to `main` deploy to [hakula.xyz](https://hakula.xyz) in the `production` GitHub Environment, and pushes to `dev` deploy to [dev.hakula.xyz](https://dev.hakula.xyz) in the `development` environment. Each environment accepts deploys only from its branch. Development builds keep links on the development origin, and [`static/_headers`](../../static/_headers) sends `X-Robots-Tag: noindex` on the development and preview hosts. [README.md](../../README.md#deployment) has the manual commands.

Deploys queue per branch. A run fails if its commit is no longer the branch head.

## Pull request previews

Same-repository PRs except those opened by Dependabot get a `pr-<number>` Worker Preview with stable and per-push URLs in a PR comment. Closing the PR deletes its preview, deactivates its GitHub preview deployments, and updates the comment. Deploy and cleanup share a queue per PR and check that the event is still current. Cleanup runs the trusted `pull_request_target` checkout with deploy secrets and a write token.

Previews serve a bare `Not found` for missing paths, because Worker Previews ignore `not_found_handling` ([workers-sdk#16047](https://github.com/cloudflare/workers-sdk/issues/16047)).

## Secrets

The deploy, preview, and cleanup workflows read two repository secrets:

- `CLOUDFLARE_API_TOKEN`, scoped to Account → Workers Scripts: Edit and Zone (`hakula.xyz`) → DNS: Edit + Workers Routes: Edit.
- `CLOUDFLARE_ACCOUNT_ID`.
