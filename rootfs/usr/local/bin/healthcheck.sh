#!/bin/ash
  /opt/bind/bin/dig +time=2 +tries=1 . NS @localhost || exit 1