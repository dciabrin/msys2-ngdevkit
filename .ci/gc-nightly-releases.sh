#!/bin/bash

# Copyright (c) 2020-2023 Damien Ciabrini
# This file is part of ngdevkit

set -u

# Disable verbose to prevent leaking credentials
set +x


help() {
    echo "Usage: $0 --package {ngdevkit} --token {github-api-token}" >&2
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

cleanup() {
    if [ -f "${releases:-}" ]; then
        echo "Removing temporary files"
        rm -f "$releases"
    fi
}
trap cleanup EXIT


# ----------------- options parsing -----------------

GITHUB_TOKEN=${GH_TOKEN:-}
DRYRUN=

while true; do
    case "${1:-}" in
        --help) help;;
        --dry-run ) DRYRUN=1; shift ;;
        --package ) PACKAGE="$2"; shift 2 ;;
        --user ) USER="$2"; shift 2 ;;
        --token ) GITHUB_TOKEN="$2"; shift 2 ;;
        * ) break ;;
    esac
done

if [ -z "$USER" ]; then
    error "no user specified"
fi
if [ -z "${PACKAGE:-}" ]; then
    error "no package specified"
fi
if [ -z "${GITHUB_TOKEN:-}" ]; then
    error "no GitHub API credentials specified"
fi
CREDS=$USER:$GITHUB_TOKEN


#
# garbage-collect nightly releases for a specific package
#
releases=$(mktemp -t releases-XXXXXXX.json)

remove_release () {
    local name=$1
    local release_id=$(jq -r 'map(select(.name == "'"$name"'")) | .[].id' $releases)
    local tag_name=$(jq -r 'map(select(.name == "'"$name"'")) | .[].tag_name' $releases)

    echo "  removing release $release_id"
    if [ -z "$DRYRUN" ]; then
        ret=$(curl -s -w "%{http_code}" -X DELETE -u $CREDS https://api.github.com/repos/dciabrin/homebrew-ngdevkit/releases/${release_id})
        check "removing release_id $release_id" $ret
        sleep 0.7
    fi

    echo "  removing associated tag $tag_name"
    if [ -z "$DRYRUN" ]; then
        ret=$(curl -s -w "%{http_code}" -X DELETE -u $CREDS https://api.github.com/repos/dciabrin/homebrew-ngdevkit/git/refs/tags/${tag_name})
        check "removing tag_name $tag_name" $ret
        sleep 0.7
    fi
}

function remove_package_releases()
{
    package=$1

    # Note: keep the two most recent nightly releases
    # to ease transition to newer releases
    names=$(jq -r '. | map(select(.name | sub("^(?<pkg>[^0-9]*)-.*"; "\(.pkg)") | test("^'"$package"'$"))) | sort_by(.updated_at) | .[] | .name' $releases)

    echo "Processing all releases found for package $package..."
    num=0
    for n in $names; do
        echo "release $n"
        if [ $num -ge 2 ]; then
            remove_release $n
        fi
        ((num++))
    done

    if [ $num -gt 2 ]; then
        echo "$(expr $num - 2) release(s) removed for package $package"
    else
        echo "No release removed for package $package"
    fi
}


echo "Retrieving releases..."
ret=$(curl -s -w "%{http_code}" -X GET -u $CREDS https://api.github.com/repos/dciabrin/homebrew-ngdevkit/releases -o $releases)
check "retrieving releases" $ret

remove_package_releases $PACKAGE

echo "Cleanup successful"
