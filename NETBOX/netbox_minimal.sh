#!/bin/bash

# === Минимальный запуск NetBox по документации ===
# Только официальные шаги, без лишнего

echo "🔹 Клонируем netbox-docker..."
git clone -b release https://github.com/netbox-community/netbox-docker.git
cd netbox-docker

echo "🔹 Настраиваем порт 8000:8080"
tee docker-compose.override.yml <<'EOF'
services:
  netbox:
    ports:
      - "8000:8080"
EOF

echo "🔹 Убеждаемся, что ALLOWED_HOSTS=* в .env"
echo "ALLOWED_HOSTS=*" >> .env

echo "🔹 Скачиваем образы и запускаем"
docker compose pull
docker compose up -d

echo ""
echo "✅ Выполнено. Проверьте статус:"
echo "   docker compose ps"
echo "   docker compose logs netbox"
echo "🌐 Откройте: http://$(hostname -I | awk '{print $1}'):8000"
echo "Создать пользователя docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser"
