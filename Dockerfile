FROM alpine:3.24.3@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

RUN apk add --no-cache inotify-tools curl

COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/

USER nobody

ENTRYPOINT ["docker-entrypoint.sh"]
