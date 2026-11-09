FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

RUN apk add --no-cache inotify-tools curl

COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/

USER nobody

ENTRYPOINT ["docker-entrypoint.sh"]
