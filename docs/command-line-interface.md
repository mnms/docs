
# 1. Cluster Commands

If you want to see the list of cluster commands, use the 'cluster' command without any option.


``` bash
ec2-user@flashbase:1> cluster

NAME
    fbctl cluster - This is cluster command

SYNOPSIS
    fbctl cluster COMMAND

DESCRIPTION
    This is cluster command

COMMANDS
    COMMAND is one of the following:

     add_slave
       Add slaves to cluster additionally

     clean
       Clean cluster

     configure

     create
       Create cluster

     ls
       Check cluster list

     rebalance
       Rebalance

     restart
       Restart redist cluster

     rowcount
       Query and show cluster row count

     start
       Start cluster

     stop
       Stop cluster

     use
       Change selected cluster
```

## (1) cluster configure

redis-{port}.conf is generated with using redis-{master/slave}.conf.template and redis.properties.

``` bash
> cluster configure
```

## (2) cluster start

- Backup logs of the previous master/slave nodes
    - All log files of previous master/slave nodes in '${SR2_HOME}[^1]/logs/redis/' will be moved to '${SR2_HOME}/logs/redis/backup/'.

- Generate directories to save data
    - Save aof and rdb files of redis-server and RocksDB files in '${SR2_REDIS_DATA}'

- Start redis-server process
    - Start master and slave redis-server with '${SR2_HOME}/conf/redis/redis-{port}.conf' file
- Log files will be saved in '${SR2_HOME}/logs/redis/'

``` bash
ec2-user@flashbase:1> cluster start
Check status of hosts...
OK
Check cluster exist...
 - 127.0.0.1
OK
Backup redis master log in each MASTER hosts...
 - 127.0.0.1
Generate redis configuration files for master hosts
sync conf
+-----------+--------+
| HOST      | STATUS |
+-----------+--------+
| 127.0.0.1 | OK     |
+-----------+--------+
Starting master nodes : 127.0.0.1 : 18100|18101|18102|18103|18104 ...
Wait until all redis process up...
cur: 5 / total: 5
Complete all redis process up
```

**Errors**

- ErrorCode 11

Redis-server(master) process with same port is already running. To resolve this error, use 'cluster stop' or 'kill {pid of the process}'.

``` bash
$ cluster start
...
...
[ErrorCode 11] Fail to start... Must be checked running MASTER redis processes!
We estimate that redis process is <alive-redis-count>.
```

- ErrorCode 12

Redis-server(slave) process with same port is already running. To resolve this error, use 'cluster stop' or 'kill {pid of the process}'.

``` bash
$ cluster start
...
[ErrorCode 12] Fail to start... Must be checked running SLAVE redis processes!
We estimate that redis process is <alive-redis-count>.
```

- Conf file not exist

Conf file is not found. To resove this error, use 'cluster configure' and then 'cluster start'.
cluster configure 명령어를 실행시킨 후 cluster start를 진행하세요.

``` bash
$ cluster start
...
FileNotExistError: ${SR2_HOME}/conf/redis/redis-{port}.conf
```

- max try error
​
For detail information, please check log files.

``` bash
$ cluster start
...
max try error
```

## (3) cluster create

After checking information of the cluster, create cluster of LightningDB.

``` bash
ec2-user@flashbase:1> cluster create
Check status of hosts...
OK
>>> Creating cluster
+-----------+-------+--------+
| HOST      | PORT  | TYPE   |
+-----------+-------+--------+
| 127.0.0.1 | 18100 | MASTER |
| 127.0.0.1 | 18101 | MASTER |
| 127.0.0.1 | 18102 | MASTER |
| 127.0.0.1 | 18103 | MASTER |
| 127.0.0.1 | 18104 | MASTER |
+-----------+-------+--------+
replicas: 0

Do you want to proceed with the create according to the above information? (y/n)
y
Cluster meet...
 - 127.0.0.1:18100
 - 127.0.0.1:18103
 - 127.0.0.1:18104
 - 127.0.0.1:18101
 - 127.0.0.1:18102
Adding slots...
 - 127.0.0.1:18100, 3280
 - 127.0.0.1:18103, 3276
 - 127.0.0.1:18104, 3276
 - 127.0.0.1:18101, 3276
 - 127.0.0.1:18102, 3276
Check cluster state and asign slot...
Ok
create cluster complete.
```



**Errors**

When redis servers are not running, this error(Errno 111) will occur. To solve this error, use 'cluster start' command previously.

``` bash
ec2-user@flashbase:1> cluster create
Check status of hosts...
OK
>>> Creating cluster
+-----------+-------+--------+
| HOST      | PORT  | TYPE   |
+-----------+-------+--------+
| 127.0.0.1 | 18100 | MASTER |
| 127.0.0.1 | 18101 | MASTER |
| 127.0.0.1 | 18102 | MASTER |
| 127.0.0.1 | 18103 | MASTER |
| 127.0.0.1 | 18104 | MASTER |
+-----------+-------+--------+
replicas: 0

Do you want to proceed with the create according to the above information? (y/n)
y
127.0.0.1:18100 - [Errno 111] Connection refused
```

​​
## (4) cluster stop

​Gracefully kill all redis-servers(master/slave) with SIGINT
​​
``` bash
ec2-user@flashbase:1> cluster stop
Check status of hosts...
OK
Stopping master cluster of redis...
cur: 5 / total: 5
cur: 0 / total: 5
Complete all redis process down
```

**Options**

- Force to kill all redis-servers(master/slave) with SIGKILL


``` bash
--force
```

## (5) cluster clean

Remove conf files for redis-server and all data(aof, rdb, RocksDB) of LightningDB

``` bash
ec2-user@flashbase:1> cluster clean
Removing redis generated master configuration files
 - 127.0.0.1
Removing flash db directory, appendonly and dump.rdb files in master
 - 127.0.0.1
Removing master node configuration
 - 127.0.0.1
```

## (6) cluster restart​

Process 'cluster stop' and then 'cluster start'.​​

**Options**


- Force to kill all redis-servers(master/slave) with SIGKILL and then start again.

``` bash
--force-stop
```

- Remove all data(aof, rdb, RocksDB, conf files) before start again.

``` bash
--reset
```
 
- Process 'cluster create'. This command should be called with '--reset'.

``` bash
--cluster
```

## (7) Check Cluster Infos

With the following commands, you can check the status of the cluster.

- Send PING

``` bash
> cli ping --all
```

- Check the status of the cluster

``` bash
> cli cluster info
```

- Check the list of the nodes those are organizing the cluster.

``` bash
ec2-user@flashbase:1> cli cluster nodes
559af5e90c3f2c92f19c927c29166c268d938e8f 127.0.0.1:18104 master - 0 1574127926000 4 connected 6556-9831
174e2a62722273fb83814c2f12e2769086c3d185 127.0.0.1:18101 myself,master - 0 1574127925000 3 connected 9832-13107
35ab4d3f7f487c5332d7943dbf4b20d5840053ea 127.0.0.1:18100 master - 0 1574127926000 1 connected 0-3279
f39ed05ace18e97f74c745636ea1d171ac1d456f 127.0.0.1:18103 master - 0 1574127927172 0 connected 3280-6555
9fd612b86a9ce1b647ba9170b8f4a8bfa5c875fc 127.0.0.1:18102 master - 0 1574127926171 2 connected 13108-16383
```

​
[^1]: If user types 'cfc 1', ${SR2_HOME} will be '~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT'.
