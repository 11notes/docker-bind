# :: Header
FROM alpine:3.9

# :: Run
USER root

RUN apk --update --no-cache add \
    bash \
    bind

RUN mkdir -p /var/zones

ADD ./source/named.conf /etc/bind/named.conf
ADD ./source/zones.conf /etc/bind/zones.conf

RUN chown -R named:named /etc/bind

# :: Volumes
VOLUME ["/etc/bind", "/var/zones"]

# :: Start
USER named
CMD ["/usr/sbin/named", "-fg", "-c", "/bind/etc/named.conf"]