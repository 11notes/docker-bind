# :: Header
  FROM 11notes/alpine:stable
  ENV APP_VERSION=9.18.16-r0
  ENV APP_ROOT=/bind

# :: Run
  USER root

  # :: update image
    RUN set -ex; \
      apk update; \
      apk upgrade;

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}/etc \
      mkdir -p ${APP_ROOT}/var;

  # :: install application
    RUN set -ex; \
      apk --update --no-cache add \
        bash \
        bind=${APP_VERSION} \
        bind-dnssec-tools \
        bind-tools;

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