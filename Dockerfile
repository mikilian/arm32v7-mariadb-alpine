FROM arm32v7/alpine:3.12

LABEL maintainer="Michael Kilian <michael.kilian@gmail.com>" \
    architecture="arm32v7/armhf" \
    mariadb-version="10.4.17" \
    alpine-version="3.12"\
    build="01-Apr-2021"

ADD files/docker-entrypoint.sh /scripts/docker-entrypoint.sh

RUN apk add --no-cache mariadb mariadb-client mariadb-server-utils pwgen \
    && rm -f /var/cache/apk/*                                            \
    && mkdir /docker-entrypoint-initdb.d                                 \
    && mkdir /scripts/pre-exec.d                                         \
    && mkdir /scripts/pre-init.d                                         \
    && chmod -R 755 /scripts

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/scripts/docker-entrypoint.sh"]
