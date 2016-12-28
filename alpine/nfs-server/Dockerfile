FROM alpine:3.4
RUN apk add --no-cache nfs-utils bash
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]
