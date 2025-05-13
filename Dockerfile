FROM alpine:3.21.3@sha256:1c4eef651f65e2f7daee7ee785882ac164b02b78fb74503052a26dc061c90474

RUN apk add --no-cache inotify-tools curl

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

USER nonroot

ENTRYPOINT ["docker-entrypoint.sh"]