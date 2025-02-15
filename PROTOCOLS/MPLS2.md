# MPLS и его использование со связкой BGP  
*(Пример конфигурации на базе Mikrotik RouterOS 7)*

---

## 1. Основы MPLS

### 1.1. Что такое MPLS
**MPLS (Multi-Protocol Label Switching)** — это технология, позволяющая быстрее и 
гибче перенаправлять пакеты данных в сетях, используя короткие числовые метки (Labels) 
вместо длинных IP-адресов. MPLS работает поверх любого сетевого уровня (например, IPv4, 
IPv6) и упрощает реализацию VPN (L3VPN, L2VPN/VPLS), Traffic Engineering и Quality of 
Service (QoS).

### 1.2. Метки MPLS (Labels)
| Диапазон меток | Описание |
|---------------|----------|
| 0–15          | Зарезервированные (специальные) метки |
| 16–100000     | Общий пул доступных меток (зависит от оборудования) |

### 1.3. Основные понятия MPLS
| Понятие  | Описание |
|----------|----------|
| **LSR**  | Роутер, который обрабатывает MPLS-метки |
| **LER**  | Граничный MPLS-роутер, который назначает и снимает метки |
| **LDP**  | Протокол распределения меток |
| **L3VPN / VPLS** | VPN-решения поверх MPLS |

---

## 2. Настройка MPLS на Mikrotik RouterOS 7

### 2.1. Включение MPLS и настройка LDP
```bash
/mpls interface
add interface=ether1
add interface=ether2

/mpls ldp
set enabled=yes lsr-id=1.1.1.1 transport-address=1.1.1.1

/mpls ldp interface
add interface=ether1
add interface=ether2
```
**Проверка установленных соседств LDP:**
```bash
/mpls ldp neighbor print
```

### 2.2. Настройка L3VPN (пример)
#### Создание VRF для клиента
```bash
/ip route vrf
add routing-mark=Client_A interfaces=ether3
```
#### Настройка BGP
```bash
/routing bgp instance
add name=vrf_ClientA as=65001 router-id=1.1.1.1 vrf=Client_A

/routing bgp vpn instance
set vrf_ClientA route-distinguisher=65001:100
set vrf_ClientA import-route-targets=65001:110
set vrf_ClientA export-route-targets=65001:110
```
#### Настройка BGP для VPNv4
```bash
/routing bgp peer
add name=mpls-peer instance=default remote-address=2.2.2.2 remote-as=65002 \
    address-families=vpnv4,vpnv6
```

---

## 3. Использование BGP в MPLS-домене

### 3.1. iBGP поверх MPLS
```bash
/interface bridge add name=loopback1 protocol-mode=none
/ip address add address=1.1.1.1/32 interface=loopback1

/routing bgp instance
add name=default as=65000 router-id=1.1.1.1

/routing bgp peer
add name=ibgp-peer remote-address=2.2.2.2 remote-as=65000 \
    update-source=1.1.1.1
```
### 3.2. Влияние MPLS на атрибуты BGP
- MPLS позволяет передавать метки в BGP анонсах (Labelled-Unicast, VPNv4).
- Можно управлять маршрутизацией через фильтры in/out.

---

## 4. Best Practices
- **Стабильность**: Использовать надежные IGP (OSPF/IS-IS) и контролировать LDP-соседства.
- **Резервирование**: ECMP в LDP или Fast Reroute для быстрого переключения трафика.
- **Безопасность**: Ограничение доступа к LDP/BGP, фильтрация ненужных префиксов.
- **QoS**: Использование EXP битов в MPLS для приоритизации трафика.
- **Мониторинг**: Проверка LDP-сессий (`/mpls ldp neighbor print detail`).

---

## Заключение
MPLS — это мощный инструмент для управления маршрутизацией и организации VPN-сетей. 
В связке с BGP он позволяет строить масштабируемые и надежные решения. Mikrotik 
RouterOS 7 предлагает все необходимые инструменты для успешной настройки MPLS и BGP.
