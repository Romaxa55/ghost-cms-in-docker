# Ghost CMS in k8s

Данный скрипт помогает автоматизировать установку кластера Kubernetes с помощью инструмента Kubespray.

## Инструкция по развертки кластера


1Запустите скрипт install_cluster.sh:

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

## Установить Dashboard UI
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

