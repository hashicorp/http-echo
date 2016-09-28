VERSION?=$(shell awk -F\" '/^\tVersion/ { print $$2; exit }' version.go)

default: dev

# bin generates the binaries for all platforms.
bin:
	@sh -c "'${CURDIR}/scripts/compile.sh'"

docker:
	@echo "==> Building container..."
	@docker build \
		-f="docker/build.Dockerfile" \
		-t="hashicorp/http-echo" \
		-t="hashicorp/http-echo:${VERSION}" \
		$(shell pwd)

docker-push:
	@echo "Pushing to docker hub..."
	@docker push "hashicorp/http-echo:latest"
	@docker push "hashicorp/http-echo:${VERSION}"

# dev creates binares for testing locally - they are put into ./bin and $GOPATH.
dev:
	@XC_OS=$(shell go env GOOS) XC_ARCH=$(shell go env GOARCH) \
		sh -c "'${CURDIR}/scripts/build.sh'"

# dist creates the binaries for distibution.
dist: bin
	@sh -c "'${CURDIR}/scripts/dist.sh' '${VERSION}'"

.PHONY: default bin docker dev dist
