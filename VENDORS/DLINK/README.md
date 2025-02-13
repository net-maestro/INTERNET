# Описание ACL правил для коммутатора доступа

## Общая информация
Данные ACL предназначены для фильтрации нежелательного трафика на **пользовательских портах** (1-28), исключая **uplink/trunk порты**. Это помогает защитить клиентов от потенциально вредоносного или нежелательного сетевого трафика.

## Блокировка TCP трафика (Profile ID 1)

| Access ID | Порт TCP  | Назначение порта | Действие |
|-----------|----------|----------------|----------|
| 1  | 135  | Microsoft RPC  | Deny |
| 2  | 139  | NetBIOS Session  | Deny |
| 3  | 369  | LDAP | Deny |
| 4  | 445  | Microsoft SMB  | Deny |
| 5  | 593  | HTTP RPC | Deny |
| 6  | 2869 | UPnP SSDP | Deny |
| 7  | 5000 | UPnP | Deny |
| 8  | 3380 | RDP | Deny |
| 9  | 3382 | RDP (альтернативный) | Deny |
| 10 | 69   | TFTP | Deny |
| 11 | 42   | WINS | Deny |
| 12 | 137  | NetBIOS Name Service | Deny |
| 13 | 138  | NetBIOS Datagram Service | Deny |
| 14 | 1042 | Networked Media Streaming | Deny |
| 15 | 1034 | Networked Media Streaming | Deny |
| 16 | 2869 | UPnP SSDP (дублируется) | Deny |
| 17 | 4444 | Blaster Worm | Deny |
| 18 | 3587 | Web Services Discovery | Deny |
| 19 | 5357 | Web Services on Devices | Deny |
| 20 | 5358 | Web Services on Devices | Deny |
| 21 | 79   | Finger Protocol | Deny |
| 22 | 113  | Ident Protocol | Deny |
| 23 | 119  | NNTP (Usenet) | Deny |
| 24 | 555  | Back Orifice | Deny |
| 25 | 666  | Doom Trojan | Deny |
| 26 | 1001 | Backdoor | Deny |
| 27 | 1002 | Backdoor | Deny |
| 28 | 1243 | SubSeven Trojan | Deny |

## Блокировка UDP трафика (Profile ID 2)

| Access ID | Порт UDP | Назначение порта | Действие |
|-----------|---------|----------------|----------|
| 41 | 137  | NetBIOS Name Service | Deny |
| 42 | 138  | NetBIOS Datagram Service | Deny |
| 43 | 1900 | SSDP (UPnP) | Deny |
| 44 | 42   | WINS | Deny |
| 45 | 69   | TFTP | Deny |
| 46 | 139  | NetBIOS Session | Deny |
| 47 | 2869 | UPnP SSDP | Deny |
| 48 | 65037 | Вредоносный трафик (возможный ботнет) | Deny |
| 49 | 56330 | Вредоносный трафик (сканирование) | Deny |
| 50 | 80   | HTTP (для UDP) | Deny |
| 51 | 3540 | Teredo (IPv6 туннелирование) | Deny |
| 52 | 3702 | Web Services Discovery | Deny |
| 53 | 5355 | LLMNR (могут использовать злоумышленники) | Deny |
| 54 | 67   | DHCP (ограничение на портах клиентов) | Deny |

## Примечания
- ACL **не применяется к trunk/uplink портам** (обычно 49-50 или другие, соединяющие коммутаторы).
- Эти правила **блокируют нежелательный трафик от клиентов**, снижая риск атак и сетевых проблем.
- Убедитесь, что ACL **не блокирует важные сервисы**, такие как DHCP, DNS, VPN, PPPoE (если они нужны).

