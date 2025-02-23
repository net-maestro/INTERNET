# Защита от ICMP-атак

ICMP (Internet Control Message Protocol) играет важную роль в диагностике сети, но может быть использован в атаках. Чтобы защитить сеть от ICMP-флуда, необходимо разрешить полезные ICMP-сообщения и заблокировать потенциально опасные.

## Разрешенные и запрещенные ICMP-типы

### Разрешенные ICMP-типы

| **ICMP Type** | **Код** | **Описание** | **Причина разрешения** |
|--------------|--------|-------------|--------------------------|
| **0**  | 0  | Echo Reply | Необходим для `ping` |
| **3**  | 0-15  | Destination Unreachable | Позволяет уведомлять об ошибках маршрутизации |
| **8**  | 0  | Echo Request | Разрешен, но с ограничением по скорости |
| **11** | 0-1  | Time Exceeded | Необходим для `traceroute` |
| **12** | 0-2  | Parameter Problem | Помогает выявлять ошибки заголовков |

### Запрещенные ICMP-типы

| **ICMP Type** | **Код** | **Описание** | **Причина блокировки** |
|--------------|--------|-------------|--------------------------|
| **3**  | 4  | Fragmentation Needed | Может использоваться для атак на MTU |
| **4**  | 0  | Source Quench | Устарел, может применяться в DoS-атаках |
| **5**  | 0-3  | Redirect | Может использоваться в MITM-атаках |
| **9,10** | 0  | Router Advertisement/Solicitation | Уязвимость в динамической маршрутизации |
| **13,14** | 0  | Timestamp Request/Reply | Позволяет злоумышленникам анализировать сеть |
| **17,18** | 0  | Address Mask Request/Reply | Может использоваться для разведки сети |

---

## Настройка фаервола в MikroTik (RouterOS)

### Разрешение безопасных ICMP-сообщений
```bash
/ip firewall filter add chain=input protocol=icmp icmp-options=0:0 action=accept
/ip firewall filter add chain=input protocol=icmp icmp-options=3 action=accept
/ip firewall filter add chain=input protocol=icmp icmp-options=11 action=accept
/ip firewall filter add chain=input protocol=icmp icmp-options=12 action=accept
```

### Блокировка нежелательных ICMP-сообщений
```bash
/ip firewall filter add chain=input protocol=icmp icmp-options=3:4 action=drop
/ip firewall filter add chain=input protocol=icmp icmp-options=5 action=drop
/ip firewall filter add chain=input protocol=icmp icmp-options=9 action=drop
/ip firewall filter add chain=input protocol=icmp icmp-options=13 action=drop
/ip firewall filter add chain=input protocol=icmp icmp-options=17 action=drop
```

### Ограничение ICMP Echo Request (`ping`)
```bash
/ip firewall filter add chain=input protocol=icmp icmp-options=8:0 limit=5,10 action=accept
/ip firewall filter add chain=input protocol=icmp icmp-options=8:0 action=drop
```

---

## Вывод
1. **Оставляем** ICMP-сообщения, необходимые для диагностики сети (`Echo Reply`, `Destination Unreachable`, `Time Exceeded`).
2. **Блокируем** опасные типы (`Redirect`, `Timestamp Request`, `Address Mask Request`).
3. **Ограничиваем `ping`**, чтобы избежать `Ping Flood`.

Такой подход поможет сохранить работоспособность сети и защитить её от атак!

