# :: Arch
  FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu

# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM 11notes/apk-build:arm64v8-stable as build
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  ENV BUILD_NAME="bind"

  RUN set -ex; \
    cd ~; \
    newapkbuild ${BUILD_NAME};

  COPY ./build /apk/${BUILD_NAME}

  RUN set -ex; \
    cd ~/${BUILD_NAME}; \
    abuild checksum; \
    abuild -r; \
    ls -lah /apk/packages;

# :: Header
  FROM 11notes/alpine:arm64v8-stable
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  COPY --from=build /apk/packages/apk /tmp
  ENV APP_ROOT=/bind

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      ls -lah /tmp; \
      mkdir -p ${APP_ROOT}/etc \
      mkdir -p ${APP_ROOT}/var; \
      mkdir -p /var/run/named;

  # :: install application
    RUN set -ex; \
      apk add --allow-untrusted --repository /tmp bind; \
      rm -rf /tmp/*; \
      apk --no-cache upgrade;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
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