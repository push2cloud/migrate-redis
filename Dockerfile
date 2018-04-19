FROM mhart/alpine-node:8.10.0

RUN apk add --no-cache jq bash redis && \
    rm -f /etc/redis.conf \
          /etc/logrotate.d/redis \
          /etc/init.d/redis \
          /etc/conf.d/redis \
          /usr/bin/redis-benchmark \
          /usr/bin/redis-sentinel \
          /usr/bin/redis-server \
          /usr/bin/redis-check-aof \
          /usr/bin/redis-check-rdb \
          /usr/share/licenses/redis/COPYING \
          /usr/bin/timed-read \
          /usr/bin/tknewsbiff \
          /usr/bin/multixterm \
          /usr/bin/kibitz \
          /usr/bin/xpstat \
          /usr/bin/tkpasswd \
          /usr/bin/xkibitz \
          /usr/bin/rlogin-cwd \
          /usr/bin/expect \
          /usr/bin/autoexpect \
          /usr/bin/autopasswd \
          /usr/bin/rftp \
          /usr/bin/weather \
          /usr/bin/lpunlock \
          /usr/bin/timed-run \
          /usr/bin/ftp-rfc \
          /usr/bin/passmass \
          /usr/bin/cryptdir \
          /usr/bin/dislocate \
          /usr/bin/mkpasswd \
          /usr/bin/decryptdir \
          /usr/lib/expect5.45/libexpect5.45.so \
          /usr/lib/expect5.45/pkgIndex.tcl && \
    npm install -g redis-dump

COPY ./migrate.sh /migrate.sh

CMD [ "/migrate.sh" ]
