#!/bin/bash

# Настройка переменных
KUBESPRAY_DIR="kubespray-2.21.0"
SAMPLE_INVENTORY_DIR="$KUBESPRAY_DIR/inventory/sample/"
INVENTORY_DIR="$KUBESPRAY_DIR/inventory/mycluster"
HOSTS_FILE="$INVENTORY_DIR/hosts.yaml"

function create_inventory() {
  # Создание инвентаря, если он не существует
  if [ ! -d "$INVENTORY_DIR" ]; then
    echo "Создание каталога инвентаря"
    mkdir -p $INVENTORY_DIR
    cp -r $SAMPLE_INVENTORY_DIR/* $INVENTORY_DIR
  else
    if [ -f "$HOSTS_FILE" ]; then
      echo "Инвентарь уже существует. Информация о узлах:"
      echo "Мастер-узлы:"
      grep "master1" -A 2 $HOSTS_FILE | grep "ansible_host" | awk '{print $2}'
      echo "Рабочие узлы:"
      grep "worker" -A 2 $HOSTS_FILE | grep "ansible_host" | awk '{print $2}'
      return
    fi
  fi

  # Запросить IP-адреса мастер-узлов и рабочих узлов
  if [ -z "$1" ]; then
    echo "Введите IP-адреса мастер-узлов через пробел:"
    read -a MASTER_NODES
    echo "Введите IP-адреса рабочих узлов через пробел:"
    read -a WORKER_NODES
  else
    MASTER_NODES=("$1")
    WORKER_NODES=("$2" "$3")
  fi

  # Запросить имя пользователя
  echo "Введите имя пользователя (по умолчанию root):"
  read -r USER_NAME
  USER_NAME=${USER_NAME:-root}

  # Обновление файла hosts.yaml
  cat > $HOSTS_FILE << EOL
  all:
    hosts:
      master1:
        ansible_host: ${MASTER_NODES[0]}
        ip: ${MASTER_NODES[0]}
        access_ip: ${MASTER_NODES[0]}
      worker1:
        ansible_host: ${WORKER_NODES[0]}
        ip: ${WORKER_NODES[0]}
        access_ip: ${WORKER_NODES[0]}
      worker2:
        ansible_host: ${WORKER_NODES[1]}
        ip: ${WORKER_NODES[1]}
        access_ip: ${WORKER_NODES[1]}
    children:
      kube_control_plane:
        hosts:
          master1:
      kube_node:
        hosts:
          worker1:
          worker2:
      etcd:
        hosts:
          master1:
      k8s_cluster:
        children:
          kube_control_plane:
          kube_node:
      calico_rr:
        hosts: {}
    vars:
      ansible_user: $USER_NAME
EOL

  echo "Инвентарь успешно создан."
}

# Запросить IP-адреса, если они не переданы в качестве аргументов
if [ "$#" -eq 0 ]; then
  create_inventory
else
  create_inventory "$@"
fi

# Запрос на запуск установки кластера
echo "Вы хотите установить кластер Kubernetes? (y/n)"
read -r INSTALL_ANSWER

if [[ "$INSTALL_ANSWER" =~ [yY] ]]; then
  # Запуск плейбука для установки кластера
  echo "Запуск плейбука для установки кластера"
  cd $KUBESPRAY_DIR
  ansible-playbook -i inventory/mycluster/hosts.yaml cluster.yml -b --become-user=root
else
  echo "Установка кластера отменена."
  exit 0
fi
