```shell
! Создание VLAN'ов
vlan 2
  name SWITCH2
vlan 133
  name USERS-NAT-133
vlan 200
  name USERS-EXT-200
exit

! Включение DHCP Snooping
ip dhcp snooping
ip dhcp snooping vlan 133,200
ip dhcp snooping information option

! Включение Loop Detection
loopdetect enable
loopdetect interval 5
loopdetect recovery-time 30

! Глобальные настройки Storm Control
storm-control broadcast rate 100
storm-control multicast rate 100
storm-control unicast rate 100

! Настройка интерфейсов UPLINK (транк)
interface range gigabitEthernet 1/0/25-26
  description *** UPLINK to Core Switch ***
  switchport mode trunk
  switchport trunk allowed vlan 2,133,200
  ip dhcp snooping trust
  spanning-tree portfast trunk
  storm-control broadcast rate 100
  storm-control multicast rate 100
  storm-control unicast rate 100
exit

! Конфигурация клиентских интерфейсов (access VLAN 133)
interface range gigabitEthernet 1/0/1-24
  description *** Customer Access ***
  switchport mode access
  switchport access vlan 133
  ip verify source
  switchport port-security
  switchport port-security maximum 2
  switchport port-security violation restrict
  switchport port-security mac-address sticky
  spanning-tree bpduguard enable
  loopdetect enable
  storm-control broadcast rate 100
  storm-control multicast rate 100
  storm-control unicast rate 100
exit

! Настройка устаревания MAC-адресов
switchport port-security aging time 2
switchport port-security aging type inactivity

! Отключение неиспользуемых портов
interface range gigabitEthernet 1/0/27-28
  description *** Disabled ports ***
  shutdown
exit

! Безопасность управления
service password-encryption
username admin password 0 StrongAdminPass123

! Сохранение конфигурации
copy running-config startup-config
```
