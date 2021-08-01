FROM --platform=${TARGETPLATFORM} golang:alpine as builder
ENV CGO_ENABLED=0
ARG TAG

WORKDIR /root

RUN set -ex && \
    apk add --no-cache git && \
    git clone https://github.com/syncthing/syncthing syncthing && \
    cd ./syncthing && \
    git fetch --all --tags && \
    git checkout tags/${TAG} && \
    rm -f strelaysrv && \
    go run build.go -no-upgrade build strelaysrv

FROM --platform=${TARGETPLATFORM} alpine:3.14.0
COPY --from=builder /root/syncthing/strelaysrv /bin/strelaysrv

ENV DEBUG           false
ENV SERVER_PORT     22067
ENV STATUS_PORT     22070
ENV RATE_GLOBAL     0
ENV RATE_SESSION    0
ENV PROTOCOL        tcp
ENV POOLS           ""

RUN apk add --no-cache ca-certificates su-exec

VOLUME ["/var/strelaysrv"]

WORKDIR /var/strelaysrv

ENV PUID=1000 PGID=1000 HOME=/var/strelaysrv

COPY docker-entrypoint.sh /bin/entrypoint.sh
RUN chmod a+x /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]

EXPOSE ${SERVER_PORT} ${STATUS_PORT}

CMD /bin/strelaysrv \
    -debug="${DEBUG}" \
    -listen=":${SERVER_PORT}" \
    -status-srv=":${STATUS_PORT}" \
    -global-rate="${RATE_GLOBAL}" \
    -per-session-rate="${RATE_SESSION}" \
    -protocol="${PROTOCOL}" \
    -pools="${POOLS}"
