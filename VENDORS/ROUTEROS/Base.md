## Настройка MikroTik RouterOS для интернет-провайдера (5000 абонентов)

## 1. Обработка трафика с использованием Connection Tracking

Используем Connection Tracking для отслеживания состояния соединений (Established, Related, Invalid). Это повышает безопасность и эффективность маршрутизации.

```shell
/ip firewall filter
add chain=input action=accept connection-state=established,related log=no
add chain=input action=drop connection-state=invalid log=no
add chain=forward action=accept connection-state=established,related log=no
add chain=forward action=drop connection-state=invalid log=no
```

## 2. Ограничение ICMP-трафика

Разрешаем ICMP-трафик, но с ограничением по количеству пакетов в секунду, чтобы избежать злоупотреблений (например, ICMP-флуд).

```shell
/ip firewall filter
add chain=input action=accept protocol=icmp in-interface-list=<WAN_Interface> limit=50/5s,2:packet log=no
```

## 3. Масштабируемость и управление трафиком

### Ограничение скорости (Rate Limiting)
Настроим ограничение скорости на интерфейсах или для отдельных абонентов с использованием Queues.

### Очереди (Queues)
Используем очереди для управления пропускной способностью.

### Фильтрация по MAC-адресам
Настроим фильтрацию по MAC-адресам для предотвращения спуфинга.

### Логирование
Включаем логирование для критически важных правил.

## 4. Оптимизация для большого числа абонентов

### FastTrack
Включаем FastTrack для ускорения обработки трафика.

```shell
/ip firewall filter
add chain=forward action=fasttrack-connection connection-state=established,related
```

### Увеличение размера таблицы соединений

```shell
/ip firewall connection/tracking set enabled=yes table-size=65536
```

## 5. Безопасность

### Защита от DDoS
Настраиваем правила для защиты от DDoS-атак.

### Фильтрация по гео-IP
Используем списки IP-адресов для блокировки трафика из подозрительных регионов.

### Ограничение доступа к управлению маршрутизатором

```shell
/ip firewall filter
add action=accept chain=input src-address-list=allow_ips comment="Разрешенные IP для управления"
add action=reject chain=input protocol=tcp reject-with=tcp-reset src-address-list=temporary_blocked_ips comment="Блокировка временно заблокированных IP"
```

## 6. Мониторинг и управление

### SNMP
Настраиваем SNMP для мониторинга состояния маршрутизатора.

### Логирование DNS-запросов

```shell
/ip firewall filter
add action=passthrough chain=forward comment="Подсчет DNS-запросов" dst-port=53 protocol=udp
```

### Ограничение ICMP-запросов

```shell
/ip firewall filter
add action=add-src-to-address-list address-list=allowed_ips address-list-timeout=10m chain=input comment="Добавление в список разрешенных, если 5 ICMP-пакетов с размером 8328" limit=5,5:packet packet-size=8328 protocol=icmp
add action=accept chain=input comment="Разрешение ICMP размером 8328" icmp-options=8:0 packet-size=8328 protocol=icmp
add action=drop chain=input comment="Блокировка ICMP-запросов от неразрешенных IP" protocol=icmp src-address-list=!allowed_ips
```

### Защита от сканирования портов

```shell
/ip firewall filter
add action=add-src-to-address-list address-list=temporary_blocked_ips address-list-timeout=2h chain=input comment="Добавление в блок-лист при попытке сканирования портов" dst-port=22,23,53,80,2000,8292 protocol=tcp src-address-list=!allowed_ips
```

### Фильтрация DNS-запросов

```shell
/ip firewall filter
add action=drop chain=input comment="Блокировка DNS-запросов" dst-port=53 protocol=udp
```
