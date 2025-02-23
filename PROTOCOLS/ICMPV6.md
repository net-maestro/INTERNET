# Настройки ICMPv6: Разрешенные и запрещенные сообщения

## 1. Какие ICMPv6 Type можно разрешить?

| **ICMPv6 Type** | **Код** | **Описание** | **Разрешить?** |
|---------------|--------|-------------|---------------|
| **1**  | 0  | Destination Unreachable | ✅ Да |
| **2**  | 0  | Packet Too Big | ✅ Да |
| **3**  | 0-1  | Time Exceeded | ✅ Да |
| **4**  | 0-1  | Parameter Problem | ✅ Да |
| **128** | 0  | Echo Request (`ping`) | ✅ Да, но с лимитом |
| **129** | 0  | Echo Reply (ответ `ping`) | ✅ Да |
| **133** | 0  | Router Solicitation | ✅ Да (если используется SLAAC) |
| **134** | 0  | Router Advertisement | ✅ Да (но только от доверенных маршрутизаторов) |
| **135** | 0  | Neighbor Solicitation | ✅ Да (для ARP-аналога) |
| **136** | 0  | Neighbor Advertisement | ✅ Да |

## 2. Какие ICMPv6 Type лучше заблокировать?

| **ICMPv6 Type** | **Код** | **Описание** | **Почему блокировать?** |
|---------------|--------|-------------|--------------------------|
| **128** | 0  | Echo Request (`ping`) | Ограничить, чтобы избежать `Ping Flood` |
| **130-132** | 0  | Multicast Listener Discovery (MLD) | Может использоваться для DDoS-атак |
| **137** | 0  | Redirect | Может использоваться для MITM-атак |
| **141-147** | 0  | Мобильные IPv6 сообщения | Не используются в большинстве сетей |

## 3. Как защититься с помощью фаервола?

### ✅ Разрешить полезные ICMPv6 сообщения
```bash
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=1:0 action=accept  # Destination Unreachable
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=2:0 action=accept  # Packet Too Big
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=3 action=accept  # Time Exceeded
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=4 action=accept  # Parameter Problem
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=129:0 action=accept  # Echo Reply
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=133:0 action=accept  # Router Solicitation
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=134:0 action=accept  # Router Advertisement
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=135:0 action=accept  # Neighbor Solicitation
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=136:0 action=accept  # Neighbor Advertisement
```

### ❌ Блокировать нежелательные ICMPv6
```bash
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=137:0 action=drop  # Redirect
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=130-132 action=drop  # Multicast Listener Discovery
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=141-147 action=drop  # Мобильные IPv6 сообщения
```

### ⚠️ Ограничить `ping` (Echo Request)
```bash
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=128:0 limit=5,10 action=accept
/ipv6 firewall filter add chain=input protocol=icmpv6 icmp-options=128:0 action=drop
```

## 4. Вывод
1. **Оставляем** `Destination Unreachable`, `Packet Too Big`, `Time Exceeded`, `Parameter Problem`, `Neighbor Solicitation/Advertisement`, но с ограничением `ping`.
2. **Блокируем** `Redirect`, `MLD`, `Mobile IPv6`.
3. **Ограничиваем `ping`** (ICMPv6 Type 128) по скорости, чтобы избежать `Ping Flood`.

Этот набор правил обеспечит баланс между функциональностью и безопасностью! 🚀
