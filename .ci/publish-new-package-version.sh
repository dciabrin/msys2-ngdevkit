#!/bin/sh
set -eu

# The package built depends on the branch's name
BRANCH=${GITHUB_REF#refs/heads/}
if [ -z "$BRANCH" ]; then
    echo "Script not run in CI. Use local branch name for building package"
    BRANCH=$(git branch --show-current)
fi
PKG=$(.ci/pkg-name-from-branch.sh $BRANCH)
echo "Publishing new package for $PKG (branch $BRANCH)"
test -f mingw-w64-$PKG/PKGBUILD

# merge from the detached branch to master
git format-patch -1 -o new-version
git checkout main
git am new-version/*
git push
