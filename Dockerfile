FROM node:10 AS build

RUN apt update && \
      apt -y install sudo supervisor

WORKDIR /opt

COPY push-server-0.2.2.tgz /opt/push-server-0.2.2.tgz
RUN npm install --production ./push-server-0.2.2.tgz \
    && rm /opt/push-server-0.2.2.tgz

FROM node:10-alpine

COPY config /etc/push-server
COPY sysconfig /etc/sysconfig
COPY start /usr/local/bin/start
COPY supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY --from=build /opt/node_modules/push-server /opt/push-server
COPY --from=build /opt/node_modules/push-server/etc/init.d/push-server-multi /usr/local/bin/push-server-multi
COPY --from=build /opt/node_modules/push-server/logs /var/log/push-server
COPY --from=build /lib/lsb/init-functions /lib/lsb/init-functions

RUN apk update && apk add \
    sudo \
    bash \
    supervisor \
    && rm -rf /var/cache/apk/* \
    && chmod u+x /usr/local/bin/start \
    && chown -R node:node /var/log/push-server

WORKDIR /opt/push-server

CMD ["/usr/local/bin/start"]