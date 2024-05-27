FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx
FROM --platform=$BUILDPLATFORM caddy:2.8.4-builder AS builder
COPY --from=xx / /

RUN apk add --no-cache bash

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

ENV CGO_ENABLED=0 \
    GOOS="${TARGETOS}" \
    GOARCH="${TARGETARCH}"

RUN if [[ "${TARGETARCH}${TARGETVARIANT}" == amd64v* ]]; then \
      export GOAMD64="${TARGETVARIANT}"; \
    fi && \
    xcaddy build \
      --with github.com/caddy-dns/cloudflare \
      --with github.com/mholt/caddy-dynamicdns

FROM caddy:2.8.4-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
