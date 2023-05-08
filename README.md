# Ghost CMS in k8s

Данный скрипт помогает автоматизировать установку кластера Kubernetes с помощью инструмента Kubespray.

## Инструкция по развертки кластера


1. Запустите скрипт install_cluster.sh:

```bash
sudo ./install_cluster.sh
```

2. Следуйте инструкциям скрипта для ввода IP-адресов мастер-узлов и рабочих узлов, а также для ввода имени пользователя.
3. Если инвентарь уже существует, скрипт выведет информацию о мастер-узлах и рабочих узлах. В этом случае вы можете пропустить шаг 4.
4. Скрипт запросит подтверждение установки кластера. Введите y, если хотите продолжить, или n, чтобы отменить установку.
5. Если вы подтвердили установку кластера, скрипт запустит установку кластера Kubernetes с помощью Kubespray.

После завершения установки кластера вы сможете управлять им с помощью `kubectl`. 
Для этого вам нужно будет скопировать файл конфигурации кластера на свою локальную машину и установить переменную `KUBECONFIG` в этот файл. Например:

```bash
# Скопировать файл конфигурации кластера на локальную машину
scp root@<master-node-ip>:/etc/kubernetes/admin.conf ~/.kube/config

# Установить переменную KUBECONFIG в файл конфигурации кластера
export KUBECONFIG=~/.kube/config
```

После этого вы можете использовать команду `kubectl` для управления кластером.

## Установить Dashboard UI k8s
1. Установите Kubernetes Dashboard с помощью команды:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```
2. Создайте администраторский токен для доступа к Kubernetes Dashboard.

```bash
kubectl apply -f k8s/dashboard-adminuser.yaml
```

3. Запустите прокси-сервер для доступа к Kubernetes Dashboard. Для этого выполните команду:
```bash
kubectl proxy
```

4. Откройте браузер и перейдите по адресу http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/. Вы увидите страницу входа в Kubernetes Dashboard.

5. Введите токен, созданный на шаге 2, и нажмите "Sign In". Вы должны увидеть главную страницу Kubernetes Dashboard.

Получение токена пример
```bash
kubectl -n kubernetes-dashboard create token admin-user


```

## Установка Helm на Linux и macOS включает следующие шаги:

```bash

export PSQL_PASSWORD=pass

kubectl create namespace ghost-cms
kubectl config set-context --current --namespace ghost-cms
helm install postgresql --version 11.0.0 \
 --set primary.containerSecurityContext.enabled=false \
 --set primary.podSecurityContext.enabled=false \
 --set primary.podSecurityContext.fsGroup=0 \
 --set primary.containerSecurityContext.runAsUser=0 \
 oci://registry-1.docker.io/bitnamicharts/postgresql-ha

kubectl get pods -n ghost-cms
```
# Подключение к DB
```bash
export POSTGRES_PASSWORD=$(kubectl get secret --namespace ghost-cms postgresql-postgresql-ha-postgresql -o jsonpath="{.data.password}" | base64 -d)
export REPMGR_PASSWORD=$(kubectl get secret --namespace ghost-cms postgresql-postgresql-ha-postgresql -o jsonpath="{.data.repmgr-password}" | base64 -d)
kubectl run postgresql-postgresql-ha-client --rm --tty -i --restart='Never' --namespace ghost-cms --image docker.io/bitnami/postgresql-repmgr:15.2.0-debian-11-r26 --env="PGPASSWORD=$POSTGRES_PASSWORD"  \
        --command -- psql -h postgresql-postgresql-ha-pgpool -p 5432 -U ghost -d ghost-cms

```
To connect to your database from outside the cluster execute the following commands:
```bash
kubectl port-forward --namespace ghost-cms svc/postgresql-postgresql-ha-pgpool 5432:5432 &
psql -h 127.0.0.1 -p 5432 -U ghost -d ghost-cms
```

Update
```bash
export PSQL_PASSWORD=pass

helm upgrade postgresql \
    --set postgresql.username=ghost \
    --set postgresql.password=${PSQL_PASSWORD} \
    --set postgresql.database=ghost \
    --set pgpool.adminPassword=${PSQL_PASSWORD} \
    --set global.pgpool.adminUsername=ghost  \
    --set postgresql.repmgrPassword=${PSQL_PASSWORD}  \
    oci://registry-1.docker.io/bitnamicharts/postgresql-ha

```

Uninstall
```bash
helm uninstall postgresql
```



