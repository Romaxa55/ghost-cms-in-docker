#!/bin/bash

#sudo crontab -e
#0 0 1 * * /root/certbot.sh
# Обновление сертификатов
certbot renew

# Объединение сертификата и ключа в один файл
domain="roshamagin.site"
ssl_directory="/etc/ssl/${domain}"
cert_directory="/etc/letsencrypt/live/${domain}"

mkdir -p "${ssl_directory}"
cat "${cert_directory}/fullchain.pem" "${cert_directory}/privkey.pem" \
    | tee "${ssl_directory}/${domain}.pem"

# Перезапуск HAProxy
systemctl restart haproxy
