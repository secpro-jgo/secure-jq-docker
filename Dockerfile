# Stage 1: Builder
FROM alpine:latest AS builder

# Install jq, busybox, and required dependencies, then clean up for a smaller image
RUN apk add --no-cache jq busybox oniguruma && \
    rm -rf /var/cache/apk/* /lib/apk /etc/apk

# Create non-root user and group early to limit privileges
RUN addgroup -g 10000 jquser && \
    adduser -D -u 10000 -G jquser -s /bin/false jquser

# Ensure jq has correct permissions
RUN chmod 750 /usr/bin/jq

# Stage 2: Runtime
FROM alpine:latest

# Metadata for tracking and documentation
LABEL maintainer="Your Name <your@email.com>"
LABEL description="Secure jq container with restricted execution"

# Install busybox and jq dependencies in runtime stage
RUN apk add --no-cache busybox oniguruma

# Recreate the non-root user in the runtime stage
RUN addgroup -g 10000 jquser && \
    adduser -D -u 10000 -G jquser -s /bin/false jquser

# Copy necessary components
COPY --from=builder /usr/bin/jq /bin/jq
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Set ownership correctly for security
RUN chown jquser:jquser /bin/jq

# Security configurations
USER jquser
WORKDIR /tmp
ENV PATH=/bin
ENV SHELL=/bin/sh

# Apply Seccomp profile (ensure seccomp.json is available in the container)
COPY seccomp.json /seccomp.json
CMD ["jq", "--version"] # Default command

# Enforce read-only root filesystem
VOLUME [ "/tmp" ]  # Allow writing only to /tmp
ENTRYPOINT ["/bin/jq"]

# Health check to validate container functionality
HEALTHCHECK CMD jq --version || exit 1

# Debugging support (optional)
ARG DEBUG=false
ENV DEBUG=${DEBUG}
CMD [ "echo", "Secure jq container is running..." ]