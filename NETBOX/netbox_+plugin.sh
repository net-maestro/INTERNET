#!/bin/bash

# === Минимальный запуск NetBox с плагином netbox-bgp ===
# Официальные шаги + установка плагина через pip

echo "🔹 Клонируем netbox-docker..."
git clone -b release https://github.com/netbox-community/netbox-docker.git
cd netbox-docker

echo "🔹 Создаем кастомный Dockerfile для установки netbox-bgp..."
tee Dockerfile.custom <<'EOF'
FROM netboxcommunity/netbox:latest

# Устанавливаем плагин netbox-bgp
RUN pip install netbox-bgp
EOF

echo "🔹 Настраиваем docker-compose.override.yml для использования кастомного образа и порта 8000:8080..."
tee docker-compose.override.yml <<'EOF'
services:
  netbox:
    build:
      context: .
      dockerfile: Dockerfile.custom
    image: custom-netbox:latest
    ports:
      - "8000:8080"
EOF

echo "🔹 Создаем configuration.py с включенным плагином netbox-bgp..."
mkdir -p configuration
tee configuration/configuration.py <<'EOF'
PLUGINS = ['netbox_bgp']
ALLOWED_HOSTS = ['*']
LANGUAGE_CODE = 'ru'
EOF

echo "🔹 Настраиваем volume для configuration.py в docker-compose.yml..."
# Добавляем volume в существующую секцию netbox, не перезаписывая весь файл
tee -a docker-compose.yml <<'EOF'
services:
  netbox:
    volumes:
      - ./configuration/configuration.py:/opt/netbox/netbox/netbox/configuration.py:ro
EOF

echo "🔹 Убеждаемся, что ALLOWED_HOSTS=* и LANGUAGE_CODE=ru в .env..."
echo "ALLOWED_HOSTS=*" >> .env
echo "LANGUAGE_CODE=ru" >> .env

echo "🔹 Скачиваем образы, собираем кастомный образ и запускаем..."
docker compose pull
docker compose build
docker compose up -d

echo "🔹 Применяем миграции для плагина netbox-bgp..."
docker compose exec netbox /opt/netbox/netbox/manage.py migrate

echo ""
echo "✅ Выполнено. Проверьте статус:"
echo "   docker compose ps"
echo "   docker compose logs netbox"
echo "🌐 Откройте: http://$(hostname -I | awk '{print $1}'):8000"
echo "Создать пользователя: docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser"
