FROM alpine

ADD "https://curl.haxx.se/ca/cacert.pem" "/etc/ssl/certs/ca-certificates.crt"
ADD "./pkg/linux_amd64/http-echo" "/"
RUN apk add curl

# Create a non-root user to run the software.
RUN addgroup http-echo
RUN adduser -S -G http-echo 100

USER 100
ENTRYPOINT ["/http-echo"]
