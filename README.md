![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - BIND
[<img src="https://img.shields.io/badge/github-source-blue?logo=github">](https://github.com/11notes/docker-bind/tree/9.18.31) ![size](https://img.shields.io/docker/image-size/11notes/bind/9.18.31?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/bind/9.18.31?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/bind?color=2b75d6)

**High performance bind with default operating modes**

# SYNOPSIS
**What can I do with this?** This image will run BIND9 DNS server precompiled for large installations and maximum performance. It also offers three operating modes: Master, Slave and Resolver set via **command: ["mode"]**.

# Master
If run as master, set the IPs of the slaves via *BIND_SLAVES*. Bind will operate with catalog zones for all slaves. You can add new zones via the *addzone* script that requires the zone name and the IP of at least one NS (slave). You can then use nsupdate to update the master with new records and all changes are populates to all slaves automatically. Add a new zone like this:

```shell
docker exec master addzone contoso.com 10.255.53.52
```

It will automatically create a default zone and populate it as well as add a random key for managing the zone via nsupdate or via the dynamically created root key at startup (check /bind/etc/keys.conf for generated keys). Checkout **compose.authoritative.yaml** for an example.

# Slave
If run as slave, make sure you set the *BIND_MASTERS* IPs so they will pickup all changes automatically. The slave enables recursion, so make sure you have a resolver present to resolve queries not handles by the slave. The slave will respond to all IPs on RFC1918 by default. You can setup your own config as well. You can run as many slaves as you like.

# Resolver
If run as a resolver, it will cache all results and use the root zone NS to create its own cache database for all records requested. Make sure the resolver has internet access. The resolver will accept all connections from any RFC1918 address. Checkout **compose.resolver.yaml** for an example.

# VOLUMES
* **/bind/etc** - Directory of named.conf
* **/bind/var** - Directory of zone data

# COMPOSE
```yaml
services:
  bind:
    image: "11notes/bind:9.18.31"
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
| `BIND_SLAVES` | IPs of bind slaves if using authoritative master (add ;) | |
| `BIND_MASTERS` | IPs of bind master if using authoritative slave (add ;) | |

# SOURCE
* [11notes/bind:9.18.31](https://github.com/11notes/docker-bind/tree/9.18.31)

# PARENT IMAGE
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH
* [bind](https://www.isc.org/downloads/bind)
* [alpine](https://alpinelinux.org)

# TIPS
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [RELEASE.md](https://github.com/11notes/docker-bind/blob/9.18.31/RELEASE.md) for breaking changes. You can find all my repositories on [github](https://github.com/11notes).