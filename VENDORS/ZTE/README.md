## Добавление ACL для защиты от NetBIOS и вредоносного трафика

Для защиты от NetBIOS (портов 137-139) и других видов вредоносного трафика, включая популярные порты для атак (например, SMB - порт 445), можно использовать следующую ACL:

```shell
acl hybrid number 300
  rule 1 deny udp any eq 137 any any ingress any egress any
  rule 2 deny udp any eq 138 any any ingress any egress any
  rule 3 deny udp any eq 139 any any ingress any egress any
  rule 4 deny tcp any eq 137 any any ingress any egress any
  rule 5 deny tcp any eq 138 any any ingress any egress any
  rule 6 deny tcp any eq 139 any any ingress any egress any
  rule 7 deny tcp any eq 445 any any ingress any egress any
  rule 8 deny udp any eq 135 any any ingress any egress any
  rule 9 deny tcp any eq 135 any any ingress any egress any
  rule 10 deny tcp any eq 445 any any ingress any egress any
  rule 11 deny udp any eq bootps any any ingress any egress any # BOOTP Server (порт 67 UDP) используется DHCP-сервером для раздачи IP-адресов.
  rule 12 deny udp any eq bootpc any any ingress any egress any # BOOTP Client (порт 68 UDP) используется DHCP-клиентом для получения адреса от DHCP-сервера.
  rule 13 deny udp any eq 1900 any any ingress any egress any  ! (SSDP)
  rule 14 deny udp any eq 161 any any ingress any egress any  ! (SNMP)
  rule 15 deny tcp any eq 1080 any any ingress any egress any  ! (SOCKS proxy)
  rule 16 deny tcp any eq 3127 any any ingress any egress any  ! (Backdoor port)
  rule 17 deny tcp any eq telnet any any ingress any egress any
  rule 100 permit any any any any ingress any egress any  ! Default rule to allow traffic
```

### Применение ACL

После того как ACL добавлены, примените их к соответствующим интерфейсам:

###ACL на ону :
```shell
> configure terminal
(config)# interface gpon-onu_1/1/3:1
(config-if)# max-mac-learn 4
(config-if)# ip access-group 300 in
(config-if)# ip access-group 300 out
```

Это ограничит распространение NetBIOS трафика и других потенциально вредоносных пакетов, таких как трафик на порты 445, 135 и 139, которые часто используются для атак.

# Какой ACL использовать?

| Тип ACL      | Фильтрует по                      | Когда использовать?                        |
|-------------|----------------------------------|--------------------------------------------|
| **Standard**  | Только IP-источник              | Простая фильтрация IP                     |
| **Extended**  | IP-источник, IP-назначение, порты | Блокировка сервисов (SSH, DHCP, HTTP)     |
| **Hybrid**    | IP, MAC, VLAN                   | Гибкая настройка безопасности             |
| **Link Layer** | Только MAC-адреса               | Контроль доступа по MAC                   |


## Дополнительные рекомендации

- **Обновление SNMP**: Настройте SNMP для мониторинга устройства, но ограничьте доступ только из доверенных IP-адресов.
- **Логи**: Убедитесь, что на устройстве настроены логи для всех важных событий безопасности, чтобы быстро реагировать на подозрительные активности.

Эти изменения помогут улучшить безопасность сети, уменьшить возможности для атак и повысить производительность устройства.

