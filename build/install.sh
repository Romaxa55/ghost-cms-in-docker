#!/bin/sh

# Установка зависимостей
apt-get update && \
apt-get install -y git python && \
rm -rf /var/lib/apt/lists/*

# Клонирование репозитория Ghost
git clone --recurse-submodules https://github.com/TryGhost/Ghost.git

# Переход в каталог Ghost
cd Ghost

# Запуск сборки
yarn setup
