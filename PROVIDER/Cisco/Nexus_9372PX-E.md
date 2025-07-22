! Cisco Nexus 9372PX-E Configuration
! Aggregates two 28-port switches with Nexus 3064 enhancements
! Version: 9.3(10)

hostname NEXUS-AGG-01

! --- Feature Enablement ---
feature telnet
feature ssh
feature lacp
feature vpc
feature lldp
feature udld
feature interface-vlan
feature sflow
feature scheduler
no feature cdp

! --- System Settings ---
clock timezone UTC 3 0
banner motd #Nexus 9372PX-E Aggregation Switch#
ip domain-lookup
service unsupported-transceiver
port-channel load-balance src-dst-ip

! --- Spanning Tree Configuration ---
spanning-tree mode rapid-pvst
spanning-tree port type edge bpduguard default
spanning-tree port type edge bpdufilter default
spanning-tree loopguard default

! --- Error Recovery ---
errdisable recovery interval 90
errdisable recovery cause link-flap
errdisable recovery cause bpduguard
errdisable recovery cause loopback
errdisable recovery cause storm-control
errdisable recovery cause security-violation

! --- MAC Move Detection ---
mac address-table notification mac-move
mac address-table notification threshold 50 interval 10
event-handler applet MAC_MOVE_ALERT
  event snmp oid 1.3.6.1.4.1.9.9.500.1.2.1.1.5 get-type exact entry-op ge entry-val 1
  action 1.0 syslog msg "WARNING: MAC move detected - $_snmp_oid_val"

! --- ACLs for Security ---
ip access-list manage
  10 permit ip 10.2.1.0/24 any
  20 permit ip 192.168.48.0/30 any
  30 permit ip 192.168.88.0/24 any
  100 deny ip any any log
ip access-list ACL-IPV4-SNMPv2
  10 permit udp 192.168.48.1/32 any eq snmp log
  20 permit udp 192.168.48.61/32 any eq snmp log
  100 deny ip any any log

! --- QoS for Jumbo Frames ---
policy-map type network-qos jumbo
  class type network-qos class-default
    mtu 9216
system qos
  service-policy type network-qos jumbo

! --- CoPP for Control Plane Protection ---
class-map type control-plane match-any copp-s-default
class-map type control-plane match-any copp-s-ping
  match access-group name copp-system-acl-ping
class-map type control-plane match-any copp-ssh
  match access-group name copp-system-acl-ssh
class-map type control-plane match-any copp-snmp
  match access-group name copp-system-acl-snmp
policy-map type control-plane copp-system-policy
  class copp-s-default
    police pps 400
  class copp-s-ping
    police pps 100
  class copp-ssh
    police pps 500
  class copp-snmp
    police pps 500
control-plane
  service-policy input copp-system-policy

! --- SNMP and RMON ---
snmp-server contact admin@example.com
snmp-server location Your_Location
snmp-server community public use-ipv4acl ACL-IPV4-SNMPv2
snmp-server enable traps bridge newroot
snmp-server enable traps bridge topologychange
snmp-server enable traps stpx inconsistency
snmp-server enable traps stpx root-inconsistency
snmp-server enable traps stpx loop-inconsistency
rmon event 1 log trap public description FATAL(1) owner PMON@FATAL
rmon event 2 log trap public description CRITICAL(2) owner PMON@CRITICAL
rmon event 3 log trap public description ERROR(3) owner PMON@ERROR
rmon event 4 log trap public description WARNING(4) owner PMON@WARNING
rmon event 5 log trap public description INFORMATION(5) owner PMON@INFO
ntp server <NTP_SERVER_IP> use-vrf management
ntp logging

! --- Scheduler for Backup ---
scheduler job name BACKUP-CFG
  copy running-config tftp://<TFTP_SERVER_IP>/Nexus9372PX-E/$(SWITCHNAME)-$(TIMESTAMP).cfg
end-job
scheduler schedule name DAILY
  job name BACKUP-CFG
  time start 2025:07:22:23:00 repeat 0:24:0

! --- VLAN Configuration (from previous config) ---
vlan 2
  name switch
vlan 3
  name fake
vlan 13
  name 10ap03
vlan 21
  name she21
vlan 71
  name ka9
vlan 72
  name ka1a
vlan 73
  name ka11a
vlan 91
  name bar1
vlan 92
  name bar2
vlan 93
  name bar3
vlan 94
  name bar4
vlan 110
  name 11067
vlan 111
  name 10ap1
vlan 112
  name 10ap2
vlan 114
  name 10ap4
vlan 115
  name 10ap5
vlan 116
  name 10ap6
vlan 117
  name server
vlan 120
  name videocam
vlan 121
  name 10bp1
vlan 122
  name 10bp2
vlan 123
  name 10bp3
vlan 124
  name 10bp4
vlan 125
  name 10bp5
vlan 131
  name 10vp1
vlan 132
  name 10vp2
vlan 133
  name 10vp3
vlan 141
  name 10gp1
vlan 142
  name 10gp2
vlan 143
  name 10gp3
vlan 144
  name 10gp4
vlan 145
  name 10gp5
vlan 151
  name 10dp1
vlan 152
  name 10dp2
vlan 153
  name 10dp3
vlan 154
  name 10dp4
vlan 155
  name 10dp5
vlan 156
  name 10d/1
vlan 161
  name 14p1
vlan 162
  name 14p2
vlan 163
  name 14p3
vlan 164
  name 14p4
vlan 165
  name 14p5
vlan 171
  name 20p1
vlan 172
  name 20p2
vlan 173
  name 20p3
vlan 174
  name 20p4
vlan 175
  name 20p5
vlan 176
  name 20p6
vlan 177
  name 20p7
vlan 178
  name 20p8
vlan 179
  name 20p9
vlan 200
  name rip
vlan 201
  name MNG201
vlan 202
  name NAT
vlan 254
  name IBGP-KRIUK
vlan 255
  name IBGP-NAT
vlan 1001
  name pon
vlan 1002
  name pon2
vlan 1003
  name pon3
vlan 1080
  name triolan
vlan 3337
  name ett
vlan 3926
  name Transport_Radionet_Ukrtel
vlan 4022
  name kvlua
vlan 4023
  name kvlwr
vlan 4026
  name KVLv6

! --- Management Interface ---
vrf context management
  ip route 0.0.0.0/0 <Gateway_IP>
interface mgmt0
  vrf member management
  ip address <MGMT_IP>/<MASK>
  no shutdown

! --- SSH and Console Settings ---
line console
line vty
  access-class manage in
  exec-timeout 30
  session-limit 32
  transport input ssh

! --- vPC Configuration ---
vpc domain 1
  role priority 1000
  system-priority 4096
  peer-keepalive destination <PEER_IP> source <LOCAL_IP> vrf management

! --- Access Ports ---
interface Ethernet1/17-18
  description "ACCESS_DEFAULT"
  switchport mode access
  switchport access vlan 1
  switchport block multicast
  spanning-tree bpdufilter enable
  spanning-tree bpduguard disable
  spanning-tree port type edge
  no lldp transmit
  no lldp receive
  no shutdown

interface Ethernet1/22
  description "ACCESS_RIP"
  switchport mode access
  switchport access vlan 200
  switchport block multicast
  spanning-tree bpdufilter enable
  spanning-tree bpduguard disable
  spanning-tree port type edge
  no lldp transmit
  no lldp receive
  no shutdown

! --- Trunk Ports (First Switch) ---
interface Ethernet1/1-10
  description "TRUNK_FIRST_SWITCH"
  switchport mode trunk
  switchport trunk allowed vlan 2,13,21,71-73,91-94,110-112,114-117,121-125,131-133,141-145,151-154,156,161-165,171-179,200-202,254-255,1001-1003,4022-4023,4026
  switchport block multicast
  spanning-tree bpdufilter enable
  spanning-tree bpduguard disable
  spanning-tree port type edge
  no lldp transmit
  no lldp receive
  channel-group 10 mode active
  no shutdown

! --- Trunk Ports (Second Switch) ---
interface Ethernet1/29-38
  description "TRUNK_SECOND_SWITCH"
  switchport mode trunk
  switchport trunk allowed vlan 2-3,13,21,71-73,91-94,110-112,114-117,120-125,131-133,141-145,151-156,161-165,171-179,200-202,254-255,1001-1003,1080,3337,4022-4023,4026
  switchport block multicast
  spanning-tree bpdufilter enable
  spanning-tree bpduguard disable
  spanning-tree port type edge
  no lldp transmit
  no lldp receive
  channel-group 20 mode active
  no shutdown

! --- Uplink Ports (QSFP+) ---
interface Ethernet1/49-50
  description "CORE_UPLINK"
  switchport mode trunk
  switchport trunk allowed vlan 2-3,13,21,71-73,91-94,110-112,114-117,120-125,131-133,141-145,151-156,161-165,171-179,200-202,254-255,1001-1003,1080,3337,3926,4022-4023,4026
  switchport block multicast
  spanning-tree bpdufilter enable
  spanning-tree bpduguard disable
  spanning-tree port type edge
  channel-group 1 mode active
  no shutdown

! --- Port-Channel Configurations ---
interface port-channel1
  description "UPLINK_TO_CORE"
  switchport mode trunk
  switchport trunk allowed vlan 2-3,13,21,71-73,91-94,110-112,114-117,120-125,131-133,141-145,151-156,161-165,171-179,200-202,254-255,1001-1003,1080,3337,3926,4022-4023,4026
  switchport block multicast
  spanning-tree bpdufilter enable
  spanning-tree bpduguard disable
  vpc peer-link
  no shutdown

interface port-channel10
  description "FIRST_SWITCH_LAG"
  switchport mode trunk
  switchport trunk allowed vlan 2,13,21,71-73,91-94,110-112,114-117,121-125,131-133,141-145,151-154,156,161-165,171-179,200-202,254-255,1001-1003,4022-4023,4026
  switchport block multicast
  no shutdown

interface port-channel20
  description "SECOND_SWITCH_LAG"
  switchport mode trunk
  switchport trunk allowed vlan 2-3,13,21,71-73,91-94,110-112,114-117,120-125,131-133,141-145,151-156,161-165,171-179,200-202,254-255,1001-1003,1080,3337,4022-4023,4026
  switchport block multicast
  no shutdown
