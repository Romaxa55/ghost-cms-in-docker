import paramiko
import yaml
import os
import getpass
import logging
import colorlog
from kubespray.contrib.inventory_builder.inventory import KubesprayInventory


class KubesprayClusterSetup:
    def __init__(self, config_file):
        self.config = self.load_config_from_file(config_file)
        self.logger = self.init_logger()

    @staticmethod
    def init_logger():
        logger = logging.getLogger(__name__)
        logger.setLevel(logging.DEBUG)
        formatter = colorlog.ColoredFormatter(
            "%(asctime)s %(log_color)s%(levelname)s %(message)s",
            datefmt="%Y-%m-%d %H:%M:%S",
            log_colors={
                'DEBUG': 'yellow',
                'INFO': 'green',
                'WARNING': 'yellow,bg_white',
                'ERROR': 'red,bg_white',
                'CRITICAL': 'red,bg_white',
            },
        )
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
        return logger

    @staticmethod
    def load_config_from_file(config_file):
        with open(config_file, 'r') as config_file:
            return yaml.safe_load(config_file)

    def ssh_check_and_copy_id(self):

        # Получение списка всех узлов
        nodes = self.config["nodes"]

        # Запрос имени пользователя для подключения по SSH
        user_input = input("Введите имя пользователя для подключения по SSH (по умолчанию 'root'): ").strip()
        default_user = user_input if user_input else "root"

        for node_type in nodes:
            for node in nodes[node_type]:
                address = str(node["address"])
                name = node["name"]
                user_name = node.get("user", default_user)

                self.logger.info(f"Проверка подключения по SSH к {name} ({address})")

                ssh = paramiko.SSHClient()
                ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                try:
                    # Попытка подключения по SSH
                    ssh.connect(address, username=user_name, timeout=5)
                    self.logger.info(f"Успешное подключение по SSH к {name} ({address})")
                except paramiko.AuthenticationException:
                    self.logger.warning(f"Подключение по SSH к {name} ({address}) не удалось, запрашивается пароль")

                    # Запрос пароля у пользователя
                    password = ""
                    while not password:
                        password = getpass.getpass(f"Введите пароль для {user_name}@{address}: ")
                        # Проверка пароля
                        try:
                            ssh.connect(address, username=user_name, password=password, timeout=5)
                            self.logger.info(f"Пароль для {user_name}@{address} принят")
                            # Проброс публичного ключа на удаленный сервер
                            # Чтение публичного ключа из файла
                            with open(os.path.expanduser("~/.ssh/id_rsa.pub"), "r") as public_key_file:
                                public_key = public_key_file.read().strip()
                                ssh.exec_command("mkdir -p ~/.ssh")
                                ssh.exec_command(f"echo '{public_key}' >> ~/.ssh/authorized_keys")
                        except paramiko.AuthenticationException:
                            self.logger.warning(f"Неверный пароль для {user_name}@{address}")
                            password = ""
                except Exception as e:
                    self.logger.error(f"Не удалось подключиться по SSH к {name} ({address}): {e}")
                finally:
                    ssh.close()

    def build_inventory(self):
        # Инициализация объекта KubesprayInventory с параметрами
        ips = [f"{ip['name']},{ip['address']}" for node in self.config['nodes'] if node != 'haproxy' for ip in self.config['nodes'][node]]
        inventory = KubesprayInventory(changed_hosts=ips, config_file=self.config['kubespray']['hosts_file'])
        inventory.ensure_required_groups(['haproxy'])
        for node, haproxies in self.config['nodes'].items():
            if node == 'haproxy':
                for haproxy in haproxies:
                    optstring = {'ansible_host': haproxy['address'],
                                 'ansible_user': haproxy['user'],
                                 'ip': haproxy['address'],
                                 'access_ip': haproxy['address']}
                    inventory.add_host_to_group('all', haproxy['name'], optstring)
                    inventory.add_host_to_group('haproxy', haproxy['name'])
        inventory.write_config(self.config['kubespray']['hosts_file'])
        inventory.print_config()


    def main(self):
        # self.ssh_check_and_copy_id()
        self.build_inventory()


if __name__ == "__main__":
    config_path = "config.yaml"
    kubespray_setup = KubesprayClusterSetup(config_path)
    kubespray_setup.main()
