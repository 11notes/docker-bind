#!/bin/ash
  if [ -z "${1}" ]; then

    if [ ! -f "/bind/var/root.db" ]; then
      elevenLogJSON info "creating root db"
      rootdb
    fi

    elevenLogJSON info "starting bind9"
    set -- "named" \
      -fg \
      -c "/bind/etc/named.conf"  \
      -u docker \
      -4
  fi

  exec "$@"