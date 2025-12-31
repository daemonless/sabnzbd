ARG BASE_VERSION=15
FROM ghcr.io/daemonless/base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
ARG PACKAGES="python311 py311-pip py311-setuptools py311-sqlite3 py311-cryptography py311-feedparser py311-configobj py311-cherrypy py311-portend py311-chardet py311-pysocks py311-sabctools py311-guessit py311-puremagic py311-rarfile py311-apprise par2cmdline-turbo unrar 7-zip ca_root_nss"
ARG UPSTREAM_URL="https://api.github.com/repos/sabnzbd/sabnzbd/releases/latest"
ARG UPSTREAM_SED="s/.*\"tag_name\":\"\\([^\"]*\\)\".*/\\1/p"

LABEL org.opencontainers.image.title="SABnzbd" \
    org.opencontainers.image.description="SABnzbd Usenet downloader on FreeBSD" \
    org.opencontainers.image.source="https://github.com/daemonless/sabnzbd" \
    org.opencontainers.image.url="https://sabnzbd.org/" \
    org.opencontainers.image.documentation="https://sabnzbd.org/wiki/" \
    org.opencontainers.image.licenses="GPL-2.0-or-later" \
    org.opencontainers.image.vendor="daemonless" \
    org.opencontainers.image.authors="daemonless" \
    io.daemonless.port="8080" \
    io.daemonless.arch="${FREEBSD_ARCH}" \
    io.daemonless.volumes="/downloads" \
    io.daemonless.category="Downloaders" \
    io.daemonless.upstream-url="${UPSTREAM_URL}" \
    io.daemonless.upstream-sed="${UPSTREAM_SED}" \
    io.daemonless.packages="${PACKAGES}"

# Install dependencies
RUN pkg update && \
    pkg install -y \
    ${PACKAGES} && \
    pkg clean -ay && \
    rm -rf /var/cache/pkg/* /var/db/pkg/repos/*

# Download and install SABnzbd from GitHub
RUN mkdir -p /app/sabnzbd && \
    chmod 755 /app && \
    SABNZBD_VERSION=$(fetch -qo - "${UPSTREAM_URL}" | \
    sed -n "${UPSTREAM_SED}" | head -1) && \
    echo "Downloading SABnzbd ${SABNZBD_VERSION}" && \
    fetch -qo /tmp/sabnzbd.tar.gz "https://github.com/sabnzbd/sabnzbd/releases/download/${SABNZBD_VERSION}/SABnzbd-${SABNZBD_VERSION}-src.tar.gz" && \
    LANG=C.UTF-8 tar xzf /tmp/sabnzbd.tar.gz -C /app/sabnzbd --strip-components=1 && \
    test -f /app/sabnzbd/SABnzbd.py && \
    chmod -R o+rX /app/sabnzbd && \
    printf "UpdateMethod=docker\nPackageVersion=%s\nPackageAuthor=[daemonless](https://github.com/daemonless/daemonless)\n" "$SABNZBD_VERSION" > /app/sabnzbd/package_info && \
    echo "$SABNZBD_VERSION" > /app/version && \
    rm -f /tmp/sabnzbd.tar.gz

# Create directories
RUN mkdir -p /config /downloads/complete /downloads/incomplete && \
    chown -R bsd:bsd /app/sabnzbd /config /downloads

# Copy service definition and init scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/services.d/sabnzbd/run /etc/cont-init.d/* 2>/dev/null || true

# Set up s6 service link

EXPOSE 8080
VOLUME /config /downloads


