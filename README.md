# docker-bind

Dockerfile to create and run your own named process inside an alpine docker container.

## Volumes

/bind/etc

Purpose: named config directory

/var/zones

Purpose: zone files directory

## Run
```shell
docker run --name nginx \
    -v volume-etc:/etc/bind \
    -v volume-zones:/var/zones:ro \
    -d 11notes/bind:latest
```

## Build with

* [Alpine Linux](https://alpinelinux.org/) - Alpine Linux
* [bind/named](https://www.isc.org/downloads/bind/) - bind

## Tips

* [Permanent Storge with NFS/CIFS/...](https://github.com/11notes/alpine-docker-netshare) - Module to store permanent container data via NFS/CIFS/...