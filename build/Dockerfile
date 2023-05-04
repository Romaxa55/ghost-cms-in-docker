FROM node:16-bullseye-slim

# остальные инструкции до строки ENV NODE_ENV production

ENV NODE_ENV production

# Копирование и запуск скрипта install.sh
COPY install.sh .
RUN chmod +x ./install.sh && ./install.sh

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 2368
CMD ["node", "current/index.js"]
