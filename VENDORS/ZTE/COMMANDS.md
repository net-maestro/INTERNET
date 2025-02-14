##show processor
##show card
##show patch-running
##show ip dhcp snooping database 
##show version-running  slotno 1
##show version-running
##show version-running
## show onu-type gpon
https://www.scribd.com/document/449050498/How-to-update-ONT-from-ZTE-C320

pon
onu-profile gpon line 5mb
fec upstream
tcont 3 name T-INET profile UP-5mb
gemport 2 name G-INET unicast tcont 3 dir both
gemport 2 traffic-limit downstream DOWN-5mb
gemport 3 name MNG unicast tcont 3 dir both
gemport 3 traffic-limit downstream DOWN-5mb




###ACL на ону :
ZXAN#configure terminal
ZXAN(config)# interface gpon-onu_1/1/3:1
ZXAN(config-if)# max-mac-learn 4
ZXAN(config-if)# ip access-group 300 in
ZXAN(config-if)# ip access-group 300 out

