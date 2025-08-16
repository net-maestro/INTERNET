#!/bin/bash

# === Минимальный запуск NetBox по документации с плагином BGP ===
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

echo "🔹 Устанавливаем язык системы в .env"
echo "LANGUAGE_CODE=ru" >> .env

echo "🔹 Добавляем конфигурацию плагина BGP"
tee -a configuration/plugins/netbox_bgp.py <<'EOF'
from django.conf import settings

PLUGINS_CONFIG = {
    'netbox_bgp': {
        'device_ext_page': 'right',
    }
}
EOF

echo "🔹 Добавляем плагин в configuration.py"
tee -a configuration/configuration.py <<'EOF'
PLUGINS = ['netbox_bgp']
EOF

echo "🔹 Добавляем установку плагина в Dockerfile"
sed -i '/^FROM netbox\/netbox:/a RUN pip install netbox-bgp' Dockerfile

echo "🔹 Скачиваем образы и запускаем"
docker compose build --no-cache
docker compose pull
docker compose up -d

echo ""
echo "✅ Выполнено. Проверьте статус:"
echo "   docker compose ps"
echo "   docker compose logs netbox"
echo "🌐 Откройте: http://$(hostname -I | awk '{print $1}'):8000"
echo "Создать пользователя: docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser"
echo "Плагин BGP установлен и активирован"
