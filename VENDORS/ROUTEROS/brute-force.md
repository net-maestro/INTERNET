```
# 1️⃣ Добавляем в blacklist при превышении количества одновременных соединений (3+)
/ip firewall filter
add action=add-src-to-address-list address-list=BRUTE_FORCE_BLACKLIST address-list-timeout=2h chain=input comment=\
    "BRUTE_FORCE: MORE THAN 3 CONCURRENT CONNECTIONS" connection-limit=3,32 dst-port=8292 protocol=tcp

# 2️⃣ Блокируем доступ к Winbox тем, кто попал в blacklist
/ip firewall filter
add action=reject chain=input comment="TCP RESET BRUTE_FORCE IPS (BLACKLISTED)" in-interface-list=!LAN protocol=tcp reject-with=\
    tcp-reset src-address-list=BRUTE_FORCE_BLACKLIST
```
