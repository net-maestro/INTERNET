# BPDU_PROTECTION

```
enable bpdu_protection
config bpdu_protection recovery_timer 300
config bpdu_protection ports 1-24 state enable 
config bpdu_protection ports 1-24 mode drop
config bpdu_protection ports 25-26 mode shutdown
```


Состояние «под атакой» имеет три режима: 

drop — отбрасываются все пакеты BPDU;
block  — отбрасываются все пакеты;
shutdown — порт отключается.



Команда config bpdu_protection [trap | log] [none | attack_detected | attack_cleared | both] используется для указания, когда информация об атаке логируется (log) или отправляется trap (trap):

none — указывает, что ни attack_detected, ни attack_cleared  не регистрируются;
attack_detected — указывает, что события будут регистрироваться при обнаружении атак BPDU;
attack_cleared — указывает, что события будут регистрироваться , когда удалены атаки BPDU.
Включается BPDU Protection глобально на коммутаторе командой enable bpdu_protection.
