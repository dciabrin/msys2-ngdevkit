#!/bin/bash
set -eu

# The package built depends on the branch's name
BRANCH=${GITHUB_REF#refs/heads/}
if [ -z "$BRANCH" ]; then
    echo "Script not run in CI. Use local branch name for building package"
    BRANCH=$(git branch --show-current)
fi
PKG=$(.ci/pkg-name-from-branch.sh $BRANCH)
cd mingw-w64-$PKG

# Only build 64bits package for now
MINGW_ARCH=mingw64 makepkg-mingw --noconfirm --noprogressbar -sCLf
