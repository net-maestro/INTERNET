```! =============================================
! 1. Информация о версии и hostname
! =============================================
version 9.3(12)            ! Версия NX-OS
hostname N9K-CORE-AGG-01   ! Имя коммутатора

! =============================================
! 2. QoS / Jumbo Frames
! =============================================
policy-map type network-qos JUMBO
  class type network-qos class-default
    mtu 9216

! =============================================
! 3. VDC (Virtual Device Context) лимиты
! =============================================
vdc N9K-CORE-AGG-01 id 1
  limit-resource vlan minimum 16 maximum 4094
  limit-resource vrf minimum 2 maximum 4096
  limit-resource port-channel minimum 0 maximum 256
  limit-resource u4route-mem minimum 248 maximum 248
  limit-resource u6route-mem minimum 96 maximum 96
  limit-resource m4route-mem minimum 58 maximum 58
  limit-resource m6route-mem minimum 8 maximum 8


! =============================================
! 4. Включенные функции
! =============================================
feature telnet
feature bash-shell
feature interface-vlan
feature lacp
clock timezone UTC 3 0


! =============================================
! 5. Логирование
! =============================================
logging level l2fm 5
logging level lacp 5
logging level vlan_mgr 5
logging level clis 6


! =============================================
! 6. Пользователи и banner
! =============================================
no password strength-check
username admin password 5 $5$MKKPJB$  role network-admin

banner motd #
     __o           WELCOME TO HAPPYLINK CORE AGG-01
   _ \<_            Authorized Admins Only
  (_)>(_)
...
EMERGENCY CONTACT
   Email         : noc@happylink.net
#


! =============================================
! 7. Безопасность и errdisable recovery
! =============================================
no ip domain-lookup
errdisable recovery interval 90
errdisable recovery cause link-flap
errdisable recovery cause bpduguard
errdisable recovery cause loopback
errdisable recovery cause storm-control
errdisable recovery cause security-violation
errdisable recovery cause failed-port-state


! =============================================
! 8. ACLs 
! =============================================
####ACL для управления коммутатором. Разрешает доступ только с определенных подсетей/хостов, все остальное блокирует.
ip access-list ALLOW_MANAGE_NETWORK
  10 permit tcp 172.16.1.0 0.0.0.255 any eq 22
  20 permit tcp 172.16.1.0 0.0.0.255 any eq telnet
  30 permit udp 172.16.17.0 0.0.0.255 any eq snmp
  ...
  200 permit ip any any


####Фильтр для клиентов, блокирует опасные порты и протоколы. Практика хранения — хорошая.
ip access-list CLIENT-IN-FILTER
  10 deny tcp any any eq ftp
  20 deny tcp any any eq 22
  30 deny tcp any any eq telnet
  ...
  200 permit ip any any


####ACL для CoPP (Control Plane Policing) — ограничивает трафик на процессор, предотвращает DDoS/ICMP flood. Хранить — да, полезно для восстановления.
ip access-list COPP-ACL-ICMP
  10 permit icmp any any
ip access-list COPP-ACL-SNMP
  10 permit udp any any eq snmp
  20 permit udp any any eq snmptrap



! =============================================
! 9. Control Plane Policing
! =============================================
class-map type control-plane match-any COOP-CLASS-ICMP
  match access-group name COPP-ACL-ICMP
class-map type control-plane match-any COOP-CLASS-SNMP
  match access-group name COPP-ACL-SNMP

policy-map type control-plane COOP-POLICY
  class COOP-CLASS-SNMP
    police cir 2000 pps bc 16 packets conform transmit violate drop
  class COOP-CLASS-ICMP
    police cir 1000 pps bc 16 packets conform transmit violate drop

control-plane
  service-policy input COOP-POLICY


```
