!!! Note
    Command Line Interface(CLI) of LightningDB supports not only deploy and start command but also many commands to access and manipulate data in LightningDB.


If you want to see the list of cluster commands, use the `cluster` command without any option.

``` bash
ec2-user@lightningdb:1> cluster

NAME
    ltcli cluster - This is cluster command

SYNOPSIS
    ltcli cluster COMMAND

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


# 1. Deploy and Start

**(1) Cluster configure**

`redis-{port}.conf` is generated with using `redis-{master/slave}.conf.template` and `redis.properties` files.

``` bash
matthew@lightningdb:21> cluster configure
Check status of hosts...
OK
sync conf
+----------------+--------+
| HOST           | STATUS |
+----------------+--------+
| 192.168.111.44 | OK     |
| 192.168.111.41 | OK     |
+----------------+--------+
OK
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
ec2-user@lightningdb:1> cluster start
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
ec2-user@lightningdb:1>cluster create
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
ec2-user@lightningdb:4>cluster create
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
ec2-user@lightningdb:1>cluster create
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
ec2-user@lightningdb:1> cluster stop
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
ec2-user@lightningdb:1> cluster clean
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

**(7) Update version**

You can update LightningDB by using the 'deploy' command.

``` bash
> c 1 // alias of 'cluster use 1'
> deploy
(Watch out) Cluster 1 is already deployed. Do you want to deploy again? (y/n) [n]
y
```

- Select installer

``` bash
Select installer

    [ INSTALLER LIST ]
    (1) lightningdb.release.master.5a6a38.bin
    (2) lightningdb.trial.master.dbcb9e-dirty.bin
    (3) lightningdb.trial.master.dbcb9e.bin

Please enter the number, file path or URL of the installer you want to use.
you can also add a file in list by copy to '$FBPATH/releases/'
1
OK, lightningdb.release.master.5a6a38.bin
```

- Restore

``` bash
Do you want to restore conf? (y/n)
y
```

If the current settings will be reused, type 'y'.

- Check all settings finally
    - Backup path of cluster: ${base-directory}/backup/cluster\_${cluster-id}\_bak\_${time-stamp}
    - Backup path of conf files: $FBAPTH/conf_backup/cluster_${cluster-id}\_conf_bak\_${time-stamp}

``` bash
+-----------------+---------------------------------------------------+
| NAME            | VALUE                                             |
+-----------------+---------------------------------------------------+
| installer       | lightningdb.release.master.5a6a38.bin             |
| nodes           | nodeA                                             |
|                 | nodeB                                             |
|                 | nodeC                                             |
|                 | nodeD                                             |
| master ports    | 18100                                             |
| slave ports     | 18150-18151                                       |
| ssd count       | 3                                                 |
| redis data path | ~/sata_ssd/ssd_                                   |
| redis db path   | ~/sata_ssd/ssd_                                   |
| flash db path   | ~/sata_ssd/ssd_                                   |
+-----------------+---------------------------------------------------+
Do you want to proceed with the deploy accroding to the above information? (y/n)
y
Check status of hosts...
+-----------+--------+
| HOST      | STATUS |
+-----------+--------+
| nodeA     | OK     |
| nodeB     | OK     |
| nodeC     | OK     |
| nodeD     | OK     |
+-----------+--------+
Checking for cluster exist...
+------+--------+
| HOST | STATUS |
+------+--------+
Backup conf of cluster 1...
OK, cluster_1_conf_bak_<time-stamp>
Backup info of cluster 1 at nodeA...
OK, cluster_1_bak_<time-stamp>
Backup info of cluster 1 at nodeB...
OK, cluster_1_bak_<time-stamp>
Backup info of cluster 1 at nodeC...
OK, cluster_1_bak_<time-stamp>
Backup info of cluster 1 at nodeD...
OK, cluster_1_bak_<time-stamp>
Transfer installer and execute...
 - nodeA
 - nodeB
 - nodeC
 - nodeD
Sync conf...
Complete to deploy cluster 1.
Cluster 1 selected.
```

- Restart

``` bash
> cluster restart
```

After the restart, the new version will be applied.


# 2. Monitor

**(1) Cluster use**

Change the cluster to use LTCLI. Use `cluster use` or `c` commands.

**Examples**

``` bash
ec2-user@lightningdb:2> cluster use 1
Cluster '1' selected.
ec2-user@lightningdb:1> c 2
Cluster '2' selected.
```

**(2) Cluster ls**

List the deployed clusters.

**Examples**

``` bash
ec2-user@lightningdb:2> cluster ls
[1, 2]
```

**(3) Cluster rowcount**

Check the count of records that are stored in the cluster.

**Examples**

``` bash
ec2-user@lightningdb:1> cluster rowcount
0
```

**(4) Cluster tree**

User can check the status of master nodes and slaves and show which master and slave nodes are linked. 

**Examples**

``` bash
ec2-user@lightningdb:9> cluster tree
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

**(5) Cluster distribution**

The distribution of Master/Slave nodes are displayed with their hostnames(IP addresses).

**Examples**

```
matthew@lightningdb:21> cluster distribution
+-----------------------+--------+-------+
| HOST                  | MASTER | SLAVE |
+-----------------------+--------+-------+
| fbg04(192.168.111.41) | 4      | 2     |
| fbg05(192.168.111.44) | 2      | 4     |
| TOTAL                 | 6      | 6     |
+-----------------------+--------+-------+
```


# 3. Failover

**(1) Cluster failover_list**

- failovered masters
    - The node, that initialized as a slave by the cluster, becomes a master by failover now.
- no-slave masters
    - Masters without slaves. You need to replicate the failbacked slaves to this node.
- no-slot masters
    - Not yet added into the cluster or masters without slot
- failbacked slaves
    - The nodes, that initialized as a master, becomes a slave by failback now.

**Examples**

```
matthew@lightningdb:21> cluster failover_list

1) failovered masters:
192.168.111.44:20152
192.168.111.44:20153
192.168.111.44:20156

2) no-slave masters:
192.168.111.44:20100
192.168.111.41:20101

3) no-slot masters:
192.168.111.44:20152

4) failbacked slaves:
192.168.111.41:20102
192.168.111.41:20105
```

**(2) Cluster do_replicate**

You can add a node as the slave of a master nodes like `cluster do_replicate {slave's IP}:{slave's Port} {master's IP}:{master's Port}`.

The IP addresses of masters or slaves can be replaced with their hostnames.

**Examples**

```
matthew@lightningdb:21> cluster tree
192.168.111.44:20101(connected)
|__ 192.168.111.44:20151(connected)

192.168.111.44:20102(connected)
|__ 192.168.111.44:20152(connected)

192.168.111.44:20150(connected)
|__ 192.168.111.44:20100(connected)

matthew@lightningdb:21> cluster do_replicate 192.168.111.44:20100 192.168.111.44:20101
Start to replicate...

OK

matthew@lightningdb:21> cluster tree
192.168.111.44:20101(connected)
|__ 192.168.111.44:20100(connected)
|__ 192.168.111.44:20151(connected)

192.168.111.44:20102(connected)
|__ 192.168.111.44:20152(connected)

192.168.111.44:20150(connected)
```

with hostnames,

```
matthew@lightningdb:21> cluster do_replicate fbg05:20100 fbg05:20101
Start to replicate...

OK
```


**(3) Cluster find_noaddr & cluster forget_noaddr**

You can find and remove 'noaddr' nodes in the current cluster.

'noaddr' nodes are no more valid nodes.

**Examples**

```
matthew@lightningdb:21> cluster find_noaddr

+------------------------------------------+
| UUID                                     |
+------------------------------------------+
| 40675af73cd8fa1272a20fe9536ad19c398b5bca |
+------------------------------------------+

matthew@lightningdb:21> cluster forget_noaddr

"27" nodes have forgot "40675af73cd8fa1272a20fe9536ad19c398b5bca"

matthew@lightningdb:21> cluster find_noaddr

+------+
| UUID |
+------+
```

**(4) Cluster failover**

If a master node is killed, its slave node will automatically promote after 'cluster-node-time'[^2].

User can promote the slave node immediately by using the 'cluster failover' command.

**Examples**


Step 1) Check the status of the cluster

In this case, '127.0.0.1:18902' node is killed.

``` bash
ec2-user@lightningdb:9> cluster tree
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
ec2-user@lightningdb:9> cluster failover
failover 127.0.0.1:18952 for 127.0.0.1:18902
OK
ec2-user@lightningdb:9> cluster tree
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

**(5) Cluster failback**

With 'cluster failback' command, the killed node is restarted and added to the cluster as the slave node.

**Examples**

``` bash
ec2-user@lightningdb:9> cluster failback
run 127.0.0.1:18902
ec2-user@lightningdb:9> cluster tree
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

**(6) Cluster reset_distribution**

To initialize the node distribution, use 'reset-distribution'.

**Examples**

```
matthew@lightningdb:21> cluster failover_list
1) failovered masters:
192.168.111.44:20152

2) no-slave masters:

3) no-slot masters:

4) failbacked slaves:
192.168.111.41:20101

matthew@lightningdb:21> cluster reset_distribution
'192.168.111.41:20101' will be master...

OK

matthew@lightningdb:21> cluster failover_list
1) failovered masters:

2) no-slave masters:

3) no-slot masters:

4) failbacked slaves:
```

**(7) Cluster nodes_with_dir & Cluster masters_with_dir**

- Cluster nodes_with_dir
    - List up all nodes those are using the disk with HW fault.
- Cluster masters_with_dir
    - List up all master those are using the disk with HW fault.


**Examples**

```

matthew@lightningdb:21> cluster nodes_with_dir 192.168.111.44 matthew03
+----------------+-------+------------------------------------------+
| HOST           | PORT  | PATH                                     |
+----------------+-------+------------------------------------------+
| 192.168.111.44 | 20102 | /sata_ssd/ssd_02/matthew03/nvkvs/matthew |
| 192.168.111.44 | 20105 | /sata_ssd/ssd_02/matthew03/nvkvs/matthew |
| 192.168.111.44 | 20150 | /sata_ssd/ssd_02/matthew03/nvkvs/matthew |
| 192.168.111.44 | 20153 | /sata_ssd/ssd_02/matthew03/nvkvs/matthew |
| 192.168.111.44 | 20156 | /sata_ssd/ssd_02/matthew03/nvkvs/matthew |
+----------------+-------+------------------------------------------+

matthew@lightningdb:21> cluster masters_with_dir 192.168.111.44 matthew03
+----------------+-------+------------------------------------------+
| HOST           | PORT  | PATH                                     |
+----------------+-------+------------------------------------------+
| 192.168.111.44 | 20102 | /sata_ssd/ssd_02/matthew03/nvkvs/matthew |
| 192.168.111.44 | 20105 | /sata_ssd/ssd_02/matthew03/nvkvs/matthew |
+----------------+-------+------------------------------------------+
```

with hostnames,

```
matthew@lightningdb:21> cluster nodes_with_dir fbg05 matthew02
+-------+-------+------------------------------------------+
| HOST  | PORT  | PATH                                     |
+-------+-------+------------------------------------------+
| fbg05 | 20101 | /sata_ssd/ssd_02/matthew02/nvkvs/matthew |
| fbg05 | 20152 | /sata_ssd/ssd_02/matthew02/nvkvs/matthew |
+-------+-------+------------------------------------------+
matthew@lightningdb:21> cluster masters_with_dir fbg05 matthew02
+-------+-------+------------------------------------------+
| HOST  | PORT  | PATH                                     |
+-------+-------+------------------------------------------+
| fbg05 | 20101 | /sata_ssd/ssd_02/matthew02/nvkvs/matthew |
+-------+-------+------------------------------------------+
```

**(8) Cluster failover_with_dir**

Do failover and change the master using the disk to the slave

**Examples**

```
matthew@lightningdb:21> cluster masters_with_dir 192.168.111.44 matthew03
+----------------+-------+------------------------------------------+
| HOST           | PORT  | PATH                                     |
+----------------+-------+------------------------------------------+
| 192.168.111.44 | 20102 | /sata_ssd/ssd_02/matthew03/nvkvs/matthew |
| 192.168.111.44 | 20105 | /sata_ssd/ssd_02/matthew03/nvkvs/matthew |
+----------------+-------+------------------------------------------+

matthew@lightningdb:21> cluster failover_list
1) failovered masters:

2) no-slave masters:

3) no-slot masters:

4) failbacked slaves:

matthew@lightningdb:21> cluster failover_with_dir 192.168.111.44 matthew03
'192.168.111.41:20152' will be master...
OK

'192.168.111.41:20155' will be master...
OK

matthew@lightningdb:21> cluster failover_list
1) failovered masters:
192.168.111.41:20152
192.168.111.41:20155

2) no-slave masters:

3) no-slot masters:

4) failbacked slaves:
192.168.111.44:20102
192.168.111.44:20105

matthew@lightningdb:21> cluster masters_with_dir 192.168.111.44 matthew03
+------+------+------+
| HOST | PORT | PATH |
+------+------+------+
```

with hostnames,

```
matthew@lightningdb:21> cluster masters_with_dir fbg05 matthew01
+-------+-------+------------------------------------------+
| HOST  | PORT  | PATH                                     |
+-------+-------+------------------------------------------+
| fbg05 | 20151 | /sata_ssd/ssd_02/matthew01/nvkvs/matthew |
+-------+-------+------------------------------------------+
matthew@lightningdb:21> cluster tree
192.168.111.44:20102(connected)
|__ 192.168.111.44:20152(connected)

192.168.111.44:20150(connected)
|__ 192.168.111.44:20100(connected)

192.168.111.44:20151(connected)
|__ 192.168.111.44:20101(connected)

matthew@lightningdb:21> cluster failover_with_dir fbg05 matthew01
'192.168.111.44:20101' will be master...
OK


matthew@lightningdb:21> cluster tree
192.168.111.44:20101(connected)
|__ 192.168.111.44:20151(connected)

192.168.111.44:20102(connected)
|__ 192.168.111.44:20152(connected)

192.168.111.44:20150(connected)
|__ 192.168.111.44:20100(connected)
```

**(9) Cluster force_failover**

When a server need to be shutdown by HW fault or checking, change all masters in the server to slaves by failover of those slaves.

**Examples**

```
matthew@lightningdb:21> cluster distribution
+----------------+--------+-------+
| HOST           | MASTER | SLAVE |
+----------------+--------+-------+
| 192.168.111.44 | 7      | 7     |
| 192.168.111.41 | 7      | 7     |
| TOTAL          | 14     | 14    |
+----------------+--------+-------+


matthew@lightningdb:21> cluster force_failover 192.168.111.41
'192.168.111.44:20150' will be master...
OK

'192.168.111.44:20151' will be master...
OK

'192.168.111.44:20152' will be master...
OK

'192.168.111.44:20153' will be master...
OK

'192.168.111.44:20154' will be master...
OK

'192.168.111.44:20155' will be master...
OK

'192.168.111.44:20156' will be master...
OK

matthew@lightningdb:21> cluster distribution
+----------------+--------+-------+
| HOST           | MASTER | SLAVE |
+----------------+--------+-------+
| 192.168.111.44 | 14     | 0     |
| 192.168.111.41 | 0      | 14    |
| TOTAL          | 14     | 14    |
+----------------+--------+-------+
matthew@lightningdb:21>
```


# 4. Scale out

**(1) Cluster add_slave**

!!! Warning
    Before using the `add-slave` command, ingestion to master nodes should be stopped. After replication and sync between master and slave are completed, ingestion will be available again.

You can add a slave to a cluster that is configured only with the master without redundancy.

- Create cluster only with masters
    - Procedure for configuring the test environment. If cluster with the only masters already exists, go to the **add slave info**.

- Proceed with the deploy.
    - Enter 0 in replicas as shown below when deploy.

``` bash
ec2-user@lightningdb:2> deploy 3
Select installer

    [ INSTALLER LIST ]
    (1) lightningdb.dev.master.5a6a38.bin

Please enter the number, file path or url of the installer you want to use.
you can also add file in list by copy to '$FBPATH/releases/'
https://flashbase.s3.ap-northeast-2.amazonaws.com/lightningdb.release.master.5a6a38.bin
Downloading lightningdb.release.master.5a6a38.bin
[==================================================] 100%
OK, lightningdb.release.master.5a6a38.bin
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
| installer    | lightningdb.dev.master.5a6a38.bin |
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
ec2-user@lightningdb:3> cluster start
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
ec2-user@lightningdb:3> cluster create
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
ec2-user@lightningdb:3>
```

- Add slave info

Open the conf file.

``` bash
ec2-user@lightningdb:3> conf cluster
```

You can modify redis.properties by entering the command as shown above.

``` bash
#!/bin/bash

## Master hosts and ports
export SR2_REDIS_MASTER_HOSTS=( "127.0.0.1" )
export SR2_REDIS_MASTER_PORTS=( $(seq 18300 18304) )

## Slave hosts and ports (optional)
[[export]] SR2_REDIS_SLAVE_HOSTS=( "127.0.0.1" )
[[export]] SR2_REDIS_SLAVE_PORTS=( $(seq 18600 18609) )

## only single data directory in redis db and flash db
## Must exist below variables; 'SR2_REDIS_DATA', 'SR2_REDIS_DB_PATH' and 'SR2_FLASH_DB_PATH'
[[export]] SR2_REDIS_DATA="/nvdrive0/nvkvs/redis"
[[export]] SR2_REDIS_DB_PATH="/nvdrive0/nvkvs/redis"
[[export]] SR2_FLASH_DB_PATH="/nvdrive0/nvkvs/flash"

## multiple data directory in redis db and flash db
export SSD_COUNT=3
[[export]] HDD_COUNT=3
export SR2_REDIS_DATA="~/sata_ssd/ssd_"
export SR2_REDIS_DB_PATH="~/sata_ssd/ssd_"
export SR2_FLASH_DB_PATH="~/sata_ssd/ssd_"

#######################################################
# Example : only SSD data directory
[[export]] SSD_COUNT=3
[[export]] SR2_REDIS_DATA="/ssd_"
[[export]] SR2_REDIS_DB_PATH="/ssd_"
[[export]] SR2_FLASH_DB_PATH="/ssd_"
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
[[export]] SR2_REDIS_DATA="/nvdrive0/nvkvs/redis"
[[export]] SR2_REDIS_DB_PATH="/nvdrive0/nvkvs/redis"
[[export]] SR2_FLASH_DB_PATH="/nvdrive0/nvkvs/flash"

## multiple data directory in redis db and flash db
export SSD_COUNT=3
[[export]] HDD_COUNT=3
export SR2_REDIS_DATA="~/sata_ssd/ssd_"
export SR2_REDIS_DB_PATH="~/sata_ssd/ssd_"
export SR2_FLASH_DB_PATH="~/sata_ssd/ssd_"

#######################################################
# Example : only SSD data directory
[[export]] SSD_COUNT=3
[[export]] SR2_REDIS_DATA="/ssd_"
[[export]] SR2_REDIS_DB_PATH="/ssd_"
[[export]] SR2_FLASH_DB_PATH="/ssd_"
#######################################################
```

Save the modification and exit.

``` bash
ec2-user@lightningdb:3> conf cluster
Check status of hosts...
OK
sync conf
OK
Complete edit
```

- Execute `cluster add-slave` command

``` bash
ec2-user@lightningdb:3> cluster add-slave
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
ec2-user@lightningdb:3> cli cluster nodes
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

**(2) Scale out**

You can scale out the current cluster with a new server.

**Examples**

- Check the current distribution of masters/slaves in each server. 

```

matthew@lightningdb:21> cluster distribution
+-----------------------+--------+-------+
| HOST                  | MASTER | SLAVE |
+-----------------------+--------+-------+
| fbg04(192.168.111.41) |  3     |  3    |
| TOTAL                 |  3     |  3    |
+-----------------------+--------+-------+
```

- Scale out with the new server.

```
matthew@lightningdb:21> cluster scaleout
Please type hosts to scaleout separated by comma(,) [127.0.0.1]
fbg05
OK, ['fbg05']
Check status of hosts...
OK
Checking cluster exist...
 - fbg04
 - fbg05
OK
+-------+-------+--------+
| HOST  | PORT  | TYPE   |
+-------+-------+--------+
| fbg04 | 20100 | MASTER |
| fbg04 | 20101 | MASTER |
| fbg04 | 20102 | MASTER |
| fbg05 | 20100 | MASTER |
| fbg05 | 20101 | MASTER |
| fbg05 | 20102 | MASTER |
| fbg04 | 20150 | SLAVE  |
| fbg04 | 20151 | SLAVE  |
| fbg04 | 20152 | SLAVE  |
| fbg05 | 20150 | SLAVE  |
| fbg05 | 20151 | SLAVE  |
| fbg05 | 20152 | SLAVE  |
+-------+-------+--------+
replicas: 1
Do you want to proceed with replicate according to the above information? (y/n)
y
Backup redis master log in each MASTER hosts...
 - fbg04
 - fbg05
Backup redis slave log in each SLAVE hosts...
 - fbg04
 - fbg05
create redis data directory in each MASTER
 - fbg04
 - fbg05
create redis data directory in each SLAVE
 - fbg04
 - fbg05
sync conf
OK
Starting master nodes : fbg04 : 20100|20101|20102 ...
Starting master nodes : fbg05 : 20100|20101|20102 ...
Starting slave nodes : fbg04 : 20150|20151|20152 ...
Starting slave nodes : fbg05 : 20150|20151|20152 ...
Wait until all redis process up...
alive redis 12/12
Complete all redis process up.
Replicate [M] fbg04:20100 - [S] fbg05:20150
Replicate [M] fbg04:20101 - [S] fbg05:20151
Replicate [M] fbg04:20102 - [S] fbg05:20152
Replicate [M] fbg05:20100 - [S] fbg04:20150
Replicate [M] fbg05:20101 - [S] fbg04:20151
Replicate [M] fbg05:20102 - [S] fbg04:20152
6 / 6 replicate completion.
M: 47f7f65f36fbf1eb89e29ce1fd2facd8bb646f15 192.168.111.41 20100 slots:5462-10922 (5461 slots)
M: 2ee3d14c92321132e12cddb90dde8240ea6b8768 192.168.111.44 20101 slots: (0 slots)
S: 0516e827969880b2322ae112e70e809b395c6d46 192.168.111.44 20151 slots: (0 slots)
S: fd1466ec198951cbe7e172ae34bd5b3db66aa309 192.168.111.44 20150 slots: (0 slots)
S: 28e4d04419c90c7b1bb4b067f9e15d4012d313b1 192.168.111.44 20152 slots: (0 slots)
S: 56e1d3ab563b23bbf857a8f502d1c4b24ce74a3c 192.168.111.41 20151 slots: (0 slots)
M: 00d9cea97499097645eecd0bddf0f4679a6f1be1 192.168.111.44 20100 slots: (0 slots)
S: 9a21e798fc8d69a4b04910b9e4b87a69417d33fe 192.168.111.41 20150 slots: (0 slots)
M: 6afbfe0ed8d701d269d8b2837253678d3452fb70 192.168.111.41 20102 slots:0-5461 (5462 slots)
M: 7e2e3de6daebd6e144365d58db19629cfb1b87d1 192.168.111.41 20101 slots:10923-16383 (5461 slots)
S: 1df738824e9d41622158a4102ba4aab355225747 192.168.111.41 20152 slots: (0 slots)
M: 71334ecc4e6e1a707b0f7f6c85f0a75ece45f891 192.168.111.44 20102 slots: (0 slots)
>>> Performing Cluster Check (using node 192.168.111.41:20100)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered
err_perc: 50.009156
err_perc: 50.018308
err_perc: 50.009156
>>> Rebalancing across 6 nodes. Total weight = 6
2ee3d14c92321132e12cddb90dde8240ea6b8768 balance is -2732
00d9cea97499097645eecd0bddf0f4679a6f1be1 balance is -2731
71334ecc4e6e1a707b0f7f6c85f0a75ece45f891 balance is -2731
47f7f65f36fbf1eb89e29ce1fd2facd8bb646f15 balance is 2731
7e2e3de6daebd6e144365d58db19629cfb1b87d1 balance is 2731
6afbfe0ed8d701d269d8b2837253678d3452fb70 balance is 2732
Moving 2732 slots from 6afbfe0ed8d701d269d8b2837253678d3452fb70 to 2ee3d14c92321132e12cddb90dde8240ea6b8768
############################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################

Moving 2731 slots from 7e2e3de6daebd6e144365d58db19629cfb1b87d1 to 00d9cea97499097645eecd0bddf0f4679a6f1be1
###########################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################

Moving 2731 slots from 47f7f65f36fbf1eb89e29ce1fd2facd8bb646f15 to 71334ecc4e6e1a707b0f7f6c85f0a75ece45f891
###########################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################################

OK
```

- The result of scale out

```
matthew@lightningdb:21> cluster distribution
+-----------------------+--------+-------+
| HOST                  | MASTER | SLAVE |
+-----------------------+--------+-------+
| fbg04(192.168.111.41) | 3      | 3     |
| fbg05(192.168.111.44) | 3      | 3     |
| TOTAL                 | 6      | 6     |
+-----------------------+--------+-------+
```

[^1]: If user types 'cfc 1', ${SR2_HOME} will be '~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT'.
[^2]: 'cluster-node-time' can be set with using 'config set' command. Its default time is 1200,000 msec.