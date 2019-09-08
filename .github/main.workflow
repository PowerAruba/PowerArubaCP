workflow "script-analysis" {
  resolves = ["analyze"]
  on = "push"
}

workflow "pr-script-analysis" {
  resolves = "analyze-pr"
  on = "pull_request"
}

action "analyze-pr" {
  uses = "devblackops/github-action-psscriptanalyzer@master"
  secrets = ["GITHUB_TOKEN"]
}

action "analyze" {
  uses = "devblackops/github-action-psscriptanalyzer@master"
  secrets = ["GITHUB_TOKEN"]
}
