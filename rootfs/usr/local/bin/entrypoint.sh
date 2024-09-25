#!/bin/ash
  if [ -z "${1}" ]; then
    if [ ! -f "/bind/var/root.db" ]; then
      elevenLogJSON info "creating root db"
      rootdb
    fi

    elevenLogJSON info "starting ${APP_NAME} (${APP_VERSION})"
    set -- "/opt/bind/sbin/named" \
      -fg \
      -c "/bind/etc/named.conf"  \
      -u docker
  fi

  exec "$@"