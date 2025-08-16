#!/bin/bash

# === Запуск NetBox с плагином netbox-bgp ===
# Совместимо с netbox-docker, учитывает отсутствие pip в PATH

echo "🔹 Клонируем netbox-docker..."
git clone -b release https://github.com/netbox-community/netbox-docker.git
cd netbox-docker

echo "🔹 Настраиваем порт 8000:8080"
cat > docker-compose.override.yml <<'EOF'
services:
  netbox:
    ports:
      - "8000:8080"
EOF

echo "🔹 Настраиваем .env: ALLOWED_HOSTS и язык"
echo "ALLOWED_HOSTS=*" >> .env
echo "LANGUAGE_CODE=ru" >> .env

echo "🔹 Создаём requirements.txt для установки плагинов"
cat > requirements.txt <<'EOF'
netbox-bgp
EOF

echo "🔹 Запускаем контейнеры (автоматически подхватит requirements.txt)"
docker compose pull
docker compose up -d

#echo "🔹 Ожидаем готовности базы данных..."
#until docker compose exec netbox netbox-status 2>/dev/null | grep -q "Database ready"; do
  #echo "⏳ Ждём инициализации..."
  #sleep 5
#done

echo "🔹 Добавляем плагин в configuration.py"
docker compose exec netbox sh -c "
if ! grep -q \"PLUGINS\" /opt/netbox/netbox/netbox/configuration.py; then
    echo 'PLUGINS = [\"netbox_bgp\"]' >> /opt/netbox/netbox/netbox/configuration.py
fi
"

echo "🔹 Перезапускаем netbox для активации плагина"
docker compose restart netbox

echo ""
echo "✅ NetBox запущен с плагином netbox-bgp"
echo "   Проверь статус: docker compose ps"
echo "   Логи: docker compose logs netbox"
echo "🌐 Открой: http://$(hostname -I | awk '{print $1}'):8000"
echo "🔧 Создай суперпользователя: docker compose exec netbox /opt/netbox/netbox/manage.py createsuperuser"
