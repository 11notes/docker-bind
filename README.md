# docker-bind

Dockerfile to create and run your own named process inside an alpine docker container.

## Volumes

/bind/etc

Purpose: named config directory

/bind/var

Purpose: zone files directory

## Run
```shell
docker run --name nginx \
    -v volume-etc:/bind/etc \
    -v volume-zones:/bind/var:ro \
    -d 11notes/bind:latest
```

## Docker -u 1000:1000 (no root initiative)

As part to make containers more secure, this container will not run as root, but as uid:gid 1000:1000.

## Build with

* [Alpine Linux](https://alpinelinux.org/) - Alpine Linux
* [bind/named](https://www.isc.org/downloads/bind/) - bind

## Tips

* [Permanent Storge with NFS/CIFS/...](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS/...