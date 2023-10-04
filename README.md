# Alpine :: Bind (DNS)
![size](https://img.shields.io/docker/image-size/11notes/bind/9.18.19?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/bind?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/bind?color=2b75d6) ![activity](https://img.shields.io/github/commit-activity/m/11notes/docker-bind?color=c91cb8) ![commit-last](https://img.shields.io/github/last-commit/11notes/docker-bind?color=c91cb8)

Run Bind (DNS) based on Alpine Linux. Small, lightweight, secure and fast 🏔️

## Volumes
* **/bind/etc** - Directory of named.conf
* **/bind/var** - Directory of zone files

## Run
```shell
docker run --name bind \
  -p 53:53 \
  -p 53:53/udp \
  -p 8053:8053 \
  -v ../etc:/bind/etc \
  -v ../var:/bind/var \
  -d 11notes/bind:[tag]
```

Update root db (will update on start if does not exist)
```shell
docker exec bind rootdb
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /bind | home directory of user docker |

## Parent image
* [11notes/alpine:stable](https://github.com/11notes/docker-alpine)

## Built with and thanks to
* [bind](https://www.isc.org/downloads/bind)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Only use rootless container runtime (podman, rootless docker)
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy (haproxy, traefik, nginx)