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
```
## Пример конфигурации дефолтного Cisco CoPP profile

```cisco
! ---------- Jumbo Frames ----------
policy-map type network-qos jumbo
  class type network-qos class-default
    mtu 9216

system qos
  service-policy type network-qos jumbo


! ---------- Control Plane Policing ----------
! ACL matching for different protocols
class-map type control-plane match-any copp-icmp
  match access-group name copp-system-acl-icmp

class-map type control-plane match-any copp-ntp
  match access-group name copp-system-acl-ntp

class-map type control-plane match-any copp-snmp
  match access-group name copp-system-acl-snmp

class-map type control-plane match-any copp-ssh
  match access-group name copp-system-acl-ssh

class-map type control-plane match-any copp-telnet
  match access-group name copp-system-acl-telnet

class-map type control-plane match-any copp-tacacsradius
  match access-group name copp-system-acl-tacacsradius

class-map type control-plane match-any copp-stftp
  match access-group name copp-system-acl-stftp

class-map type control-plane match-any copp-s-arp
class-map type control-plane match-any copp-s-bfd
class-map type control-plane match-any copp-s-bpdu
class-map type control-plane match-any copp-s-dai
class-map type control-plane match-any copp-s-dhcpreq
class-map type control-plane match-any copp-s-dhcpresp
  match access-group name copp-system-dhcp-relay
class-map type control-plane match-any copp-s-eigrp
  match access-group name copp-system-acl-eigrp
  match access-group name copp-system-acl-eigrp6
class-map type control-plane match-any copp-s-glean
class-map type control-plane match-any copp-s-igmp
  match access-group name copp-system-acl-igmp
class-map type control-plane match-any copp-s-ipmcmiss
class-map type control-plane match-any copp-s-l2switched
class-map type control-plane match-any copp-s-l3destmiss
class-map type control-plane match-any copp-s-l3mtufail
class-map type control-plane match-any copp-s-l3slowpath
class-map type control-plane match-any copp-s-mpls
class-map type control-plane match-any copp-s-pimautorp
class-map type control-plane match-any copp-s-pimreg
  match access-group name copp-system-acl-pimreg
class-map type control-plane match-any copp-s-ping
  match access-group name copp-system-acl-ping
class-map type control-plane match-any copp-s-ptp
class-map type control-plane match-any copp-s-routingProto1
  match access-group name copp-system-acl-routingproto1
  match access-group name copp-system-acl-v6routingproto1
class-map type control-plane match-any copp-s-routingProto2
  match access-group name copp-system-acl-routingproto2
class-map type control-plane match-any copp-s-v6routingProto2
  match access-group name copp-system-acl-v6routingProto2
class-map type control-plane match-any copp-s-selfIp
class-map type control-plane match-any copp-s-ttl1
class-map type control-plane match-any copp-s-vxlan
class-map type control-plane match-any copp-s-dpss


! ---------- Policy-map for CoPP ----------
policy-map type control-plane copp-system-policy
  class copp-s-default        police pps 400
  class copp-s-l2switched     police pps 200
  class copp-s-ping           police pps 100
  class copp-s-l3destmiss     police pps 100
  class copp-s-glean          police pps 500
  class copp-s-selfIp         police pps 500
  class copp-s-l3mtufail      police pps 100
  class copp-s-ttl1           police pps 100
  class copp-s-ipmcmiss       police pps 400
  class copp-s-l3slowpath     police pps 100
  class copp-s-dhcpreq        police pps 300
  class copp-s-dhcpresp       police pps 300
  class copp-s-dai            police pps 300
  class copp-s-igmp           police pps 400
  class copp-s-eigrp          police pps 200
  class copp-s-pimreg         police pps 200
  class copp-s-pimautorp      police pps 200
  class copp-s-routingProto2  police pps 1300
  class copp-s-v6routingProto2 police pps 1300
  class copp-s-routingProto1  police pps 1000
  class copp-s-arp            police pps 200
  class copp-s-ptp            police pps 1000
  class copp-s-vxlan          police pps 1000
  class copp-s-bfd            police pps 350
  class copp-s-bpdu           police pps 12000
  class copp-s-dpss           police pps 1000
  class copp-s-mpls           police pps 100
  class copp-icmp             police pps 200
  class copp-telnet           police pps 500
  class copp-ssh              police pps 500
  class copp-snmp             police pps 500
  class copp-ntp              police pps 100
  class copp-tacacsradius     police pps 400
  class copp-stftp            police pps 400


! ---------- Apply policy ----------
control-plane
  service-policy input copp-system-policy
```
