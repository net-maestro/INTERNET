# DHCP, DHCP Relay и Option 82
Этот файл содержит структурированные заметки по DHCP, DHCP Relay и Option 82, включая примеры настройки на MikroTik и D-Link.

## 1. Протокол DHCP (Dynamic Host Configuration Protocol)

### 1.1. Основные принципы работы DHCP

- **Автоматическое получение адресных параметров**: DHCP позволяет автоматически раздавать IP-адреса, сетевые маски, шлюзы по умолчанию, DNS-серверы и другие параметры без необходимости ручной конфигурации.
- **Типы сообщений DHCP**:
  - `DHCPDISCOVER` – клиент ищет доступные DHCP-серверы.
  - `DHCPOFFER` – сервер предлагает клиенту IP-адрес.
  - `DHCPREQUEST` – клиент запрашивает предложенный IP.
  - `DHCPACK` – сервер подтверждает аренду IP-адреса.
  - `DHCPNAK` – сервер отклоняет запрос клиента.
- **Механизм аренды (lease)**: IP-адреса выдаются на ограниченный срок (`lease time`). После истечения срока клиент может запросить продление аренды или новый адрес.
- **SCOPE-диапазоны и пулы адресов**: На DHCP-сервере определяются `SCOPE` (диапазоны адресов) и `options` (дополнительные параметры), которые предоставляются клиентам.

### 1.2. Режимы взаимодействия DHCP

- **DHCP Server** – центральная точка, выдающая конфигурацию (IP, маску, шлюз, DNS и прочее).
- **DHCP Client** – устройство (ПК, телефон, роутер), запрашивающее адресную информацию у сервера.
- **DHCP Relay (агент ретрансляции)** – устройство (маршрутизатор, L3-коммутатор), пересылающее DHCP-запросы от клиентов к серверу в другой подсети.

## 2. DHCP Relay

### 2.1. Назначение DHCP Relay

- **Преодоление границ вещания (Broadcast)**: DHCP-запросы по умолчанию являются широковещательными (broadcast) и не выходят за пределы L3-сегмента. Relay принимает broadcast-запросы и отправляет их как unicast на DHCP-сервер.
- **Централизация**: Позволяет обслуживать несколько VLAN/подсетей одним DHCP-сервером.

### 2.2. Механизм работы DHCP Relay

1. Клиент отправляет `DHCPDISCOVER` (Broadcast).
2. DHCP Relay перехватывает запрос, добавляет `giaddr` (Gateway IP Address) и перенаправляет его как Unicast на DHCP-сервер.
3. DHCP-сервер отправляет ответ обратно на Relay.
4. Relay ретранслирует ответ клиенту (Broadcast/Unicast).

## 3. Option 82 (Relay Agent Information Option)

### 3.1. Назначение Option 82

- **Дополнительная информация о местоположении клиента**: Позволяет указывать, с какого порта, VLAN или устройства пришел запрос.
- **Безопасность и контроль**: Используется для привязки пользователя к порту (Port Security, IP-MAC-Port binding).

### 3.2. Состав Option 82

- **Circuit ID (sub-option 1)** – идентификатор порта коммутатора, VLAN ID или их комбинация.
- **Remote ID (sub-option 2)** – MAC-адрес коммутатора, серийный номер или другой уникальный идентификатор.

### 3.3. Применение и политика обработки

- DHCP Relay добавляет Option 82 к запросу.
- DHCP-сервер может использовать эту информацию для выдачи IP-адресов на основе `Circuit ID`/`Remote ID`.
- Сервер может игнорировать, сохранять или перезаписывать Option 82 в зависимости от настроек.

## 4. Популярные опции DHCP

| Опция  | Назначение | Применение |
|--------|------------------------------|----------------------------------|
| Option 1 | Subnet Mask | Указывает маску подсети |
| Option 3 | Router (Default Gateway) | IP-адрес шлюза по умолчанию |
| Option 6 | DNS Servers | Список DNS-серверов |
| Option 15 | Domain Name | Доменное имя (example.local) |
| Option 42 | NTP Servers | Список NTP-серверов |
| Option 51 | IP Address Lease Time | Время аренды IP (в секундах) |
| Option 53 | DHCP Message Type | Тип DHCP-сообщения |
| Option 54 | DHCP Server Identifier | Адрес DHCP-сервера |
| Option 66 | TFTP Server Name | Адрес TFTP-сервера (PXE, VoIP) |
| Option 67 | Bootfile Name | Имя загружаемого файла (PXE) |
| Option 82 | Relay Agent Information | Информация о порте/VLAN/устройстве |
| Option 121 | Classless Static Routes | Определение статических маршрутов |
| Option 125 | Vendor Specific Info | Данные для определенных вендоров |
| Option 150 | TFTP Server Address | Альтернатива Option 66 (Cisco, VoIP) |

## 5. Краткие рекомендации по настройке

### DHCP Server

- Организовать `SCOPE` для каждой VLAN/подсети.
- Настроить `lease time` в зависимости от потребностей сети.
- Указать основные (`Subnet Mask`, `Gateway`, `DNS`) и дополнительные (`Option 66/67` для PXE) параметры.

### DHCP Relay

- Активировать `ip helper-address` на L3-интерфейсах.
- Указать IP-адрес DHCP-сервера в настройках Relay.
- Контролировать обработку `Option 82`.

### Option 82

- Использовать для идентификации порта и логирования.
- Настроить политику обработки на DHCP-сервере.
- Предотвращать подделку данных клиентами (DHCP Snooping).

### Безопасность DHCP

- Включить **DHCP Snooping** на коммутаторах для защиты от rogue DHCP-серверов.
- Использовать **Dynamic ARP Inspection (DAI)** и **IP Source Guard (IPSG)** для предотвращения атак на уровень 2.

## 6. Пример настройки на MikroTik RouterOS v7.17 и D-Link DES-1228ME (VLAN 100)

### Конфигурация MikroTik:
```shell
/ip dhcp-server
add address-pool=dhcp_pool interface=vlan100 lease-time=12h name=dhcp1
/ip dhcp-server network
add address=192.168.100.0/24 gateway=192.168.100.1
/ip dhcp-relay
add dhcp-server=192.168.1.1 interface=vlan100 name=relay1
```

### Конфигурация D-Link DES-1228ME:
```shell
config vlan 100 add tagged 1-24
config ipif System dhcp relay state enable
config ipif System dhcp relay server ip-address 192.168.1.1
config save
```


