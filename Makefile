# Metadata about this makefile and position
MKFILE_PATH := $(lastword $(MAKEFILE_LIST))
CURRENT_DIR := $(patsubst %/,%,$(dir $(realpath $(MKFILE_PATH))))

# Ensure GOPATH
GOPATH ?= $(HOME)/go
GOBIN ?= $(GOPATH)/bin

# List all our actual files, excluding vendor
GOFILES ?= $(shell go list $(TEST) | grep -v /vendor/)

# Tags specific for building
GOTAGS ?=

# Number of procs to use
GOMAXPROCS ?= 4

# Get the project metadata
GOVERSION := $(shell go version | awk '{print $3}' | sed -e 's/^go//')
PROJECT := $(CURRENT_DIR:$(GOPATH)/src/%=%)
OWNER ?= hashicorp
NAME ?= http-echo
REVISION ?= $(shell git rev-parse --short HEAD)
VERSION := $(shell cat "${CURRENT_DIR}/version/VERSION")
TIMESTAMP := $(shell date)

# Get local ARCH; on Intel Mac, 'uname -m' returns x86_64 which we turn into amd64.
# Not using 'go env GOOS/GOARCH' here so 'make docker' will work without local Go install.
ARCH     ?= $(shell A=$$(uname -m); [ $$A = x86_64 ] && A=amd64; echo $$A)
OS       ?= $(shell uname | tr [[:upper:]] [[:lower:]])
PLATFORM = $(OS)/$(ARCH)
DIST     = dist/$(PLATFORM)
BIN      = $(DIST)/$(NAME)

# Default os-arch combination to build
XC_OS ?= darwin linux windows
XC_ARCH ?= amd64 arm64
XC_EXCLUDE ?=

# List of ldflags
LD_FLAGS ?= \
	-s \
	-w \
	-X 'github.com/hashicorp/http-echo/version.Version=${VERSION}' \
	-X 'github.com/hashicorp/http-echo/version.GitCommit=${REVISION}' \
	-X 'github.com/hashicorp/http-echo/version.Timestamp=${TIMESTAMP}'

# List of tests to run
TEST ?= ./...

version:
	@echo $(VERSION)
.PHONY: version


dist:
	mkdir -p $(DIST)

# build is used for the CRT build.yml workflow. 
# Environment variables are populated by hashicorp/actions-go-build, not the makefile.
# https://github.com/hashicorp/actions-go-build
build:
	CGO_ENABLED=0 go build \
		-a \
		-o="${BIN_PATH}" \
		-ldflags " \
			-X 'github.com/hashicorp/http-echo/version.Version=${PRODUCT_VERSION}' \
			-X 'github.com/hashicorp/http-echo/version.GitCommit=${PRODUCT_REVISION}' \
			-X 'github.com/hashicorp/http-echo/version.Timestamp=${PRODUCT_REVISION_TIME}' \
		" \
		-tags "${GOTAGS}" \
		-trimpath \
		-buildvcs=false 
.PHONY: build

bin: dist
	@echo "==> Building ${BIN}"
	@GOARCH=$(ARCH) GOOS=$(OS) CGO_ENABLED=0 go build -trimpath -buildvcs=false -ldflags="$(LD_FLAGS)" -o $(BIN)
.PHONY: bin

# dev builds and installs the project locally.
dev: bin
	cp $(BIN) $(GOBIN)/$(BIN_NAME)
.PHONY: dev

# Docker Stuff.
export DOCKER_BUILDKIT=1
BUILD_ARGS = BIN_NAME=http-echo PRODUCT_VERSION=$(VERSION)
TAG        = $(NAME):local
BA_FLAGS   = $(addprefix --build-arg=,$(BUILD_ARGS))
FLAGS      = --platform $(PLATFORM) --tag $(TAG) $(BA_FLAGS)

# Set OS to linux for all docker/* targets.
docker: OS = linux

docker: bin
	docker build ${FLAGS} .
	@echo 'Image built; run "docker run --rm ${TAG}" to try it out.'
.PHONY: docker

# test runs the test suite.
test:
	@echo "==> Testing ${NAME}"
	@go test -timeout=30s -parallel=20 -tags="${GOTAGS}" ${GOFILES} ${TESTARGS}
.PHONY: test

# test-race runs the test suite.
test-race:
	@echo "==> Testing ${NAME} (race)"
	@go test -timeout=60s -race -tags="${GOTAGS}" ${GOFILES} ${TESTARGS}
.PHONY: test-race

# clean removes any previous binaries
clean:
	@rm -rf "${CURRENT_DIR}/pkg/"
	@rm -rf "${CURRENT_DIR}/bin/"
.PHONY: clean

