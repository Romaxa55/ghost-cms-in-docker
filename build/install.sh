#!/bin/sh

# Установка зависимостей
apt-get update && \
apt-get install -y git python g++ make python3 && \
rm -rf /var/lib/apt/lists/*

# Клонирование репозитория Ghost
git clone --recurse-submodules https://github.com/TryGhost/Ghost.git /var/lib/ghost

# Переход в каталог Ghost
cd /var/lib/ghost

# Запуск сборки
yarn setup

# Очистка кэша
yarn cache clean
npm cache clean --force
