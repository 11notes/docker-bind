# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone https://github.com/11notes/util.git;

# :: Build
  FROM 11notes/apk-build:stable as build
  ENV APK_NAME="bind"
  COPY ./build /src
  RUN set -ex; \
    apk-build

# :: Header
  FROM 11notes/alpine:stable
  COPY --from=util /util/linux/shell/elevenLogJSON /usr/local/bin
  COPY --from=build /apk /apk/custom
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
      apk add --no-cache --allow-untrusted --repository /apk/custom bind; \
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