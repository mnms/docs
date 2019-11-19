!!! Note
    Command Line Interface(CLI) of LightningDB supports not only deploy and start command but also many commands to access and manipulate data in LightningDB.
​
# 1. How to run fbctl

If you try to use fbctl for the first time after EC2 instance was created, please update fbctl like below.

``` bash
pip install fbctl --upgrade --user
```


## (1) Run

To run fbctl, ${FBPATH} should be set. If not, following error messages will be shown.

``` bash
To start using fbctl, you should set env FBPATH
ex)
export FBPATH=$HOME/.flashbase
```

!!! Tip
    In case of EC2 Instance, this path is set automatically.


Run **fbctl** by typing 'fbctl'

``` bash
$ fbctl
```

When fbctl starts at the first time, user needs to confirm 'base_directory'. 

[~/tsr2][^1] is default value.

``` bash
Type base directory of flashbase [~/tsr2]
~/tsr2
OK, ~/tsr2
```

In '${FBPATH}/.flashbase/config', user can modify 'base_directory'.

If user logs in fbctl normally, fbctl starts on last visited cluster.
In case of first login, '-' is shown instead of cluster number.


``` bash
root@flashbase:->

...
...

root@flashbase:1>
```

!!! Tip
    In this page, '$' means that user is in Centos and '>' means that user is in fbctl.


## (2) Log messages

Log messages of fbctl will be saved in '${FBPATH}/logs/fb-roate.log'.

Its max-file-size is 1GiB and **rolling update** will be done in case of exceed of size limit.


# 2. Deploy LightningDB

**Deploy** is the procedure that LightningDB is installed with the specified cluster number.

User could make LightningDB cluster with the following command.

``` bash
> deploy 1
```

After deploy command, user should type the following information that provides its last used value.

- installer
- host
- number of masters
- replicas
- number of ssd(disk)
- prefix of db path


Use below option not to save last used value.

``` bash
> deploy --history-save=False
```

## (1) Select installer

``` bash
Select installer

    [ INSTALLER LIST ]
    (1) flashbase.dev.master.dbcb9e.bin
    (2) flashbase.trial.master.dbcb9e-dirty.bin
    (3) flashbase.trial.master.dbcb9e.bin

Please enter the number, file path or url of the installer you want to use.
you can also add file in list by copy to '$FBPATH/releases/'
1
OK, flashbase.dev.master.dbcb9e.bin
```

With only URL, instead of file path, LightningDB can be installed like below. The downloaded file is stored under '${FBPATH}/releases/'

To copy the link of the recommended FlashBase version, use [Release Notes](release-note.md).

``` bash
https://flashbase.s3.ap-northeast-2.amazonaws.com/flashbase.dev.master.dbcb9e.bin 

Downloading flashbase.dev.master.dbcb9e.bin
[=======                                           ] 15%
```

If the list is empty like below, you can select the installer only by entering the file path or by entering url. To add an installer to the list, copy it under '${FBPATH}/releases/'

``` bash
Select installer

    [ INSTALLER LIST ]
    (empty)

Please enter file path or url of the installer you want to use
you can also add file in list by copy to '$FBPATH/releases/'
```

## (2) Type Hosts

IP address or hostname can be used. In case of several hosts, list can be seperated by comma(',').

``` bash
Please type host list separated by comma(,) [127.0.0.1]
nodeA, nodeB, nodeC, nodeD
OK, ['nodeA', 'nodeB', 'nodeC', 'nodeD']
```

## (3) Type Masters


``` bash
How many masters would you like to create on each host? [1]
1
OK, 1
Please type ports separate with comma(,) and use hyphen(-) for range. [18100]
18100
OK, ['18100']
```

Define how many master processes will be created in the cluster per server.

## (4) Type information of slave

``` bash
How many replicas would you like to create on each master? [2]
2
OK, 2
Please type ports separate with comma(,) and use hyphen(-) for range. [18150-18151]
18150-18151
OK, ['18150-18151']
```

Define how many slave processes will be created for a master process.



[^1]: If user types 'enter' without any text, the default value is applied. In some case, default value will not provided.

## (5) Type the count of SSD(disk) and the path of DB files

``` bash
How many ssd would you like to use? [3]
3
OK, 3

Type prefix of db path [~/sata_ssd/ssd_]
OK, ~/sata_ssd/ssd_

```

## (6) Check all settings finally
Finally all settings will be shown and confirmation will be requested like below.


``` bash
+-----------------+---------------------------------------------+
| NAME            | VALUE                                       |
+-----------------+---------------------------------------------+
| installer       | flashbase.dev.master.dbcb9e.bin             |
| nodes           | nodeA                                       |
|                 | nodeB                                       |
|                 | nodeC                                       |
|                 | nodeD                                       |
| master ports    | 18100                                       |
| slave ports     | 18150-18151                                 |
| ssd count       | 3                                           |
| db path         | ~/sata_ssd/ssd_                             |
+-----------------+---------------------------------------------+
Do you want to proceed with the deploy accroding to the above information? (y/n)
y
```

## (7) Deploy cluster


After deploying is completed, following messages are shown and fbctl of the cluster is activated.

``` bash
Check status of hosts...
+-----------+--------+
| HOST      | STATUS |
+-----------+--------+
| nodeA     | OK     |
| nodeB     | OK     |
| nodeC     | OK     |
| nodeD     | OK     |
+-----------+--------+
OK
Checking for cluster exist...
+-----------+--------+
| HOST      | STATUS |
+-----------+--------+
| nodeA     | CLEAN  |
| nodeB     | CLEAN  |
| nodeC     | CLEAN  |
| nodeD     | CLEAN  |
+-----------+--------+
OK
Transfer installer and execute...
 - nodeA
 - nodeB
 - nodeC
 - nodeD
Sync conf...
Complete to deploy cluster 1
Cluster 1 selected.
```

When an error occurs during deploying, error messages will be shown like below.

**Host connection error**

``` bash
Check status of hosts...
+-------+------------------+
| HOST  | STATUS           |
+-------+------------------+
| nodeA | OK               |
| nodeB | SSH ERROR        |
| nodeC | UNKNOWN HOST     |
| nodeD | CONNECTION ERROR |
+-------+------------------+
There are unavailable host.
```


- SSH ERROR 
    - SSH access error. Please check SSH KEY exchange or the status of SSH client/server.
- UNKNOWN HOST
    - Can not get IP address with the hostname. Please check if the hostname is right.
- CONNECTION ERROR
    - Please check the status of host(server) or outbound/inbound of the server.


**Cluster already exist**

``` bash
Checking for cluster exist...
+-------+---------------+
| HOST  | STATUS        |
+-------+---------------+
| nodeA | CLEAN         |
| nodeB | CLEAN         |
| nodeC | CLUSTER EXIST |
| nodeD | CLUSTER EXIST |
+-------+---------------+
Cluster information exist on some hosts.
```

- CLUSTER EXIST
    - LightningDB is already deployed in the cluster of the host.


**Not include localhost**

``` bash
 Check status of hosts...
  +-------+------------------+
  | HOST  | STATUS           |
  +-------+------------------+
  | nodeB | OK               |
  | nodeC | OK               |
  | nodeD | OK               |
  +-------+------------------+
  Must include localhost.
```

If localhost(127.0.0.1) is not included in host information, this error occurs. Please add localhost in host list in this case.

From now, user can start and manage clusters of LightningDB with [Commands](command-line-interface.md).


# 3. LightningDB Version Update

In case of version update, 'deploy' command is used.

``` bash
> c 1 // alias of 'cluster use 1'
> deploy
(Watch out) Cluster 1 is already deployed. Do you want to deploy again? (y/n) [n]
y
```

## (1) Select installer

``` bash
Select installer

    [ INSTALLER LIST ]
    (1) flashbase.dev.master.dbcb9e.bin
    (2) flashbase.trial.master.dbcb9e-dirty.bin
    (3) flashbase.trial.master.dbcb9e.bin

Please enter the number, file path or url of the installer you want to use.
you can also add file in list by copy to '$FBPATH/releases/'
1
OK, flashbase.dev.master.dbcb9e.bin
```


## (2) Restore

``` bash
Do you want to restore conf? (y/n)
y
```

If the current settings will be reused, type 'y'.

## (3) Check all settings finally

``` bash
+-----------------+---------------------------------------------+
| NAME            | VALUE                                       |
+-----------------+---------------------------------------------+
| installer       | flashbase.dev.master.dbcb9e.bin             |
| nodes           | nodeA                                       |
|                 | nodeB                                       |
|                 | nodeC                                       |
|                 | nodeD                                       |
| master ports    | 18100                                       |
| slave ports     | 18150-18151                                 |
| ssd count       | 3                                           |
| redis data path | ~/sata_ssd/ssd_                             |
| redis db path   | ~/sata_ssd/ssd_                             |
| flash db path   | ~/sata_ssd/ssd_                             |
+-----------------+---------------------------------------------+
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

- Backup path of cluster: ${base-directory}/backup/cluster\_${cluster-id}\_bak\_${time-stamp}
- Backup path of conf files: $FBAPTH/conf_backup/cluster_${cluster-id}\_conf_bak\_${time-stamp}


## (4) Restart


``` bash
> cluster restart
```

After restart, new version will be applied.


# 4. Add Slave

You can add a slave to a cluster that is configured only with master

## (1) create cluster only with master

(Procedure for configuring the test environment. If cluster with only master already exists, go to the [add slave info](#2-add-slave-info).

Proceed with the deploy.

``` bash
> deploy 1
```

Enter 0 in replicas as shown below when deploy.


``` bash
Select installer

    [ INSTALLER LIST ]
    (1) tsr2-installer.bin.flashbase_v1.1.10.centos

Please enter the number, file path or url of the installer you want to use.
you can also add file in list by copy to '$FBPATH/releases/'
1
OK, tsr2-installer.bin.flashbase_v1.1.10.centos
Please type host list separated by comma(,) [127.0.0.1]
127.0.0.1
OK, ['127.0.0.1']
How many masters would you like to create on each host? [1]
1
OK, 1
Please type ports separate with comma(,) and use hyphen(-) for range. [18100]
18300
OK, ['18100']

*-----------------------------------------------------------------*
| How many replicas would you like to create on each master? [2]  |
| 0                                                               |
| OK, 0                                                           |
*-----------------------------------------------------------------*
 ↳ (a border just for emphasis)

How many ssd would you like to use? [3]
3
OK, 3
Type prefix of db path [~/sata_ssd/ssd_]
~/sata_ssd/ssd_
OK, /sata_ssd/ssd_
+-------------------+---------------------------------------------+
| NAME              | VALUE                                       |
+-------------------+---------------------------------------------+
| installer         | tsr2-installer.bin.flashbase_v1.1.10.centos |
| hosts             | 127.0.0.1                                   |
| master ports      | 18100                                       |
| ssd count         | 3                                           |
| prefix_of_db_path | ~/sata_ssd/ssd_                              |
+-------------------+---------------------------------------------+
Do you want to proceed with the deploy accroding to the above information? (y/n)
y
```

When the deploy is complete, start and create the cluster.

``` bash
> cluster start
...
> cluster create
...
```

## (2) add slave info

You can modify `redis.properties` by entering the command `conf cluster`.

``` bash
> conf cluster
```

Toggle and modify commented `SR2_REDIS_SLAVE_HOSTS` and `SR2_REDIS_SLAVE_PORTS` as shown below.

``` bash
  1 #!/bin/bash
  2
  3 ## Master hosts and ports
  4 export SR2_REDIS_MASTER_HOSTS=( "127.0.0.1" )
  5 export SR2_REDIS_MASTER_PORTS=( 18100 )
  6
  7 ## Slave hosts and ports (optional)
  8 export SR2_REDIS_SLAVE_HOSTS=( "127.0.0.1" )
  9 export SR2_REDIS_SLAVE_PORTS=( $(seq 18150 18151) )
 10
 11 ## only single data directory in redis db and flash db
 12 ## Must exist below variables; 'SR2_REDIS_DATA', 'SR2_REDIS_DB_PATH' and 'SR2_FLASH_DB_PATH'
 13 #export SR2_REDIS_DATA="/nvdrive0/nvkvs/redis"
 14 #export SR2_REDIS_DB_PATH="/nvdrive0/nvkvs/redis"
 15 #export SR2_FLASH_DB_PATH="/nvdrive0/nvkvs/flash"
 16
 17 ## multiple data directory in redis db and flash db
 18 export SSD_COUNT=3
 19 #export HDD_COUNT=3
 20 export SR2_REDIS_DATA="~/sata_ssd/ssd_"
 21 export SR2_REDIS_DB_PATH="~/sata_ssd/ssd_"
 22 export SR2_FLASH_DB_PATH="~/sata_ssd/ssd_"
 23
 24 #######################################################
 25 # Example : only SSD data directory.
 26 #export SSD_COUNT=3
 27 #export SR2_REDIS_DATA="/ssd_"
 28 #export SR2_REDIS_DB_PATH="/ssd_"
 29 #export SR2_FLASH_DB_PATH="/ssd_"
 30 #######################################################
```

## (3) execute command cluster addslaves

``` bash
> cluster addslaves
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
Starting slave nodes : 127.0.0.1 : 18150|18151 ...
Wait until all redis process up...
cur: 3 / total: 3
Complete all redis process up
replicate [M] 127.0.0.1 18100 - [S] 127.0.0.1 18150
replicate [M] 127.0.0.1 18100 - [S] 127.0.0.1 18151
1 / 2 meet complete.
2 / 2 meet complete.
```

## (4) check configuration information

``` bash
> cli cluster nodes
fc7d8c... 127.0.0.1:18100 myself,master - 0 15736... 0 connected 0-16383
f9dbb3... 127.0.0.1:18151 slave fc7d8c... 0 15736... 1 connected
60c723... 127.0.0.1:18150 slave fc7d8c... 0 15736... 1 connected
```

``` bash
> cli cluster slots
+-------+-------+-----------+--------+-----------+----------+-----------+----------+
| start | end   | m_ip      | m_port | s_ip_0    | s_port_0 | s_ip_1    | s_port_1 |
+-------+-------+-----------+--------+-----------+----------+-----------+----------+
| 0     | 16383 | 127.0.0.1 | 18100  | 127.0.0.1 | 18151    | 127.0.0.1 | 18150    |
+-------+-------+-----------+--------+-----------+----------+-----------+----------+
```