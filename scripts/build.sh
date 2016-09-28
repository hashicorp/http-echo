#!/usr/bin/env bash
#
# This script builds the application from source for multiple platforms.
set -e

# Get the parent directory of where this script is.
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ] ; do SOURCE="$(readlink "$SOURCE")"; done
DIR="$(cd -P "$(dirname "$SOURCE")/.." && pwd)"

# Change into that directory
cd "$DIR"

# Get the name from the directory and package
PKGNAME="$(basename $(cd ../../ && pwd))/$(basename $(cd ../ && pwd))/$(basename $(pwd))"
NAME=${NAME:-"$(basename $(pwd))"}

# Build using go cross-compiling
echo "==> Starting container..."
docker run \
  --rm \
  --env="XC_OS=${XC_OS}" \
  --env="XC_ARCH=${XC_ARCH}" \
  --workdir="/go/src/${PKGNAME}" \
  --volume="$(pwd):/go/src/${PKGNAME}" \
  golang:1.7 /bin/sh -c "make bin"

# Move all the compiled things to the $GOPATH/bin
GOPATH=${GOPATH:-$(go env GOPATH)}
case $(uname) in
  CYGWIN*)
    GOPATH="$(cygpath $GOPATH)"
    ;;
esac
OLDIFS=$IFS
IFS=: MAIN_GOPATH=($GOPATH)
IFS=$OLDIFS

# Copy our OS/Arch to the bin/ directory
DEV_PLATFORM="./pkg/$(go env GOOS)_$(go env GOARCH)"
for F in $(find ${DEV_PLATFORM} -mindepth 1 -maxdepth 1 -type f); do
  cp ${F} bin/
  cp ${F} ${MAIN_GOPATH}/bin/
done
