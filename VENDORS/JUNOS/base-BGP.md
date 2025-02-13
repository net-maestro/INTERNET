```shell
#run show configuration | display set
#run show configuration | display set | match bgp
```

# Удаляем существующую конфигурацию перед настройкой устройства

```shell
delete system
delete interfaces
delete routing-options
delete protocols
delete security
delete policy-options
delete forwarding-options
```
## Указываем имя устройства и доменное имя

```shell
set system host-name JUN-SRX-NG  # Устанавливаем имя устройства
set system domain-name example.com  # Указываем доменное имя устройства
set system root-authentication encrypted-password admin  # Устанавливаем зашифрованный пароль для root

set system login user <имя_пользователя> class super-user authentication plain-text-password
```

## Настройки часового пояса

```shell
set system time-zone Europe/Kiev  # Устанавливаем часовой пояс
```
## Включаем SSH

```shell
set system services ssh  # Разрешаем доступ по SSH
```
## Настройка интерфейсов

```shell
set interfaces ge-0/0/0 unit 0 family inet address 172.16.17.250/24  # Интерфейс для связи с провайдером (WAN)
set interfaces ge-0/0/1 unit 0 family inet address 10.1.33.1/30  # Интерфейс для подключения к BGP-соседу
```
## Назначение интерфейсов в зоны безопасности

```shell
set security zones security-zone internal interfaces ge-0/0/1.0  # Интерфейс ge-0/0/1.0 относится к внутренней (локальной) зоне
set security zones security-zone external interfaces ge-0/0/0.0  # Интерфейс ge-0/0/0.0 относится к внешней (интернет) зоне
```
## разршаем ходить трафику

### разрешаем весь трафик с нутри в во вне

```shell
set security policies from-zone internal to-zone external policy ALLOW-INTERNET match source-address any
set security policies from-zone internal to-zone external policy ALLOW-INTERNET match destination-address any
set security policies from-zone internal to-zone external policy ALLOW-INTERNET match application any
set security policies from-zone internal to-zone external policy ALLOW-INTERNET then permit
commit
```
### разрешаем весь трафик из вне во внутрь

```shell
set security policies from-zone external to-zone internal policy ALLOW-INTERNAL match source-address any
set security policies from-zone external to-zone internal policy ALLOW-INTERNAL match destination-address any
set security policies from-zone external to-zone internal policy ALLOW-INTERNAL match application any
set security policies from-zone external to-zone internal policy ALLOW-INTERNAL then permit
commit
```
 
### разрешаем сервис ping с зоны безопасности internal и  external (по умолчанию запрещен)

```shell
set security zones security-zone internal host-inbound-traffic system-services ping
set security zones security-zone external host-inbound-traffic system-services ping
```
### разрешаем сервис ssh с зоны безопасности  external (по умолчанию запрещен)

```shell
set security zones security-zone external host-inbound-traffic system-services ssh
```


## NAT (если требуется интернет-доступ для локальной сети)


```shell
set security nat source rule-set NAT-RULES from zone internal  # Определяем зону "internal"
set security nat source rule-set NAT-RULES to zone external  # Определяем зону "external"
set security nat source rule-set NAT-RULES rule INTERNET match source-address 10.1.33.0/30  # Разрешаем NAT для подсети 10.1.33.0/30
set security nat source rule-set NAT-RULES rule INTERNET then source-nat interface  # Выполняем NAT на интерфейс
```
## Настройки SNMP для мониторинга устройства

```shell
set snmp location servena-1  # Указываем местоположение устройства
set snmp contact "noc@happylink.net.ua"  # Указываем контактную информацию
set snmp community public  # Устанавливаем SNMP community (небезопасно, рекомендуется изменить)
```
## Определение списка допустимых префиксов

```shell
set policy-options prefix-list ALLOWED-NETWORK 146.120.101.0/24  # Добавляем подсеть 146.120.101.0/24 в список ALLOWED-NETWORK
set policy-options prefix-list ALLOWED-NETWORK 193.176.2.0/24  # Добавляем подсеть 193.176.2.0/24 в список ALLOWED-NETWORK
```
## Политики маршрутизации

```shell
set policy-options policy-statement EXPORT-DEFAULT term 1 from protocol static  # Определяем экспорт статических маршрутов
set policy-options policy-statement EXPORT-DEFAULT term 1 then accept  # Разрешаем экспорт статических маршрутов
set policy-options policy-statement IMPORT-NETWORK term 1 from protocol bgp  # Определяем импорт маршрутов BGP
set policy-options policy-statement IMPORT-NETWORK term 1 from prefix-list ALLOWED-NETWORK  # Импортируем только сети из списка ALLOWED-NETWORK
set policy-options policy-statement IMPORT-NETWORK term 1 then accept  # Принимаем эти маршруты
```
## Настройка BGP

```shell
set protocols bgp group EBGP type external  # Создаем eBGP-группу
set protocols bgp group EBGP import IMPORT-NETWORK  # Применяем импортную политику
set protocols bgp group EBGP export EXPORT-DEFAULT  # Применяем экспортную политику
set protocols bgp group EBGP peer-as 100  # Определяем AS соседа
set protocols bgp group EBGP neighbor 10.1.33.2  # Указываем IP-адрес BGP-соседа
```
## Указываем автономную систему устройства

```shell
set routing-options autonomous-system 500  # Устанавливаем AS устройства в 500
```
## Настройка статического маршрута по умолчанию

```shell
set routing-options static route 0.0.0.0/0 next-hop 172.16.17.1  # Указываем шлюз по умолчанию для выхода в интернет

```

