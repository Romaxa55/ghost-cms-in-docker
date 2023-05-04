FROM node:16-bullseye-slim

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.16
COPY install.sh /install.sh
RUN chmod +x /install.sh && /install.sh

ENV NODE_ENV production
ENV GHOST_CLI_VERSION 1.24.0
RUN set -eux; \
    npm install -g "ghost-cli@$GHOST_CLI_VERSION"; \
    npm cache clean --force

ENV GHOST_INSTALL /var/lib/ghost
ENV GHOST_CONTENT /var/lib/ghost/content
ENV GHOST_VERSION 5.46.1

COPY setup_ghost.sh /setup_ghost.sh
RUN chmod +x /setup_ghost.sh && /setup_ghost.sh

WORKDIR $GHOST_INSTALL
VOLUME $GHOST_CONTENT

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 2368
CMD ["node", "current/index.js"]
