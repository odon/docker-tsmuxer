#
# tsmuxer Dockerfile
#
# https://github.com/jlesage/docker-tsmuxer
#

# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.6-v2.0.6

# Define working directory.
WORKDIR /tmp

# Install tsMuxeR.
ADD tsmuxer-builder/tsmuxer.tar.gz /

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://raw.githubusercontent.com/jlesage/docker-templates/master/jlesage/images/tsmuxer-icon.png && \
    install_app_icon.sh "$APP_ICON_URL"

# Define software versions.
ARG MKVTOOLNIX_VERSION=15.0.0

# Define software download URLs.
ARG MKVTOOLNIX_URL=https://mkvtoolnix.download/sources/mkvtoolnix-${MKVTOOLNIX_VERSION}.tar.xz

# Install MKVToolNix.
RUN \
    # Install packages needed by the build.
    add-pkg --virtual build-dependencies \
        curl \
        patch \
        imagemagick \
        build-base \
        ruby-rake \
        ruby-json \
        qt5-qtbase-dev \
        qt5-qtmultimedia-dev \
        boost-dev \
        file-dev \
        zlib-dev \
        libmatroska-dev \
        flac-dev \
        libogg-dev \
        libvorbis-dev \
        docbook-xsl \
        && \

    # Download the MKVToolNix package.
    echo "Downloading MKVToolNix package..." && \
    curl -# -L ${MKVTOOLNIX_URL} | tar xJ && \

    # Remove embedded profile from PNGs to avoid the "known incorrect sRGB
    # profile" warning.
    find mkvtoolnix-${MKVTOOLNIX_VERSION} -name "*.png" -exec convert -strip {} {} \; && \

    # Compile MKVToolNix.
    cd mkvtoolnix-${MKVTOOLNIX_VERSION} && \
    ./configure --without-gettext \
                --with-docbook-xsl-root=/usr/share/xml/docbook/xsl-stylesheets-1.79.1 && \
    rake install && \
    cd .. && \

    # Cleanup.
    del-pkg build-dependencies && \
    rm -rf /tmp/*

# Install dependencies.
RUN add-pkg \
        boost-system \
        boost-regex \
        boost-filesystem \
        libmagic \
        libmatroska \
        libebml \
        flac \
        qt5-qtmultimedia \
        mesa-dri-swrast

# Add files.
COPY rootfs/ /

# Set environment variables.
ENV APP_NAME="tsMuxeR"

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/storage"]

# Metadata.
LABEL \
      org.label-schema.name="tsmuxer" \
      org.label-schema.description="Docker container for tsMuxeR" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/jlesage/docker-tsmuxer" \
      org.label-schema.schema-version="1.0"
