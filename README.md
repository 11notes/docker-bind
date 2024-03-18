![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - BIND9
![size](https://img.shields.io/docker/image-size/11notes/bind/9.18.24?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/bind/9.18.24?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/bind?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-bind?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-bind?color=c91cb8) ![stars](https://img.shields.io/docker/stars/11notes/bind?color=e6a50e)

**BIND9 DNS server**

# SYNOPSIS
What can I do with this? This image will run BIND9 DNS server precompiled for large installations and maximum performance.

# VOLUMES
* **/bind/etc** - Directory of named.conf
* **/bind/var** - Directory of zone data

# RUN
```shell
docker run --name bind \
  -v .../etc:/bind/etc \
  -v .../var:/bind/var \
  -d 11notes/bind:[tag]
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

# PARENT IMAGE
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH
* [bind9](https://www.isc.org/downloads/bind)
* [alpine](https://alpinelinux.org)

# TIPS
* Only use rootless container runtime (podman, rootless docker)
* Allow non-root ports < 1024 via `echo "net.ipv4.ip_unprivileged_port_start=53" > /etc/sysctl.d/ports.conf`
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a new version. Check the changelog for breaking changes.
    