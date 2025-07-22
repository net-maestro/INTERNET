# Cisco Nexus 9372PX-E Aggregation Configuration

> Aggregates two 28-port switches  
> Version: `9.3(5)`  
> Hostname: `NEXUS-AGG-01`

---

## 🔧 Feature Enablement

```bash
feature telnet  
feature ssh  
feature lacp  
feature vpc  
feature lldp  
feature udld  
feature interface-vlan  
no feature cdp
```

---

## 🌲 Spanning Tree Configuration

```bash
spanning-tree mode rapid-pvst  
spanning-tree port type edge bpduguard default  
spanning-tree port type edge bpdufilter default
```

---

## 🔁 MAC Move Detection

```bash
mac address-table notification mac-move  
mac address-table notification threshold 50 interval 10  

event-handler applet MAC_MOVE_ALERT  
  event snmp oid 1.3.6.1.4.1.9.9.500.1.2.1.1.5 get-type exact entry-op ge entry-val 1  
  action 1.0 syslog msg "WARNING: MAC move detected - $_snmp_oid_val"
```

---

## 🧱 VLAN Configuration

```bash
vlan 2      name switch  
vlan 3      name fake  
vlan 13     name 10ap03  
vlan 21     name she21  
vlan 71     name ka9  
vlan 72     name ka1a  
vlan 73     name ka11a  
vlan 91-94  name bar1–bar4  
vlan 110    name 11067  
vlan 111-117 name 10ap1–10ap6, server  
vlan 120-125 name videocam, 10bp1–10bp5  
vlan 131-133 name 10vp1–10vp3  
vlan 141-145 name 10gp1–10gp5  
vlan 151-156 name 10dp1–10d/1  
vlan 161-165 name 14p1–14p5  
vlan 171-179 name 20p1–20p9  
vlan 200    name rip  
vlan 201    name MNG201  
vlan 202    name NAT  
vlan 254    name IBGP-KRIUK  
vlan 255    name IBGP-NAT  
vlan 1001-1003 name pon, pon2, pon3  
vlan 1080   name triolan  
vlan 3337   name ett  
vlan 4022-4023 name kvlua, kvlwr  
vlan 4026   name KVLv6
```

---

## 🌐 Management Interface

```bash
vrf context management  
  ip route 0.0.0.0/0 <Gateway_IP>  

interface mgmt0  
  vrf member management  
  ip address <MGMT_IP>/<MASK>  
  no shutdown
```

---

## 🔐 SSH and Console Settings

```bash
line console  
line vty  
  exec-timeout 30  
  session-limit 32  
  transport input ssh
```

---

## 🤝 vPC Configuration

```bash
vpc domain 1  
  role priority 1000  
  system-priority 4096  
  peer-keepalive destination <PEER_IP> source <LOCAL_IP> vrf management
```

---

## 🔌 Access Ports

```bash
interface Ethernet1/17-18  
  description "ACCESS_DEFAULT"  
  switchport mode access  
  switchport access vlan 1  
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
  spanning-tree bpdufilter enable  
  spanning-tree bpduguard disable  
  spanning-tree port type edge  
  no lldp transmit  
  no lldp receive  
  no shutdown
```

---

## 🌉 Trunk Ports – First Switch (Lill)

```bash
interface Ethernet1/1-10  
  description "TRUNK_FIRST_SWITCH"  
  switchport mode trunk  
  switchport trunk allowed vlan 2,13,21,71-73,91-94,110-112,114-117,121-125,131-133,141-145,151-154,156,161-165,171-179,200-202,254-255,1001-1003,4022-4023,4026  
  spanning-tree bpdufilter enable  
  spanning-tree bpduguard disable  
  spanning-tree port type edge  
  no lldp transmit  
  no lldp receive  
  channel-group 10 mode active  
  no shutdown
```

---

## 🌉 Trunk Ports – Second Switch

```bash
interface Ethernet1/29-38  
  description "TRUNK_SECOND_SWITCH"  
  switchport mode trunk  
  switchport trunk allowed vlan 2-3,13,21,71-73,91-94,110-112,114-117,120-125,131-133,141-145,151-156,161-165,171-179,200-202,254-255,1001-1003,1080,3337,4022-4023,4026  
  spanning-tree bpdufilter enable  
  spanning-tree bpduguard disable  
  spanning-tree port type edge  
  no lldp transmit  
  no lldp receive  
  channel-group 20 mode active  
  no shutdown
```

---

## 🚀 Uplink Ports (QSFP+)

```bash
interface Ethernet1/49-50  
  description "CORE_UPLINK"  
  switchport mode trunk  
  switchport trunk allowed vlan 2-3,13,21,71-73,91-94,110-112,114-117,120-125,131-133,141-145,151-156,161-165,171-179,200-202,254-255,1001-1003,1080,3337,4022-4023,4026  
  spanning-tree bpdufilter enable  
  spanning-tree bpduguard disable  
  spanning-tree port type edge  
  channel-group 1 mode active  
  no shutdown
```

---

## 🔗 Port-Channel Configuration

```bash
interface port-channel1  
  description "UPLINK_TO_CORE"  
  switchport mode trunk  
  switchport trunk allowed vlan 2-3,13,21,71-73,91-94,110-112,114-117,120-125,131-133,141-145,151-156,161-165,171-179,200-202,254-255,1001-1003,1080,3337,4022-4023,4026  
  spanning-tree bpdufilter enable  
  spanning-tree bpduguard disable  
  vpc peer-link  
  no shutdown

interface port-channel10  
  description "FIRST_SWITCH_LAG"  
  switchport mode trunk  
  switchport trunk allowed vlan 2,13,21,71-73,91-94,110-112,114-117,121-125,131-133,141-145,151-154,156,161-165,171-179,200-202,254-255,1001-1003,4022-4023,4026  
  no shutdown

interface port-channel20  
  description "SECOND_SWITCH_LAG"  
  switchport mode trunk  
  switchport trunk allowed vlan 2-3,13,21,71-73,91-94,110-112,114-117,120-125,131-133,141-145,151-156,161-165,171-179,200-202,254-255,1001-1003,1080,3337,4022-4023,4026  
  no shutdown
```

---

> ✅ **Note**: Replace `<MGMT_IP>`, `<MASK>`, `<Gateway_IP>`, `<PEER_IP>`, and `<LOCAL_IP>` with actual IP addresses.
