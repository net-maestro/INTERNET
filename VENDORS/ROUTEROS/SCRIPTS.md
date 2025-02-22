```bash
:foreach queue in=[/queue simple find where target~"172.16.107"] do={:log info ("Found queue with target " . [/queue simple get $queue target])
```
