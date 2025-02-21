# MikroTik Firewall Filter Rules (Правила файрвола)

## IPv4 Firewall Rules (Правила для IPv4)

#### Сами правила

# Оптимизация трафика в MikroTik с FastTrack

## Описание правила

```bash
/ip firewall filter
add action=fasttrack-connection chain=forward connection-state=established,related hw-offload=yes
add action=passthrough chain=forward comment="COUNT DNS QUERY" disabled=yes dst-port=53 protocol=udp
add action=accept chain=input comment="INPUT (established,related) ACCEPT" connection-state=established,related
add action=drop chain=input comment="INPUT (invalid) DROP" connection-state=invalid
add action=accept chain=forward comment="FORWARD (established,related) ACCEPT" connection-state=established,related
add action=drop chain=forward comment="FORWARD (invalid) DROP" connection-state=invalid
add action=accept chain=input comment="INPUT ALLOW ICMP( limit=300/10s,50:packet)" limit=300/10s,50:packet protocol=icmp
add action=drop chain=input comment="INPUT DROP ICMP FLOOD" protocol=icmp
add action=drop chain=input comment="INPUT DNS DROP" dst-port=53 protocol=udp
add action=add-src-to-address-list address-list=temporary_blocked_ips address-list-timeout=2h chain=input comment="INPUT ADD LIST (temporary_blocked_ips) SCAN PORTS" dst-port=22,23,53,80,2000,8292 protocol=tcp src-address-list=!allowed_ips
add action=accept chain=input comment="INPUT ACCEPT IPs" src-address-list=allow_ips
add action=reject chain=input comment="INPUT BLOCK IPs" protocol=tcp reject-with=tcp-reset src-address-list=temporary_blocked_ips
```

## Разбор параметров FastTrack

- **action=fasttrack-connection** – включает FastTrack для определённых соединений, ускоряя их обработку.
- **chain=forward** – правило применяется к транзитному трафику (трафик, проходящий через маршрутизатор).
- **connection-state=established,related**:
  - **established** – уже установленное соединение.
  - **related** – соединение, связанное с установленным (например, вторичные подключения FTP, ICMP-ответы).
- **hw-offload=yes** – если оборудование поддерживает аппаратное ускорение, пакеты будут обрабатываться на уровне железа (ASIC/чип).

## Преимущества

- **Снижение нагрузки на CPU** – пакеты проходят быстрее, минуя часть обработки на процессоре.
- **Увеличение пропускной способности** – полезно для гигабитных и выше соединений.
- **Оптимизация трафика** – ускоренная передача пакетов без задержек.

## Ограничения и предупреждения

Перед включением FastTrack необходимо учитывать:

- **Не совместим с очередями (Queue)** – FastTrack обходит QoS и ограничение скорости.
- **Не работает с IPsec** – пакеты, использующие FastTrack, могут игнорировать политики шифрования.
- **Может конфликтовать с правилами Mangle** – если используется маркировка трафика, FastTrack её обходит.

## Вывод

FastTrack – мощный инструмент для ускорения работы маршрутизатора MikroTik, но перед его включением стоит убедиться, что он не нарушает вашу политику управления трафиком.



### 1. Forward Chain (Цепочка FORWARD)

#### COUNT DNS QUERY *(Отключено)*
- **Действие**: passthrough (пропуск)
- **Цепочка**: forward (пересылаемый трафик)
- **Комментарий**: Подсчёт DNS-запросов
- **Порт назначения**: 53
- **Протокол**: UDP
- **Статус**: Отключено
- **Назначение**: Данное правило не блокирует или разрешает трафик, а только подсчитывает количество DNS-запросов.

### 2. Input Chain (Цепочка INPUT)

#### INPUT (established,related) ACCEPT *(Разрешение установленных соединений)*
- **Действие**: accept (разрешить)
- **Состояние соединения**: established, related
- **Назначение**: Разрешает пакеты, относящиеся к уже установленным или связанным соединениям.

#### INPUT (invalid) DROP *(Блокировка недопустимых пакетов)*
- **Действие**: drop (отбросить)
- **Состояние соединения**: invalid
- **Назначение**: Блокирует пакеты с некорректным состоянием, что помогает защитить сеть от атак и некорректного трафика.

#### INPUT ALLOW ICMP *(Ограниченный доступ для ICMP)*
- **Действие**: accept (разрешить)
- **Протокол**: ICMP
- **Ограничение**: 300 пакетов за 10 секунд, burst 50 пакетов
- **Назначение**: Разрешает ICMP-запросы (например, `ping`), но с ограничением на частоту. **Burst** означает, что в момент пикового трафика сначала разрешается до 50 пакетов, а затем действует ограничение 300 пакетов за 10 секунд.

#### INPUT DROP ICMP FLOOD *(Блокировка ICMP-флуда)*
- **Действие**: drop (отбросить)
- **Протокол**: ICMP
- **Назначение**: Блокирует ICMP-трафик, если он превышает допустимый лимит (анти-DDoS защита).

#### INPUT DNS DROP *(Блокировка DNS-запросов к роутеру)*
- **Действие**: drop (отбросить)
- **Порт назначения**: 53
- **Протокол**: UDP
- **Назначение**: Блокирует входящие DNS-запросы, что предотвращает использование роутера в DNS-атаках.

#### INPUT ADD LIST (temporary_blocked_ips) SCAN PORTS *(Блокировка IP-адресов за сканирование портов)*
- **Действие**: add-src-to-address-list (добавить источник в список)
- **Список**: temporary_blocked_ips (время блокировки: 2 часа)
- **Порты назначения**: 22, 23, 53, 80, 2000, 8292
- **Протокол**: TCP
- **Список источников**: Исключены `allowed_ips`
- **Назначение**: Добавляет IP-адреса, сканирующие определённые порты, в список временно заблокированных.

#### INPUT ACCEPT IPs *(Разрешённые IP-адреса)*
- **Действие**: accept (разрешить)
- **Список источников**: allow_ips
- **Назначение**: Разрешает трафик от доверенных IP-адресов.

#### INPUT BLOCK IPs *(Блокировка IP-адресов из списка)*
- **Действие**: reject (отклонить)
- **Протокол**: TCP
- **Метод отклонения**: TCP Reset
- **Список источников**: temporary_blocked_ips
- **Назначение**: Отклоняет соединения от временно заблокированных IP с возвратом TCP Reset.

---

## IPv6 Firewall Rules (Правила для IPv6)
- **Тоже самое но с большими лимитами на ICMPV6 так как IPV6 зависим от ICMP**

#### Сами правила

```bash
/ipv6 firewall filter
add action=fasttrack-connection chain=forward connection-state=established,related hw-offload=yes
add action=passthrough chain=forward comment="COUNT DNS QUERY v6" disabled=yes dst-port=53 protocol=udp
add action=accept chain=input comment="INPUT (established,related) ACCEPT" connection-state=established,related
add action=drop chain=input comment="INPUT (invalid) DROP" connection-state=invalid
add action=accept chain=forward comment="FORWARD (established,related) ACCEPT" connection-state=established,related
add action=drop chain=forward comment="FORWARD (invalid) DROP" connection-state=invalid
add action=accept chain=input comment="INPUT ALLOW ICMPv6 (limit=1000/10s,100:packet)" limit=1k/10s,100:packet protocol=icmpv6
add action=drop chain=input comment="INPUT DROP ICMPv6 FLOOD" protocol=icmpv6
add action=drop chain=input comment="INPUT DNS DROP v6" dst-port=53 protocol=udp
add action=add-src-to-address-list address-list=temporary_blocked_ips_v6 address-list-timeout=2h chain=input comment="INPUT ADD LIST (temporary_blocked_ips_v6) SCAN PORTS" dst-port=22,23,53,80,2000,8292 protocol=tcp src-address-list=!allow_ips_v6
add action=accept chain=input comment="INPUT ACCEPT allow_ips_v6" src-address-list=allow_ips_v6
add action=reject chain=input comment="INPUT BLOCK IPs v6" protocol=tcp reject-with=tcp-reset src-address-list=temporary_blocked_ips_v6
```



### Для IPv6 стоит действовать ещё аккуратнее. 
### Многие ключевые функции (автоматическая настройка адресов, определение соседей, Router Advertisement и др.) завязаны на ICMPv6. 
### Если слишком жёстко «закрутить гайки», вы рискуете отрезать абонентам IPv6. Поэтому, как минимум, нужно:

- **Разрешить Neighbor Discovery трафик (типы 135, 136), Router Solicitation (133), Router Advertisement (134), а иногда и Redirect (137), если используется.**

- **Если вы решите применять лимит на весь ICMPv6, желательно отдельными правилами оставить без лимита (или с более мягкими лимитами) те типы ICMPv6, которые критичны для работы IPv6:**
```bash
# Примерно так:
/ipv6 firewall filter
add chain=input protocol=icmpv6 icmp-options=135:0-255 action=accept comment="Accept ND (Neighbor Solicitation)"
add chain=input protocol=icmpv6 icmp-options=136:0-255 action=accept comment="Accept ND (Neighbor Advertisement)"
add chain=input protocol=icmpv6 icmp-options=133:0-255 action=accept comment="Accept Router Solicitation"
add chain=input protocol=icmpv6 icmp-options=134:0-255 action=accept comment="Accept Router Advertisement"
# и т.д.

# А уже потом — общее правило на лимит
add chain=input protocol=icmpv6 limit=1000/5s,100 action=accept comment="Allow other ICMPv6 with limit"
add chain=input protocol=icmpv6 action=drop comment="Drop the rest (flood)"
```
---

## Вывод
Данные правила обеспечивают безопасность сети за счёт фильтрации трафика, предотвращения DDoS-атак и защиты от сканирования портов. Ограничения на ICMP помогают избежать перегрузки сети, а временная блокировка подозрительных IP-адресов снижает риск атак.

