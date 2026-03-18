# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID= \
      APP_GID= \
      APP_VERSION

# :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/util:bin AS util-bin
  FROM 11notes/distroless AS distroless


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: BIND
  FROM alpine AS build
  ARG APP_VERSION
  COPY --from=util-bin / /

  RUN set -ex; \
    apk --update --no-cache add \
      git \
      alpine-sdk \
      autoconf \
      automake \
      libtool \
      build-base \
      linux-headers \
      make \
      cmake \
      g++; \
    apk --update --no-cache add \
      bash \
      fstrm-dev \
      krb5-dev \
      libcap-dev \
      libuv-dev \
      libidn2-dev \
      libxml2-dev~2.13 \
      jemalloc-dev \
      json-c-dev \
      linux-headers \
      nghttp2-dev \
      openldap-dev \
      openssl-dev>3 \
      perl \
      protobuf-c-dev \
      userspace-rcu-dev \
      dnssec-root;

    RUN set -ex; \
      git clone https://gitlab.isc.org/isc-projects/bind9.git -b v${APP_VERSION};

    RUN set -ex; \
      cd /bind9; \
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
        --enable-full-report; \
      make -s -j $(nproc) 2>&1 > /dev/null; \
      make install;


# :: FILE SYSTEM
  FROM alpine AS file-system
  ARG APP_ROOT
  COPY --from=util / /
  COPY ./rootfs/ /distroless

  RUN set -ex; \
    eleven mkdir /distroless${APP_ROOT}/{etc,var};

  RUN set -ex; \
    chmod +x -R /distroless/usr/local/bin;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM 11notes/alpine:stable

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: multi-stage
    COPY --from=build /opt/bind /opt/bind
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /

# :: SETUP
  USER root

  RUN set -ex; \
    apk --no-cache --update add \
      json-c \
      libuv \
      libxml2 \
      protobuf-c \
      fstrm \
      libcap \
      jemalloc \
      userspace-rcu \
      nghttp2-libs \
      libidn2 \
      krb5;

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc", "${APP_ROOT}/var"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/opt/bind/bin/dig", "+time=2", "+tries=1", ".", "NS", "@localhost"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]