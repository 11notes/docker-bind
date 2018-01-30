# ------ Header ------ #
FROM alpine:latest

#   // add bind
RUN apk update \
    && apk add --update bash \
    && apk add --no-cache bind

#   // create directory for zone configuration files
RUN mkdir -p /var/zones \
#   // delete default files
    && rm -R /etc/bind/*

#   // add default bind config for internal, external view + recursion
ADD ./named.conf /etc/bind/named.conf

# ------ define volumes ------ #
VOLUME ["/etc/bind", "/var/zones"]

# ------ entrypoint for container ------ #
CMD ["/usr/sbin/named", "-fg", "-c", "/etc/bind/named.conf"]