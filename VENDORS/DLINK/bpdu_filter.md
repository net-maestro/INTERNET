# BPDU_PROTECTION

```
enable bpdu_protection
config bpdu_protection recovery_timer 300
config bpdu_protection ports 2:24 state enable 
config bpdu_protection ports 2:24 mode drop
config bpdu_protection ports 1:1-1:24,2:1-2:23 mode shutdown
```
