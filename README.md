# catkin-release-action

GitHub Action to create a ROS package release candidate branch.

## Inputs
<dl>
  <dt>github_token</dt> <dd>GITHUB_TOKEN. (required)</dd>
  <dt>version</dt> <dd>New package version. One of version and issue_title must be specified.</dd>
  <dt>issue_title</dt> <dd>Issue title containing new package version. One of version and issue_title must be specified.</dd>
  <dt>git_user</dt> <dd>User name of commit author. (required)</dd>
  <dt>git_email</dt> <dd>E-mail address of commit author. (required)</dd>
</dl>

## Outputs
<dl>
  <dt>created_branch</dt> <dd>Created branch of the release candidate.</dd>
  <dt>version</dt> <dd>Created release version.</dd>
</dl>

## Example

Following example creates a release candidate branch with CHANGELOG.rst and open a pull-request.

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
        uses: at-wat/catkin-release-action@v1
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

See https://github.com/at-wat/mcl_3dl for the working example.
