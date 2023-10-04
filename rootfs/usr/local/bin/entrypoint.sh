#!/bin/ash
  if [ -z "${1}" ]; then

    if [ ! -f "/bind/var/root.db" ]; then
      rootdb
    fi

    set -- "named" \
      -fg \
      -c "/bind/etc/named.conf"  \
      -u docker \
      -4
  fi

  exec "$@"