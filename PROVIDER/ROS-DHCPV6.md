# Конфигурация раздачи IPv6 по DHCPv6 на R1 и SLAAC на R2
#### R1 --->  R2
---

## R1

```bash
/ipv6 address
add address=2a0f:8fc2:3:1::2 advertise=no interface=wg-core-happylink
add address=2a0f:8fc2:3:100:1::1 advertise=no interface=bridge

/ipv6 pool
add name=internet prefix=2a0f:8fc2:3:180::/60 prefix-length=60

/ipv6 nd
set [ find default=yes ] disabled=yes
add advertise-dns=no interface=bridge managed-address-configuration=yes

/ipv6 dhcp-server option
add code=23 name=DNS1 value="'2606:4700:4700::1111'"
add code=23 name=DNS2 value="'2001:4860:4860::8844'"
add code=23 name=DNS3 value="'2606:4700:4700::1111'"

/ipv6 dhcp-server
add dhcp-option=DNS1,DNS2,DNS3 interface=bridge lease-time=2h name=bridge prefix-pool=internet use-reconfigure=yes


## R2
/ipv6 address
add address=::/60 advertise=no from-pool=internet interface=bridge

/ipv6 nd
set [ find default=yes ] disabled=yes
add advertise-dns=no interface=bridge other-configuration=yes

/ipv6 dhcp-server option
add code=23 name=DNS value="'2606:4700:4700::1111'"

/ipv6 dhcp-server
add address-pool=internet dhcp-option=DNS interface=bridge lease-time=1h name=server1

```
