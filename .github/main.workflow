workflow "script-analysis" {
  resolves = ["analyze"]
  on = "push"
}

workflow "pr-script-analysis" {
  resolves = "analyze-pr"
  on = "pull_request"
}

action "filter-to-pr-open-synced" {
  uses = "actions/bin/filter@master"
  args = "action 'opened|synchronize'"
}

action "analyze-pr" {
  uses = "devblackops/github-action-psscriptanalyzer@master"
  needs = "filter-to-pr-open-synced"
  secrets = ["GITHUB_TOKEN"]
}

action "analyze" {
  uses = "devblackops/github-action-psscriptanalyzer@master"
  secrets = ["GITHUB_TOKEN"]
}
