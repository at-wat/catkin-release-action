# catkin-release-action

## example

```yaml
name: release-candidate
on:
  issues:
    types: [opened]

jobs:
  release-candidate:
    runs-on: ubuntu-latest
    if: startsWith(github.event.issue.title, 'Release ')
    steps:
      - name: checkout
        uses: actions/checkout@v2
      - name: create release
        id: create_release
        uses: at-wat/catkin-release-action@v1.0.0
        with:
          issue_title: ${{ github.event.issue.title }}
          git_user: @@MAINTAINER_LOGIN@@
          git_email: @@MAINTAINER_EMAIL_ADDRESS@@
          github_token: ${{ secrets.GITHUB_TOKEN }}
      - name: open pull-request
        uses: repo-sync/pull-request@v2
        with:
          source_branch: ${{ steps.create_release.outputs.created_branch }}
          destination_branch: master
          pr_title: Release ${{ steps.create_release.outputs.version}}
          pr_body: close \#${{ github.event.issue.number }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```
