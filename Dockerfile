FROM mhart/alpine-node:8.10.0

RUN apk add --no-cache jq bash redis expect && \
    rm -f /etc/redis.conf \
          /etc/logrotate.d/redis \
          /etc/init.d/redis \
          /etc/conf.d/redis \
          /usr/bin/redis-benchmark \
          /usr/bin/redis-sentinel \
          /usr/bin/redis-server \
          /usr/bin/redis-check-aof \
          /usr/bin/redis-check-rdb \
          /usr/share/licenses/redis/COPYING && \
    npm install -g redis-dump

COPY ./migrate.sh /migrate.sh

CMD [ "/migrate.sh" ]
