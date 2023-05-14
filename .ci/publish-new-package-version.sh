#!/bin/sh
set -eu

# The package built depends on the branch's name
BRANCH=${GITHUB_REF#refs/heads/}
if [ -z "$BRANCH" ]; then
    echo "Script not run in CI. Use local branch name for building package"
    BRANCH=$(git branch --show-current)
fi
PKG=$(.ci/pkg-name-from-branch.sh $BRANCH)
echo "Publishing new package for $PKG"
test -f mingw-w64-$PKG/PKGBUILD

# Ensure that CI has fetched all the refs we need
git fetch --all

# Merge the original commit as a fast forward to avoid diverging
git checkout main
git merge origin/nightly/$PKG --ff-only
git push
echo
echo "New PKGBUILD version for $PKG published"
