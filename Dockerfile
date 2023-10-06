# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

FROM gcr.io/distroless/static-debian12:nonroot as default

# TARGETOS and TARGETARCH are set automatically when --platform is provided.
ARG TARGETOS
ARG TARGETARCH
ARG PRODUCT_VERSION
ARG BIN_NAME

LABEL name="http-echo" \
      maintainer="HashiCorp Consul Team <consul@hashicorp.com>" \
      vendor="HashiCorp" \
      version=$PRODUCT_VERSION \
      release=$PRODUCT_VERSION \
      summary="A test webserver that echos a response. You know, for kids." 

COPY dist/$TARGETOS/$TARGETARCH/$BIN_NAME /

EXPOSE 5678/tcp

ENV ECHO_TEXT="hello-world"

ENTRYPOINT ["/http-echo"]
