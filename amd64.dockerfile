# :: Header
  FROM 11notes/alpine:stable
  ENV APP_VERSION=9.18.14-r1

# :: Run
  USER root

  # :: update image
    RUN set -ex; \
      apk update; \
      apk upgrade;

  # :: prepare image
    RUN set -ex; \
      mkdir -p /bind/etc \
      mkdir -p /bind/var;

  # :: install application
    RUN set -ex; \
      apk --update --no-cache add \
        bash \
        bind=${APP_VERSION} \
        bind-tools;

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d /bind docker; \
      chown -R 1000:1000 \
        /bind \
        /var/run/named;

# :: Volumes
  VOLUME ["/bind/etc", "/bind/var"]

# :: Monitor
  HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
  USER docker
  ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]	