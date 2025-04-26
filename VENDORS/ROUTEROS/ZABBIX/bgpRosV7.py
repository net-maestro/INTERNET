#!/usr/bin/env python3.10

import os
import re
import json
import sys
from librouteros import connect
from dotenv import load_dotenv

# Загрузка переменных из файла .env
load_dotenv()

# Из .env
user =  os.getenv("API_USER")
senha = os.getenv("API_PASS")
ip = os.getenv("HOST_IP") # IP для управления BGP
porta = os.getenv("API_PORT")

# Из аргументов командной строки
# user = sys.argv[1]
# senha = sys.argv[2]
# ip = sys.argv[3]
# porta = sys.argv[4]

# Подключение
try:
    api = connect(username=user, password=senha, host=ip, port=porta)
except Exception as e:
    print('[]')  # Возвращаем пустой JSON, чтобы Zabbix не упал
    sys.exit(1)

# Функция для разбора времени работы BGP-сессий
def parse_uptime(uptime):
    time_dict = {"w": 7*86400, "d": 86400, "h": 3600, "m": 60, "s": 1}
    uptime_secs = 0
    for k, v in time_dict.items():
        m = re.search(f"(\d+){k}", uptime)
        if m:
            uptime_secs += int(m.group(1)) * v
    return uptime_secs

# Получение BGP-сессий и сохранение нужной информации в список словарей
search_sessions = []
for session in api(cmd="/routing/bgp/session/print"):
    uptime_secs = parse_uptime(session.get("uptime", "0s"))  # Значение по умолчанию "0s", если ключ "uptime" отсутствует
    messages = session.get("remote.messages", 0)  # Значение по умолчанию 0, если ключ "remote.messages" отсутствует
    status = session.get("established", 0)  # Значение по умолчанию 0, если ключ "established" отсутствует
    search_sessions.append({
        "NAME": session["name"],
        "IP": session["remote.address"],
        "AS": session["remote.as"],
        "MESSAGES": messages,
        "UPTIME": uptime_secs,
        "STATUS": int(status)
    })

# Получение маршрутов происхождения и сохранение нужной информации в список словарей
search_routes = []
for route in api(cmd="/routing/stats/origin/print"):
    if "bgp-IP-" in route["name"]:
        search_routes.append({
            "IP": route["name"],
            "COUNT": route["total-route-count"]
        })
    elif "bgp-IP6-" in route["name"]:
        search_routes.append({
            "IP6": route["name"],
            "COUNT": route["total-route-count"]
        })

# Объединение информации о BGP-сессиях и маршрутах в один JSON-объект
discovery_data = search_sessions + search_routes
discovery_json = json.dumps(discovery_data, ensure_ascii=False)
print(discovery_json)
