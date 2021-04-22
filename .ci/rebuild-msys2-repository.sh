#!/bin/bash

# Copyright (c) 2021 Damien Ciabrini
# This file is part of ngdevkit

# fail on any error, before breaking the msys2 repository :P
set -e

# Disable verbose to prevent leaking credentials
# set +x


help() {
    echo "Usage: $0 -u {user} -t {github-api-token}" >&2
    exit ${1:-0}
}

error() {
    echo "Error: $1" >&2
    help 1
}

check() {
    if [ $2 != 200 ] && [ $2 != 204 ]; then
        error "unexpected return from '$1' ($2). Aborting"
    fi
}


# ----------------- config parsing -----------------
#
USER=
GITHUB_TOKEN=${GH_TOKEN:-}
DRYRUN=

# assume getopt is the BSD variant, with only short options
OPTS=$(/usr/bin/getopt hdu:r:t:b: $@)
if [ $? != 0 ]; then
    error "parsing arguments failed"
fi

eval set -- "$OPTS"
while true; do
    case "$1" in
        -h) help;;
        -d ) DRYRUN=1; shift ;;
        -u ) USER="$2"; shift 2 ;;
        -t ) GITHUB_TOKEN="$2"; shift 2 ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

if [ -z "$USER" ]; then
    error "no user specified"
fi
if [ -z "$GITHUB_TOKEN" ]; then
    error "no token/password specified for GitHub API credentials"
fi
CREDS=$USER:$GITHUB_TOKEN



# Get all the releases for all the subpackages
echo "Downloading all releases for all subpackages..."
ret=$(curl -s -w "%{http_code}" -X GET -u $CREDS https://api.github.com/repos/$USER/msys2-ngdevkit/releases -o releases)
check "downloading all releases for all subpackages" $ret

echo "Extracting tarball URL from releases..."
jq -r '.. | .browser_download_url? // empty' releases > tarballs

pkgs=""
for subproject in emudbg ngdevkit-gngeo ngdevkit-toolchain ngdevkit; do
    echo "Looking for latest releases for $subproject..."
    pkg=$(grep "$subproject-[0-9]" tarballs | sort | tail -1);
    test -n "$pkg"
    pkgs="$pkgs $pkg"
done

# If we end up here, we know we have all the necessary package to
# rebuild an up-to-date MSYS2 package repository

echo "Checking out the current MSYS2 repository"
git worktree add -b pkg-repo repository origin/pkg-repo
cd repository

echo "Removing current packages from the repository"
git rm -f docs/x86_64/*.pkg.tar.zst

echo "Download new packages for all subprojects"
pushd docs/x86_64
for p in $pkgs; do
    dstname=$(basename $p | sed 's/%2b/+/i')
    echo "$p"
    curl -sL $p -o $dstname
done

echo "Rebuild the repository and commit the changes"
repo-add -R ngdevkit.db.tar.gz *.pkg.tar.zst
git add *.pkg.tar.zst ngdevkit.db ngdevkit.db.tar.gz ngdevkit.files ngdevkit.files.tar.gz

echo -e "Repository rebuild $(date '+%Y%m%d%H%M')\n" > commitmsg
for i in *.pkg.tar.zst; do echo $(echo $i | sed -e 's/mingw-w64-x86_64-\([^0-9]*\)-\(.*\)-x86_64.*/\1: \2/'); done | column -s: -t >> commitmsg
git commit --amend --no-edit -F commitmsg
