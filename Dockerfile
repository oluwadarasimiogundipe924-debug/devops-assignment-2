FROM alpine:3.22

RUN apk add --no-cache \
    bash \
    coreutils \
    procps \
    iputils \
    bind-tools \
    libc-utils

WORKDIR /app

COPY app/diagnostic.sh /app/diagnostic.sh
COPY app/health-check.sh /app/health-check.sh

RUN chmod +x /app/diagnostic.sh /app/health-check.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD ["/app/health-check.sh"]

ENTRYPOINT ["/app/diagnostic.sh"]

CMD ["help"]
