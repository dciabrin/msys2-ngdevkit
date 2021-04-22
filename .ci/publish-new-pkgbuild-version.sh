#!/bin/sh
set -e

test -n "$GITHUB_REF"
BRANCH=$GITHUB_REF

branch=$(echo $BRANCH | sed 's%refs/heads/%%')
pkg=$(.ci/pkg-name-from-branch.sh $branch)
test -f mingw-w64-$pkg/PKGBUILD
echo "Publishing new PKGBUILD for $pkg (branch $branch)"

# merge from the detached branch to master
git format-patch -1 -o new-version
git checkout main
git am new-version/*
git push
