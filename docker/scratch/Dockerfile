FROM scratch

# TARGETOS and TARGETARCH are set automatically when --platform is provided.
ARG TARGETOS
ARG TARGETARCH

ADD "https://curl.haxx.se/ca/cacert.pem" "/etc/ssl/certs/ca-certificates.crt"
ADD "./pkg/${TARGETOS}_${TARGETARCH}/http-echo" "/"
ENTRYPOINT ["/http-echo"]
