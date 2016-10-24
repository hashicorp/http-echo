# Metadata about this makefile and position
MKFILE_PATH := $(lastword $(MAKEFILE_LIST))
CURRENT_DIR := $(dir $(realpath $(MKFILE_PATH)))
CURRENT_DIR := $(CURRENT_DIR:/=)

# Get the project metadata
VERSION := 0.2.0
PROJECT := $(shell echo $(CURRENT_DIR) | rev | cut -d'/' -f1 -f2 -f3 | rev)
OWNER := $(dir $(PROJECT))
OWNER := $(notdir $(OWNER:/=))
NAME := $(notdir $(PROJECT))

# Current system information (this is the invoking system)
ME_OS = $(shell go env GOOS)
ME_ARCH = $(shell go env GOARCH)

# Default os-arch combination to build
XC_OS ?= darwin linux windows
XC_ARCH ?= amd64
XC_EXCLUDE ?=

# GPG Signing key (blank by default, means no GPG signing)
GPG_KEY ?=

# bin builds the project by invoking the compile script inside of a Docker
# container. Invokers can override the target OS or architecture using
# environment variables.
bin:
	@echo "==> Building ${PROJECT}..."
	@docker run \
		--rm \
		--env="VERSION=${VERSION}" \
		--env="PROJECT=${PROJECT}" \
		--env="NAME=${NAME}" \
		--env="XC_OS=${XC_OS}" \
		--env="XC_ARCH=${XC_ARCH}" \
		--env="XC_EXCLUDE=${XC_EXCLUDE}" \
		--workdir="/go/src/${PROJECT}" \
		--volume="${CURRENT_DIR}:/go/src/${PROJECT}" \
		golang:1.7 /bin/sh -c "scripts/compile.sh"

# deps gets all the dependencies for this repository and vendors them.
deps:
	@echo "==> Updating dependencies..."
	@echo "--> Installing dependency manager..."
	@go get -u github.com/kardianos/govendor
	@govendor init
	@echo "--> Installing all dependencies..."
	@govendor fetch -v +outside

# dev builds the project for the current system as defined by go env.
dev:
	@env \
		XC_OS="${ME_OS}" \
		XC_ARCH="${ME_ARCH}" \
		$(MAKE) -f "${MKFILE_PATH}" bin
	@echo "--> Moving into PATH"
	@cp "${CURRENT_DIR}/pkg/${ME_OS}_${ME_ARCH}/${NAME}" "${CURRENT_DIR}/bin/"
	@cp "${CURRENT_DIR}/pkg/${ME_OS}_${ME_ARCH}/${NAME}" "${GOPATH}/bin/"

# dist builds the binaries and then signs and packages them for distribution
dist: bin
	@echo "==> Tagging release (v${VERSION})..."
ifdef GPG_KEY
	@git commit --allow-empty --gpg-sign="${GPG_KEY}" -m "Release v${VERSION}"
	@git tag -a -m "Version ${VERSION}" -s -u "${GPG_KEY}" "v${VERSION}" master
	@gpg --default-key "${GPG_KEY}" --detach-sig "${CURRENT_DIR}/pkg/dist/${NAME}_${VERSION}_SHA256SUMS"
else
	@git commit --allow-empty -m "Release v${VERSION}"
	@git tag -a -m "Version ${VERSION}" "v${VERSION}" master
endif
	@echo "--> Do not forget to run:"
	@echo ""
	@echo "    git push && git push --tags"
	@echo ""
	@echo "And then upload the binaries in dist/ to GitHub!"

# docker builds the docker container
docker:
	@echo "==> Building container..."
	@docker build \
		--pull \
		--rm \
		--file="docker/Dockerfile" \
		--tag="${OWNER}/${NAME}" \
		--tag="${OWNER}/${NAME}:${VERSION}" \
		"${CURRENT_DIR}"

# docker-push pushes the container to the registry
docker-push:
	@echo "==> Pushing to Docker registry..."
	@docker push "${OWNER}/${NAME}:latest"
	@docker push "${OWNER}/${NAME}:${VERSION}"

.PHONY: bin deps dev dist docker docker-push
