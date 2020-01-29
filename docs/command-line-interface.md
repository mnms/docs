
!!! Note
    Command Line Interface(CLI) of LightningDB supports not only deploy and start command but also many commands to access and manipulate data in LightningDB.

# 1. Cluster Commands

If you want to see the list of cluster commands, use the `cluster` command without any option.

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

**(1) Cluster configure**

`redis-{port}.conf` is generated with using `redis-{master/slave}.conf.template` and `redis.properties` files.

``` bash
> cluster configure
```

**(2) Cluster start**

- Backup logs of the previous master/slave nodes
    - All log files of previous master/slave nodes in `${SR2_HOME}/logs/redis/`[^1] will be moved to `${SR2_HOME}/logs/redis/backup/`.
- Generate directories to save data
    - Save aof and rdb files of redis-server and RocksDB files in `${SR2_REDIS_DATA}`
- Start redis-server process
    - Start master and slave redis-server with `${SR2_HOME}/conf/redis/redis-{port}.conf` file
- Log files will be saved in `${SR2_HOME}/logs/redis/`

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

Redis-server(master) process with the same port is already running. To resolve this error, use `cluster stop` or `kill {pid of the process}`.

``` bash
$ cluster start
...
...
[ErrorCode 11] Fail to start... Must be checked running MASTER redis processes!
We estimate that redis process is <alive-redis-count>.
```

- ErrorCode 12

Redis-server(slave) process with the same port is already running. To resolve this error, use `cluster stop` or `kill {pid of the process}`.

``` bash
$ cluster start
...
[ErrorCode 12] Fail to start... Must be checked running SLAVE redis processes!
We estimate that redis process is <alive-redis-count>.
```

- Conf file not exist

Conf file is not found. To resove this error, use `cluster configure` and then `cluster start`.

``` bash
$ cluster start
...
FileNotExistError: ${SR2_HOME}/conf/redis/redis-{port}.conf
```

- Max try error
​
For detail information, please check the log files.

``` bash
$ cluster start
...
ClusterRedisError: Fail to start redis: max try exceed
Recommendation Command: 'monitor'
```

**(3) Cluster create**

After checking the information of the cluster, create a cluster of LightningDB.

**Case 1)** When redis-server processes are running, create a cluster only.

``` bash
ec2-user@flashbase:1>`cluster create`
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

**Case 2)** When redis-server processes are not running, create a cluster after launching redis-server processes with `cluster start` command.

``` bash
ec2-user@flashbase:4>`cluster create`
Check status of hosts...
OK
Backup redis master log in each MASTER hosts...
 - 127.0.0.1
create redis data directory in each MASTER hosts
 - 127.0.0.1
sync conf
+-----------+--------+
| HOST      | STATUS |
+-----------+--------+
| 127.0.0.1 | OK     |
+-----------+--------+
OK
Starting master nodes : 127.0.0.1 : 18100|18101|18102|18103|18104 ...
Wait until all redis process up...
cur: 5 / total: 5
Complete all redis process up
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
 - 127.0.0.1:18103
 - 127.0.0.1:18104
 - 127.0.0.1:18101
 - 127.0.0.1:18102
 - 127.0.0.1:18100
Adding slots...
 - 127.0.0.1:18103, 3280
 - 127.0.0.1:18104, 3276
 - 127.0.0.1:18101, 3276
 - 127.0.0.1:18102, 3276
 - 127.0.0.1:18100, 3276
Check cluster state and asign slot...
Ok
create cluster complete.
```

**Errors**

When redis servers are not running, this error(Errno 111) will occur. To solve this error, use `cluster start` command previously.

``` bash
ec2-user@flashbase:1>`cluster create`
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

**(4) Cluster stop**

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

**(5) Cluster clean**

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

**(6) Cluster restart​**

Process `cluster stop` and then `cluster start`.​​

**Options**

- Force to kill all redis-servers(master/slave) with SIGKILL and then start again.

``` bash
--force-stop
```

- Remove all data(aof, rdb, RocksDB, conf files) before starting again.

``` bash
--reset
```

- Process `cluster create`. This command should be called with `--reset`.

``` bash
--cluster
```

**(7) Cluster ls**

List the deployed clusters.

``` bash
ec2-user@flashbase:2> cluster ls
[1, 2]
```

**(8) Cluster use**

Change the cluster to use FBCTL. Use `cluster use` or `c` commands.

``` bash
ec2-user@flashbase:2> cluster use 1
Cluster '1' selected.
ec2-user@flashbase:1> c 2
Cluster '2' selected.
```

**(9) Cluster add_slave**

!!! Warning
    Before using the `add-slave` command, ingestion to master nodes should be stopped. After replication and sync between master and slave are completed, ingestion will be available again.

You can add a slave to a cluster that is configured only with the master without redundancy.

- Create cluster only with masters
    - Procedure for configuring the test environment. If cluster with the only masters already exists, go to the **add slave info**.

- Proceed with the deploy.
    - Enter 0 in replicas as shown below when deploy.

``` bash
ec2-user@flashbase:2> deploy 3
Select installer

    [ INSTALLER LIST ]
    (1) flashbase.dev.master.5a6a38.bin

Please enter the number, file path or url of the installer you want to use.
you can also add file in list by copy to '$FBPATH/releases/'
https://flashbase.s3.ap-northeast-2.amazonaws.com/flashbase.dev.master.5a6a38.bin
Downloading flashbase.dev.master.5a6a38.bin
[==================================================] 100%
OK, flashbase.dev.master.5a6a38.bin
Please type host list separated by comma(,) [127.0.0.1]

OK, ['127.0.0.1']
How many masters would you like to create on each host? [5]

OK, 5
Please type ports separate with comma(,) and use hyphen(-) for range. [18300-18304]

OK, ['18300-18304']
How many replicas would you like to create on each master? [0]

OK, 0
How many ssd would you like to use? [3]

OK, 3
Type prefix of db path [~/sata_ssd/ssd_]

OK, ~/sata_ssd/ssd_
+--------------+---------------------------------+
| NAME         | VALUE                           |
+--------------+---------------------------------+
| installer    | flashbase.dev.master.5a6a38.bin |
| hosts        | 127.0.0.1                       |
| master ports | 18300-18304                     |
| ssd count    | 3                               |
| db path      | ~/sata_ssd/ssd_                 |
+--------------+---------------------------------+
Do you want to proceed with the deploy accroding to the above information? (y/n)
y
Check status of hosts...
+-----------+--------+
| HOST      | STATUS |
+-----------+--------+
| 127.0.0.1 | OK     |
+-----------+--------+
OK
Checking for cluster exist...
+-----------+--------+
| HOST      | STATUS |
+-----------+--------+
| 127.0.0.1 | CLEAN  |
+-----------+--------+
OK
Transfer installer and execute...
 - 127.0.0.1
Sync conf...
Complete to deploy cluster 3.
Cluster '3' selected.
```

- When the deploy is complete, start and create the cluster.

``` bash
ec2-user@flashbase:3> cluster start
Check status of hosts...
OK
Check cluster exist...
 - 127.0.0.1
OK
Backup redis master log in each MASTER hosts...
 - 127.0.0.1
create redis data directory in each MASTER hosts
 - 127.0.0.1
sync conf
+-----------+--------+
| HOST      | STATUS |
+-----------+--------+
| 127.0.0.1 | OK     |
+-----------+--------+
OK
Starting master nodes : 127.0.0.1 : 18300|18301|18302|18303|18304 ...
Wait until all redis process up...
cur: 5 / total: 5
Complete all redis process up
ec2-user@flashbase:3> cluster create
Check status of hosts...
OK
>>> Creating cluster
+-----------+-------+--------+
| HOST      | PORT  | TYPE   |
+-----------+-------+--------+
| 127.0.0.1 | 18300 | MASTER |
| 127.0.0.1 | 18301 | MASTER |
| 127.0.0.1 | 18302 | MASTER |
| 127.0.0.1 | 18303 | MASTER |
| 127.0.0.1 | 18304 | MASTER |
+-----------+-------+--------+
replicas: 0

Do you want to proceed with the create according to the above information? (y/n)
y
Cluster meet...
 - 127.0.0.1:18300
 - 127.0.0.1:18303
 - 127.0.0.1:18304
 - 127.0.0.1:18301
 - 127.0.0.1:18302
Adding slots...
 - 127.0.0.1:18300, 3280
 - 127.0.0.1:18303, 3276
 - 127.0.0.1:18304, 3276
 - 127.0.0.1:18301, 3276
 - 127.0.0.1:18302, 3276
Check cluster state and asign slot...
Ok
create cluster complete.
ec2-user@flashbase:3>
```

- Add slave info

Open the conf file.

``` bash
ec2-user@flashbase:3> conf cluster
```

You can modify redis.properties by entering the command as shown above.

``` bash
#!/bin/bash

## Master hosts and ports
export SR2_REDIS_MASTER_HOSTS=( "127.0.0.1" )
export SR2_REDIS_MASTER_PORTS=( $(seq 18300 18304) )

## Slave hosts and ports (optional)
#export SR2_REDIS_SLAVE_HOSTS=( "127.0.0.1" )
#export SR2_REDIS_SLAVE_PORTS=( $(seq 18600 18609) )

## only single data directory in redis db and flash db
## Must exist below variables; 'SR2_REDIS_DATA', 'SR2_REDIS_DB_PATH' and 'SR2_FLASH_DB_PATH'
#export SR2_REDIS_DATA="/nvdrive0/nvkvs/redis"
#export SR2_REDIS_DB_PATH="/nvdrive0/nvkvs/redis"
#export SR2_FLASH_DB_PATH="/nvdrive0/nvkvs/flash"

## multiple data directory in redis db and flash db
export SSD_COUNT=3
#export HDD_COUNT=3
export SR2_REDIS_DATA="~/sata_ssd/ssd_"
export SR2_REDIS_DB_PATH="~/sata_ssd/ssd_"
export SR2_FLASH_DB_PATH="~/sata_ssd/ssd_"

#######################################################
# Example : only SSD data directory
#export SSD_COUNT=3
#export SR2_REDIS_DATA="/ssd_"
#export SR2_REDIS_DB_PATH="/ssd_"
#export SR2_FLASH_DB_PATH="/ssd_"
#######################################################
```

Modify `SR2_REDIS_SLAVE_HOSTS` and `SR2_REDIS_SLAVE_PORTS` as shown below.

``` bash
#!/bin/bash

## Master hosts and ports
export SR2_REDIS_MASTER_HOSTS=( "127.0.0.1" )
export SR2_REDIS_MASTER_PORTS=( $(seq 18300 18304) )

## Slave hosts and ports (optional)
export SR2_REDIS_SLAVE_HOSTS=( "127.0.0.1" )
export SR2_REDIS_SLAVE_PORTS=( $(seq 18350 18354) )

## only single data directory in redis db and flash db
## Must exist below variables; 'SR2_REDIS_DATA', 'SR2_REDIS_DB_PATH' and 'SR2_FLASH_DB_PATH'
#export SR2_REDIS_DATA="/nvdrive0/nvkvs/redis"
#export SR2_REDIS_DB_PATH="/nvdrive0/nvkvs/redis"
#export SR2_FLASH_DB_PATH="/nvdrive0/nvkvs/flash"

## multiple data directory in redis db and flash db
export SSD_COUNT=3
#export HDD_COUNT=3
export SR2_REDIS_DATA="~/sata_ssd/ssd_"
export SR2_REDIS_DB_PATH="~/sata_ssd/ssd_"
export SR2_FLASH_DB_PATH="~/sata_ssd/ssd_"

#######################################################
# Example : only SSD data directory
#export SSD_COUNT=3
#export SR2_REDIS_DATA="/ssd_"
#export SR2_REDIS_DB_PATH="/ssd_"
#export SR2_FLASH_DB_PATH="/ssd_"
#######################################################
```

Save the modification and exit.

``` bash
ec2-user@flashbase:3> conf cluster
Check status of hosts...
OK
sync conf
OK
Complete edit
```

- Execute `cluster add-slave` command

``` bash
ec2-user@flashbase:3> cluster add-slave
Check status of hosts...
OK
Check cluster exist...
 - 127.0.0.1
OK
clean redis conf, node conf, db data of master
clean redis conf, node conf, db data of slave
 - 127.0.0.1
Backup redis slave log in each SLAVE hosts...
 - 127.0.0.1
create redis data directory in each SLAVE hosts
 - 127.0.0.1
sync conf
OK
Starting slave nodes : 127.0.0.1 : 18350|18351|18352|18353|18354 ...
Wait until all redis process up...
cur: 10 / total: 10
Complete all redis process up
replicate [M] 127.0.0.1 18300 - [S] 127.0.0.1 18350
replicate [M] 127.0.0.1 18301 - [S] 127.0.0.1 18351
replicate [M] 127.0.0.1 18302 - [S] 127.0.0.1 18352
replicate [M] 127.0.0.1 18303 - [S] 127.0.0.1 18353
replicate [M] 127.0.0.1 18304 - [S] 127.0.0.1 18354
5 / 5 meet complete.
```

- Check configuration information

``` bash
ec2-user@flashbase:3> cli cluster nodes
0549ec03031213f95121ceff6c9c13800aef848c 127.0.0.1:18303 master - 0 1574132251126 3 connected 3280-6555
1b09519d37ebb1c09095158b4f1c9f318ddfc747 127.0.0.1:18352 slave a6a8013cf0032f0f36baec3162122b3d993dd2c8 0 1574132251025 6 connected
c7dc4815e24054104dff61cac6b13256a84ac4ae 127.0.0.1:18353 slave 0549ec03031213f95121ceff6c9c13800aef848c 0 1574132251126 3 connected
0ab96cb79165ddca7d7134f80aea844bd49ae2e1 127.0.0.1:18351 slave 7e97f8a8799e1e28feee630b47319e6f5e1cfaa7 0 1574132250724 4 connected
7e97f8a8799e1e28feee630b47319e6f5e1cfaa7 127.0.0.1:18301 master - 0 1574132250524 4 connected 9832-13107
e67005a46984445e559a1408dd0a4b24a8c92259 127.0.0.1:18304 master - 0 1574132251126 5 connected 6556-9831
a6a8013cf0032f0f36baec3162122b3d993dd2c8 127.0.0.1:18302 master - 0 1574132251126 2 connected 13108-16383
492cdf4b1dedab5fb94e7129da2a0e05f6c46c4f 127.0.0.1:18350 slave 83b7ef98b80a05a4ee795ae6b399c8cde54ad04e 0 1574132251126 6 connected
f9f7fcee9009f25618e63d2771ee2529f814c131 127.0.0.1:18354 slave e67005a46984445e559a1408dd0a4b24a8c92259 0 1574132250724 5 connected
83b7ef98b80a05a4ee795ae6b399c8cde54ad04e 127.0.0.1:18300 myself,master - 0 1574132250000 1 connected 0-3279

```

**(10) Cluster rowcount**

Check the count of records that are stored in the cluster.

``` bash
ec2-user@flashbase:1> cluster rowcount
0
```

**(11) Check the status of cluster**

With the following commands, you can check the status of the cluster.

- Send PING

``` bash
ec2-user@flashbase:1> cli ping --all
alive redis 10/10
```

If a node does not reply, the fail node will be displayed like below.

``` bash
+-------+-----------------+--------+
| TYPE  | ADDR            | RESULT |
+-------+-----------------+--------+
| Slave | 127.0.0.1:18352 | FAIL   |
+-------+-----------------+--------+
alive redis 9/10
```


- Check the status of the cluster

``` bash
ec2-user@flashbase:1> cli cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:5
cluster_size:5
cluster_current_epoch:4
cluster_my_epoch:2
cluster_stats_messages_ping_sent:12
cluster_stats_messages_pong_sent:14
cluster_stats_messages_sent:26
cluster_stats_messages_ping_received:10
cluster_stats_messages_pong_received:12
cluster_stats_messages_meet_received:4
cluster_stats_messages_received:26
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

**(12) Cluster tree**

User can check the status of master nodes and slaves and show which master and slave nodes are linked. 

``` bash
ec2-user@flashbase:9> cluster tree
127.0.0.1:18900(connected)
|__ 127.0.0.1:18950(connected)

127.0.0.1:18901(connected)
|__ 127.0.0.1:18951(connected)

127.0.0.1:18902(connected)
|__ 127.0.0.1:18952(connected)

127.0.0.1:18903(connected)
|__ 127.0.0.1:18953(connected)

127.0.0.1:18904(connected)
|__ 127.0.0.1:18954(connected)

127.0.0.1:18905(connected)
|__ 127.0.0.1:18955(connected)

127.0.0.1:18906(connected)
|__ 127.0.0.1:18956(connected)
```

**(13) Cluster failover**

If a master node is killed, its slave node will automatically promote after 'cluster-node-time'[^2].

User can promote the slave node immediately by using the 'cluster failover' command.

Step 1) Check the status of the cluster

In this case, '127.0.0.1:18902' node is killed.

``` bash
ec2-user@flashbase:9> cluster tree
127.0.0.1:18900(connected)
|__ 127.0.0.1:18950(connected)

127.0.0.1:18901(connected)
|__ 127.0.0.1:18951(connected)

127.0.0.1:18902(disconnected)   <--- Killed!
|__ 127.0.0.1:18952(connected)

127.0.0.1:18903(connected)
|__ 127.0.0.1:18953(connected)

127.0.0.1:18904(connected)
|__ 127.0.0.1:18954(connected)

127.0.0.1:18905(connected)
|__ 127.0.0.1:18955(connected)

127.0.0.1:18906(connected)
|__ 127.0.0.1:18956(connected)
```

Step 2) Do failover with 'cluster failover' command

``` bash
ec2-user@flashbase:9> cluster failover
failover 127.0.0.1:18952 for 127.0.0.1:18902
OK
ec2-user@flashbase:9> cluster tree
127.0.0.1:18900(connected)
|__ 127.0.0.1:18950(connected)

127.0.0.1:18901(connected)
|__ 127.0.0.1:18951(connected)

127.0.0.1:18902(disconnected)   <--- Killed!

127.0.0.1:18903(connected)
|__ 127.0.0.1:18953(connected)

127.0.0.1:18904(connected)
|__ 127.0.0.1:18954(connected)

127.0.0.1:18905(connected)
|__ 127.0.0.1:18955(connected)

127.0.0.1:18906(connected)
|__ 127.0.0.1:18956(connected)

127.0.0.1:18952(connected)      <--- Promoted to master!
```

**(14) Cluster failover**

With 'cluster failover' command, the killed node is restarted and added to the cluster as the slave node.

``` bash
ec2-user@flashbase:9> cluster failback
run 127.0.0.1:18902
ec2-user@flashbase:9> cluster tree
127.0.0.1:18900(connected)
|__ 127.0.0.1:18950(connected)

127.0.0.1:18901(connected)
|__ 127.0.0.1:18951(connected)

127.0.0.1:18903(connected)
|__ 127.0.0.1:18953(connected)

127.0.0.1:18904(connected)
|__ 127.0.0.1:18954(connected)

127.0.0.1:18905(connected)
|__ 127.0.0.1:18955(connected)

127.0.0.1:18906(connected)
|__ 127.0.0.1:18956(connected)

127.0.0.1:18952(connected)       <--- Promoted to master!
|__ 127.0.0.1:18902(connected)   <--- Failbacked. Now this node is slave!
```

# 2. Thrift Server Commands

If you want to see the list of Thrift Server commands, use the the `thriftserver` command without any option.

``` bash
NAME
    fbctl thriftserver

SYNOPSIS
    fbctl thriftserver COMMAND

COMMANDS
    COMMAND is one of the following:

     beeline
       Connect to thriftserver command line

     monitor
       Show thriftserver log

     restart
       Thriftserver restart

     start
       Start thriftserver

     stop
       Stop thriftserver
```

**(1) Thriftserver beeline**

Connect to the thrift server

``` bash
ec2-user@flashbase:1> thriftserver beeline
Connecting...
Connecting to jdbc:hive2://localhost:13000
19/11/19 04:45:18 INFO jdbc.Utils: Supplied authorities: localhost:13000
19/11/19 04:45:18 INFO jdbc.Utils: Resolved authority: localhost:13000
19/11/19 04:45:18 INFO jdbc.HiveConnection: Will try to open client transport with JDBC Uri: jdbc:hive2://localhost:13000
Connected to: Spark SQL (version 2.3.1)
Driver: Hive JDBC (version 1.2.1.spark2)
Transaction isolation: TRANSACTION_REPEATABLE_READ
Beeline version 1.2.1.spark2 by Apache Hive
0: jdbc:hive2://localhost:13000> show tables;
+-----------+------------+--------------+--+
| database  | tableName  | isTemporary  |
+-----------+------------+--------------+--+
+-----------+------------+--------------+--+
No rows selected (0.55 seconds)
```

Default value of db url to connect is `jdbc:hive2://$HIVE_HOST:$HIVE_PORT`

You can modify `$HIVE_HOST` and `$HIVE_PORT` by the command `conf thriftserver`

**(2) Thriftserver monitor**

You can view the logs of the thrift server in real-time.

``` bash
ec2-user@flashbase:1> thriftserver monitor
Press Ctrl-C for exit.
19/11/19 04:43:33 INFO storage.BlockManagerMasterEndpoint: Registering block manager ip-172-31-39-147.ap-northeast-2.compute.internal:35909 with 912.3 MB RAM, BlockManagerId(4, ip-172-31-39-147.ap-northeast-2.compute.internal, 35909, None)
19/11/19 04:43:33 INFO cluster.YarnSchedulerBackend$YarnDriverEndpoint: Registered executor NettyRpcEndpointRef(spark-client://Executor) (172.31.39.147:53604) with ID 5
19/11/19 04:43:33 INFO storage.BlockManagerMasterEndpoint: Registering block manager
...
```

**(3) Thriftserver restart**

Restart the thrift server.

``` bash
ec2-user@flashbase:1> thriftserver restart
no org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 to stop
starting org.apache.spark.sql.hive.thriftserver.HiveThriftServer2, logging to /opt/spark/logs/spark-ec2-user-org.apache.spark.sql.hive.thriftserver.HiveThriftServer2-1-ip-172-31-39-147.ap-northeast-2.compute.internal.out
```

**(4) Start thriftserver**

Run the thrift server.

``` bash
ec2-user@flashbase:1> thriftserver start
starting org.apache.spark.sql.hive.thriftserver.HiveThriftServer2, logging to /opt/spark/logs/spark-ec2-user-org.apache.spark.sql.hive.thriftserver.HiveThriftServer2-1-ip-172-31-39-147.ap-northeast-2.compute.internal.out
```

You can view the logs through the command `monitor`.

**(5) Stop thriftserver**

Shut down the thrift server.

``` bash
ec2-user@flashbase:1> thriftserver stop
stopping org.apache.spark.sql.hive.thriftserver.HiveThriftServer2
```

**(6) Conf thriftserver**

``` bash
ec2-user@flashbase:1> conf thriftserver

#!/bin/bash
###############################################################################
# Common variables
SPARK_CONF=${SPARK_CONF:-$SPARK_HOME/conf}
SPARK_BIN=${SPARK_BIN:-$SPARK_HOME/bin}
SPARK_SBIN=${SPARK_SBIN:-$SPARK_HOME/sbin}
SPARK_LOG=${SPARK_LOG:-$SPARK_HOME/logs}

SPARK_METRICS=${SPARK_CONF}/metrics.properties
SPARK_UI_PORT=${SPARK_UI_PORT:-14050}
EXECUTERS=12
EXECUTER_CORES=32

HIVE_METASTORE_URL=''
HIVE_HOST=${HIVE_HOST:-localhost}
HIVE_PORT=${HIVE_PORT:-13000}

COMMON_CLASSPATH=$(find $SR2_LIB -name 'tsr2*' -o -name 'spark-r2*' -o -name '*jedis*' -o -name 'commons*' -o -name 'jdeferred*' \
-o -name 'geospark*' -o -name 'gt-*' | tr '\n' ':')

###############################################################################
# Driver
DRIVER_MEMORY=6g
DRIVER_CLASSPATH=$COMMON_CLASSPATH

###############################################################################
# Execute
EXECUTOR_MEMORY=2g
EXECUTOR_CLASSPATH=$COMMON_CLASSPATH

###############################################################################
# Thrift Server logs
EVENT_LOG_ENABLED=false
EVENT_LOG_DIR=/nvdrive0/thriftserver-event-logs
EVENT_LOG_ROLLING_DIR=/nvdrive0/thriftserver-event-logs-rolling
EVENT_LOG_SAVE_MIN=60
EXTRACTED_EVENT_LOG_SAVE_DAY=5
SPARK_LOG_SAVE_MIN=2000
##############
```

[^1]: If user types 'cfc 1', ${SR2_HOME} will be '~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT'.
[^2]: 'cluster-node-time' can be set with using 'config set' command. Its default time is 1200,000 msec.
