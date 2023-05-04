FROM node:16.20.0-buster-slim

ENV NODE_ENV=production

WORKDIR /app
COPY install.sh .

RUN chmod +x ./install.sh && ./install.sh