# Alpine :: Bind (DNS)
Run Bind (DNS) based on Alpine Linux. Small, lightweight, secure and fast 🏔️

## Volumes
* **/bind/etc** - Directory of named.conf
* **/bind/var** - Directory of zone files

## Run
```shell
docker run --name bind \
  -v ../etc:/bind/etc \
  -v ../var:/bind/var \
  -d 11notes/bind:[tag]
```

## Defaults
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |

## Parent
* [11notes/alpine:stable](https://github.com/11notes/docker-alpine)

## Built with
* [bind](https://www.isc.org/downloads/bind)
* [Alpine Linux](https://alpinelinux.org)

## Tips
* Don't bind to ports < 1024 (requires root), use NAT/reverse proxy
* [Permanent Storage](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS and more