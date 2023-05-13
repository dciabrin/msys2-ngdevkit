#!/bin/bash
set -eu

help() {
    echo "Usage: $0 [--package NGDEVKIT_PKG] [--env MINGW_SUBSYSTEM]" >&2
    echo "Build a ngdevkit package based on its associate PKGBUILD"
    echo ""
    echo "Options:"
    echo "  --package: ngdevkit pagkage to build (default: autodetect)"
    echo "  --env: mingw subsystem to target (default: ucrt64)"
    exit ${1:-0}
}

while true; do
    case "${1:-}" in
        --help) help;;
        --package) PKG="$2"; shift 2 ;;
        --env) ENV="$2"; shift 2 ;;
        * ) break ;;
    esac
done


if [ -z "${PKG:-}" ]; then
    # The package built depends on the branch's name
    GITHUB_REF=${GITHUB_REF:-}
    BRANCH=${GITHUB_REF#refs/heads/}
    if [ -z "$BRANCH" ]; then
        echo "Script not run in CI. Use local branch name for building package"
        BRANCH=$(git branch --show-current)
    fi
    PKG=$(.ci/pkg-name-from-branch.sh $BRANCH)
fi

# Note: we support ucrt64 packages for now
ENV=${ENV:-ucrt64}

echo "Building package $PKG for target subsystem $ENV"
echo ""

cd mingw-w64-$PKG
MINGW_ARCH=${ENV} makepkg-mingw --noconfirm --noprogressbar -sCLf
