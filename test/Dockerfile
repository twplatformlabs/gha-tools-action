FROM alpine:3.19.1

LABEL org.opencontainers.image.title="circleci-remote-docker" \
      org.opencontainers.image.description="Alpine-based CircleCI executor image containing only the minimum required packages" \
      org.opencontainers.image.documentation="https://github.com/ThoughtWorks-DPS/circleci-remote-docker" \
      org.opencontainers.image.source="https://github.com/ThoughtWorks-DPS/circleci-remote-docker" \
      org.opencontainers.image.url="https://github.com/ThoughtWorks-DPS/circleci-remote-docker" \
      org.opencontainers.image.vendor="ThoughtWorks, Inc." \
      org.opencontainers.image.authors="nic.cheneweth@thoughtworks.com" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.created="CREATED" \
      org.opencontainers.image.version="VERSION"

RUN apk add --no-cache \
        git==2.43.0-r0 \
        openssh==9.6_p1-r0 \
        tar==1.35-r2 \
        gzip==1.13-r0 \
        ca-certificates==20240226-r0
