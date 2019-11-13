# 1. cluster start

  **Procedure**

(1) Backup logs of the previous master/slave nodes

- All log files of previous master/slave nodes in '${SR2_HOME}[^1]/logs/redis/' will be moved to '${SR2_HOME}/logs/redis/backup/'.


(2) Generate directories to save data

- Save aof and rdb files of redis-server and RocksDB files in '${SR2_REDIS_DATA}'


(3) Start redis-server process

- Start master and slave redis-server with '${SR2_HOME}/conf/redis/redis-{port}.conf' file
- Log files will be saved in '${SR2_HOME}/logs/redis/'

``` bash
> cluster start
Check status of hosts ...
OK
Check cluster exist...

...

OK
Backup redis master log in each MASTER hosts...

...

Starting master nodes : nodeA : 18100 ...

...

Starting slave nodes : nodeA : 18150|18151 ...

...

Wait until all redis process up...
cur: 0 / total: 12

...

cur: 12 / total: 12
Complete all redis process up.
```

**Error Handling**

(1) ErrorCode 11

Redis-server(master) process with same port is already running. To resolve this error, use 'cluster stop' or 'kill {pid of the process}'.

``` bash
$ cluster start
...
...
[ErrorCode 11] Fail to start... Must be checked running MASTER redis processes!
We estimate that redis process is <alive-redis-count>.
```

(2) ErrorCode 12

Redis-server(slave) process with same port is already running. To resolve this error, use 'cluster stop' or 'kill {pid of the process}'.

``` bash
$ cluster start
...
[ErrorCode 12] Fail to start... Must be checked running SLAVE redis processes!
We estimate that redis process is <alive-redis-count>.
```

(3) Conf file not exist

Conf file is not found. To resove this error, use 'cluster configure' and then 'cluster start'.
cluster configure 명령어를 실행시킨 후 cluster start를 진행하세요.

``` bash
$ cluster start
...
FileNotExistError: ${SR2_HOME}/conf/redis/redis-{port}.conf
```

(4) max try error
​
For detail information, please check log files.

``` bash
$ cluster start
...
max try error
```


# 2. cluster stop

​Gracefully kill all redis-servers(master/slave) with SIGINT
​​
**Options**

(1) Force to kill all redis-servers(master/slave) with SIGKILL


``` bash
--force
```


# 3. cluster create

After checking information of the cluster, create cluster of LightningDB.

``` bash
> cluster create
>>> Creating cluster
+-------+-------+--------+
| HOST  | PORT  | TYPE   |
+-------+-------+--------+
| nodeA | 18100 | MASTER |
| nodeB | 18100 | MASTER |
|   .       .       .    |
|   .       .       .    |
|   .       .       .    |
| nodeD | 18150 | SLAVE  |
| nodeD | 18151 | SLAVE  |
+-------+-------+--------+
Do you want to proceed with the create according to the above information? (y/n)
y
replicas: 2.00
replicate [M] nodeA 18100 - [S] nodeA 18150
replicate [M] nodeD 18100 - [S] nodeD 18151
1 / 8 meet complete.
2 / 8 meet complete.

...

8 / 8 meet complete.
create cluster complete.
```
​​

# 4. cluster clean


**Procedure​**


(1) Remove conf files for redis-server

(2) Remove all data(aof, rdb, RocksDB) of LightningDB



# 5. cluster restart​

Process 'cluster stop' and then 'cluster start'.​​

**Options**


(1) Force to kill all redis-servers(master/slave) with SIGKILL and then start again.

``` bash
--force-stop
```

(2) Remove all data(aof, rdb, RocksDB, conf files) before start again.

``` bash
--reset
```
 
(3) Process 'cluster create'. This command should be called with '--reset'.

``` bash
--cluster
```

## 6. Check Cluster Infos


``` bash
cli ping --all
```

Send PING to all redis-server processes and check if all of them are healthy.

``` bash
cli cluster info
```

Check information of the cluster.

``` bash
cli cluster nodes
```

List up all redis-server processes that compose the cluster.


​
​
[^1]: If user types 'cfc 1', ${SR2_HOME} will be '~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT'.
