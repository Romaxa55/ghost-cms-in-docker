FROM node:16.20.0-buster-slim
WORKDIR /app
COPY app/ /app
RUN apt-get update && \
    apt-get install -y git python && \
    rm -rf /var/lib/apt/lists/*

RUN yarn setup
ENV NODE_ENV production

