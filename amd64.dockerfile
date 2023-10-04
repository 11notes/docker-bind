# :: Build
  FROM 11notes/apk-build:stable as build
  ENV APK_NAME="bind"
  ENV APK_VERSION="9.18.19"

  RUN set -ex; \
    cd ~; \
    newapkbuild ${APK_NAME};

  COPY ./build /apk/${APK_NAME}

  RUN set -ex; \
    cd ~/${APK_NAME}; \
    sed -i "s/\$APK_VERSION/${APK_VERSION}/g" ./APKBUILD; \
    abuild checksum; \
    abuild -r; \
    ls -lah /apk/packages;

# :: Header
  FROM 11notes/alpine:stable
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