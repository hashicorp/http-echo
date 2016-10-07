VERSION?=$(shell awk -F\" '/^\tVersion/ { print $$2; exit }' version.go)

default: dev

bin:
	@sh -c "'${CURDIR}/scripts/compile.sh'"

docker:
	@echo "==> Building container..."
	@docker build \
		--pull \
		--rm \
		--file="docker/Dockerfile" \
		--tag="hashicorp/http-echo" \
		--tag="hashicorp/http-echo:${VERSION}" \
		$(shell pwd)

docker-push:
	@echo "==> Pushing to Docker registry..."
	@docker push "hashicorp/http-echo:latest"
	@docker push "hashicorp/http-echo:${VERSION}"

dev:
	@XC_OS=$(shell go env GOOS) XC_ARCH=$(shell go env GOARCH) \
		sh -c "'${CURDIR}/scripts/build.sh'"

dist: bin
	@sh -c "'${CURDIR}/scripts/dist.sh' '${VERSION}'"

.PHONY: default bin docker dev dist
