---

# 📘 ZTE OLT — Команды и описание  
Разделён на две части:  
- show — просмотр состояния и конфигурации  
- mng — управление, настройка и действия
---

## 👁️‍🗨️ I. Команды `show` (просмотр)

### 🔹 ONU и PON
| Команда | Описание |
|--------|---------|
| `show pon onu uncfg` | Показывает все обнаруженные, но не авторизованные ONU. |
| `show gpon onu by sn CDTC1DFFB038` | Информация об ONU по серийному номеру (включая статус, порт, ID). |
| `show gpon onu distance gpon_onu-1/1/1:1` | Расстояние до ONU (в метрах). |
| `show gpon onu config-fail gpon_onu-1/1/1` | ONU с ошибками конфигурации на PON-порту. |
| `show gpon onu optical-info gpon_onu-1/1/1:1` | Rx/Tx power, температура, напряжение ONU. |
| `show interface gpon_olt-1/1/X` | Статус и оптические параметры PON-порта на OLT (`X` — номер порта). |

### 🔹 Информация о удалённой ONU (`remote-onu`)
> Эти команды дают детальную информацию о состоянии и возможностях конкретной ONU.

| Команда | Описание |
|--------|---------|
| `show gpon remote-onu interface pon gpon_onu-1/1/1:1` | Состояние PON-интерфейса на ONU (up/down, FEC, скорость). |
| `show gpon remote-onu equip gpon_onu-1/1/1:1` | Оборудование ONU: vendor ID, модель, версия прошивки. |
| `show gpon remote-onu capability gpon_onu-1/1/1:1` | Возможности ONU: поддерживаемые T-CONT, порты, скорости. |
| `show gpon remote-onu service gpon_onu-1/1/1:1` | Активные сервисы на ONU (VLAN, GEM-порты, сервис-порты). |
| `show gpon remote-onu mac gpon_onu-1/1/1:1 ethuni eth_0/1` | MAC-адреса устройств за Ethernet-портом ONU. |
| `show gpon remote-onu dhcp-ip ethuni gpon_onu-1/1/1:1` | IP-адреса, полученные по DHCP за указанным Ethernet-портом ONU. |

### 🔹 Конфигурация интерфейсов
| Команда | Описание |
|--------|---------|
| `show running-config-interface gpon_olt-1/1/1` | Конфигурация PON-порта (OLT side). |
| `show running-config-interface gpon_onu-1/1/1:1` | Конфигурация ONU (включая профили и сервис-порты). |
| `show running-config-interface vport-1/1/1.1:1` | Конфигурация виртуального порта (VPort), включая VLAN и QoS. |
| `show service-port interface gpon_onu-1/1/1:1` | Список сервис-портов, привязанных к ONU. |

### 🔹 Система и сервисы
| Команда | Описание |
|--------|---------|
| `show running-config xpon` | Полная конфигурация XPON-модуля. |
| `show running-config msan` | Конфигурация MSAN-сервисов (если используется). |
| `show running-config snmp` | Настройки SNMP (community, traps). |
| `show running-config alarm` | Настройки тревог. |
| `show version` | Версия ПО, модель, uptime. |

### 🔹 Безопасность
| Команда | Описание |
|--------|---------|
| `show security port-protect` | Состояние защиты портов (MAC-limit, блокировки). |
| `show security mac-move-log` | Журнал перемещения MAC между портами. |
| `show security mac-anti-spoofing configuration` | Текущие настройки защиты от MAC spoofing. |
| `show ip dhcp snooping dynamic database` | Таблица DHCP Snooping (IP–MAC–VLAN–Port). |
| `show access-list hybrid number 300` | **Полный вывод ACL с правилами** (включая deny/permit, порты, протоколы). |
| `show access-list bound` | Какие ACL применены к интерфейсам или сервисам. |

> 💡 В ZTE используется **`hybrid` ACL** — поддерживает L2/L3/L4 фильтрацию с указанием `ingress` и `egress`.

### 🔹 VLAN и коммутация
| Команда | Описание |
|--------|---------|
| `show vlan` | Список всех VLAN. |
| `show eth-switch max-frame-length` | Текущее значение MTU на коммутаторе. |
| `show loopback-detection slot 1` | Статус детектирования петель на слоте. |

### 🔹 Профили
| Команда | Описание |
|--------|---------|
| `show gpon profile dba` | Список DBA-профилей. |
| `show gpon profile tcont` | Список T-CONT профилей. |
| `show pon onu-profile gpon line Line-1G` | Параметры Line Profile. |
| `show onu-type` | Поддерживаемые типы ONU. |

---

## ⚙️ II. Команды `mng` (управление и настройка)

### 🔹 Управление ONU
| Команда | Описание |
|--------|---------|
| `pon-onu-mng gpon_onu-1/1/1:1` | Вход в контекст управления ONU (`config-gpon-onu-mng`). |
| `reboot` *(внутри `config-gpon-onu-mng`)* | Перезагрузка ONU. |
| `reset` *(внутри `config-gpon-onu-mng`)* | Сброс ONU к заводским настройкам. |
| `service-port delete all` *(внутри контекста)* | Удалить все сервис-порты ONU. |

### 🔹 ACL (пример создания)
```bash
acl number 300
 name CLIENT-IN-FILTER-300
 rule 10 deny tcp any any eq 135 ipv4
 rule 20 deny tcp any any eq 137 ipv4
 rule 30 deny udp any any eq 137 ipv4
 rule 40 deny tcp any any eq 138 ipv4
 rule 50 deny udp any any eq 138 ipv4
 rule 60 deny tcp any any eq 139 ipv4
 rule 70 deny tcp any any eq 445 ipv4
 rule 200 permit any any any ipv4
```
> ⚠️ Обязательно завершать ACL правилом разрешения (`permit`), иначе весь трафик будет заблокирован.

### 🔹 Применение ACL
```bash
interface gpon_onu-1/1/1:1
 ip access-group 300 in
```

### 🔹 Безопасность
| Команда | Описание |
|--------|---------|
| `mac-anti-spoofing enable` *(в контексте интерфейса)* | Включить защиту от подмены MAC. |
| `loopback-detection enable` *(в контексте слота/порта)* | Включить детектирование петель. |

### 🔹 Системные команды
| Команда | Описание |
|--------|---------|
| `write` | **Сохраняет текущую конфигурацию** в startup-config. |
| `reload system force` | **Принудительная перезагрузка OLT** (без запроса подтверждения). |
| `auto-learning enable` | Разрешить автоматическое обучение новых ONU. |

> ❗ В ZTE **`reload system force`** — это аналог `reboot`, но без интерактивного подтверждения.  
> ❗ **`write`** — основная команда сохранения (аналог `save` в других вендорах).

---

## 💡 Примечания по синтаксису ZTE

- ACL всегда **`hybrid`** — поддерживает L2–L4.
- В ACL обязательно указывать направление трафика: `ingress any egress any` или конкретные интерфейсы.
- Порты могут указываться как числами (`eq 137`), так и именами (`eq bootps`, `eq telnet`).
- Все интерфейсы ONU имеют формат: `gpon_onu-<slot>/<pon>/<onu-id>:<instance>`
- Интерфейсы OLT: `gpon_olt-<slot>/<pon>/<port>`

---

Если нужно — могу оформить это в виде Markdown-файла для скачивания или добавить примеры вывода команд.
