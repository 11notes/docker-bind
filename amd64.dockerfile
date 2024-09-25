# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM 11notes/alpine:stable as build
  ARG BUILD_VERSION=9.18.30
  ARG BUILD_DIR=/bind9

  USER root

  RUN set -ex; \
    apk add --no-cache --update \
      alpine-sdk \
      openssl-dev \
      libuv-dev \
      curl \
      wget \
      unzip \
      build-base \
      linux-headers \
      make \
      cmake \
      autoconf \
      automake \
      libtool \
      bash \
      userspace-rcu \
      fstrm-dev \
      jemalloc-dev \
      json-c-dev \
      libidn2-dev \
      krb5-dev \
      libcap-dev \
      libuv-dev \
      libxml2-dev \
      linux-headers \
      nghttp2-dev \
      openldap-dev \
      openssl-dev>3 \
      perl \
      protobuf-c-dev \
      g++ \
      git;

  RUN set -ex; \
    git clone https://gitlab.isc.org/isc-projects/bind9.git -b v${BUILD_VERSION};

  RUN set -ex; \
    cd ${BUILD_DIR}; \
    autoreconf --install; \
    ./configure \
      --prefix=/opt/bind \
      --sysconfdir=/bind/etc \
      --localstatedir=/var \
      --mandir=/usr/share/man \
      --infodir=/usr/share/info \
      --with-tuning=large \
      --with-gssapi \
      --with-libxml2 \
      --with-json-c \
      --with-openssl \
      --with-jemalloc \
      --with-libidn2 \
      --enable-dnstap \
      --enable-largefile \
      --enable-linux-caps \
      --enable-shared \
      --disable-static \
      --enable-full-report;

  RUN set -ex; \
    cd ${BUILD_DIR}; \
    make -j$(nproc);

  RUN set -ex; \
    cd ${BUILD_DIR}; \
    make install-strip;

# :: Header
  FROM 11notes/alpine:stable
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  COPY --from=build /opt/bind /opt/bind
  ENV APP_NAME="bind"
  ENV APP_VERSION=9.18.30
  ENV APP_ROOT=/bind

# :: Run
  USER root

  # :: prepare
    RUN set -ex; \
      mkdir -p \
        ${APP_ROOT}/etc \
        ${APP_ROOT}/var \
        /var/run/named;

  # :: install
    RUN set -ex; \
      apk --no-cache --update add \
        json-c \
        libuv \
        libxml2 \
        protobuf-c \
        fstrm \
        libcap \
        jemalloc \
        krb5;

  # :: upgrade
    RUN set -ex; \
      apk --no-cache --update upgrade;

  # :: copy root filesystem
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change permissions
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT} \
        /var/run/named;

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]	