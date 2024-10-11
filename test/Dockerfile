# hadolint ignore=DL3006
FROM alpine

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

# hadolint ignore=DL3018
RUN apk add --no-cache \
        git \
        openssh \
        tar \
        gzip \
        ca-certificates
