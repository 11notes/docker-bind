![banner](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/banner/README.png)

# BIND
![size](https://img.shields.io/badge/image_size-41MB-green?color=%2338ad2d)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![pulls](https://img.shields.io/docker/pulls/11notes/bind?color=2b75d6)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)[<img src="https://img.shields.io/github/issues/11notes/docker-bind?color=7842f5">](https://github.com/11notes/docker-bind/issues)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

High performance bind with default operating modes

# SYNOPSIS 📖
**What can I do with this?** This image will run BIND9 DNS server precompiled for large installations and maximum performance. It also offers three operating modes: Master, Slave and Resolver set via **command: ["mode"]**.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image is very small

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| 11notes/bind | 41MB | 1000:1000 | ❌ | amd64, arm64, armv7 |
| internetsystemsconsortium/bind9 | 43MB | 0:0 | ❌ | amd64 |

# Master
If run as master, set the IPs of the slaves via *BIND_SLAVES*. Bind will operate with catalog zones for all slaves. You can add new zones via the *addzone* script that requires the zone name and the IP of at least one NS (slave). You can then use nsupdate to update the master with new records and all changes are populates to all slaves automatically. Add a new zone like this:

```shell
docker exec master addzone contoso.com 10.255.53.52
```

It will automatically create a default zone and populate it as well as add a random key for managing the zone via nsupdate or via the dynamically created root key at startup (check /bind/etc/keys.conf for generated keys). Checkout **compose.authoritative.yml** for an example.

# Slave
If run as slave, make sure you set the *BIND_MASTERS* IPs so they will pickup all changes automatically. The slave enables recursion, so make sure you have a resolver present to resolve queries not handles by the slave. The slave will respond to all IPs on RFC1918 by default. You can setup your own config as well. You can run as many slaves as you like.

# Resolver
If run as a resolver, it will cache all results and use the root zone NS to create its own cache database for all records requested. Make sure the resolver has internet access. The resolver will accept all connections from any RFC1918 address. Checkout **compose.resolver.yml** for an example.

# VOLUMES 📁
* **/bind/etc** - Directory of named.conf
* **/bind/var** - Directory of Directory of zone data

# COMPOSE ✂️
```yaml
name: "ns"

x-lockdown: &lockdown
  # prevents write access to the image itself
  read_only: true
  # prevents any process within the container to gain more privileges
  security_opt:
    - "no-new-privileges=true"

services:
  bind:
    image: "11notes/bind:9.20.21"
    <<: *lockdown
    command: ["master"]
    environment:
      TZ: "Europe/Zurich"
    volumes:
      - "bind.etc:/bind/etc"
      - "bind.var:/bind/var"
    tmpfs:
      - "/var/run/named:uid=1000,gid=1000"
    ports:
      - "53:53/udp"
      - "53:53/tcp"
      - "8053:8053/tcp"
    networks:
      frontend:
    sysctls:
      net.ipv4.ip_unprivileged_port_start: 53
    restart: "always"

volumes:
  bind.etc:
  bind.var:

networks:
  frontend:
```
To find out how you can change the default UID/GID of this container image, consult the [RTFM](https://github.com/11notes/RTFM/blob/main/linux/container/image/11notes/how-to.changeUIDGID.md#change-uidgid-the-correct-way).

# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /bind | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |
| `BIND_SLAVES` | IPs of bind slaves if using authoritative master (add ;) | |
| `BIND_MASTERS` | IPs of bind master if using authoritative slave (add ;) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [9.20.21](https://hub.docker.com/r/11notes/bind/tags?name=9.20.21)
* [stable](https://hub.docker.com/r/11notes/bind/tags?name=stable)
* [9.20.21-unraid](https://hub.docker.com/r/11notes/bind/tags?name=9.20.21-unraid)
* [stable-unraid](https://hub.docker.com/r/11notes/bind/tags?name=stable-unraid)
* [9.20.21-nobody](https://hub.docker.com/r/11notes/bind/tags?name=9.20.21-nobody)
* [stable-nobody](https://hub.docker.com/r/11notes/bind/tags?name=stable-nobody)

### There is no latest tag, what am I supposed to do about updates?
It is my opinion that the ```:latest``` tag is a bad habbit and should not be used at all. Many developers introduce **breaking changes** in new releases. This would messed up everything for people who use ```:latest```. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:9.20.21``` you can use ```:9``` or ```:9.20```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version. Which in theory should not introduce breaking changes.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/bind:9.20.21
docker pull ghcr.io/11notes/bind:9.20.21
docker pull quay.io/11notes/bind:9.20.21
```

# UNRAID VERSION 🟠
This image supports unraid by default. Simply add **-unraid** to any tag and the image will run as 99:100 instead of 1000:1000.

# NOBODY VERSION 👻
This image supports nobody by default. Simply add **-nobody** to any tag and the image will run as 65534:65534 instead of 1000:1000.

# SOURCE 💾
* [11notes/bind](https://github.com/11notes/docker-bind)

# PARENT IMAGE 🏛️
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH 🧰
* [bind](https://gitlab.isc.org/isc-projects/bind9)
* [11notes/util](https://github.com/11notes/docker-util)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-bind/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-bind/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-bind/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 26.03.2026, 07:18:36 (CET)*