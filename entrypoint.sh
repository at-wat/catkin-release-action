#!/bin/bash

cd "${GITHUB_WORKSPACE}" \
  || (echo "Workspace is unavailable" >&2; exit 1)

. /usr/ros/${ROS_DISTRO}/setup.bash

set -eu


if [ ! -z "${INPUT_ISSUE_TITLE:-}" ]
then
  if [ ! -z "${INPUT_VERSION:-}" ]
  then
    echo "Both issue_title and version are specified" >&2
    exit 1
  fi
  INPUT_VERSION=$(echo ${INPUT_ISSUE_TITLE} | sed -e 's/^Release \(.*\)$/\1/')
fi


# Setup
echo -e "machine github.com\nlogin ${INPUT_GITHUB_TOKEN}" > ~/.netrc
git config user.name ${INPUT_GIT_USER}
git config user.email ${INPUT_GIT_EMAIL}

# Fetch all history to generate changelog
git fetch --tags --prune --unshallow

git checkout -b release-${INPUT_VERSION}

# Update CHANGELOG
catkin_generate_changelog -y

# Fix RST format
sed '/^Forthcoming/,/[0-9]\+\.[0-9]\+\.[0-9]\+/{/^  /d}' \
  -i $(find . -name CHANGELOG.rst)

git add $(find . -name CHANGELOG.rst)
git commit -m "Update changelog"

# Bump version
catkin_prepare_release -y --no-push --version ${INPUT_VERSION}
git tag -d ${INPUT_VERSION}

# Show
git log ${GITHUB_REF}..HEAD

# Push
git push origin release-${INPUT_VERSION}

echo "::set-output name=created_branch::release-${INPUT_VERSION}"
echo "::set-output name=version::${INPUT_VERSION}"

# Clean-up
if [[ "${GITHUB_REF}" == refs/heads/* ]]
then
  git checkout ${GITHUB_REF}
else
  # Detach head to work with repo-sync/pull-request
  git checkout refs/heads/${GITHUB_REF}
fi
git branch -D release-${INPUT_VERSION}
