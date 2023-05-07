#!/bin/bash

# Проверяем, существует ли директория kubespray/inventory/my_cluster
if [ ! -d "kubespray/inventory/my_cluster" ]; then
    cp -r "kubespray/inventory/sample" "kubespray/inventory/my_cluster"
    echo "Директория kubespray/inventory/my_cluster создана."
else
    echo "Директория kubespray/inventory/my_cluster уже существует, копирование не будет выполнено."
fi
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
fi

# Запрос на запуск установки кластера
echo "Вы хотите установить HAproxy? (y/n)"
read -r INSTALL_ANSWER

if [[ "$INSTALL_ANSWER" =~ [yY] ]]; then
  # Запуск плейбука для установки кластера
  echo "Запуск плейбука для установки HAproxy"
  ansible-playbook -i hosts.yaml playbook_haproxy.yaml -b --become-user=root
else
  echo "Установка HAproxy отменена."
fi

# Проверяем, существует ли файл ~/.kube/config
if [ ! -f ~/.kube/config ]; then
    USER=$(cat hosts.yaml | awk '/master/,/ansible_user/ {if(/ansible_user/) print $2}')
    SERVER=$(cat hosts.yaml | awk '/master/,/ansible_host/ {if(/ansible_host/) print $2}')
    mkdir -p ~/.kube || true
    scp $USER@$SERVER:/etc/kubernetes/admin.conf ~/.kube/config
    # Заменяем 127.0.0.1 на IP-адрес из переменной $SERVER в файле config
    sed -i '' "s/127.0.0.1/$SERVER/g" ~/.kube/config
else
    echo "Файл config уже существует, код не будет выполнен."
fi

kubectl get nodes
