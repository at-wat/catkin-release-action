#!/bin/sh

cd "${GITHUB_WORKSPACE}" \
  || (echo "Workspace is unavailable" >&2; exit 1)


. /usr/ros/${ROS_DISTRO}/setup.sh

set -eu


# Setup
echo -e "machine github.com\nlogin ${GITHUB_TOKEN}" > ~/.netrc
git config user.name ${INPUT_GIT_USER}
git config user.email ${INPUT_GIT_EMAIL}

# Fetch all history to generate changelog
git fetch --prune --unshallow

git branch pr-base
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
git log pr-base..HEAD

# Push
git push origin release-${INPUT_VERSION}
