# MPLS и его использование со связкой BGP  
*(Пример конфигурации на базе Mikrotik RouterOS 7)*

---

## 1. Основы MPLS

### 1.1. Что такое MPLS
**MPLS (Multi-Protocol Label Switching)** — это технология, позволяющая быстрее и гибче перенаправлять пакеты данных в сетях, используя короткие числовые метки (Labels) вместо длинных IP-адресов. MPLS работает поверх любого сетевого уровня (например, IPv4, IPv6) и упрощает реализацию VPN (L3VPN, L2VPN/VPLS), Traffic Engineering и Quality of Service (QoS).

### 1.2. Метки MPLS (Labels)
| Диапазон меток | Описание             |
|---------------|----------------------|
| 0–15          | Зарезервированные (специальные) метки для протокола |
| 16–100000     | Общий пул доступных меток для MPLS (значение зависит от оборудования/вендора) |

*Примечание:* В Mikrotik RouterOS под капотом используется несколько внутренних резервированных меток, однако в пользовательских настройках мы их обычно не трогаем.

### 1.3. Основные понятия MPLS
| Понятие            | Описание |
|--------------------|----------|
| **LSR** (Label Switch Router)       | Устройство (роутер) с поддержкой MPLS, которое может устанавливать, считывать и/или менять метки MPLS на пакетах |
| **LER** (Label Edge Router)         | Граничный роутер MPLS; обычно является входной/выходной точкой MPLS-домена (именно LER присваивает пакетам метку при входе и снимает при выходе) |
| **LDP** (Label Distribution Protocol) | Протокол распределения меток в MPLS. Автоматически рекламирует метки между соседями и поддерживает синхронизацию |
| **L3VPN / VPLS**                    | VPN-решения поверх MPLS. L3VPN обеспечивает маршрутизацию на уровне IP-сетей, а VPLS (Virtual Private LAN Service) – "прозрачную" L2-сеть |

---

## 2. Настройка MPLS на Mikrotik RouterOS 7

### 2.1. Включение MPLS и настройка LDP
1. **Активируем MPLS на интерфейсах**  
   Обычно MPLS включается на "корневых" (транзитных) интерфейсах, через которые будет проходить метка.
   ```bash
   /mpls interface
   add interface=ether1
   add interface=ether2
Включаем LDP и указываем транзитные интерфейсы.
LDP (Label Distribution Protocol) отвечает за автоматическое формирование меток и их обмен между соседями.

bash
Copy
Edit
/mpls ldp
set enabled=yes lsr-id=1.1.1.1 transport-address=1.1.1.1
/mpls ldp interface
add interface=ether1
add interface=ether2
lsr-id: Обычно выбирается Loopback-адрес, уникальный в пределах MPLS-домена.
transport-address: Часто совпадает с lsr-id, чтобы смежные LDP соседи "видели" роутер по надежному (loopback) адресу.

Проверка установленных соседств LDP
Если соседства сформированы корректно, вы увидите список LDP-соседей, их состояние и статус обмена метками.
bash
Copy
Edit
/mpls ldp neighbor print
2.2. Настройка L3VPN (пример)
Для организации маршрутизации (Layer 3) поверх MPLS часто используют BGP как протокол передачи VPNv4 (или VPNv6) маршрутов.

Создаем VRF для клиента (пример для одного клиента с VRF "Client_A"):

bash
Copy
Edit
/ip route vrf
add routing-mark=Client_A interfaces=ether3
Регистрируем Route Distinguisher (RD) и Route Targets (RT) (в RouterOS 7 это делается через раздел Routing → BGP → Instances/Peers/Route Distinguisher):

bash
Copy
Edit
/routing bgp instance
add name=vrf_ClientA as=65001 router-id=1.1.1.1 vrf=Client_A
/routing bgp vpn instance
set vrf_ClientA route-distinguisher=65001:100
set vrf_ClientA import-route-targets=65001:110
set vrf_ClientA export-route-targets=65001:110
Настроим BGP для обмена VPNv4 маршрутами между PE (Provider Edge) роутерами:

bash
Copy
Edit
/routing bgp peer
add name=mpls-peer instance=default remote-address=2.2.2.2 remote-as=65002 \
    address-families=vpnv4,vpnv6
address-families указывает, что хотим анонсировать VPN-пространство (VPNv4 и/или VPNv6).

Проверка маршрутов
Проверяем, что маршруты Client_A экспортируются в BGP и импортируются на другом PE с аналогичными настройками (своим RD/RT).

3. Использование BGP в MPLS-домене
3.1. iBGP поверх MPLS
В некоторых случаях для обеспечения связности между PE роутерами (при наличии развитой MPLS-сети) используют iBGP, установленный по loopback-адресам, и транспорт (LDP/RSVP-TE) между ними. При этом MPLS обеспечивает "прозрачную" передачу пакетов BGP без необходимости полноценной IP-маршрутизации на промежуточных узлах.

Преимущества:

Упрощенная внутренняя маршрутизация (в транзитных LSR не нужно настраивать полноценную OSPF/BGP, достаточно LDP).
Гибкое управление трафиком: можно использовать TE (Traffic Engineering) и различные политики на уровне MPLS.
Настройка:

Конфигурируем Loopback-интерфейсы для PE роутеров.
Настроим iBGP соседство между Loopback-адресами.
Обеспечиваем, чтобы LDP формировал метки для Loopback-сетей (чтобы пакеты BGP доходили по MPLS).
Пример:

bash
Copy
Edit
# На каждом PE
/interface bridge add name=loopback1 protocol-mode=none
/ip address add address=1.1.1.1/32 interface=loopback1

/routing bgp instance
add name=default as=65000 router-id=1.1.1.1

/routing bgp peer
add name=ibgp-peer remote-address=2.2.2.2 remote-as=65000 update-source=1.1.1.1
Указываем update-source, чтобы BGP использовал наш loopback1.

3.2. Влияние MPLS на атрибуты BGP
В контексте MPLS атрибуты BGP (local-pref, as-path, med и т.д.) продолжают работать по стандартным правилам. Однако появляется дополнительная возможность — передача метки в анонсах BGP (Labelled-Unicast, VPNv4 и т.д.). Для этого:

В out-filter можно указывать, какую метку присвоить маршруту.
В in-filter можно анализировать полученную метку и управлять дальнейшей маршрутизацией.
4. Best Practices и советы по использованию MPLS в BGP
Стабильность IGP (OSPF/IS-IS) или LDP-соседства
Убедитесь, что внутри MPLS-домена корректно работает связность между LSR, чтобы BGP не "падал" из-за потери доступа к loopback-адресам.

Резервирование
Используйте ECMP (Equal-Cost Multi-Path) в LDP, если несколько параллельных линков.
Или внедряйте OSPF/IS-IS Fast Reroute для быстрого переключения трафика.
Безопасность
Ограничивайте доступ к LDP/BGP только с доверенных IP (Loopback).
Фильтруйте нежелательные обновления BGP (bogons, приватные префиксы, etc.) при выходе в публичную сеть.
Маркировка и QoS
MPLS поддерживает DiffServ/EXP биты в заголовке метки. Можно использовать для классификации трафика и гибкого управления приоритетами.

Мониторинг
Используйте команду /mpls ldp neighbor print detail для просмотра состояния LDP-сессий. Также можно использовать MPLS-метки в BGP для понимания маршрутов с точки зрения MPLS.

Заключение
MPLS — это мощный инструмент для управления маршрутизацией в сетях с большим числом узлов и маршрутных точек. В связке с BGP он позволяет строить масштабируемые и надежные решения для передачи данных и организации VPN-сетей. Mikrotik RouterOS 7 предлагает все необходимые инструменты для успешной настройки MPLS и использования его возможностей в рамках BGP-маршрутизации.
