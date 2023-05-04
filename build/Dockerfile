FROM node:16.20.0-buster-slim
WORKDIR /app
#COPY app/ /app
RUN apt-get update && \
    apt-get install -y git python && \
    rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/TryGhost/Ghost.git
RUN cd Ghost && yarn setup
ENV NODE_ENV production

