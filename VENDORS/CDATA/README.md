# Конфигурация ACL 3001

## Описание
ACL 3001 настроен для блокировки определенных TCP и UDP портов, связанных с известными уязвимостями и нежелательными сервисами. ACL применяется как для входящего, так и для исходящего трафика на порту `epon 0/0 1`.

## Конфигурация ACL

```plaintext
acl 3001
  acl name ACL3001
  rule 1 deny tcp dest-port 135    # Блокировка Microsoft RPC
  rule 2 deny tcp dest-port 137    # Блокировка NetBIOS Name Service
  rule 3 deny tcp dest-port 138    # Блокировка NetBIOS Datagram Service
  rule 4 deny tcp dest-port 139    # Блокировка NetBIOS Session Service
  rule 5 deny tcp dest-port 445    # Блокировка SMB
  rule 6 deny tcp dest-port 1900   # Блокировка SSDP (UPnP)
  rule 7 deny tcp dest-port 2869   # Блокировка Windows UPnP
  rule 8 deny tcp dest-port 666    # Блокировка потенциального вредоносного трафика
  rule 9 deny udp dest-port 135    # Блокировка Microsoft RPC (UDP)
  rule 10 deny udp dest-port 137   # Блокировка NetBIOS Name Service (UDP)
  rule 11 deny udp dest-port 138   # Блокировка NetBIOS Datagram Service (UDP)
  rule 12 deny udp dest-port 139   # Блокировка NetBIOS Session Service (UDP)
  rule 13 deny udp dest-port 445   # Блокировка SMB (UDP)
  rule 14 deny udp dest-port 1900  # Блокировка SSDP (UDP)
  rule 15 deny tcp dest-port 23    # Блокировка Telnet
  rule 16 permit ip                # Разрешение всего остального трафика
exit
```

## Применение ACL

ACL применяется к порту `epon 0/0 1` в обоих направлениях: входящем и исходящем.

```plaintext
packet-filter inbound 3001 port epon 0/0 1
packet-filter outbound 3001 port epon 0/0 1
```

## Команды проверки

Чтобы проверить, правильно ли применен ACL:
```plaintext
show acl all
```
Чтобы убедиться, что ACL активно фильтрует трафик:
```plaintext
show packet-filter all
```
Чтобы проверить назначения ACL на интерфейсе:
```plaintext
show packet-filter port epon 0/0/1
```

## Заметки
- **Фильтрация входящего трафика**: Блокирует запрещенный трафик от ONU к сети.
- **Фильтрация исходящего трафика**: Блокирует запрещенный трафик от сети к ONU.



