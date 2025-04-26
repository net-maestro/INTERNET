import os
import re
import json
import sys
from librouteros import connect

from dotenv import load_dotenv

# Загрузка переменных из .env файла
load_dotenv()

'''
# Passar sys.argv[] para produção no Zabbix
user = sys.argv[1]
senha = sys.argv[2]
ip = sys.argv[3]
porta = sys.argv[4]

'''


# Configurações de conexão
user =  os.getenv("API_USER")
password = os.getenv("API_PASS")
ip = os.getenv("HOST_IP") # IP de Gerencia do BGP
port = os.getenv("API_PORT")

# Conecta ao dispositivo
api = connect(username=user, password=password, host=ip, port=port)

# Função para analisar o tempo de atividade das sessões BGP
def parse_uptime(uptime):
    time_dict = {"w": 7*86400, "d": 86400, "h": 3600, "m": 60, "s": 1}
    uptime_secs = 0
    for k, v in time_dict.items():
        m = re.search(f"(\d+){k}", uptime)
        if m:
            uptime_secs += int(m.group(1)) * v
    return uptime_secs

# Consulta as sessões BGP e armazena as informações relevantes em uma lista de dicionários
search_sessions = []
for session in api(cmd="/routing/bgp/session/print"):
    uptime_secs = parse_uptime(session.get("uptime", "0s"))  # Valor padrão "0s" para chave "uptime" ausente
    messages = session.get("remote.messages", 0)  # Valor padrão 0 para chave "remote.messages" ausente
    status = session.get("established", 0) # Valor padrão 0 para chave "established" ausente
    search_sessions.append({
        "NAME": session["name"],
        "IP": session["remote.address"],
        "AS": session["remote.as"],
        "MESSAGES": messages,
        "UPTIME": uptime_secs,
        "STATUS": int(status)
    })

# Consulta as rotas de origem e armazena as informações relevantes em uma lista de dicionários
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

# Combina as informações das sessões BGP e das rotas de origem em um objeto JSON
discovery_data = search_sessions + search_routes
discovery_json = json.dumps(discovery_data, ensure_ascii=False)
print(discovery_json)
