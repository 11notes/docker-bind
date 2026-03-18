![banner](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/banner/README.png)

# BIND
![size](https://img.shields.io/badge/image_size-${{ image_size }}-green?color=%2338ad2d)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![pulls](https://img.shields.io/docker/pulls/11notes/bind?color=2b75d6)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)[<img src="https://img.shields.io/github/issues/11notes/docker-bind?color=7842f5">](https://github.com/11notes/docker-bind/issues)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

High performance bind with default operating modes

# SYNOPSIS 📖
**What can I do with this?** This image will run BIND9 DNS server precompiled for large installations and maximum performance. It also offers three operating modes: Master, Slave and Resolver set via **command: ["mode"]**.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! All the other images on the market that do exactly the same don’t do or offer these options:

> [!IMPORTANT]
>* This image runs as 1000:1000 by default, most other images run everything as root
>* This image is created via a secure, pinned CI/CD process and immune to upstream attacks, most other images have upstream dependencies that can be exploited
>* This image contains a proper health check that verifies the app is actually working, most other images have either no health check or only check if a port is open or ping works
>* This repository has an auto update feature that will automatically build the latest version if released, most other providers don't do this
>* This image is a lot smaller than most other images

If you value security, simplicity and the ability to interact with the maintainer and developer of an image. Using my images is a great start in that direction.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| internetsystemsconsortium/bind9 | 43MB | 0:0 | ❌ | amd64 |

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

# VOLUMES 📁
* **/bind/etc** - Directory of named.conf
* **/bind/var** - Directory of Directory of zone data

# COMPOSE ✂️
```yaml
name: "bind"
services:
  bind:
    image: "11notes/bind:9.20.20"
    command: ["master"]
    environment:
      TZ: "Europe/Zurich"
    volumes:
      - "etc:/bind/etc"
      - "var:/bind/var"
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
  etc:
  var:

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

* [9.20.20](https://hub.docker.com/r/11notes/bind/tags?name=9.20.20)
* [stable](https://hub.docker.com/r/11notes/bind/tags?name=stable)
* [9.20.20-unraid](https://hub.docker.com/r/11notes/bind/tags?name=9.20.20-unraid)
* [stable-unraid](https://hub.docker.com/r/11notes/bind/tags?name=stable-unraid)
* [9.20.20-nobody](https://hub.docker.com/r/11notes/bind/tags?name=9.20.20-nobody)
* [stable-nobody](https://hub.docker.com/r/11notes/bind/tags?name=stable-nobody)

### There is no latest tag, what am I supposed to do about updates?
It is my opinion that the ```:latest``` tag is a bad habbit and should not be used at all. Many developers introduce **breaking changes** in new releases. This would messed up everything for people who use ```:latest```. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:9.20.20``` you can use ```:9``` or ```:9.20```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version. Which in theory should not introduce breaking changes.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/bind:9.20.20
docker pull ghcr.io/11notes/bind:9.20.20
docker pull quay.io/11notes/bind:9.20.20
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

*created 18.03.2026, 07:32:51 (CET)*