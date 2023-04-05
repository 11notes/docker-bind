# :: Header
FROM alpine:latest
ENV binVersion=9.18.13-r0

# :: Run
	USER root

	# :: prepare
		RUN set -ex; \
			mkdir -p /bind; \
			mkdir -p /bind/etc \
			mkdir -p /bind/var;

	# :: install
		RUN set -ex; \
			apk add --update --no-cache \
				bash \
				bind>=${binVersion} \
				bind-tools \
				shadow;

	# :: configure
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

# :: Volumes
	VOLUME ["/bind/etc", "/bind/var"]

# :: Monitor
	RUN set -ex; chmod +x /usr/local/bin/healthcheck.sh
	HEALTHCHECK CMD /usr/local/bin/healthcheck.sh || exit 1

# :: Start
	RUN set -ex; chmod +x /usr/local/bin/entrypoint.sh
	USER bind
	ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]	