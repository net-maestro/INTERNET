Да, именно UFW — нет, не может подвесить саму VM вместе с консолью гипервизора.

UFW работает в userspace/netfilter и максимум что делает:

* режет пакеты,
* создаёт нагрузку на conntrack при огромном трафике,
* иногда может вызвать network lag.

Но:

* freeze консоли hypervisor,
* watchdog timeout journald,
* RX errors на NIC

— это уже уровень:

* kernel,
* драйвера,
* виртуального железа,
* hypervisor backend.

И после перехода:

```text id="thozr5"
e1000e -> virtio_net
```

у тебя исчезли:

```text id="wk5r8y"
RX errors
```

Это очень сильное подтверждение, что проблема была именно в виртуальном NIC/driver path.

---

Вот хороший набор команд для будущего дебага Linux VM.

# 1. Проверка жив ли kernel

## Magic SysRq

Включить один раз:

```bash id="b5pnpr"
echo "kernel.sysrq = 1" > /etc/sysctl.d/99-sysrq.conf
sysctl --system
```

При зависании:

## показать stack traces задач

```bash id="xb5c5m"
echo t > /proc/sysrq-trigger
```

## показать hung tasks

```bash id="8ixc3q"
echo w > /proc/sysrq-trigger
```

## memory info

```bash id="c3mk8r"
echo m > /proc/sysrq-trigger
```

Если это работает —
ядро живо.

Если нет —
hard lockup/hypervisor freeze.

---

# 2. Главные логи после ребута

## ошибки прошлого boot

```bash id="0tl7b0"
journalctl -b -1 -p err
```

## kernel log прошлого boot

```bash id="t1v96m"
journalctl -k -b -1
```

## последние 200 строк kernel

```bash id="54n7tw"
journalctl -k -b -1 -n 200
```

---

# 3. Искать kernel проблемы

```bash id="7a2h3q"
journalctl -k -b -1 | grep -Ei 'error|fail|timeout|lockup|hung|stall|oom|reset'
```

---

# 4. Проверка NIC

## драйвер

```bash id="m1wwsl"
ethtool -i ens18
```

## статистика интерфейса

```bash id="sh8o8v"
ip -s link show ens18
```

Важно:

* RX errors
* dropped
* carrier

---

# 5. Смотреть ошибки в realtime

```bash id="wzoh2j"
watch -n1 'ip -s link show ens18'
```

---

# 6. Проверка диска/IO

```bash id="0c8vys"
dmesg -T | grep -Ei 'blk|I/O|ext4|xfs|reset|timeout'
```

---

# 7. Проверка памяти/OOM

```bash id="f6k2cl"
dmesg -T | grep -i oom
```

```bash id="yjvlgo"
free -h
```

---

# 8. Проверка нагрузки

```bash id="83pdgj"
top
```

или лучше:

```bash id="x4kgx4"
htop
```

---

# 9. Проверка stuck IO

```bash id="r6qqs3"
ps aux | awk '$8 ~ /D/'
```

Если процессы в `D` state —
обычно storage/kernel wait.

---

# 10. Проверка сети

## кто слушает порты

```bash id="jlwmgb"
ss -lntp
```

## активные соединения

```bash id="v6fjv1"
ss -s
```

---

# 11. Проверка firewall

```bash id="2awf2u"
ufw status verbose
```

```bash id="98k6ws"
iptables -L -n -v
```

---

# 12. Проверка systemd failed units

```bash id="m6m6vx"
systemctl --failed
```

---

# 13. Проверка watchdog/timeouts

```bash id="2jg4i4"
journalctl | grep -Ei 'watchdog|timeout'
```

---

# 14. Проверка hypervisor-related проблем

## virtio driver

```bash id="1yyrgr"
lsmod | grep virtio
```

## dmesg virtio

```bash id="u4v4mk"
dmesg -T | grep -i virtio
```

---

# 15. Полезный realtime debug

Очень полезно держать:

```bash id="s3xhkk"
journalctl -f
```

или:

```bash id="ux2jmk"
dmesg -w
```

---

# 16. Что почти всегда подозрительно в VM

Если видишь:

* RX/TX errors,
* NETDEV WATCHDOG,
* soft lockup,
* journald watchdog timeout,
* hung task,
* random freeze,

то проверять:

1. NIC model
2. VirtIO
3. storage latency
4. host overload
5. ballooning
6. offloading

---

# 17. Для Proxmox особенно

Лучшие практики:

* NIC = VirtIO
* Disk = VirtIO SCSI
* qemu-guest-agent installed
* ballooning OFF если нестабильно
* avoid E1000 unless needed
* latest kernel guest+host

---

# 18. Минимальный "аварийный набор"

Вот прям must-have:

```bash id="mepc4u"
journalctl -b -1 -p err
journalctl -k -b -1 -n 200
ip -s link
ethtool -i ens18
dmesg -T | tail -200
systemctl --failed
free -h
ss -s
```

Этого обычно хватает чтобы за 5 минут понять направление проблемы.


И ещё один очень полезный practical checklist именно для VM freeze/debug.

Сохрани себе.

# Linux VM freeze/debug checklist

## 0. Базовая информация

```bash
uname -a
hostnamectl
uptime
```

---

# 1. Проверка предыдущего падения

## Ошибки прошлого boot

```bash
journalctl -b -1 -p err
```

## Kernel log прошлого boot

```bash
journalctl -k -b -1
```

## Последние 200 строк kernel log

```bash
journalctl -k -b -1 -n 200
```

---

# 2. Поиск явных проблем

```bash
journalctl -k -b -1 | grep -Ei 'error|fail|timeout|lockup|hung|stall|oom|reset'
```

---

# 3. Проверка сетевой карты

## Какой драйвер

```bash
ethtool -i ens18
```

## Ошибки интерфейса

```bash
ip -s link show ens18
```

Смотреть:

* RX errors
* dropped
* carrier

---

# 4. Смотреть network errors realtime

```bash
watch -n1 'ip -s link show ens18'
```

---

# 5. Проверка storage / IO

```bash
dmesg -T | grep -Ei 'blk|I/O|ext4|xfs|reset|timeout'
```

---

# 6. Проверка памяти

```bash
free -h
```

## OOM killer

```bash
dmesg -T | grep -i oom
```

---

# 7. Проверка процессов в D-state

```bash
ps aux | awk '$8 ~ /D/'
```

Если есть процессы в D:

* storage hang
* NFS hang
* kernel wait

---

# 8. Проверка сервисов

```bash
systemctl --failed
```

---

# 9. Проверка listening ports

```bash
ss -lntp
```

---

# 10. Проверка активных соединений

```bash
ss -s
```

---

# 11. Firewall

```bash
ufw status verbose
```

```bash
iptables -L -n -v
```

---

# 12. Realtime logs

## systemd/journal

```bash
journalctl -f
```

## kernel realtime

```bash
dmesg -w
```

---

# 13. Magic SysRq (важно)

## Включить

```bash
echo "kernel.sysrq = 1" > /etc/sysctl.d/99-sysrq.conf
sysctl --system
```

## Stack traces задач

```bash
echo t > /proc/sysrq-trigger
```

## Hung tasks

```bash
echo w > /proc/sysrq-trigger
```

## Memory dump

```bash
echo m > /proc/sysrq-trigger
```

Если это работает при "зависании":

* kernel жив
* userspace/network умерли

Если не работает:

* hard lockup
* hypervisor freeze
* kernel deadlock

---

# 14. Для Proxmox/KVM

Рекомендуется:

* NIC = VirtIO
* Disk = VirtIO SCSI
* qemu-guest-agent installed
* avoid E1000/E1000E
* ballooning OFF если VM нестабильна

---

# 15. Самые подозрительные симптомы

Если видишь:

* RX/TX errors
* NETDEV WATCHDOG
* journald watchdog timeout
* soft lockup
* hung task
* random freeze

Проверять:

1. NIC model
2. VirtIO driver
3. hypervisor load
4. storage latency
5. offloading
6. host kernel logs
