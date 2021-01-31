FROM alpine:3.13

ARG STRELAYSRV_VER=v1.8.0
ARG STRELAYSRV_URL=https://github.com/syncthing/relaysrv/releases/download/$STRELAYSRV_VER/strelaysrv-linux-amd64-${STRELAYSRV_VER}.tar.gz

RUN set -ex && \
    apk add --no-cache ca-certificates su-exec tar wget && \
    mkdir -p /var/strelaysrv && \
    cd /tmp && \
    wget $STRELAYSRV_URL && \
    tar xzvf strelaysrv-linux-amd64-${STRELAYSRV_VER}.tar.gz && \
    mv strelaysrv-linux-amd64-${STRELAYSRV_VER}/strelaysrv /bin/strelaysrv && \
    rm -rf /tmp/*

VOLUME ["/var/strelaysrv"]

WORKDIR /var/strelaysrv

ENV PUID=1000 PGID=1000 HOME=/var/strelaysrv

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

EXPOSE 22067 22070
CMD /bin/strelaysrv -pools="" -protocol=tcp