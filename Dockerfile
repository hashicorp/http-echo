# Using lightweight base image
FROM golang:1.20

# Set the working directory inside the container
WORKDIR /app

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

# Copy the source code into the container
COPY . .

EXPOSE 5678/tcp

ENV ECHO_TEXT="hello-world"

# Build the Go application
RUN go build -o http-echo .

# Expose the port the application listens on
EXPOSE 8080

# Command to run the executable
CMD ["/app/http-echo"]
