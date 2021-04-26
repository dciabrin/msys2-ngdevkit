#!/bin/bash
# $1: package name
set -eu
PKG=$1
MASTER_BRANCH=${2:-master}

if [ -f configure.ac ]; then
    HEAD_VERSION=$(sed -ne 's/AC_INIT.*\[\([^]]*\)\].*/\1/p' configure.ac)
elif [ -f Makefile ]; then
    HEAD_VERSION=$(sed -ne 's%VERSION=\(.*\)$%\1%p' Makefile)
else
    echo "Cannot parse head version for $PKG in $(pwd)" >&2
    exit 1
fi

MSYS2_REPO_BASEDIR=$(dirname $(dirname $0))
export GIT_ASKPASS=$(realpath ${MSYS2_REPO_BASEDIR}/.ci/git-ask-pass.sh)

git checkout ${MASTER_BRANCH}
HEAD_COMMIT_DATE=$(TZ=UTC git show --quiet --date='format-local:%Y%m%d%H%M' --format='%cd')

if ! (git tag -l | grep -q nightly-$HEAD_COMMIT_DATE); then
    echo "Tagging $PKG with new version ${HEAD_COMMIT_DATE} on tip of ${MASTER_BRANCH}"
    git tag nightly-$HEAD_COMMIT_DATE
    if ! git push origin nightly-$HEAD_COMMIT_DATE; then
        # If the tag has been created by somebody else in the mean time
        # the push will fail. This is alright for us though
        if [ "$(git ls-remote origin refs/tags/nightly-$HEAD_COMMIT_DATE)" != "" ]; then
            echo "Tag already exists on origin, tag push in unecessary"
        else
            echo "Tagging $PKG with ${HEAD_COMMIT_DATE} failed" >&2
            exit 1
        fi
    fi
else
    echo "Tagging ${HEAD_COMMIT_DATE} for $PKG already exists, not retagging"
fi

echo "Computing archive URL and SHA256 for $PKG $HEAD_COMMIT_DATE"
ARCHIVE=$(echo "https://github.com/dciabrin/$PKG/archive/nightly-${HEAD_COMMIT_DATE}.tar.gz" | sed 's/ngdevkit-gngeo/gngeo/')
HASH=$(curl -sL $ARCHIVE | sha256sum | cut -d' ' -f1)

echo "Computing new package version"
PKGBUILD_FILE=$(realpath ${MSYS2_REPO_BASEDIR}/mingw-w64-$PKG/PKGBUILD)
MSYS2_VERSION=${HEAD_VERSION}+${HEAD_COMMIT_DATE}

if grep "^pkgver=${MSYS2_VERSION}" $PKGBUILD_FILE; then
    # the tag exist in msys2, bump the rebuild
    MSYS2_REBUILD=$(awk -F= '/pkgrel/ {print $2+1}' $PKGBUILD_FILE)
else
    # new tag, fresh rebuild version
    MSYS2_REBUILD=1
fi

echo "Preparing new nightly version ${MSYS2_VERSION}-${MSYS2_REBUILD} of $PKG in msys2 ngdevkit repository"
cd $MSYS2_REPO_BASEDIR
git checkout main
sed -i -e "s/^pkgver=.*/pkgver=${MSYS2_VERSION}/" -e "s/^pkgrel=.*/pkgrel=${MSYS2_REBUILD}/" -e "s/^pkgvernightly=.*/pkgvernightly=nightly-${HEAD_COMMIT_DATE}/" -e "s/^sha256sums=.*/sha256sums=('${HASH}')/" $PKGBUILD_FILE

NEW_NIGHTLY_VERSION=nightly/${PKG}-${HEAD_COMMIT_DATE}
git checkout -b ${NEW_NIGHTLY_VERSION}
git add ${PKGBUILD_FILE}
if [ "$MSYS2_REBUILD" -ne "1" ]; then
    REBUILD=" - rebuild #${MSYS2_REBUILD}"
else
    REBUILD=""
fi
git commit -m "Nightly build ${PKG} ${HEAD_COMMIT_DATE}${REBUILD}"
git push -f -u origin ${NEW_NIGHTLY_VERSION}
echo "New nightly version ready to be rebuilt in MSYS2 repository"
