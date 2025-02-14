```markdown
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
| 16–100000      | Общий пул доступных меток для MPLS (значение зависит от оборудования/вендора) |

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
   ...
   ```
2. **Включаем LDP и указываем транзитные интерфейсы**  
   LDP (Label Distribution Protocol) отвечает за автоматическое формирование меток и их обмен между соседями.
   ```bash
   /mpls ldp
   set enabled=yes lsr-id=1.1.1.1 transport-address=1.1.1.1
   /mpls ldp interface
   add interface=ether1
   add interface=ether2
   ```
   - **lsr-id**: Обычно выбирается Loopback-адрес, уникальный в пределах MPLS-домена.
   - **transport-address**: Часто совпадает с lsr-id, чтобы смежные LDP соседи "видели" роутер по надежному (loopback) адресу.

3. **Проверка установленных соседств LDP**  
   ```bash
   /mpls ldp neighbor print
   ```
   Если соседства сформированы корректно, вы увидите список LDP-соседей, их состояние и статус обмена метками.

### 2.2. Настройка L3VPN (пример)
Для организации маршрутизации (Layer 3) поверх MPLS часто используют BGP как протокол передачи VPNv4 (или VPNv6) маршрутов.

1. Создаем **VRF** для клиента (пример для одного клиента с VRF "Client_A"):
   ```bash
   /ip route vrf
   add routing-mark=Client_A interfaces=ether3
   ```
2. Регистрируем **Route Distinguisher (RD)** и **Route Targets (RT)** (в RouterOS 7 это делается через раздел Routing → BGP → Instances/Peers/Route Distinguisher):
   ```bash
   /routing bgp instance
   add name=vrf_ClientA as=65001 router-id=1.1.1.1 vrf=Client_A
   /routing bgp vpn instance
   set vrf_ClientA route-distinguisher=65001:100
   set vrf_ClientA import-route-targets=65001:110
   set vrf_ClientA export-route-targets=65001:110
   ```
3. Настраиваем **BGP** для обмена VPNv4 маршрутами между PE (Provider Edge) роутерами:
   ```bash
   /routing bgp peer
   add name=mpls-peer instance=default remote-address=2.2.2.2 remote-as=65002 \
       address-families=vpnv4,vpnv6
   ```
   - `address-families` указывает, что хотим анонсировать VPN-пространство (VPNv4 и/или VPNv6).

4. Проверяем, что маршруты Client_A **экспортируются** в BGP и **импортируются** на другом PE с аналогичными настройками (своим RD/RT).

---

## 3. Использование BGP в MPLS-домене

### 3.1. iBGP поверх MPLS
В некоторых случаях для обеспечения связности между PE роутерами (при наличии развитой MPLS-сети) используют iBGP, установленный по loopback-адресам, и транспорт (LDP/RSVP-TE) между ними. При этом MPLS обеспечивает "прозрачную" передачу пакетов BGP без необходимости полноценной IP-маршрутизации на промежуточных узлах.

- **Преимущества**:
  - Упрощенная внутренняя маршрутизация (в транзитных LSR не нужно настраивать полноценную OSPF/BGP, достаточно LDP).
  - Гибкое управление трафиком: можно использовать TE (Traffic Engineering) и различные политики на уровне MPLS.

- **Настройка**:
  1. Конфигурируем Loopback-интерфейсы для PE роутеров.
  2. Настраиваем iBGP соседство между Loopback-адресами.
  3. Обеспечиваем, чтобы LDP формировал метки для Loopback-сетей (чтобы пакеты BGP доходили по MPLS).

Пример:
```bash
# На каждом PE
/interface bridge add name=loopback1 protocol-mode=none
/ip address add address=1.1.1.1/32 interface=loopback1

/routing bgp instance
add name=default as=65000 router-id=1.1.1.1

/routing bgp peer
add name=ibgp-peer remote-address=2.2.2.2 remote-as=65000 update-source=1.1.1.1
# Указываем update-source, чтобы BGP использовал наш loopback1
```

### 3.2. Влияние MPLS на атрибуты BGP
В контексте MPLS атрибуты BGP (local-pref, as-path, med и т.д.) продолжают работать по стандартным правилам. Однако появляется дополнительная возможность — **передача метки** в анонсах BGP (Labelled-Unicast, VPNv4 и т.д.). Для этого:
- В **out-filter** можно указывать, какую метку присвоить маршруту.
- В **in-filter** можно анализировать полученную метку и управлять дальнейшей маршрутизацией.

---

## 4. Best Practices и советы по использованию MPLS в BGP

1. **Стабильная IGP (OSPF/IS-IS) или LDP-соседства**:  
   Убедитесь, что внутри MPLS-домена корректно работает связность между LSR, чтобы BGP не "падал" из-за потери доступа к loopback-адресам.

2. **Резервирование**:  
   - Используйте **ECMP (Equal-Cost Multi-Path)** в LDP, если несколько параллельных линков.
   - Или внедряйте **OSPF/IS-IS** Fast Reroute для быстрого переключения трафика.

3. **Безопасность**:  
   - Ограничивайте доступ к LDP/BGP только с доверенных IP (Loopback).
   - Фильтруйте нежелательные обновления BGP (bogons, приватные префиксы, etc.) при выходе в публичную сеть.

4. **Маркировка и QoS**:  
   MPLS поддерживает DiffServ/EXP биты в заголовке метки. Можно использовать для классификации трафика и гибкого управления приоритетами.

5. **Мониторинг**:  
   - Команда `/mpls ldp neighbor print detail` для просмотра состояния LDP-сессий.
   - Используйте инструменты `/tool sniffer`, `/tool torch` для отладки.
   - В случае BGP применяйте `routing bgp peer print status` и смотрите логи для выявления причин разрывов.

---

## 5. Пример настройки (обобщенный сценарий)

Предположим, у нас два провайдера-роутера **R1** и **R2**, между ними несколько промежуточных маршрутизаторов, все внутри одного MPLS-домена. На **R1** и **R2** требуется поднимать iBGP и MPLS для организации VPN L3:

1. На всех промежуточных роутерах (**Core**):
   ```bash
   /mpls interface
   add interface=core-link1
   add interface=core-link2
   ...
   /mpls ldp set enabled=yes lsr-id=10.10.10.1 transport-address=10.10.10.1
   /mpls ldp interface
   add interface=core-link1
   add interface=core-link2
   ...
   ```
2. На **R1**:
   ```bash
   /interface bridge add name=lo1
   /ip address add address=1.1.1.1/32 interface=lo1
   /mpls interface add interface=core-link1
   /mpls ldp set enabled=yes lsr-id=1.1.1.1 transport-address=1.1.1.1
   /mpls ldp interface add interface=core-link1

   /routing bgp instance
   add name=default as=65000 router-id=1.1.1.1
   /routing bgp peer
   add name=R2 remote-as=65000 remote-address=2.2.2.2 update-source=1.1.1.1 \
       address-families=vpnv4,vpnv6
   ```
3. На **R2** аналогичная конфигурация, где `router-id=2.2.2.2`, `remote-address=1.1.1.1` и т.д.

4. Создаем VRF (при необходимости отдельной L3VPN) и настраиваем соответствующие RD/RT:
   ```bash
   /ip route vrf add routing-mark=Client_A interfaces=ether5
   /routing bgp vpn instance set default route-distinguisher=65000:1 \
       import-route-targets=65000:10 export-route-targets=65000:10
   ```

В результате **R1** и **R2** через iBGP смогут обмениваться маршрутами клиента, а весь транзит осуществляется по MPLS-домену с использованием меток.

---

## Заключение

**MPLS** в связке с **BGP** — мощный инструмент для провайдерских и корпоративных сетей, позволяющий:
- Упростить внутреннюю маршрутизацию при большом количестве узлов.
- Организовать VPN (L3VPN, VPLS) и гибко управлять трафиком.
- Использовать механизмы BGP (communities, local-pref, as-path prepend и т.д.) уже не только для IP-маршрутизации, но и для меток.

В Mikrotik RouterOS 7 настройка стала более гибкой: появилась поддержка VRF, VPN-Instances, расширенные настройки BGP, что упрощает реализацию MPLS-сетей. Главное — **корректно настроить LDP** и **iBGP** с использованием loopback-адресов, а затем накладывать нужные фильтры и политики, соответствующие требованиям сети.
```
