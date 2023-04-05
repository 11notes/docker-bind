#!/bin/ash
  if [ -z "${1}" ]; then
    set -- "named" \
      -fg \
      -c "/bind/etc/named.conf"  \
      -u bind
  fi

  exec "$@"