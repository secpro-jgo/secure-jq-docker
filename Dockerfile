# Use a minimal Alpine Linux image
FROM alpine:latest

# Update package lists
RUN apk update

# Install jq
RUN apk add --no-cache jq

# Set the entrypoint to run jq with any provided arguments
ENTRYPOINT ["jq"]