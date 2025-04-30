# :: Util
  FROM 11notes/util AS util

# :: Build / bind
  FROM alpine/git AS build
  ARG APP_VERSION
  ENV BUILD_ROOT=/git/bind9
  RUN set -ex; \
    apk --update --no-cache add \
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
      g++;

    RUN set -ex; \
      git clone https://gitlab.isc.org/isc-projects/bind9.git -b v${APP_VERSION};

    RUN set -ex; \
      cd ${BUILD_ROOT}; \
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
      # configure: error: Static linking is not supported as it disables dlopen() and certain security features (e.g. RELRO, ASLR)
  
    RUN set -ex; \
      cd ${BUILD_ROOT}; \
      make -j$(nproc);
  
    RUN set -ex; \
      cd ${BUILD_ROOT}; \
      make install;

# :: Header
  FROM 11notes/alpine:stable

  # :: arguments
    ARG TARGETARCH
    ARG APP_IMAGE
    ARG APP_NAME
    ARG APP_VERSION
    ARG APP_ROOT
    ARG APP_UID
    ARG APP_GID

  # :: environment
    ENV APP_IMAGE=${APP_IMAGE}
    ENV APP_NAME=${APP_NAME}
    ENV APP_VERSION=${APP_VERSION}
    ENV APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=util /usr/local/bin/ /usr/local/bin
    COPY --from=build /opt/bind /opt/bind

# :: Run
  USER root
  RUN eleven printenv;

  # :: install application
    RUN set -ex; \
      eleven mkdir ${APP_ROOT}/{etc,var}; \
      mkdir -p /var/run/named;

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

  # :: copy filesystem changes and set correct permissions
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin; \
      chown -R 1000:1000 \
        ${APP_ROOT} \
        /var/run/named;

# :: Volumes
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD dig +time=2 +tries=1 . NS @localhost || exit 1

# :: Start
  USER docker