## 📌 Общие фильтры

### 🎯 Фильтрация по IP-адресу

```wireshark
ip.addr == 192.168.1.1         # Любой пакет, содержащий указанный IP
ip.src == 192.168.1.1          # Пакеты от источника с этим IP
ip.dst == 192.168.1.1          # Пакеты, направленные к этому IP
ip.addr == 192.168.1.0/24      # Все пакеты в указанной подсети
ip.addr == 192.168.1.10 and tcp    # Трафик TCP от/до конкретного IP

🧬 Фильтрация по MAC-адресу
eth.addr == 00:11:22:33:44:55

⚙️ Комбинированные фильтры
(ip.src == 192.168.1.1 and tcp.port == 80) or (ip.dst == 192.168.1.1 and tcp.port == 443)

📡 Протоколы
dns
http
tls
bootp
arp
not arp     # Исключить ARP
icmp
tcp
udp

🤝 TLS
tls.handshake
tls.handshake.certificate

🔢 Фильтрация по портам
tcp.port == 443
udp.port == 53
tcp.port >= 1000 and tcp.port <= 2000


🧾 Анализ флагов и состояний TCP
tcp.flags.reset == 1               # TCP Reset флаг
tcp.analysis.duplicate_ack        # Дубликаты ACK (признак проблем с сетью)

📦 Размер фрейма
frame.len > 1500                  # Jumbo Frames или фрагментированные пакеты


🌐 Хосты HTTP
http.host == "example.com"


⏱️ Временные фильтры
frame.time_relative <= 10         # Пакеты в первые 10 секунд захвата

```
