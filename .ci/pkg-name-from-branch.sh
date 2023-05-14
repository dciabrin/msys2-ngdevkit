#!/bin/bash
set -eu
# $1: branch name, e.g.
# refs/heads/nightly/ngdevkit-gngeo-202001191709
# refs/heads/nightly/ngdevkit-gngeo
# refs/heads/ngdevkit-gngeo-202001191709
# refs/heads/ngdevkit-gngeo
# nightly/ngdevkit-gngeo-202001191709
# nightly/ngdevkit-gngeo
# ngdevkit-gngeo-202001191709
# ngdevkit-gngeo
BRANCH=$1
echo $BRANCH | sed -E -e 's%^refs/heads/%%' -e 's%-[0-9]*$%%' -e 's%^(nightly/)?(.*)%\2%'
