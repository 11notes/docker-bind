# :: Header
FROM alpine:3.10

# :: Run
RUN mkdir -p /bind/etc \
    && mkdir -p /bind/var

RUN apk --update --no-cache add \
    bash \
    bind \
    shadow

ADD ./source/named.conf /bind/etc/named.conf
ADD ./source/zones.conf /bind/etc/zones.conf

RUN chown -R named:named /bind

# :: Version
RUN echo "CI/CD{{$(named -v 2>&1)}}"

# :: docker -u 1000:1000 (no root initiative)
RUN usermod -u 1000 named \
        && groupmod -g 1000 named \
        && chown -R named:named /bind /var/run/named

# :: Volumes
VOLUME ["/bind/etc", "/bind/var"]

# :: Start
CMD ["/usr/sbin/named", "-fg", "-c", "/bind/etc/named.conf", "-u", "named"]