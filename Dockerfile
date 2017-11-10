FROM alpine
LABEL maintainer="Alexandre Buisine <alexandrejabuisine@gmail.com>" version="1.3.0"

RUN apk update && apk upgrade
RUN apk add --no-cache lighttpd git openssh rsync
COPY resources/*.sh /usr/local/sbin/
COPY resources/lighttpd.conf /usr/local/etc/lighttpd.conf

RUN chmod +x /usr/local/bin/* /usr/local/sbin/* \
 && mkdir -p /root/.ssh/

EXPOSE 80

ENV GIT_SSH_KEY= GIT_SSH_TARGET= ROTATE_MAX_DAYS=90

# ENTRYPOINT /usr/local/sbin/entrypoint.sh
# CMD ["/usr/local/sbin/deploy.sh", "clone"]
CMD ["lighttpd", "-D", "-f", "/usr/local/etc/lighttpd.conf"]