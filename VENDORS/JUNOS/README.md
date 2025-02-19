# JunosRR — Заметки для работы

## 1. SHOW команды

### Просмотр настроек:
```sh
show configuration
```

### Проверка состояния системы:
```sh
show system uptime
```

### Перезагрузка устройства:
```sh
reboot
```

### Просмотр памяти и ресурсов:
```sh
show system memory
```

### Конфигурация в SET виде без JSON:
```sh
run show configuration | display set
run show configuration | display set | match bgp
```

## Работа с интерфейсами

### Просмотр интерфейсов:
```sh
show interfaces terse
```

### Просмотр состояния интерфейса:
```sh
show interfaces <interface-name>
```

### Просмотр VLAN:
```sh
show vlans
```

## Таблица маршрутов (Routing Table)

### Просмотр таблицы маршрутов:
```sh
show route
```

### Просмотр маршрутов по конкретному протоколу:
```sh
show route protocol bgp
```

## Проверка работы NAT

```sh
show security nat source rule all
show security flow session | match 10.1.33.1
```

### Проверка состояния BGP:
```sh
show bgp summary
```

### Просмотр BGP маршрутов:
```sh
show route protocol bgp
```

## Проверка назначенных фильтров BGP в Junos

## Просмотр назначенных import/export политик для BGP
```sh
show configuration protocols bgp | display set | match "policy|import|export"
```

## Проверка применяемых фильтров для конкретного соседа
```sh
show bgp neighbor <IP-адрес> | match "Import|Export"
```

## Просмотр содержимого политики фильтрации
```sh
show policy | match "<policy-name>"
```

## Просмотр всех настроенных политик фильтрации
```sh
show configuration policy-options
```

## Проверка получаемых маршрутов от конкретного соседа
```sh
show route receive-protocol bgp <IP-адрес>
```

## Проверка рекламируемых маршрутов конкретному соседу
```sh
show route advertising-protocol bgp <IP-адрес>
```


## Проверка настроек DHCP в Junos

## Просмотр текущей конфигурации DHCP
```sh
show configuration system services dhcp
```

## Проверка состояния DHCP-сервера
```sh
show system services dhcp binding
```

## Просмотр активных DHCP-аренд
```sh
show dhcp server binding
```

## Проверка полученных DHCP-запросов
```sh
show dhcp relay statistics
```

## Просмотр переданных DHCP-запросов
```sh
show dhcp relay binding
```

## Проверка статуса DHCP-клиента
```sh
show dhcp client binding
```

## Просмотр информации о подписчиках
```sh
show subscribers
```

## Расширенная информация о подписчиках
```sh
show subscribers extensive
```

## Просмотр подписчиков по DHCP
```sh
show subscribers dhcp
```

## Проверка подписчиков на определённом интерфейсе
```sh
show subscribers interface <interface-name>
```





---

## 2. SET команды

### Настройка интерфейса (например, для VLAN):
```sh
set interfaces <interface-name> unit 0 family ethernet-switching vlan members <vlan-id>
commit
```

### Настройка VLAN

#### Создание VLAN:
```sh
set vlans <vlan-name> vlan-id <vlan-id>
commit
```

#### Привязка интерфейса к VLAN:
```sh
set interfaces <interface-name> unit 0 family ethernet-switching vlan members <vlan-id>
commit
```

### Добавление статического маршрута:
```sh
set routing-options static route <destination> next-hop <next-hop>
commit
```

### Настройка BGP:
```sh
set routing-options autonomous-system <AS-number>
set protocols bgp group <group-name> type external
set protocols bgp group <group-name> peer-as <peer-AS-number>
set protocols bgp group <group-name> neighbor <peer-IP>
commit
```

### Настройка SNMP:
```sh
set snmp community <community-name> authorization read-only
set snmp contact <contact-info>
set snmp location <location-info>
commit
```

### Настройка SSH:
```sh
set system services ssh
commit
```

### Настройка Syslog:
```sh
set system syslog host <syslog-server-ip> any any
commit
```

---

## 3. DELETE команды

### Удаление интерфейса:
```sh
delete interfaces <interface-name>
commit
```

### Удаление статического маршрута:
```sh
delete routing-options static route <destination>
commit
```

---

## 4. Commit и Uncommit (откат изменений)

### Выполнение commit:
```sh
commit
```

### Просмотр списка изменений:
```sh
show system commit
```

### Откат последнего commit:
```sh
rollback 1
commit
```

### Откат на конкретный commit:
```sh
rollback <commit-number>
commit
```

