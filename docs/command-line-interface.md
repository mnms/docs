!!! Note
    Command Line Interface(CLI) of FlashBase supports not only deploy and start command but also many commands to access and manipulat data in FlashBase.
​
# 1. cluster start

  **Procedure**

(1) Backup logs of the previous master/slave nodes

- All log files of previous master/slave nodes in '${SR2_HOME}[^1]/logs/redis/' will be moved to '${SR2_HOME}/logs/redis/backup/'.


(2) Generate directories to save data

- Save aof and rdb files of redis-server and RocksDB files in '${SR2_REDIS_DATA}'


(3) Start redis-server process

- Start master and slave redis-server with '${SR2_HOME}/conf/redis/redis-{port}.conf' file
- Log files will be saved in '${SR2_HOME}/logs/redis/'


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

To-Do
​​

# 4. cluster clean


**Procedure​**


(1) Remove conf files for redis-server

(2) Remove all data(aof, rdb, RocksDB) of FlashBase



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



​
​
[^1]: If user types 'cfc 1', ${SR2_HOME} will be '~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT'.