# :: Header
	FROM alpine:3.16

# :: Run
	USER root

	# :: prepare
        RUN set -ex; \
            mkdir -p /bind; \
            mkdir -p /bind/etc \
            mkdir -p /bind/var;

		RUN set -ex; \
			apk add --update --no-cache \
				bash \
                bind>=9.16.29 \
				shadow;

		RUN set -ex; \
			addgroup --gid 1000 -S bind; \
			adduser --uid 1000 -D -S -h /bind -s /sbin/nologin -G bind bind;

    # :: copy root filesystem changes
        COPY ./rootfs /

    # :: docker -u 1000:1000 (no root initiative)
        RUN set -ex; \
            chown -R bind:bind \
				/bind \
                /var/run/named;

    # :: Version
        RUN set -ex; \
            echo "CI/CD{{$(named -v 2>&1)}}";

# :: Volumes
	VOLUME ["/bind/etc", "/bind/var"]

# :: Start
	USER bind
	CMD ["/usr/sbin/named", "-fg", "-c", "/bind/etc/named.conf", "-u", "bind"]