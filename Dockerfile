# Use a minimal Go base image
FROM golang:alpine AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the source code into the container
COPY . .

# Build the http-echo server
RUN go build -o http-echo .

# Start a new stage for a lightweight image
FROM alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the built binary from the previous stage
COPY --from=builder /app/http-echo .

# Expose the port that the server listens on
EXPOSE 5678/tcp

# // Debugging 

ENV ECHO_TEXT="hello-world" 

# Set the default command to run the server
ENTRYPOINT ["./http-echo"]

