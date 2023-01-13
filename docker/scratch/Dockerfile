FROM ubuntu:latest
RUN useradd -u 1005 scratchuser

FROM scratch

# TARGETOS and TARGETARCH are set automatically when --platform is provided.
ARG TARGETOS
ARG TARGETARCH

ADD "https://curl.haxx.se/ca/cacert.pem" "/etc/ssl/certs/ca-certificates.crt"
ADD "./pkg/${TARGETOS}_${TARGETARCH}/http-echo" "/"
COPY --from=0 /etc/passwd /etc/passwd

USER scratchuser

ENTRYPOINT ["/http-echo"]
