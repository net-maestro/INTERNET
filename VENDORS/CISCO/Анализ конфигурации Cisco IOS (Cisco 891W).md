---

# 📡 Анализ конфигурации Cisco IOS (Cisco 891W)

**Общее назначение устройства:** Периферийный маршрутизатор филиала с поддержкой DMVPN, резервированием каналов связи (основной WAN, StarLink в отдельном VRF, резервный ADSL), политикой маршрутизации (PBR) и автоматическим переключением каналов через EEM (Embedded Event Manager).

---

## 1. Глобальные настройки и базовая безопасность (Global & Security)
```cisco
version 15.9
no service pad
service tcp-keepalives-in
service tcp-keepalives-out
service timestamps debug datetime msec localtime show-timezone
service timestamps log datetime localtime show-timezone
service password-encryption
service sequence-numbers
hostname KU_LEV
```
* **`no service pad`**: Отключает службу PAD (Packet Assembler/Disassembler) для X.25, что является стандартом безопасности для закрытия неиспользуемых сервисов.
* **`service tcp-keepalives...`**: Включает отправку TCP-keepalive пакетов для обнаружения "мертвых" соединений.
* **`service timestamps ...`**: Добавляет метки времени с миллисекундами, локальным временем и часовым поясом к логам и отладке. Критично для траблшутинга.
* **`service password-encryption`**: Шифрует пароли типа 7 (слабое шифрование, но лучше, чем открытый текст). *Рекомендация: использовать `enable secret 9` (scrypt) или 8 (pbkdf2), что уже частично сделано.*
* **`hostname KU_LEV`**: Имя устройства.

---

## 2. Загрузка и виртуализация (Boot & VRF)
```cisco
boot system flash:/c890-universalk9-mz.159-3.M5.bin
boot system flash:/c890-universalk9-mz.157-3.M4a.bin
!
vrf definition SL
 description StarLink
 rd 65000:1
 route-target export 65000:1
 route-target import 65000:1
 address-family ipv4
 exit-address-family
```
* **`boot system`**: Задает порядок загрузки образов. Если основной (`159-3.M5`) поврежден, роутер загрузит резервный (`157-3.M4a`). Отличная практика отказоустойчивости.
* **`vrf definition SL`**: Создает VRF (Virtual Routing and Forwarding) с именем `SL` (StarLink). 
  * **`rd` и `route-target`**: Хотя это VRF-Lite (без MPLS), эти параметры заданы. В чистом L3 VRF-Lite они не обязательны, но могут использоваться для совместимости или будущей миграции на MPLS.

---

## 3. AAA и управление доступом (AAA & Access)
```cisco
aaa new-model
aaa authentication login default local
aaa authentication login userlist local
aaa authorization exec default local none 
aaa session-id common
enable secret 9 **************************************
username cad privilege 15 password ************
username fad privilege 15 password ************
```
* **`aaa new-model`**: Включает современную модель AAA.
* **`aaa authentication ... local`**: Задает аутентификацию через локальную базу данных пользователей.
* **`enable secret 9`**: Использует алгоритм хеширования scrypt (надежный) для пароля привилегированного режима.
* **`username ... privilege 15`**: Создание локальных администраторов.

---

## 4. Службы DHCP и DNS
```cisco
ip dhcp excluded-address 192.168.12.1
ip dhcp excluded-address 192.168.12.1 192.168.12.20
! ... другие исключения ...
!
ip dhcp pool ogly
 host 192.168.12.65 255.255.255.0
 client-identifier 01aa.5af3.72сс.56
!
ip dhcp pool dhcp
 network 192.168.12.0 255.255.255.0
 default-router 192.168.12.1 
 dns-server 10.52.15.18 10.52.15.19 
```
* **`ip dhcp excluded-address`**: Резервирует IP-адреса, чтобы DHCP-сервер не выдавал их динамически. 
  * ⚠️ **Экспертное замечание**: В конфиге есть дублирование и пересечения (например, `.1` исключен отдельно и в составе диапазона `.1-.20`). Это не ломает работу, но засоряет конфигурацию. Рекомендуется консолидировать в один диапазон `192.168.12.1 192.168.12.220`.
* **`pool ogly`**: Статическая резервация (DHCP Reservation) по MAC-адресу (`client-identifier`). Префикс `01` указывает на тип адреса Ethernet.
* **`pool dhcp`**: Основной пул для динамической раздачи адресов клиентам.

---

## 5. Криптография и VPN (IPsec / IKEv1 / IKEv2 / DMVPN)
```cisco
crypto ikev2 proposal default
 encryption aes-gcm-256
 prf sha256
 group 20
!
crypto ipsec transform-set AES-SHA esp-aes 256 esp-sha256-hmac 
 mode tunnel
!
crypto ipsec profile AES-SHA
 set transform-set AES-SHA 
```
* **IKEv2 Proposal**: Использует современные и стойкие алгоритмы: AES-GCM-256 (шифрование и аутентификация в одном), SHA256 (целостность), Группа 20 (эллиптические кривые, высокая стойкость при низкой нагрузке на CPU).
* **Transform-set**: Определяет параметры IPsec туннеля (ESP, AES-256, SHA256-HMAC).
* **IPsec Profile**: Связывает transform-set с туннельными интерфейсами. Используется как шаблон защиты для DMVPN.
* *Примечание*: В конфиге также присутствует устаревший `crypto isakmp` (IKEv1). Это может быть нужно для совместимости со старыми пирами, но с точки зрения безопасности рекомендуется отключить IKEv1, если он не используется.

---

## 6. Интерфейсы и коммутация (Interfaces)
### LAN (VLAN 1)
```cisco
interface Vlan1
 ip address 192.168.12.1 255.255.255.0
 ip nat inside
 ip policy route-map SL
```
* Внутренний интерфейс. К нему применяется **PBR (Policy-Based Routing)** через `route-map SL`, который перенаправляет определенный трафик в VRF StarLink.

### WAN Основной (FastEthernet 4)
```cisco
interface FastEthernet4
 ip address 193.**.**.52 255.255.255.248
 ip nat outside
 ip inspect OUTSIDE out
 ip virtual-reassembly in
```
* Внешний интерфейс. Включен `ip virtual-reassembly in` (обязательно для корректной работы IPsec и NAT при фрагментации пакетов). `ip inspect` (CBAC) обеспечивает stateful фильтрацию исходящего трафика.

### WAN StarLink (VLAN 2)
```cisco
interface Vlan2
 vrf forwarding SL
 ip address 192.168.1.12 255.255.255.0
 ip nat outside
```
* Интерфейс подключен к модему StarLink и помещен в изолированную таблицу маршрутизации `VRF SL`.

### Туннели (DMVPN и Point-to-Point)
* **Tunnel1 / Tunnel2**: DMVPN (GRE Multipoint + NHRP + EIGRP). По умолчанию находятся в состоянии `shutdown`. Управляются через EEM при падении основного канала.
* **Tunnel10 / Tunnel20**: Классические point-to-point туннели (GRE over IPsec) с использованием IKEv2 (`virtual-template 1`), направленные на конкретные публичные IP-адреса хабов (`195.**.**.69` / `195.**.**.70`).

---

## 7. Маршрутизация и мониторинг (EIGRP & IP SLA)
```cisco
router eigrp 1
 bfd all-interfaces
 network 10.65.0.0 0.0.1.255
 passive-interface default
 no passive-interface Tunnel1
!
ip sla 1
 icmp-echo 8.8.8.8 source-interface FastEthernet4
 frequency 30
track 1 ip sla 1 reachability
 delay down 30 up 5
```
* **EIGRP**: Используется BFD (Bidirectional Forwarding Detection) для сверхбыстрого обнаружения падения соседства (быстрее, чем hello-таймеры). `passive-interface default` предотвращает случайную рассылку EIGRP-пакетов во внутреннюю сеть, разрешая их только на туннелях.
* **IP SLA + Track**: Каждые 30 секунд отправляет ICMP-эхо на `8.8.8.8` через основной интерфейс `FastEthernet4`. Если 30 секунд нет ответа, трек переходит в состояние `down` (с задержкой 30с для защиты от "дребезга" канала), что триггерит EEM.

---

## 8. NAT и Policy-Based Routing (PBR)
```cisco
ip nat inside source route-map NAT_ISP1 interface FastEthernet4 overload
ip nat inside source route-map NAT_ISP3 interface Vlan2 overload
!
route-map SL permit 10
 match ip address 101
 set ip vrf SL next-hop 192.168.1.1
```
* **NAT Overload (PAT)**: Использует route-maps для определения, какой трафик через какой интерфейс должен выходить во внешнюю сеть.
* **PBR (`route-map SL`)**: Трафик, подпадающий под ACL 101, принудительно отправляется в шлюз `192.168.1.1`, который находится в VRF `SL` (StarLink), минуя основную таблицу маршрутизации.

---

## 9. Списки доступа (ACLs)
* **`INETIN`**: Фильтрует входящий трафик на WAN-интерфейсах. Разрешает только необходимый трафик: DHCP, IKE (isakmp/non500), ICMP, ESP/AHP (для VPN), и SSH с доверенных подсетей. Запрещает все остальное (неявный `deny ip any any` в конце).
* **`TUNIN` / `TUNOUT`**: Фильтруют трафик, проходящий через туннели. Разрешают управляющие протоколы (SSH, RDP, HTTPS), EIGRP, NHRP и специфичные бизнес-приложения (порты 4899, 6129, 37777 и т.д.).
* **`BLOCK`**: Применяется к Vlan1. Разрешает хосту `.65` полный доступ, но блокирует доступ всей сети к определенным внешним IP-адресам (`195.**.**.94/95`).

---

## 10. Embedded Event Manager (EEM) – Автоматизация
Это "мозг" отказоустойчивости данной конфигурации.

```cisco
event manager applet ISP_1_DOWN
 event track 1 state down
 action 001 cli command "enable"
 action 003 cli command "no ip route 0.0.0.0 0.0.0.0 **.**.49"
 action 004 cli command "interface range tunnel1, tunnel2"
 action 005 cli command "no shutdown"
```
* **Логика падения канала**: Когда `track 1` переходит в `down` (основной интернет недоступен):
  1. Удаляет статический маршрут по умолчанию через основной WAN.
  2. Включает (`no shutdown`) интерфейсы `Tunnel1` и `Tunnel2`, активируя DMVPN через резервный канал.

```cisco
event manager applet ISP_1_UP
 event track 1 state up
 action 003 cli command "ip route 0.0.0.0 0.0.0.0 193.**.**.49"
 action 005 cli command "shutdown"
```
* **Логика восстановления**: Когда основной канал возвращается:
  1. Восстанавливает маршрут по умолчанию через основной WAN.
  2. Выключает (`shutdown`) туннели DMVPN, чтобы вернуть топологию в исходное состояние и сэкономить ресурсы.

* ⚠️ **Экспертное замечание по EEM**: Использование EEM для модификации конфигурации (`conf t`) рискованно. Если скрипт прервется, роутер может остаться в противоречивом состоянии. Более надежным подходом (Best Practice) является использование **Floating Static Routes** с привязкой к `track` (например, `ip route 0.0.0.0 0.0.0.0 193.x.x.49 track 1` и `ip route 0.0.0.0 0.0.0.0 Vlan2 200`). Это работает на уровне плоскости пересылки и не требует выполнения CLI-команд.

---

## 11. Системные службы (SNMP, Logging, NTP)
```cisco
logging host 10.52.15.10
snmp-server community public RO
ntp server 10.65.0.1
```
* **Logging**: Отправка syslog на центральный сервер.
* **SNMP**: Включен с community строкой только для чтения (RO). *Рекомендация: строка `public` является стандартом де-факто и небезопасна. Следует использовать SNMPv3 с аутентификацией и шифрованием.*
* **NTP**: Синхронизация времени с внутренними серверами (вероятно, хабам DMVPN), что критично для корректной работы IPsec и валидации сертификатов/логов.

---

## 📝 Резюме и рекомендации по улучшению

1. **Оптимизация DHCP**: Объедините дублирующиеся записи `ip dhcp excluded-address` в один непрерывный диапазон для чистоты конфигурации.
2. **Безопасность SNMP**: Замените `snmp-server community public` на SNMPv3 или хотя бы на сложную строку сообщества, если v3 не поддерживается мониторингом.
3. **Упрощение отказоустойчивости**: Рассмотрите замену скриптов EEM `ISP_1_DOWN`/`UP` на **Floating Static Routes** с отслеживанием IP SLA. Это стандартный, более стабильный и предсказуемый способ резервирования каналов в Cisco IOS.
4. **Очистка криптографии**: Если все спицы (spokes) поддерживают IKEv2, удалите разделы `crypto isakmp` (IKEv1) для уменьшения поверхности атаки.
5. **VRF-Lite**: Параметры `rd` и `route-target` в VRF `SL` избыточны, если не используется MPLS. Их можно удалить для упрощения, оставив только `vrf forwarding SL` на интерфейсе.

--- 
