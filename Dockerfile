FROM alpine:3.14.0

########################################
#              Settings                #
########################################

ENV DEBUG           false
ENV SERVER_PORT     22067
ENV STATUS_PORT     22070
ENV RATE_GLOBAL     0
ENV RATE_SESSION    0
ENV PROTOCOL        tcp
ENV POOLS           ""

########################################
#               Build                  #
########################################

ARG STRELAYSRV_VER=v1.15.0
ARG PLATFORM=amd64
ARG STRELAYSRV_URL=https://github.com/syncthing/relaysrv/releases/download/${STRELAYSRV_VER}/strelaysrv-linux-${PLATFORM}-${STRELAYSRV_VER}.tar.gz

RUN set -ex && \
    apk add --no-cache ca-certificates su-exec tar wget && \
    mkdir -p /var/strelaysrv && \
    cd /tmp && \
    wget ${STRELAYSRV_URL} && \
    tar xzvf strelaysrv-linux-${PLATFORM}-${STRELAYSRV_VER}.tar.gz && \
    mv strelaysrv-linux-${PLATFORM}-${STRELAYSRV_VER}/strelaysrv /usr/bin/strelaysrv && \
    rm -rf /tmp/*

VOLUME ["/var/strelaysrv"]

WORKDIR /var/strelaysrv

ENV PUID=1000 PGID=1000 HOME=/var/strelaysrv

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

EXPOSE ${STATUS_PORT} ${SERVER_PORT}

CMD /usr/bin/strelaysrv \
    -debug="${DEBUG}" \
    -listen=":${SERVER_PORT}" \
    -status-srv=":${STATUS_PORT}" \
    -global-rate="${RATE_GLOBAL}" \
    -per-session-rate="${RATE_SESSION}" \
    -protocol="${PROTOCOL}" \
    -pools="${POOLS}"