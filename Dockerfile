FROM arm32v7/alpine:3.9

LABEL maintainer="Michael Kilian <michael.kilian@gmail.com>" \
    architecture="arm32v7/armhf"                             \
    mariadb-version="10.3.23"                                \
    alpine-version="3.9"                                     \
    build="16-Sep-2020"

ADD files/run.sh /scripts/run.sh

RUN apk add --no-cache mariadb mariadb-client mariadb-server-utils pwgen \
    && rm -f /var/cache/apk/*                                            \
    && mkdir /docker-entrypoint-initdb.d                                 \
    && mkdir /scripts/pre-exec.d                                         \
    && mkdir /scripts/pre-init.d                                         \
    && chmod -R 755 /scripts

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/scripts/run.sh"]
