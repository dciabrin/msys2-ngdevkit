#!/bin/bash

set -eu

# Copyright (c) 2021-2023 Damien Ciabrini
# This file is part of ngdevkit


help() {
    echo "Usage: $0 [--package {PKG}] [--branch {BRANCH}] [--push-tag] [--push-version] [--batch]" >&2
    echo "Bump a package's brew formula to the latest development commit and trigger a nightly build in CI"
    echo ""
    echo "Options:"
    echo "  --package {PKG}: one of ngdevkit's packages (emudbg, ngdevkit-toolchain, ngdevkit, ngdevkit-gngeo)"
    echo "  --branch {BRANCH}: look for latest commit in branch BRANCH"
    echo "  --push-tag: tag the tip of BRANCH to prepare for the formula update"
    echo "  --push-version: push a formula's new nightly version. This triggers a rebuild in CI"
    echo "  --batch: used by the CI workflow on every new commit in the main branch. Implies --push-tag + --push-version."
    exit ${1:-0}
}

git_checkout() {
    branch=$1
    repo=$(basename `git config --get remote.origin.url`)

    if [ -z "${BATCH:-}" ]; then
        read -p "Confirm checkout to branch ${branch} in repo ${repo} (y/n)?" answer
        case $answer in
            [Yy] )
                git checkout -q $branch ;;
            * ) echo "Branch checkout cancelled. Bailing out"
                exit ;;
        esac
    else
        git checkout -q $branch
    fi

    # check that the branch is the same as origin (not changed locally)
    if (git branch -a | grep -q "origin/$branch\$") && \
       ! git status --ahead-behind | grep -q 'up to date'; then
        echo "Your local copy of branch ${branch} in repo ${repo} is not up to date with remote. Fix it and try again" >&2
        exit 1
    fi
}

echo "MSYS2 nightly build script invoked with \"$0 $*\""
echo "---"

while true; do
    case "${1:-}" in
        --help) help;;
        --package ) PKG=$2; shift 2 ;;
        --branch ) MASTER_BRANCH=$2; shift 2 ;;
        --push-tag ) PUSH_TAG=1; shift ;;
        --push-version ) PUSH_VERSION=1; shift ;;
        --batch ) BATCH=1; PUSH_TAG=1; PUSH_VERSION=1; shift ;;
        * ) break ;;
    esac
done


MSYS2_REPO_BASEDIR=$(dirname $(dirname $0))
echo "PKGBUILD base directory: ${MSYS2_REPO_BASEDIR}"


if [ -z "${PKG:-}" ]; then
    REMOTE_URL=$(git config --get remote.origin.url)
    PKG=$(basename $REMOTE_URL | sed 's/gngeo/ngdevkit-gngeo/')
    # Only allow known ngdevkit project to build
    if ! echo "${PKG}" | grep -q -w -e '\(ngdevkit\|emudbg\|ngdevkit-toolchain\|ngdevkit-gngeo\)'; then
        echo "Cannot determine package to build (found '${PKG}'). Use --package manually" >&2
        exit 1
    fi
fi

if [ -z "${MASTER_BRANCH:-}" ]; then
    MASTER_BRANCH=$(git symbolic-ref HEAD | sed 's%refs/heads/%%')
fi

echo "Preparing new nightly build for ${PKG} (branch ${MASTER_BRANCH})"

if [ -f configure.ac ]; then
    HEAD_VERSION=$(sed -ne 's/AC_INIT.*\[\([^]]*\)\].*/\1/p' configure.ac)
elif [ -f Makefile ]; then
    HEAD_VERSION=$(sed -ne 's%VERSION=\(.*\)$%\1%p' Makefile)
else
    echo "Cannot parse head version for $PKG in $(pwd)" >&2
    exit 1
fi

echo "Last released version for ${PKG}: ${HEAD_VERSION}"


# CI: Use the right credentials for git
if [ -n "${GH_TOKEN:-}" ]; then
    export GIT_ASKPASS=$(realpath ${MSYS2_REPO_BASEDIR}/.ci/git-ask-pass.sh)
fi

# Checkout the right branch before querying timestamps
git_checkout ${MASTER_BRANCH}

HEAD_COMMIT_DATE=$(TZ=UTC git show --quiet --date='format-local:%Y%m%d%H%M' --format='%cd')
echo "Last commit timestamp for ${PKG} in branch ${MASTER_BRANCH}: ${HEAD_COMMIT_DATE}"

NIGHTLY_TAG=nightly-$HEAD_COMMIT_DATE
if ! (git tag -l | grep -q $NIGHTLY_TAG); then
    echo "Creating GitHub archive version '${NIGHTLY_TAG}' for tip of branch '${MASTER_BRANCH}'"
    if [ -z "${PUSH_TAG:-}" ]; then
        echo "Not tagging source repository because --push-tag option is disabled. Bailing out"
        exit 0
    fi
    git tag $NIGHTLY_TAG
    if ! git push origin $NIGHTLY_TAG; then
        # The tag might have already been created (e.g. by another nightly
        # build for another package manager, or if we are about to force
        # rebuild this tag). If so, the push will fail, but this is alright
        # as we can reference the github archive for this commit anyway
        if [ "$(git ls-remote origin refs/tags/$NIGHTLY_TAG)" != "" ]; then
            echo "Tag already exists in origin, push in unnecessary"
        else
            echo "Tagging ${PKG} with ${NIGHTLY_TAG} failed" >&2
            exit 1
        fi
    fi
else
    echo "GitHub archive version '${NIGHTLY_TAG}' for branch '${MASTER_BRANCH}' already exists, keep tag"
fi

ARCHIVE=$(echo "https://github.com/dciabrin/$PKG/archive/${NIGHTLY_TAG}.tar.gz" | sed 's/ngdevkit-gngeo/gngeo/')
echo "New PKGBUILD version for package ${PKG} will be based on source archive ${ARCHIVE}"

cd $MSYS2_REPO_BASEDIR
# Checkout the main branch before querying the package's properties
git_checkout main

PKGBUILD_FILE=$(realpath mingw-w64-$PKG/PKGBUILD)
PKGBUILD_CURRENT_URL=$(bash -c "source ${PKGBUILD_FILE}; echo \$source")

if [ "${PKGBUILD_CURRENT_URL}" = "${ARCHIVE}" ]; then
    CURRENT_VERSION_REBUILD=$(bash -c "source ${PKGBUILD_FILE}; echo \$pkgrel")
    VERSION_BASE=$(bash -c "source ${PKGBUILD_FILE}; echo \$pkgver")
    VERSION_REBUILD=$(expr ${CURRENT_VERSION_REBUILD} + 1)
    PKGBUILD_CURRENT_VERSION=${VERSION_BASE}-${CURRENT_VERSION_REBUILD}
    PKGBUILD_VERSION=${VERSION_BASE}-${VERSION_REBUILD}
    echo "Current PKGBUILD version for package ${PKG} already uses this source archive, new version will be a rebuild (${PKGBUILD_CURRENT_VERSION} -> ${PKGBUILD_VERSION})"
else
    VERSION_BASE=${HEAD_VERSION}+${HEAD_COMMIT_DATE}
    VERSION_REBUILD=1
    PKGBUILD_VERSION=${VERSION_BASE}-${VERSION_REBUILD}
    echo "New PKGBUILD version for package ${PKG} will be bumped to version ${PKGBUILD_VERSION}"
fi

echo "Computing SHA256 for source archive ${ARCHIVE}"
HASH=$(curl -sL $ARCHIVE | sha256sum | cut -d' ' -f1)

echo "Preparing new nightly version ${PKGBUILD_VERSION} of ${PKG} in branch nightly/${PKG}"
git_checkout nightly/${PKG}
git merge -q --ff-only main

# Preparing the new yet-to-be-built version in the package branch
# Once the CI job runs on this branch, the newly built package
# will become available in the MSYS2 repo for ngdevkit
sed -i -e "s/^pkgver=.*/pkgver=${VERSION_BASE}/" -e "s/^pkgrel=.*/pkgrel=${VERSION_REBUILD}/" -e "s/^pkgvernightly=.*/pkgvernightly=nightly-${HEAD_COMMIT_DATE}/" -e "s/^sha256sums=.*/sha256sums=('${HASH}')/" $PKGBUILD_FILE
git add ${PKGBUILD_FILE}
git commit -m "Nightly version ${PKG} ${PKGBUILD_VERSION}"

if [ -z "${PUSH_VERSION:-}" ]; then
    echo "Not publishing new PKGBUILD version because --push-version is disabled. Bailing out"
else
    git push -u origin nightly/${PKG}
    echo "New nightly version ready to be rebuilt in CI for integration in MSYS2 repository"
fi
