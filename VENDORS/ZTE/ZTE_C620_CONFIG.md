```
                ! show version-running
! 
! %Error 140303: Invalid input detected at '^' marker.
! show patch-running
! 
! %Error 140303: Invalid input detected at '^' marker.
!<mim>
!configuration has not been saved since system starting
!configuration was loaded by txt that saved at 16:43:13 Thu Nov 6 2025
!last configuration change at 20:37:10 Mon Nov 17 2025 by NULL
!</mim>
!<system-config>
hostname ZTE
banner incoming #
Support: noc@golden.net.ua
 Commands:
   show:
   - show pon onu uncfg
   - show gpon onu state
   - show gpon onu baseinfo gpon_olt-1/1/1
   - show gpon onu detail-info gpon_onu-1/1/1:1
   - show gpon onu by sn CDTC1DFFB038
   - show gpon onu distance gpon_onu-1/1/1:1
   - show gpon remote-onu interface pon gpon_onu-1/1/1:1
   - show gpon remote-onu equip gpon_onu-1/1/1:1
   - show gpon remote-onu capability gpon_onu-1/1/1:1
   - show gpon remote-onu service gpon_onu-1/1/1:1
   - show gpon remote-onu mac gpon_onu-1/1/1:1 ethuni eth_0/1
   - show gpon remote-onu dhcp-ip ethuni gpon_onu-1/1/1:1
   - show running-config-interface gpon_olt-1/1/1
   - show running-config-interface gpon_onu-1/1/1:1
   - show running-config-interface vport-1/1/1.1:1
   - show interface gpon_olt-1/1/X
   - show running-config xpon
   - show running-config msan
   - show running-config snmp
   - show running-config alarm
   - show loopback-detection slot 1
   - show ip dhcp snooping dynamic database
   - show security port-protect
#
!</system-config>
!<if-intf>
interface gpon_olt-1/1/1
$
interface gpon_olt-1/1/2
$
interface gpon_olt-1/1/3
$
interface gpon_olt-1/1/4
$
interface gpon_olt-1/1/5
$
interface gpon_olt-1/1/6
$
interface gpon_olt-1/1/7
$
interface gpon_olt-1/1/8
$
interface gpon_olt-1/1/9
$
interface gpon_olt-1/1/10
$
interface gpon_olt-1/1/11
$
interface gpon_olt-1/1/12
$
interface gpon_olt-1/1/13
$
interface gpon_olt-1/1/14
$
interface gpon_olt-1/1/15
$
interface gpon_olt-1/1/16
$
interface gpon_onu-1/1/1:1
$
interface vport-1/1/1.1:1
$
interface xgei-1/4/1
  description Uplink
  no shutdown
$
interface xgei-1/4/2
$
interface xgei-1/4/3
$
interface xgei-1/4/4
$
interface xgei-1/5/1
$
interface xgei-1/5/2
$
interface xgei-1/5/3
$
interface xgei-1/5/4
$
interface mgmt_eth
  ip address 172.17.13.100 255.255.0.0
$
interface vlan360
$
interface vlan502
  ip address 10.1.2.3 255.255.255.0
$
interface null1
$
!</if-intf>
!<clock-mgr>
clock timezone KIEV 3
!</clock-mgr>
!<system-user>
login block 900 attempts 30 within 120
login on-failure alarm
system-user
  authorization-template 1
    bind aaa-authorization-template 2001
    local-privilege-level 15
  $
  authentication-template 1
    bind aaa-authentication-template 2001
  $
  global-user-aging day 90
  user-authen-restriction fail-time 10 lock-minute 15
  user-name service
    bind authentication-template 1
    bind authorization-template 1
    password encrypted *21*Cd9FBNz0tjJfcP3wUqcjfVKnI31SpyN9UqcjffPT8eVs3oJf4twUS
EnvYlmNAbXJqa3a2xEbSY7NWT9jfjIKtZzxfbErkSS6HjSRFdwzmXP9lRWsquH9TSPAQ9TUgprMGTJ7c
ew9AdE+v57z
  $
  user-name zte
    once-password
    bind authentication-template 1
    bind authorization-template 1
    password encrypted *21*Cd9FBNz0tjJfcP3wGK1oIRitaCEYrWghGK1oIWgEhNYkFvy7mdWXv
oUGtPahwEXyqkRJ2W4fEbAyTxUOOjfdyIFSQWzMVKencKo3w3j6h5q9GSxPdPxzBrZbfFf02OCFdTP+u
5OQpzPFn82l
  $
  strong-username min-len 3
  strong-password length 8 character-set-num 3
  strong-password date-check enable
  strong-password username-related-chk substring inverse
  strong-password check disable
$
!</system-user>
!<ntp>
ntp enable
ntp server 10.1.2.1 priority 1
!</ntp>
!<aaa>
aaa-authentication-template 2001
  aaa-authentication-type local
$
aaa-authorization-template 2001
  aaa-authorization-type local
$
!</aaa>
!<stp>
spantree
$
!</stp>
!<ssh>
ssh server enable
!</ssh>
!<xpon>
pon
  onu-type XGPONONU gpon description XGPONONU speed-mode xg-pon
  onu-type F601 gpon description F601 speed-mode gpon
  onu-type-if XGPONONU eth_0/1
  onu-type-if F601 eth_0/1
  onu-profile gpon service vlan360
    type PROFILE-DEFAULT
    vlan port eth_0/1 mode tag vlan 360
  $
  onu-profile gpon service vlan311
    type PROFILE-DEFAULT
    vlan port eth_0/1 mode tag vlan 311
  $
$
interface gpon_olt-1/1/1
  onu 1 type F601 sn FHTT6A9B7700
  fiber-distance 0 200
  uncfg-onu-aging-time 30
$
interface gpon_onu-1/1/1:1
  name ********
  description ********
  fec enable
  tcont 1 profile T500M
  gemport 1 tcont 1
$
gpon
  profile tcont T100M type 4 maximum 95000
  profile tcont T1000M type 4 maximum 990000
  profile tcont T2500M type 4 maximum 2400000
  profile tcont T5000M type 4 maximum 9900000
  profile tcont T500M type 4 maximum 600000
$
wdm-pon
  group profile Default channel-num 20 channel-space 100 up-base-freq 191300 dow
n-base-freq 194100
$
pon-onu-mng gpon_onu-1/1/1:1
  loop-detect ethuni eth_0/1 enable
  service vlan311 gemport 1 vlan 311
  vlan port eth_0/1 mode tag vlan 311
$
!</xpon>
!<alarm>
logging file default almlog
  accept on
$
logging file default cmdlog
  buffer 1000
$
logging file default netclog
  accept on
$
logging file default snmplog
  accept on
$
logging file default srvlog
  accept on
  interval 10
$
logging file default weblog
  accept on
$
logging snmp
  accept on
  match cmdlog
$
!</alarm>
!<snmp>
snmp-server community encrypted *31*RNZdUtVWwH0DwdHkGmYSMhpmEjIaZhIyGmYSMqvXYv2q
Bl3JaaQ4tKNvsOvR1MLTx4fAfLuBZnnwSlKBT1p3TBOUoqobCClcVUblDQ== view AllView rw 
snmp-server enable inform system
snmp-server version v2c enable
!</snmp>
!<static>
ip route 0.0.0.0 0.0.0.0 10.1.2.1
!</static>
!<MSAN>
ecmp-mode srcip-dstip
vgw-bypass mode normal
add-card rackno 1 shelfno 1 slotno 1 GFBN
interface gpon_olt-1/1/1
  no shutdown
$
interface vport-1/1/1.1:1
  service-port 1 user-vlan 311 vlan 311 egress 500M
  security max-mac-learn 4
  security vlan-stormcontrol unknowncast vlan 311 rate 20
  security vlan-stormcontrol multicast vlan 311 rate 30
  security vlan-stormcontrol broadcast vlan 311 rate 150
  ip access-group 300 in
$
interface xgei-1/4/1
  switchport mode trunk
  switchport vlan 311-314,360,502 tag
  switchport vlan 1098,1676 tag
  loopback-detection disable
  loopback-detect active-detect enable
  
$
interface xgei-1/4/2
  switchport mode trunk
$
interface xgei-1/4/3
  switchport mode trunk
$
interface xgei-1/4/4
  switchport mode trunk
$
interface xgei-1/5/1
  switchport mode trunk
$
interface xgei-1/5/2
  switchport mode trunk
$
interface xgei-1/5/3
  switchport mode trunk
$
interface xgei-1/5/4
  switchport mode trunk
$
acl number 300
  name CLIENT-IN-FILTER-300
  rule 10 deny tcp any any eq 135 ipv4
  rule 20 deny tcp any any eq 137 ipv4
  rule 30 deny udp any any eq 137 ipv4
  rule 40 deny tcp any any eq 138 ipv4
  rule 50 deny udp any any eq 138 ipv4
  rule 60 deny tcp any any eq 139 ipv4
  rule 70 deny tcp any any eq 445 ipv4
  rule 200 permit any any any any
$
loopback-detection enable
loopback-detection active-detect disable
tpid outer 0x8100,0x88a8 inner 0x8100
vlan list 1,311-314,360,502
vlan list 1098,1676
$
vlan 311
  name lvivskiy311
$
vlan 312
  name lvivskiy312
$
vlan 313
  name lvivskiy313
$
vlan 314
  name lvivskiy314
$
vlan 360
  name BorExt360
$
vlan 502
  name GOLDENNET
$
vlan 1098
  name tr_simnet1098
$
vlan 1676
  name tr_simnet1676
$
vlan 1
$
ip dhcp snooping enable
ip dhcp snooping vlan 311
ip dhcp snooping vlan 360
ip dhcp snooping vlan 312
ip dhcp snooping vlan 313
ip dhcp snooping vlan 314
traffic-profile 100M cir 95000 cbs 65535 pir 95000 pbs 65535 color-mode blind po
licer-type enhanced_mef coupling-flag enable
traffic-profile 1000M cir 990000 cbs 114688 pir 990000 pbs 114688 color-mode bli
nd policer-type enhanced_mef coupling-flag enable
traffic-profile 2500M cir 2400000 cbs 122880 pir 2400000 pbs 122880 color-mode b
lind policer-type enhanced_mef coupling-flag enable
traffic-profile 5000M cir 9900000 cbs 131072 pir 9900000 pbs 131072 color-mode b
lind policer-type enhanced_mef coupling-flag enable
traffic-profile 500M cir 550000 cbs 98304 pir 550000 pbs 98304 color-mode blind 
policer-type enhanced_mef coupling-flag enable
qos queue-number 8
quick-ping enable
eth-switch max-frame-length 2000
discard-packet-mode disable
!</MSAN>

```
