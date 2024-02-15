FROM alpine:3.19.1@sha256:6457d53fb065d6f250e1504b9bc42d5b6c65941d57532c072d929dd0628977d0

RUN apk add --no-cache inotify-tools curl

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER nonroot

ENTRYPOINT ["docker-entrypoint.sh"]