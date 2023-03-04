# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

FROM alpine:3.17.1

# TARGETOS and TARGETARCH are set automatically when --platform is provided.
ARG TARGETOS
ARG TARGETARCH

ADD "https://curl.haxx.se/ca/cacert.pem" "/etc/ssl/certs/ca-certificates.crt"
ADD "./pkg/${TARGETOS}_${TARGETARCH}/http-echo" "/"
RUN apk add curl

# Create a non-root user to run the software.
RUN addgroup http-echo
RUN adduser -S -G http-echo 1005

USER 1005
ENTRYPOINT ["/http-echo"]
