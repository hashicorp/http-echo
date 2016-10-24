#!/usr/bin/env sh
set -e

if [ -z "$NAME" ]; then
  echo "Missing \$NAME!"
  exit 127
fi

if [ -z "$PROJECT" ]; then
  echo "Missing \$PROJECT!"
  exit 127
fi

# Get the git commit information
GIT_COMMIT="$(git rev-parse --short HEAD)"
GIT_DIRTY="$(test -n "$(git status --porcelain)" && echo "+CHANGES" || true)"

# Remove old builds
rm -rf bin/*
rm -rf pkg/*

# Runtime variables
LDFLAGS="-s -w"
LDFLAGS="$LDFLAGS -X main.Name=${NAME}"
LDFLAGS="$LDFLAGS -X main.Version=${VERSION}"
LDFLAGS="$LDFLAGS -X main.GitCommit=${GIT_COMMIT}${GIT_DIRTY}"

# Build!
for GOOS in $XC_OS; do
  for GOARCH in $XC_ARCH; do
    if [ "$XC_EXCLUDE" = "*${GOOS}/${GOARCH}*" ]; then
      continue
    fi

    printf "%s%20s %s\n" "-->" "${GOOS}/${GOARCH}:" "${PROJECT}"
    env -i \
      PATH="$PATH" \
      CGO_ENABLED=0 \
      GOPATH="$GOPATH" \
      GOROOT="$GOROOT" \
      GOOS="${GOOS}" \
      GOARCH="${GOARCH}" \
      go build \
      -a \
      -ldflags="$LDFLAGS" \
      -o="pkg/${GOOS}_${GOARCH}/${NAME}" \
      .
  done
done

echo "--> Compressing..."
mkdir pkg/dist
for PLATFORM in $(find ./pkg -mindepth 1 -maxdepth 1 -type d); do
  OSARCH=$(basename ${PLATFORM})
  if [ "$OSARCH" = "dist" ]; then
    continue
  fi

  cd $PLATFORM
  tar -czf ../dist/${NAME}_${VERSION}_${OSARCH}.tgz ${NAME}
  cd - >/dev/null 2>&1
done

echo "--> Checksumming..."
cd pkg/dist
shasum -a256 * > "${NAME}_${VERSION}_SHA256SUMS"
cd - >/dev/null 2>&1
