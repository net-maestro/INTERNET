# Control Plane Policing (CoPP) на Cisco Nexus 9000

## Общая логика
- CoPP (Control Plane Policing) защищает **Control Plane** (CPU) от перегрузки.  
- ACL внутри policy-map задаёт, какой трафик нужно **разрешить и ограничить**.  
- Всё, что **не попало в ACL**, по умолчанию попадает в **class-default**.  
- В `class-default` трафик не дропается, а **разрешается** (если не задан `drop`).  

---

## Пример конфигурации

```cisco
! Создаём ACL для ICMP
ip access-list COPP-ACL-ICMP
  10 permit icmp any any
  ! остальные протоколы сюда не попадают → значит, идут в class-default

! ACL для SNMP
ip access-list COPP-ACL-SNMP
  10 permit udp any any eq snmp
  20 permit udp any any eq snmptrap

! Создаём class-map для ICMP
class-map type control-plane match-any COOP-CLASS-ICMP
  match access-group name COPP-ACL-ICMP

! Class-map для SNMP
class-map type control-plane match-any COOP-CLASS-SNMP
  match access-group name COPP-ACL-SNMP

! Политика CoPP
policy-map type control-plane COOP-POLICY
  class COOP-CLASS-SNMP
    police cir 2000 pps bc 16 packets conform transmit violate drop
    ! SNMP ограничен до 2000 пакетов/сек
  class COOP-CLASS-ICMP
    police cir 1000 pps bc 16 packets conform transmit violate drop
    ! ICMP ограничен до 1000 пакетов/сек
  class class-default
    ! ВАЖНО: всё остальное сюда попадает и разрешается по умолчанию
    ! Если нужно дропать неизвестный трафик → явно указать "drop"
    ! Например:
    ! police cir 0 conform drop violate drop

! Применение политики к Control Plane
control-plane
  service-policy input COOP-POLICY
