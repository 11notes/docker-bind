#!/bin/ash
  NAMED_CONF=${APP_ROOT}/etc/named.conf
  RNDC_CONF=${APP_ROOT}/etc/rndc.conf

  if [ -z "${1}" ]; then
    echo "custom" > ${APP_ROOT}/etc/mode
    elevenLogJSON info "starting ${APP_NAME} v${APP_VERSION}"
    set -- "/opt/bind/sbin/named" \
      -fg \
      -c "${NAMED_CONF}"  \
      -u docker
  else
    if echo "$@" | grep -q "resolver"; then
      # run bind as a resolver
      echo "slave" > ${APP_ROOT}/etc/mode
      if [ ! -f "${APP_ROOT}/var/root.db" ]; then
        elevenLogJSON info "creating root db for resolver"
        rootdb
      fi

      if [ ! -f "${NAMED_CONF}" ]; then
        elevenLogJSON info "creating resolver configuration"
        cp ${APP_ROOT}/.default/resolver.conf ${NAMED_CONF}
      fi

      elevenLogJSON info "starting ${APP_NAME} v${APP_VERSION} as resolver"
      set -- "/opt/bind/sbin/named" \
        -fg \
        -c "${NAMED_CONF}"  \
        -u docker
    fi

    if echo "$@" | grep -q "master"; then
      # run bind as an authoritative master
      echo "master" > ${APP_ROOT}/etc/mode
      if [ ! -f "${NAMED_CONF}" ]; then
        elevenLogJSON info "creating authoritative master configuration"
        cp ${APP_ROOT}/.default/authoritative-master.conf ${NAMED_CONF}
        cp ${APP_ROOT}/.default/rndc.conf ${RNDC_CONF}

        KEY=$(head -200 /dev/urandom | cksum | cut -f1 -d " " | sha256sum | tr -d "[:space:]-")
        KEY_CATALOG=$(head -200 /dev/urandom | cksum | cut -f1 -d " " | sha256sum | tr -d "[:space:]-")

        sed -i 's/%SLAVES%/'${BIND_SLAVES}'/' ${NAMED_CONF}
        sed -i 's/%KEY%/'${KEY}'/' ${NAMED_CONF}
        sed -i 's/%KEY%/'${KEY}'/' ${RNDC_CONF}
        sed -i 's/%KEY_CATALOG%/'${KEY_CATALOG}'/' ${NAMED_CONF}
      fi

      if [ ! -f "${APP_ROOT}/var/catalog.home.arpa.db" ]; then
        echo "\$TTL 1h" > ${APP_ROOT}/var/catalog.home.arpa.db
        echo "catalog.home.arpa. IN SOA . . 1 28800 7200 604800 86400" >> ${APP_ROOT}/var/catalog.home.arpa.db
        echo "catalog.home.arpa. IN NS invalid." >> ${APP_ROOT}/var/catalog.home.arpa.db
        echo "version IN TXT \"1\"" >> ${APP_ROOT}/var/catalog.home.arpa.db
      fi

      if [ ! -f "${APP_ROOT}/etc/keys.conf" ]; then
        KEY=$(head -200 /dev/urandom | cksum | cut -f1 -d " " | sha256sum | tr -d "[:space:]-")
        echo "key \"root\" { algorithm hmac-sha256; secret \"${KEY}\"; };" > ${APP_ROOT}/etc/keys.conf
      fi

      elevenLogJSON info "starting ${APP_NAME} v${APP_VERSION} as authoritative master"
      set -- "/opt/bind/sbin/named" \
        -fg \
        -c "${NAMED_CONF}"  \
        -u docker
    fi

    if echo "$@" | grep -q "slave"; then
      # run bind as an authoritative slave
      echo "slave" > ${APP_ROOT}/etc/mode
      if [ ! -f "${NAMED_CONF}" ]; then
        elevenLogJSON info "creating authoritative slave configuration"
        cp ${APP_ROOT}/.default/authoritative-slave.conf ${NAMED_CONF}

        KEY=$(head -200 /dev/urandom | cksum | cut -f1 -d " " | sha256sum | tr -d "[:space:]-")

        sed -i 's/%MASTERS%/'${BIND_MASTERS}'/' ${NAMED_CONF}
        sed -i 's/%KEY%/'${KEY}'/' ${NAMED_CONF}
      fi

      elevenLogJSON info "starting ${APP_NAME} v${APP_VERSION} as authoritative slave"
      set -- "/opt/bind/sbin/named" \
        -fg \
        -c "${NAMED_CONF}"  \
        -u docker
    fi
  fi

  exec "$@"