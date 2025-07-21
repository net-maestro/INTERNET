```
# 🔁 Очистка перед добавлением (опционально, только если вы обновляете правила)
/ip firewall filter remove [find comment~"Winbox brute-force"]
/ip firewall address-list remove [find list="winbox_blacklist"]

# 1️⃣ Добавляем в blacklist при превышении количества одновременных соединений (3+)
/ip firewall filter
add chain=input protocol=tcp dst-port=8291 connection-limit=3,32 \
    action=add-src-to-address-list address-list=winbox_blacklist address-list-timeout=1d \
    comment="Winbox brute-force: too many concurrent connections"

# 2️⃣ Добавляем в blacklist при слишком частых подключениях (>5 соединений в секунду)
/ip firewall filter
add chain=input protocol=tcp dst-port=8291 connection-rate=5,32 \
    action=add-src-to-address-list address-list=winbox_blacklist address-list-timeout=1d \
    comment="Winbox brute-force: too many connections per second"

# 3️⃣ Блокируем доступ к Winbox тем, кто попал в blacklist
/ip firewall filter
add chain=input protocol=tcp dst-port=8291 src-address-list=winbox_blacklist action=drop \
    comment="Drop Winbox brute-force IPs (blacklisted)"
```
