
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

     addslaves
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

## (7) cluster addslaves

You can add slave to a cluster that is configured only with master. You must add the slave information by command [conf cluster](#1-conf-cluster) before running the command. For more detail, see the [Add Slave](run-and-deploy-fbctl.md#4-add-slave).

``` bash
ec2-user@flashbase:1> conf cluster

(edit cluster conf)

ec2-user@flashbase:1> cluster addslaves
Check status of hosts...
OK
Check cluster exist...
 - 127.0.0.1
OK
clean redis conf, node conf, db data of slave
 - 127.0.0.1
Backup redis slave log in each SLAVE hosts...
 - 127.0.0.1
Generate redis configuration files for slave hosts
sync conf
+-----------+--------+
| HOST      | STATUS |
+-----------+--------+
| 127.0.0.1 | OK     |
+-----------+--------+
Starting slave nodes : 127.0.0.1 : 18150|18151|18152|18153|18154 ...
Wait until all redis process up...
cur: 10 / total: 10
Complete all redis process up
replicate [M] 127.0.0.1 18100 - [S] 127.0.0.1 18150
replicate [M] 127.0.0.1 18101 - [S] 127.0.0.1 18151
replicate [M] 127.0.0.1 18102 - [S] 127.0.0.1 18152
replicate [M] 127.0.0.1 18103 - [S] 127.0.0.1 18153
replicate [M] 127.0.0.1 18104 - [S] 127.0.0.1 18154
1 / 5 meet complete.
2 / 5 meet complete.
3 / 5 meet complete.
4 / 5 meet complete.
5 / 5 meet complete.
```

## (8) cluster ls

Shows a list of cluster.

``` bash
ec2-user@flashbase:1> cluster ls 
[1, 2, 10]
```


## (9) cluster use

Select the cluster number to use.

``` bash
ec2-user@flashbase:-> cluster use 1
Cluster '1' selected. 
ec2-user@flashbase:1>
```


# 2. Conf Commands

## (1) conf cluster

Edit props of redis.

``` bash
ec2-user@flashbase:1> conf cluster
```

## (2) conf master

Edit redis master template.

``` bash
ec2-user@flashbase:1> conf master
```

## (3) conf slave

Edit redis slave template.

``` bash
ec2-user@flashbase:1> conf slave
```

## (4) conf thriftserver

Edit props of thriftserver.

``` bash
ec2-user@flashbase:1> conf thriftserver
```
​
[^1]: If user types 'cfc 1', ${SR2_HOME} will be '~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT'.
