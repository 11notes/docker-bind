#!/bin/ash
  if [ -z "${1}" ]; then
    rootdb

    set -- "named" \
      -fg \
      -c "/bind/etc/named.conf"  \
      -u docker
  fi

  exec "$@"