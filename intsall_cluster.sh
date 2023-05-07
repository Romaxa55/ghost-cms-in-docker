#!/bin/bash

python3 kubespray/setup.py install
python3 setup.py

# Запрос на запуск установки кластера
echo "Вы хотите установить кластер Kubernetes? (y/n)"
read -r INSTALL_ANSWER

if [[ "$INSTALL_ANSWER" =~ [yY] ]]; then
  # Запуск плейбука для установки кластера
  echo "Запуск плейбука для установки кластера"
  ansible-playbook -i hosts.yaml kubespray/cluster.yml -b --become-user=root
else
  echo "Установка кластера отменена."
  exit 0
fi
