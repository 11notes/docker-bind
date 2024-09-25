![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - BIND
![size](https://img.shields.io/docker/image-size/11notes/bind/9.18.30?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/bind/9.18.30?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/bind?color=2b75d6)

**BIND DNS server**

# SYNOPSIS
What can I do with this? This image will run BIND9 DNS server precompiled for large installations and maximum performance.

# VOLUMES
* **/bind/etc** - Directory of named.conf
* **/bind/var** - Directory of zone data

# COMPOSE
```yaml
services:
  bind:
    image: "11notes/bind:9.18.30"
    container_name: "bind"
    environment:
      TZ: "Europe/Zurich"
    volumes:
      - "etc:/bind/etc"
      - "var:/bind/var"
    ports:
      - "53:53/udp"
      - "53:53/tcp"
      - "8053:8053/tcp"
    sysctls:
      - "net.ipv4.ip_unprivileged_port_start=53"
    restart: always
volumes:
  etc:
  var:
```

# EXAMPLES
## config /bind/etc/named.conf
```
options {
  listen-on { any; };
  directory "/bind/etc";
  recursion no;
  allow-notify { none; };
  forwarders { 9.9.9.9; 9.9.9.10; };
  version "0.0";
  auth-nxdomain no;
  max-cache-size 0;
  dnssec-validation auto;
};

statistics-channels {
  inet 0.0.0.0 port 8053;
};

server ::/0 { bogus yes; };
```

# DEFAULT SETTINGS
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /bind | home directory of user docker |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |

# SOURCE
* [11notes/bind](https://github.com/11notes/docker-bind)

# PARENT IMAGE
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH
* [bind](https://www.isc.org/downloads/bind)
* [alpine](https://alpinelinux.org)

# TIPS
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes. You can find all my repositories on [github](https://github.com/11notes).
    