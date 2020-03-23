
# 1. How to run LTCLI

If you try to use LTCLI for the first time after the EC2 instance was created, please update LTCLI like below.

``` bash
pip install ltcli --upgrade --user
```


**(1) Run**

To run LTCLI, ${FBPATH} should be set. If not, the following error messages will be shown.

``` bash
To start using LTCLI, you should set env FBPATH
ex)
export FBPATH=$HOME/.flashbase
```

!!! Tip
    In the case of EC2 Instance, this path is set automatically.


Run LTCLI by typing 'ltcli'

``` bash
$ ltcli
```

When LTCLI starts for the first time,  you need to confirm 'base_directory'.

[~/tsr2][^1] is default value.

``` bash
Type base directory of flashbase [~/tsr2]
~/tsr2
OK, ~/tsr2
```

In '${FBPATH}/.flashbase/config', you can modify 'base_directory'.

If you logs in LTCLI normally, LTCLI starts on the last visited cluster.
In the case of the first login, '-' is shown instead of cluster number.


``` bash
root@lightningdb:->

...
...

root@lightningdb:1>
```

!!! Tip
    In this page, '$' means that you are in Centos and '>' means that you are in LTCLI.


**(2) Log messages**

Log messages of LTCLI will be saved in '$FBPATH/logs/fb-roate.log'.

Its max-file-size is 1GiB and **rolling update** will be done in case of exceeding of size limit.


# 2. Deploy LightningDB

Deploy is the procedure that LightningDB is installed with the specified cluster number.

You could make LightningDB cluster with the following command.

``` bash
> deploy 1
```

After deploy command, you should type the following information that provides its last used value.

- Installer
- Host
- Number of masters
- Replicas
- Number of SSD(disk)
- The prefix of DB path (used for 'redis data', 'redis DB path' and 'flash DB path')


Use the below option not to save the last used value.

``` bash
> deploy --history-save=False
```

**(1) Select installer**

``` bash
Select installer

    [ INSTALLER LIST ]
    (1) [DOWNLOAD] flashbase.dev.master.dbcb9e.bin
    (2) [LOCAL] flashbase.dev.master.dbcb9e.bin
    (3) [LOCAL] flashbase.trial.master.dbcb9e-dirty.bin
    (4) [LOCAL] flashbase.trial.master.dbcb9e.bin

Please enter the number, file path or url of the installer you want to use.
you can also add file in list by copy to '$FBPATH/releases/'
1
OK, flashbase.dev.master.dbcb9e.bin
```
!!! Tip
    LOCAL means installer file under path '$FBPATH/releases/' on your local.
    DOWNLOAD refers to a file that can be downloaded and up to 5 files are displayed in the latest order. To confirm the recommended FlashBase version, use [Release Notes](release-note.md)

Select a number to use that file. Type DOWNLOAD will be used after downloading. The downloaded file is saved in path '$FBPATH/releases'.

``` bash
Select installer

    [ INSTALLER LIST ]
    (empty)

Please enter file path or url of the installer you want to use
you can also add file in list by copy to '$FBPATH/releases/'
https://flashbase.s3.ap-northeast-2.amazonaws.com/latest/flashbase.dev.master.5a6a38.bin
Downloading flashbase.dev.master.5a6a38.bin
[==================================================] 100%
OK, flashbase.dev.master.5a6a38.bin
```

If the installer list is empty like above, you can also use file path or URL. If you enter URL, download the file and use it. The downloaded file is saved in path '$FBPATH/releases'.


**(2) Type Hosts**

IP address or hostname can be used. In the case of several hosts, the list can be separated by comma(',').

``` bash
Please type host list separated by comma(,) [127.0.0.1]

OK, ['127.0.0.1']
```

**(3) Type Masters**


``` bash
How many masters would you like to create on each host? [10]

OK, 10
Please type ports separate with a comma(,) and use a hyphen(-) for range. [18100-18109]

OK, ['18100-18109']
```

Define how many master processes will be created in the cluster per server.

!!! Tip
    To create a cluster, 3 master processes should be included at least.

**(4) Type information of slave**

``` bash
How many replicas would you like to create on each master? [0]

OK, 0
```

Define how many slave processes will be created for a master process.

**(5) Type the count of SSD(disk) and the path of DB files**

``` bash
How many ssd would you like to use? [4]

OK, 4
Type prefix of db path [/nvme/data_]

OK, /nvme/data_
```

**(6) Check all settings finally**

Finally, all settings will be shown and confirmation will be requested like below.


``` bash
+--------------+---------------------------------+
| NAME         | VALUE                           |
+--------------+---------------------------------+
| installer    | flashbase.dev.master.5a6a38.bin |
| hosts        | 127.0.0.1                       |
| master ports | 18100-18109                     |
| ssd count    | 4                               |
| db path      | /nvme/data_                     |
+--------------+---------------------------------+
Do you want to proceed with the deploy accroding to the above information? (y/n)
y
```

**(7) Deploy cluster**

After deploying is completed, the following messages are shown and LTCLI of the cluster is activated.

``` bash
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
Complete to deploy cluster 1.
Cluster '1' selected.
```

When an error occurs during deploying, error messages will be shown like below.

**(8) Errors**

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
    - Please check the status of the host(server) or outbound/inbound of the server.


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

If the localhost(127.0.0.1) is not included in host information, this error occurs. Please add the localhost in the host list in this case.

# 3. Start LightningDB

Create a cluster of LightningDB using 'cluster create' command.

``` bash
ec2-user@lightningdb:1> cluster create
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
Starting master nodes : 127.0.0.1 : 18100|18101|18102|18103|18104|18105|18106|18107|18108|18109 ...
Wait until all redis process up...
cur: 10 / total: 10
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
| 127.0.0.1 | 18105 | MASTER |
| 127.0.0.1 | 18106 | MASTER |
| 127.0.0.1 | 18107 | MASTER |
| 127.0.0.1 | 18108 | MASTER |
| 127.0.0.1 | 18109 | MASTER |
+-----------+-------+--------+
replicas: 0

Do you want to proceed with the create according to the above information? (y/n)
y
Cluster meet...
 - 127.0.0.1:18107
 - 127.0.0.1:18106
 - 127.0.0.1:18101
 - 127.0.0.1:18100
 - 127.0.0.1:18103
 - 127.0.0.1:18109
 - 127.0.0.1:18102
 - 127.0.0.1:18108
 - 127.0.0.1:18105
 - 127.0.0.1:18104
Adding slots...
 - 127.0.0.1:18107, 1642
 - 127.0.0.1:18106, 1638
 - 127.0.0.1:18101, 1638
 - 127.0.0.1:18100, 1638
 - 127.0.0.1:18103, 1638
 - 127.0.0.1:18109, 1638
 - 127.0.0.1:18102, 1638
 - 127.0.0.1:18108, 1638
 - 127.0.0.1:18105, 1638
 - 127.0.0.1:18104, 1638
Check cluster state and asign slot...
Ok
create cluster complete.
ec2-user@lightningdb:1> cli ping --all
alive redis 10/10

ec2-user@lightningdb:1>
```

From now, you can try ingestion and query in LightningDB with [Zeppelin](try-with-zeppelin.md). And for further information about commands of LTCLI, please use [Command Line](command-line-interface.md).

[^1]: If you type 'enter' without any text, the default value is applied. In some cases, the default value will not be provided.
