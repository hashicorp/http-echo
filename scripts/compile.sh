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

# Get the git commit
GIT_COMMIT=$(git rev-parse HEAD)
GIT_DIRTY=$(test -n "`git status --porcelain`" && echo "+CHANGES" || true)

# Determine the arch/os combos we're building for
XC_ARCH=${XC_ARCH:-"amd64"}
XC_OS=${XC_OS:-"darwin linux windows"}
XC_EXCLUDE=${XC_EXCLUDE:-""}

# Delete the old dir
echo "==> Removing old builds..."
rm -f bin/*
rm -rf pkg/*
mkdir -p bin/

# Build
echo "==> Building..."
export CGO_ENABLED=0
for GOARCH in $XC_ARCH; do
  for GOOS in $XC_OS; do
    if [[ $XC_EXCLUDE == *"${GOOS}/${GOARCH}"* ]]; then
      continue
    fi

    printf "%s%20s %s\n" "-->" "${GOOS}/${GOARCH}:" "${PKGNAME}"
    go build \
      -a \
      -ldflags="-X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}" \
      -o="pkg/${GOOS}_${GOARCH}/${NAME}" \
      .
  done
done
