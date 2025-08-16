#!/bin/bash

# === Минимальный запуск NetBox + установка плагина netbox-bgp ===

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

echo "🔹 Устанавливаем язык интерфейса (русский)"
echo "LANGUAGE_CODE=ru" >> .env

echo "🔹 Скачиваем и запускаем контейнеры"
docker compose pull
docker compose up -d

# Ждём, пока сервис netbox станет готов
echo "🔹 Ожидаем запуска сервиса netbox..."
until docker compose exec netbox netbox-status 2>/dev/null | grep -q "Database ready"; do
  echo "⏳ Ждём инициализации базы данных..."
  sleep 5
done

echo "🔹 Устанавливаем плагин netbox-bgp через pip внутри контейнера"
docker compose exec -u root netbox pip install netbox-bgp

echo "🔹 Активируем плагин в configuration.py"
docker compose exec netbox sh -c "
if ! grep -q \"netbox_bgp\" /opt/netbox/netbox/netbox/configuration.py; then
    echo 'PLUGINS = [\"netbox_bgp\"]' >> /opt/netbox/netbox/netbox/configuration.py
fi
"

echo "🔹 Перезапускаем netbox для применения плагина"
docker compose restart netbox

echo ""
echo "✅ NetBox успешно запущен с плагином netbox-bgp"
echo "   Проверить статус: docker compose ps"
echo "   Логи: docker compose logs netbox"
echo "🌐 Откройте: http://$(hostname -I | awk '{print $1}'):8000"
echo "🔧 Создать суперпользователя: docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser"
