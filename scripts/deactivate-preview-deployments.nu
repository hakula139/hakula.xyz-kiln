# ==================================================================================================
# Preview Deployment Cleanup
# ==================================================================================================

use std-rfc/str

# Mark the current pull request's preview deployments inactive after cleanup.
def main [] {
  let pr_id = (open $env.GITHUB_EVENT_PATH).pull_request.node_id
  let query = (
    "
    query($id: ID!, $endCursor: String) {
      node(id: $id) {
        ... on PullRequest {
          timelineItems(first: 100, after: $endCursor, itemTypes: [DEPLOYED_EVENT]) {
            nodes { ... on DeployedEvent { deployment { databaseId environment } } }
            pageInfo { hasNextPage endCursor }
          }
        }
      }
    }
    "
    | str dedent
  )

  let ids = (
    ^gh api graphql
      --paginate
      --slurp
      -f $"id=($pr_id)"
      -f $"query=($query)"
    | from json
    | get data.node.timelineItems.nodes
    | flatten
    | where deployment?.environment? == "preview"
    | get deployment.databaseId
  )

  for id in $ids {
    (
      ^gh api $"repos/($env.GITHUB_REPOSITORY)/deployments/($id)/statuses"
        -f "state=inactive"
        --silent
    )
  }
}
