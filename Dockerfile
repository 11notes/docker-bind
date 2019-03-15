# :: Header
FROM alpine:3.9

# :: Run
USER root

RUN mkdir -p /bind/etc \
    && mkdir -p /bind/var

RUN apk --update --no-cache add \
    bash \
    bind

RUN rm -R /etc/bind

ADD ./source/named.conf /bind/etc/named.conf
ADD ./source/zones.conf /bind/etc/zones.conf

RUN chown -R named:named /bind

# :: Volumes
VOLUME ["/bind/etc", "/bind/var"]

# :: Start
USER named
CMD ["/usr/sbin/named", "-fg", "-c", "/bind/etc/named.conf"]