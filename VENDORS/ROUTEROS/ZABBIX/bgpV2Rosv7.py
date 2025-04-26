#!/usr/bin/env python3.10

import os
import re
import json
import sys
from librouteros import connect
from dotenv import load_dotenv

# Загружаем переменные окружения
load_dotenv()

# Данные подключения
user = os.getenv("API_USER")
senha = os.getenv("API_PASS")
ip = os.getenv("HOST_IP")
porta = os.getenv("API_PORT")

# Пытаемся подключиться к устройству
try:
    api = connect(username=user, password=senha, host=ip, port=porta)
except Exception:
    print(json.dumps({"data": []}))  # Пустой JSON для Zabbix
    sys.exit(1)

# Функция для преобразования аптайма в секунды
def parse_uptime(uptime):
    time_units = {"w": 604800, "d": 86400, "h": 3600, "m": 60, "s": 1}
    seconds = 0
    for unit, value in time_units.items():
        match = re.search(r"(\d+){}".format(unit), uptime)
        if match:
            seconds += int(match.group(1)) * value
    return seconds

# Получение BGP-сессий
bgp_peers = []
for session in api(cmd="/routing/bgp/session/print"):
    name = session.get("name", "")
    remote_ip = session.get("remote.address", "")
    remote_as = session.get("remote.as", "")
    messages = session.get("remote.messages", 0)
    uptime = parse_uptime(session.get("uptime", "0s"))
    status = int(session.get("established", 0))

    bgp_peers.append({
        "{#NAME}": name,
        "{#IP}": remote_ip,
        "{#AS}": remote_as,
        "{#MESSAGES}": messages,
        "{#UPTIME}": uptime,
        "{#STATUS}": status
    })

# Получение информации о маршрутах
ipv4_routes = {}
ipv6_routes = {}

for route in api(cmd="/routing/stats/origin/print"):
    name = route.get("name", "")
    count = route.get("total-route-count", 0)

    if name.startswith("bgp-IP-"):
        ip = name.replace("bgp-IP-", "")
        ipv4_routes[ip] = count
    elif name.startswith("bgp-IP6-"):
        ip6 = name.replace("bgp-IP6-", "")
        ipv6_routes[ip6] = count

# Добавляем информацию о количестве маршрутов для IPv4-пиров
for peer in bgp_peers:
    ip = peer.get("{#IP}")
    peer["{#COUNT_IPV4}"] = ipv4_routes.get(ip, 0)

# Готовим финальный список для discovery
lld_data = bgp_peers

# Добавляем IPv6 маршруты отдельно
for ip6, count in ipv6_routes.items():
    lld_data.append({
        "{#IP6}": ip6,
        "{#COUNT_IPV6}": count
    })

# Выводим в формате LLD
print(json.dumps({"data": lld_data}, ensure_ascii=False, indent=4))
