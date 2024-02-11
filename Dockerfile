# syntax=docker/dockerfile:1.4

ARG DISTRO_BASE=ubuntu
ARG DISTRO=jammy

FROM ${DISTRO_BASE}:${DISTRO} AS base

SHELL ["bash", "-euxo", "pipefail", "-c"]

ENV BUILD_DIR=/build_dir

FROM base AS builder

WORKDIR "${BUILD_DIR}"

COPY env "${BUILD_DIR}/env"
COPY src "${BUILD_DIR}/src"
COPY script "${BUILD_DIR}/script"
COPY Makefile "${BUILD_DIR}/Makefile"

RUN <<EOT
script/install-build-deps

env TRACE=true make

apt-get remove -y \
    wget \
    git \
    dh-make \
    make \
    rsync \
    nodejs
apt-get autoremove -y
apt-get clean
rm -rf \
    ~/.cache \
    ~/.local \
    /var/lib/apt/lists/*
EOT

FROM base AS pkgcontainer

COPY --from=builder "${BUILD_DIR}/pkg/"*.deb "${BUILD_DIR}/dest/"
COPY --from=builder "${BUILD_DIR}/pkg/"*.buildinfo "${BUILD_DIR}/dest/"
COPY --from=builder "${BUILD_DIR}/pkg/"*.changes "${BUILD_DIR}/dest/"
COPY --from=builder "${BUILD_DIR}/pkg/"*.dsc "${BUILD_DIR}/dest/"
COPY --from=builder "${BUILD_DIR}/pkg/"*.debian.tar.xz "${BUILD_DIR}/dest/"

RUN ls "${BUILD_DIR}/dest/"

FROM base AS runner

ENV DEB_FILE="${BUILD_DIR}/dest/sharkey.deb"

COPY --from=pkgcontainer "${BUILD_DIR}/dest/"*.deb "${DEB_FILE}"

COPY script/install-deb "${BUILD_DIR}/script/install-deb"
RUN <<EOT
env \
    TRACE=true \
    "${BUILD_DIR}/script/install-deb"

apt-get clean
rm -rf \
    "${BUILD_DIR}/dest" \
    "${BUILD_DIR}/script" \
    /var/lib/apt/lists/*
EOT

USER sharkey
WORKDIR /var/lib/sharkey/live/packages/backend

ENV RUN_MIGRATION_ON_START=true
ENV TRACE=true

CMD ["bash", "-c", "/usr/bin/sharkey-prestart-hook && node /var/lib/sharkey/live/packages/backend/built/boot/entry.js"]
