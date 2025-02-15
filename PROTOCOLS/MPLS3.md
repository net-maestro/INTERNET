# MPLS и его использование со связкой BGP  
*(Пример конфигурации на базе Mikrotik RouterOS 7)*

---

## 1. Основы MPLS

### 1.1. Что такое MPLS  
**MPLS (Multi-Protocol Label Switching)** — это технология, позволяющая
быстрее и гибче перенаправлять пакеты данных в сетях, используя
короткие числовые метки (Labels) вместо длинных IP-адресов. MPLS
работает поверх любого сетевого уровня (например, IPv4, IPv6) и
упрощает реализацию VPN (L3VPN, L2VPN/VPLS), Traffic Engineering и
Quality of Service (QoS).

### 1.2. Метки MPLS (Labels)  
| Диапазон меток | Описание |
|---------------|----------------------|
| 0–15 | Зарезервированные (специальные) метки для протокола |
| 16–100000 | Общий пул доступных меток для MPLS (значение зависит от оборудования/вендора) |

*Примечание:* В Mikrotik RouterOS под капотом используется несколько
внутренних резервированных меток, однако в пользовательских настройках
мы их обычно не трогаем.

### 1.3. Основные понятия MPLS  
| Понятие | Описание |
|--------------------|----------|
| **LSR** (Label Switch Router) | Устройство (роутер) с поддержкой MPLS, которое может устанавливать, считывать и/или менять метки MPLS на пакетах |
| **LER** (Label Edge Router) | Граничный роутер MPLS; обычно является входной/выходной точкой MPLS-домена (именно LER присваивает пакетам метку при входе и снимает при выходе) |
| **LDP** (Label Distribution Protocol) | Протокол распределения меток в MPLS. Автоматически рекламирует метки между соседями и поддерживает синхронизацию |
| **L3VPN / VPLS** | VPN-решения поверх MPLS. L3VPN обеспечивает маршрутизацию на уровне IP-сетей, а VPLS (Virtual Private LAN Service) – "прозрачную" L2-сеть |

---

## 2. Настройка MPLS на Mikrotik RouterOS 7

### 2.1. Включение MPLS и настройка LDP  
1. **Активируем MPLS на интерфейсах**  
   Обычно MPLS включается на "корневых" (транзитных) интерфейсах, через которые будет проходить метка.
   ```bash
   /mpls interface
   add interface=ether1
   add interface=ether2
   ```
2. **Включаем LDP и указываем транзитные интерфейсы**  
   ```bash
   /mpls ldp
   set enabled=yes lsr-id=1.1.1.1 transport-address=1.1.1.1
   /mpls ldp interface
   add interface=ether1
   add interface=ether2
   ```
   - **lsr-id**: Обычно выбирается Loopback-адрес, уникальный в пределах MPLS-домена.
   - **transport-address**: Часто совпадает с lsr-id, чтобы смежные LDP
     соседи "видели" роутер по надежному (loopback) адресу.

3. **Проверка установленных соседств LDP**  
   ```bash
   /mpls ldp neighbor print
   ```
   Если соседства сформированы корректно, вы увидите список LDP-соседей,
   их состояние и статус обмена метками.

### 2.2. Настройка L3VPN (пример)  
Для организации маршрутизации (Layer 3) поверх MPLS часто используют BGP
как протокол передачи VPNv4 (или VPNv6) маршрутов.

1. Создаем **VRF** для клиента:
   ```bash
   /ip route vrf
   add routing-mark=Client_A interfaces=ether3
   ```
2. Регистрируем **Route Distinguisher (RD)** и **Route Targets (RT)**:
   ```bash
   /routing bgp instance
   add name=vrf_ClientA as=65001 router-id=1.1.1.1 vrf=Client_A
   /routing bgp vpn instance
   set vrf_ClientA route-distinguisher=65001:100
   set vrf_ClientA import-route-targets=65001:110
   set vrf_ClientA export-route-targets=65001:110
   ```
3. Настраиваем **BGP** для обмена VPNv4 маршрутами:
   ```bash
   /routing bgp peer
   add name=mpls-peer instance=default remote-address=2.2.2.2 remote-as=65002 \
       address-families=vpnv4,vpnv6
   ```
   - `address-families` указывает, что хотим анонсировать VPN-пространство.

---

## 3. Best Practices и советы по использованию MPLS в BGP

1. **Стабильная IGP (OSPF/IS-IS) или LDP-соседства**:
   - Убедитесь, что внутри MPLS-домена корректно работает связность между LSR.

2. **Резервирование**:
   - Используйте **ECMP (Equal-Cost Multi-Path)** в LDP.
   - Или внедряйте **OSPF/IS-IS** Fast Reroute.

3. **Безопасность**:
   - Ограничивайте доступ к LDP/BGP только с доверенных IP (Loopback).
   - Фильтруйте нежелательные обновления BGP при выходе в публичную сеть.

4. **Маркировка и QoS**:
   - MPLS поддерживает DiffServ/EXP биты в заголовке метки.
   - Можно использовать для классификации трафика и гибкого управления приоритетами.

5. **Мониторинг**:
   - `/mpls ldp neighbor print detail` для просмотра состояния LDP-сессий.
   - Используйте `/tool sniffer`, `/tool torch` для отладки.
   - В случае BGP применяйте `routing bgp peer print status` и смотрите логи.

---

## Заключение

**MPLS** в связке с **BGP** — мощный инструмент для провайдерских и
корпоративных сетей, позволяющий:
- Упростить внутреннюю маршрутизацию.
- Организовать VPN (L3VPN, VPLS) и гибко управлять трафиком.
- Использовать механизмы BGP (communities, local-pref, as-path prepend и т.д.).

В Mikrotik RouterOS 7 настройка стала более гибкой: появилась поддержка
VRF, VPN-Instances, расширенные настройки BGP, что упрощает реализацию
MPLS-сетей. Главное — **корректно настроить LDP** и **iBGP** с
использованием loopback-адресов, а затем накладывать нужные фильтры и
политики, соответствующие требованиям сети.

