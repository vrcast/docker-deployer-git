FROM alpine
LABEL version="1.1.0"

RUN apk update && apk upgrade
RUN apk add --no-cache lighttpd git openssh rsync
COPY resources/*.sh /usr/local/sbin/
COPY resources/lighttpd.conf /usr/local/etc/lighttpd.conf

ADD https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux /usr/local/bin/ep

RUN chmod +x /usr/local/bin/* /usr/local/sbin/* \
 && mkdir -p /root/.ssh/ && echo '${GIT_SSH_KEY}' > /root/.ssh/git && chmod 0600 /root/.ssh/git

EXPOSE 80

ENV GIT_SSH_KEY="" GIT_SSH_TARGET="" ROTATE_MAX_DAYS=90

# ENTRYPOINT /usr/local/sbin/entrypoint.sh
# CMD ["/usr/local/sbin/deploy.sh", "clone"]
CMD ["lighttpd", "-D", "-f", "/usr/local/etc/lighttpd.conf"]