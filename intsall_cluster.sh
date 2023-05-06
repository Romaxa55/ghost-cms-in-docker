#!/bin/bash

# Настройка переменных
KUBESPRAY_DIR="kubespray-2.21.0"
SAMPLE_INVENTORY_DIR="$KUBESPRAY_DIR/inventory/sample/"
INVENTORY_DIR="$KUBESPRAY_DIR/inventory/mycluster"
HOSTS_FILE="$INVENTORY_DIR/hosts.yaml"

# Создание инвентаря, если он не существует
if [ ! -d "$INVENTORY_DIR" ]; then
  echo "Создание каталога инвентаря"
  mkdir -p $INVENTORY_DIR
  cp -r $SAMPLE_INVENTORY_DIR/* $INVENTORY_DIR
fi

# Запросить IP-адреса мастер-узлов и рабочих узлов
echo "Введите IP-адреса мастер-узлов через пробел:"
read -a MASTER_NODES
echo "Введите IP-адреса рабочих узлов через пробел:"
read -a WORKER_NODES

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

# Проверка подключения по SSH и выполнение ssh-copy-id, если необходимо
for NODE_IP in "${MASTER_NODES[@]}" "${WORKER_NODES[@]}"; do
  echo "Проверка подключения по SSH к $NODE_IP"
  if ! ssh -q -o "StrictHostKeyChecking=no" -o "BatchMode=yes" -o "ConnectTimeout=5" -l "$USER_NAME" "$NODE_IP" "exit"; then
    echo "Выполнение ssh-copy-id для $NODE_IP"
    ssh-copy-id -o "StrictHostKeyChecking=no" -i ~/.ssh/id_rsa.pub "$USER_NAME@$NODE_IP"
  else
    echo "Подключение к $NODE_IP успешно"
  fi
done
