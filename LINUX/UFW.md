# Ubuntu Server — базовая безопасность

## 1. Установка UFW

```bash
sudo apt update          # Обновить список пакетов
sudo apt install ufw     # Установить Firewall
```

## 2. Настройка правил Firewall

```bash
sudo ufw default deny incoming   # Запретить входящие соединения по умолчанию
sudo ufw default allow outgoing # Разрешить исходящие соединения

sudo ufw allow from 192.168.0.0/24 to any port 22 proto tcp  # SSH только из подсети
sudo ufw allow 443/tcp            # Разрешить HTTPS со всех адресов

sudo ufw enable             # Включить Firewall
sudo ufw status verbose     # Показать статус и правила
sudo ufw status numbered    # Показать правила с номерами
sudo ufw delete НОМЕР       # Удалить правило по номеру
```

**Важно:** перед включением UFW убедись, что SSH разрешён с твоего IP или подсети, иначе можно потерять удалённый доступ.

## 3. Запрет SSH-входа для root

```bash
sudo sshd -T | grep -i permitrootlogin  # Проверить настройку входа root
sudo nano /etc/ssh/sshd_config          # Открыть конфигурацию SSH
```

В конфигурации установить:

```text
PermitRootLogin no
```

Затем выполнить:

```bash
sudo sshd -t                           # Проверить синтаксис конфигурации
sudo systemctl reload ssh              # Применить настройки SSH
sudo sshd -T | grep -i permitrootlogin # Проверить итоговое значение
```

Ожидаемый результат: `permitrootlogin no`.

## 4. Просмотр пользователей sudo

```bash
getent group sudo  # Показать участников группы sudo
```

