# 1. Check the distribution of slots

You can use 'redis-trib.rb check {master's IP}:{master's Port} | grep slots | grep master' command to check slots assigned to each master. Any master can be used for '{master's IP}:{master's Port}'.

```
$ redis-trib.rb check 192.168.111.201:18800 | grep slots | grep master

   slots:0-818 (819 slots) master

   slots:3277-4095 (819 slots) master

   slots:5734-6553 (820 slots) master

   slots:7373-8191 (819 slots) master

   slots:13926-14745 (820 slots) master

   slots:4096-4914 (819 slots) master

   slots:8192-9010 (819 slots) master

   slots:2458-3276 (819 slots) master

   slots:9011-9829 (819 slots) master

   slots:10650-11468 (819 slots) master

   slots:11469-12287 (819 slots) master

   slots:1638-2457 (820 slots) master

   slots:12288-13106 (819 slots) master

   slots:15565-16383 (819 slots) master

   slots:9830-10649 (820 slots) master

   slots:819-1637 (819 slots) master

   slots:6554-7372 (819 slots) master

   slots:4915-5733 (819 slots) master

   slots:13107-13925 (819 slots) master

   slots:14746-15564 (819 slots) master
```


# 2. Check the distribution of redis-servers
```
$ flashbase check-distribution

check distribution of masters/slaves...

SERVER NAME     | M | S

--------------------------------

192.168.111.201 | 10 | 10

192.168.111.202 | 10 | 10

--------------------------------

Total nodes     | 20 | 20

```


# 3. Scale out

Open 'redis.properties' with 'flashbase edit' command.
```
$ flashbase edit
```

Add a new node("192.168.111.203").

**As-is**
```
#!/bin/bash

## Master hosts and ports
export SR2_REDIS_MASTER_HOSTS=( "192.168.111.201" "192.168.111.202" )
export SR2_REDIS_MASTER_PORTS=( $(seq 18800 18809) )

## Slave hosts and ports (optional)
export SR2_REDIS_SLAVE_HOSTS=( "192.168.111.201" "192.168.111.202" )
export SR2_REDIS_SLAVE_PORTS=( $(seq 18850 18859) )
```

**To-be**
```
#!/bin/bash

## Master hosts and ports

export SR2_REDIS_MASTER_HOSTS=( "192.168.111.201" "192.168.111.202" "192.168.111.203" )
export SR2_REDIS_MASTER_PORTS=( $(seq 18800 18809) )

## Slave hosts and ports (optional)
export SR2_REDIS_SLAVE_HOSTS=( "192.168.111.201" "192.168.111.202" "192.168.111.203" )
export SR2_REDIS_SLAVE_PORTS=( $(seq 18850 18859) )
```

Scale out the cluster with a 'flashbase scale-out {new node's IP}' command. If you add more than one node, you can use like 'flashbase scale-out 192.168.111.203 192.168.111.204 192.168.111.205'.

```
$ flashbase scale-out 192.168.111.203
```

# 4. Check the new distribution of slots
```
$ redis-trib.rb check 192.168.111.201:18800 | grep master | grep slot
   slots:273-818 (546 slots) master
   slots:11742-12287 (546 slots) master
   slots:0-272,10650-10921,14198-14199 (547 slots) master
   slots:10922,11469-11741,14746-15018 (547 slots) master
   slots:6827-7372 (546 slots) master
   slots:1912-2457 (546 slots) master
   slots:6008-6553 (546 slots) master
   slots:7646-8191 (546 slots) master
   slots:1911,5734-6007,13926-14197 (547 slots) master
   slots:5188-5733 (546 slots) master
   slots:13380-13925 (546 slots) master
   slots:1092-1637 (546 slots) master
   slots:1638-1910,9830-10103 (547 slots) master
   slots:3550-4095 (546 slots) master
   slots:7373-7645,8192-8464 (546 slots) master
   slots:14200-14745 (546 slots) master
   slots:2458-2730,4096-4368 (546 slots) master
   slots:4369-4914 (546 slots) master
   slots:9284-9829 (546 slots) master
   slots:12561-13106 (546 slots) master
   slots:6554-6826,15565-15837 (546 slots) master
   slots:9011-9283,12288-12560 (546 slots) master
   slots:4915-5187,13107-13379 (546 slots) master
   slots:15019-15564 (546 slots) master
   slots:10923-11468 (546 slots) master
   slots:819-1091,3277-3549 (546 slots) master
   slots:8465-9010 (546 slots) master
   slots:2731-3276 (546 slots) master
   slots:15838-16383 (546 slots) master
   slots:10104-10649 (546 slots) master
```

# 5. Check the new distribution of redis-servers
```
$ fb check-distribution
check distribution of masters/slaves...
SERVER NAME	    |	M	|	S
--------------------------------
192.168.111.201	|	10	|	10
192.168.111.202	|	10	|	10
192.168.111.203	|	10	|	10
--------------------------------
Total nodes	    |	30	|	30
```
