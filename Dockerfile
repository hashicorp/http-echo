# Use a minimal Go base image
FROM golang:alpine AS builder

WORKDIR /app

COPY . .

RUN go build -o http-echo .

FROM alpine

WORKDIR /app

COPY --from=builder /app/http-echo .
EXPOSE 5678/tcp

ENV ECHO_TEXT="hello-world" 
ENTRYPOINT ["./http-echo"]

