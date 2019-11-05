Get Started with FlashBase
==============================================================================


## 1. Optimizing System Parameters

 - System Parameters 

    (1) Edit '/etc/sysctl.conf' like following
    ``` bash
    ...
    vm.swappiness = 0 
    vm.overcommit_memory = 1 
    vm.overcommit_ratio = 50 
    fs.file-max = 6815744 
    net.ipv4.ip_local_port_range = 32768 65535 
    net.core.rmem_default = 262144 
    net.core.wmem_default = 262144 
    net.core.rmem_max = 16777216 
    net.core.wmem_max = 16777216
    net.ipv4.tcp_max_syn_backlog = 4096 
    net.core.somaxconn = 65535
    ...
    ```
    > Notice) In case of application in runtime, use 'sudo sysctl -p'
    
    (2) Edit '/etc/security/limits.conf'
    ``` bash
    ...
    * soft nofile 262144
    * hard nofile 262144
    * soft nproc 131072 
    * hard nproc 131072
    [account name] * soft nofile 262144
    [account name] * hard nofile 262144
    [account name] * soft nproc 131072 
    [account name] * hard nproc 131072
    ...
    ```
    > Notice) In case of application in runtime, use 'ulimit -n 65535, ulimit -u 131072'

    (3) Edit '/etc/fstab'
    
    Remove SWAP Partition(Comment out SWAP partition with using '#' and reboot)
    ``` bash
    ...    
    #/dev/mapper/centos-swap swap swap defaults 0 0
    ...
    ```
    > Notice) In case of application in runtime, use 'swapoff -a'

    (4) '/etc/init.d/disable-transparent-hugepages'
    ``` bash
    root@fbg01 ~]# cat /etc/init.d/disable-transparent-hugepages
    #!/bin/bash
    ### BEGIN INIT INFO
    # Provides:          disable-transparent-hugepages
    # Required-Start:    $local_fs
    # Required-Stop:
    # X-Start-Before:    mongod mongodb-mms-automation-agent
    # Default-Start:     2 3 4 5
    # Default-Stop:      0 1 6
    # Short-Description: Disable Linux transparent huge pages
    # Description:       Disable Linux transparent huge pages, to improve
    #                    database performance.
    ### END INIT INFO
    
    case $1 in
    start)
        if [ -d /sys/kernel/mm/transparent_hugepage ]; then
        thp_path=/sys/kernel/mm/transparent_hugepage
        elif [ -d /sys/kernel/mm/redhat_transparent_hugepage ]; then
        thp_path=/sys/kernel/mm/redhat_transparent_hugepage
        else
        return 0
        fi
    
        echo 'never' > ${thp_path}/enabled
        echo 'never' > ${thp_path}/defrag
    
        re='^[0-1]+$'
        if [[ $(cat ${thp_path}/khugepaged/defrag) =~ $re ]]
        then
        # RHEL 7
        echo 0  > ${thp_path}/khugepaged/defrag
        else
        # RHEL 6
        echo 'no' > ${thp_path}/khugepaged/defrag
        fi
    
        unset re
        unset thp_path
        ;;
    esac
    [root@fbg01 ~]
    [root@fbg01 ~]
    [root@fbg01 ~] chmod 755 /etc/init.d/disable-transparent-hugepages
    [root@fbg01 ~] chkconfig --add disable-transparent-hugepages
    ```


## 2. Setup Prerequisites
### Install Packages
- bash, unzip, ssh

- JDK 1.8 or greater

- gcc 4.8.5 or greater

- glibc 2.17 or greater

- epel-release
    ``` bash
    sudo yum install epel-release
    ```

- boost, boost-thread, boost-devel
    ``` bash
    sudo yum install boost boost-thread boost-devel 
    ```

 - Exchange SSH Key

    For all servers that FlashBase will be deployed, SSH key should be exchanged.
    ``` bash
    ssh-keygen -t rsa
    chmod 0600 ~/.ssh/authorized_keys
    cat .ssh/id_rsa.pub | ssh {server name} "cat >> .ssh/authorized_keys"
    ```
 - Intel MKL library
 
     (1) Intel MKL 2019 library install

    - go to the website: https://software.intel.com/en-us/mkl/choose-download/macos
    - register and login
    - select product named "Intel * Math Kernel Library for Linux" or "Intel * Math Kernel Library for Mac" from the select box "Choose Product to Download"
    - Choose a Version "2019 Update 2" and download
    - unzip the file and execute the install.sh file with root account or (sudo command)
        ``` bash
            sudo ./install.sh
        ```
    - choose custom install and configure the install directory /opt/intel (with sudo, /opt/intel is the default installation path, just confirm it)
        ``` bash
        matthew@fbg05 /opt/intel $ pwd
        /opt/intel

        matthew@fbg05 /opt/intel $ ls -alh
        합계 0
        drwxr-xr-x  10 root root 307  3월 22 01:34 .
        drwxr-xr-x.  5 root root  83  3월 22 01:34 ..
        drwxr-xr-x   6 root root  72  3월 22 01:35 .pset
        drwxr-xr-x   2 root root  53  3월 22 01:34 bin
        lrwxrwxrwx   1 root root  28  3월 22 01:34 compilers_and_libraries -> compilers_and_libraries_2019
        drwxr-xr-x   3 root root  19  3월 22 01:34 compilers_and_libraries_2019
        drwxr-xr-x   4 root root  36  1월 24 23:04 compilers_and_libraries_2019.2.187
        drwxr-xr-x   6 root root  63  1월 24 22:50 conda_channel
        drwxr-xr-x   4 root root  26  1월 24 23:01 documentation_2019
        lrwxrwxrwx   1 root root  33  3월 22 01:34 lib -> compilers_and_libraries/linux/lib
        lrwxrwxrwx   1 root root  33  3월 22 01:34 mkl -> compilers_and_libraries/linux/mkl
        lrwxrwxrwx   1 root root  29  3월 22 01:34 parallel_studio_xe_2019 -> parallel_studio_xe_2019.2.057
        drwxr-xr-x   5 root root 216  3월 22 01:34 parallel_studio_xe_2019.2.057
        drwxr-xr-x   3 root root  16  3월 22 01:34 samples_2019
        lrwxrwxrwx   1 root root  33  3월 22 01:34 tbb -> compilers_and_libraries/linux/tbb
        ```


    (2) Intel MKL 2019 library environment settings

    - append the following statement into ~/.bashrc
        ``` bash
        # INTEL MKL enviroment variables for ($MKLROOT, can be checked with the value export | grep MKL)
        source /opt/intel/mkl/bin/mklvars.sh intel64
        ```

- Apache hadoop 2.6.0 or greater

- Apache spark 2.3 on hadoop 2.6 

- ntp

    For clock synchronization between servers over packet-switched, variable-latency data networks.


## Session configuration files
 - Edit '~/.bashrc'

    Add followings
    ``` bash
    # .bashrc

    if [ -f /etc/bashrc ]; then
    . /etc/bashrc
    fi

    # User specific environment and startup programs

    PATH=$PATH:$HOME/.local/bin:$HOME/bin

    HADOOP_HOME=/home/nvkvs/hadoop
    HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
    YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop
    SPARK_HOME=/home/nvkvs/spark

    PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$SPARK_HOME/bin:$SPARK_HOME/sbin:$HOME/sbin

    export PATH SPARK_HOME HADOOP_HOME HADOOP_CONF_DIR YARN_CONF_DIR
    alias cfc='source ~/.use_cluster'
    ```

- Edit '~/.use_cluster'

    This script helps to change the path of FlasBase Cluster.
    ```bash
    #!/bin/bash

    ## set cluster-#{NUM} path
    export PATH="/bin/:/sbin/:/usr/local/bin/:/usr/local/sbin"
    export SR2_HOME=${HOME}/tsr2/cluster_$1/tsr2-assembly-1.0.0-SNAPSHOT

    source ${HOME}/.bash_profile

    echo $PATH | grep ${SR2_HOME} > /dev/null
    RET=$?
    if [[ $RET -eq 1 ]]; then
        PATH=$PATH:$SR2_HOME/bin:$SR2_HOME/sbin
    fi

    ## source command auto-complate
    source $SR2_HOME/sbin/tsr2-helper

    if [ "$#" -le "1" ]; then
        return 0
    else
        shift
        "$@"
        return $?
    fi
    ```

## Install FlashBase

(1) Generate directory for deploying FlashBase.

``` bash
mkdir ~/deploy
```

(2) Copy FlashBase binary

``` bash
cp ./flashbase.xxx.bin ~/deploy/
```

(3) Copy 'deploy-flashbase.sh'
``` bash 
cp deploy-flashbase.sh ~/deploy/
```

(4) Edit 'deploy-flashbase.sh'

``` bash
1 #nodes=("flashbase-d01" "flashbase-d02" "flashbase-d03")
2 #nodes=("flashbase-w01" "flashbase-w02" "flashbase-w03" "flashbase-w04" "flashbase-w05" "flashbasew06")
3 nodes=( "localhost")
4
5 INSTALLER_PATH=$1
6
7 [[ $INSTALLER_PATH == "" ]] && echo "NO ARGS" && echo "cmd <path of installer.bin>" && exit 1
8 [[ ! -e $INSTALLER_PATH ]] && echo "NO FILE: $INSTALLER_PATH" && exit 1
9
10 INSTALLER_BIN=$(basename $INSTALLER_PATH)
11 DATEMIN=`date +%Y%m%d%H%M%S`
12 TSR2_DIR=~/tsr2
13 echo "DATEMIN: $DATEMIN"
14 echo "INSTALLER PATH: $INSTALLER_PATH"
15 echo "INSTALLER NAME: $INSTALLER_BIN"
16
17 for cluster_num in "1";
18 do
19     CLUSTER_DIR=$TSR2_DIR/cluster_${cluster_num}
20     BACKUP_DIR="${CLUSTER_DIR}_bak_$DATEMIN"
21     CONF_BACKUP_DIR="${CLUSTER_DIR}_conf_bak_$DATEMIN"
22     SR2_HOME=${CLUSTER_DIR}/tsr2-assembly-1.0.0-SNAPSHOT
23     SR2_CONF=${SR2_HOME}/conf
24
25     echo "======================================================"
26     echo "DEPLOY CLUSTER $cluster_num"
27     echo ""
28     echo "CLUSTER_DIR: $CLUSTER_DIR"
29     echo "SR2_HOME: $SR2_HOME"
30     echo "SR2_CONF: $SR2_CONF"
31     echo "BACKUP_DIR: $BACKUP_DIR"
32     echo "CONF_BACKUP_DIR: $CONF_BACKUP_DIR"
33     echo "======================================================"
34     echo "backup..."
35     mkdir -p ${CONF_BACKUP_DIR}
36     cp -rf ${SR2_CONF}/* $CONF_BACKUP_DIR
37
38     echo ""
39
40     for node in ${nodes[@]};
41     do
42         echo "DEPLOY NODE $node"
43        # ssh $node "mv ${CLUSTER_DIR} ${BACKUP_DIR}"
44         ssh $node "mkdir -p ${CLUSTER_DIR}"
45         scp -r $INSTALLER_PATH $node:${CLUSTER_DIR}
46         ssh $node "PATH=${PATH}:/usr/sbin; ${CLUSTER_DIR}/${INSTALLER_BIN} --full ${CLUSTER_DIR}"
47         rsync -avr $CONF_BACKUP_DIR/* $node:${SR2_CONF}
48     done
49
50     echo ""
51 done

```

 - At 'line 3', add the names of servers that create FlashBase cluster. In case of multiple servers, use ' '(whitespace)  like 'line1' or 'line2'.
 - At 'line 17', type cluster number to deploy.(ex, in case of cluster_1, type '1'). Like 'for cluster_num in "1" "2" "3";', serveral clusters can be deployed simultaneously.
 - Finally, type './deploy-flashbase.sh [file name]' to deploy.

``` bash
./deploy-flashbase.sh ./flashbase.xxx.bin
```

(5) Copy '.use_cluster'

```
cp .use_cluster ~/ 
```

With '.use_cluster' like below, cluster number can be changed.
```
source ~/.use_cluster 1 
```
If 'cfc' alias is already set in '.bashrc', you can use 'cfc'.
``` bash
cfc 1
```

(6) Check cluster number and version information
```
$ which flashbase
/Users/admin/tsr2cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/sbin/flashbase

$ flashbase version
Flashbase-1.2.1-SNAPSHOT
Build Time : Mon, Nov 4, 2019 4:30PM GMT+09:00
Build Host : fbg01
Build User : hongchan.roh@sk.com
Git Branch : master
Git Commit Id : dbcb9ebd064921306cdfd64fd634424ab7c12af9
Git Commit Message : Merge pull request #149 in BDFLASH/tsr2-package from feature/BDFLASH-905-slave-psync_offset-outofrange to master
Git Commit User : sungho2.kim@sk.com
```

(7) Setup the number of redis-server process, replica and the number of disks.
```  bash
matthew@fbg05 cfc 1
matthew@fbg05 flashbase edit
```

With using 'flashbase edit', open '~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/conf/redis.properties' file.
``` bash
1 #!/bin/bash
2
3 ## Master hosts and ports
4 export SR2_REDIS_MASTER_HOSTS=( "127.0.0.1" )
5 export SR2_REDIS_MASTER_PORTS=( $(seq 18100 18104) )
6
7 ## Slave hosts and ports (optional)
8 export SR2_REDIS_SLAVE_HOSTS=( "127.0.0.1" )
9 export SR2_REDIS_SLAVE_PORTS=( $(seq 18600 18604) )
10
11 ## only single data directory in redis db and flash db
12 ## Must exist below variables; 'SR2_REDIS_DATA', 'SR2_REDIS_DB_PATH' and 'SR2_FLASH_DB_PATH'
13 export SR2_REDIS_DATA="/sata_ssd/ssd_"
14 export SR2_REDIS_DB_PATH="/sata_ssd/ssd_"
15 export SR2_FLASH_DB_PATH="/sata_ssd/ssd_"
16
17 ## multiple data directory in redis db and flash db
18 export SSD_COUNT=3
```

 At 'line 4~5', add hosts and ports of master redis-server.(the number of PORTs is the number of master redis-server in a server)

 At 'line 8~9', add hosts and ports of slave redis-server.(the number of PORTs is the number of slave redis-server in a server)

 At 'line 13~15', set the path to save data files(aof, rdb, db)

 At 'line 18', set the count of disks. With this value, FlashBase calculates the storage path of each redis-server


(8) Setup configuration and features

```
flashbase edit template
```
If 'flashbase edit template' is executed, templates of masters and slaves will be open to modify configurations and features.

### Examples
- maxmemory
``` bash
# maxmemory <bytes>
# maxmemory should be greater than 51mb in TSR2
maxmemory 200mb
```
- flash-db-ttl
```
# for setting ttl value for flash db (default value is 2592000 = 3600 secs * 24 housrs * 30 days)
flash-db-ttl 2592000
```

These values can be checked and set like bellow.
```
~ flashbase cli
127.0.0.1:18108> config get maxmemory
1) "maxmemory"
2) "209715200"
127.0.0.1:18108> config set maxmemory 210mb
OK
127.0.0.1:18108> config get maxmemory
1) "maxmemory"
2) "220200960"
127.0.0.1:18108> config get flash-db-ttl
1) "flash-db-ttl"
2) "2592000"
127.0.0.1:18108> config get *ttl*
1) "repl-backlog-ttl"
2) "3600"
3) "flash-db-ttl"
4) "2592000"
5) "redis-db-flash-db-ttl-gap"
6) "21600"
127.0.0.1:18108>
```



## Start FlashBase
(1) Set cluster number(ex, we will use cluster 1)
``` bash
source ~/.use_cluster 1
```
or
``` bash
cfc 1
```

(2) Stop all redis-server process of cluster 1
``` bash
flashbase stop
```

(3) Remove all data files of cluster 1
``` bash
flashbase clean
```

(4) Type 'flashbase edit template' and set required configurations
``` bash
flashbase edit template
```

(5) restart cluster with initialization
``` bash
flashbase restart --reset --cluster --yes
```

(6) In case of failure

Move to '$SR2_HOME/logs/redis' and check log files
``` bash
cd $SR2_HOME/logs/redis 
```

If there is no hint about error, try like below.

``` bash
DYLD_LIBRARY_PATH=~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/lib/native/ ~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/bin/redis-server ~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/conf/redis/redis-18101.conf
```



## Ingestion and Query

For Ingestion, FlashBase provides serveral ways like tsr2-tools, kafka and redis command.
With using tsr2-tools, you can ingest data easily.

> tsr2-tools insert -d [data file name or directory path] -s "[seperator]" -t [json file] -p 8 -c 1 -i

For example, we can use like below.

Let's try with sample data.

(1) mkdir directory and copy data
``` bash
mkdir ~/tsr2-test
mkdir ~/tsr2-test/load
cp data.csv ~/tsr2-test/load/
```

(2) generator json file that contains table schema information.
``` bash
mkdir ~/tsr2-test/json
```

``` bash
vi ~/tsr2-test/json/test.json

  1   {
  2       "endpoint": "127.0.0.1:18101",
  3       "id": "101",
  4       "columns": 10,
  5       "partitions": [
  6           0, 3, 4
  7       ],
  8       "rowStore" : true
  9   }
```

(3) With following command, ingestion is executed.
In this case, '|' is seperator.

``` bash
tsr2-tools insert -d ~/tsr2-test/load -s "|" -t test.json -p 8 -c 1 -i
```

(4) With monitor command, monitoring is enabled. Because monitoring will increase the load of the redis-server, it is better to quit in short time.
``` bash
flashbase cli monitor

1534483316.477876 [0 127.0.0.1:49837] "NVWRITE" "D:{101:1:event_date:4:country:5:id}" "3:0:3:4" "1" "0" "event_date\x1dname\x1dcompany\x1dcountry\x1did\x1ddata1\x1ddata2\x1ddata3\x1ddata4\x1ddata5"
1534483316.478114 [0 127.0.0.1:49837] "NVWRITE" "D:{101:1:180818:4:Mexico:5:1681090140399}" "3:0:3:4" "1" "0" "180818\x1dMaite, Christian, Tad, Illiana\x1dUltrices Corp.\x1dMexico\x1d1681090140399\x1dPUY52MAG4EK\x1d6\x1d5\x1dut quam\x1dFusce feugiat. Lorem"
1534483316.478257 [0 127.0.0.1:49837] "NVWRITE" "D:{101:1:180320:4:American Samoa:5:1680111178699}" "3:0:3:4" "1" "0" "180320\x1dTatum, Eliana, Iola, Colby\x1dMi Eleifend Egestas Institute\x1dAmerican Samoa\x1d1680111178699\x1dQYV83PRB0JW\x1d12\x1d8\x1dtortor at risus. Nunc ac sem ut dolor\x1dnon, lobortis quis, pede. Suspendisse dui. Fusce diam"
1534483316.478315 [0 127.0.0.1:49837] "NVWRITE" "D:{101:1:171102:4:Chile:5:1617010935199}" "3:0:3:4" "1" "0" "171102\x1dTheodore, Holly, Carter, Fulton\x1dNisi Nibh Lacinia Industries\x1dChile\x1d1617010935199\x1dZEK46GWB7HN\x1d14\x1d5\x1dlacus. Quisque purus sapien,\x1dtempor lorem, eget mollis lectus pede et risus. Quisque libero"
1534483316.478390 [0 127.0.0.1:49837] "NVWRITE" "D:{101:1:190718:4:Saint Martin:5:1655052520899}" "3:0:3:4" "1" "0" "190718\x1dKenyon, Jeremy, Hedda, Wayne\x1dSit Consulting\x1dSaint Martin\x1d1655052520899\x1dZKV28BVO2UJ\x1d18\x1d1\x1dsed pede nec ante blandit viverra. Donec tempus, lorem\x1da purus. Duis elementum, dui quis accumsan convallis, ante lectus"
1534483316.478481 [0 127.0.0.1:49837] "NVWRITE" "D:{101:1:181125:4:Djibouti:5:1662041755899}" "3:0:3:4" "1" "0" "181125\x1dMarvin, Berk, Connor, Britanney\x1dDonec Dignissim Magna Company\x1dDjibouti\x1d1662041755899\x1dTOY60WWP1BV\x1d22\x1d10\x1dMorbi metus. Vivamus euismod urna. Nullam\x1dmollis vitae, posuere at, velit. Cras lorem lorem, luctus"
1534483316.478565 [0 127.0.0.1:49837] "NVWRITE" "D:{101:1:190808:4:Peru:5:1633051811499}" "3:0:3:4" "1" "0" "190808\x1dAlisa, Vernon, Gregory, Dale\x1dUltrices Foundation\x1dPeru\x1d1633051811499\x1dDKY94BEN1QF\x1d28\x1d6\x1dvitae erat\x1dipsum. Phasellus vitae"
1534483316.478632 [0 127.0.0.1:49837] "NVWRITE" "D:{101:1:180726:4:Chad:5:1637081315399}" "3:0:3:4" "1" "0" "180726\x1dDrew, Adrienne, Blaze, Jade\x1dAt Nisi PC\x1dChad\x1d1637081315399\x1dMKT50ZSU1QN\x1d32\x1d10\x1dsapien. Cras dolor dolor,\x1dNulla eget metus eu erat semper rutrum. Fusce dolor"
...
...

```

(5) Check ingested data in 'flashbase cli'
``` bash 
$flashbase cli
127.0.0.1:18100> metakeys *
 1) "M:{101:1:170807:4:Tuvalu:5:1612091856899}"
 2) "M:{101:1:171102:4:Chile:5:1617010935199}"
 3) "M:{101:1:171214:4:Singapore:5:1668021703999}"
 4) "M:{101:1:171221:4:Korea, South:5:1693112634099}"
 5) "M:{101:1:180320:4:American Samoa:5:1680111178699}"
 6) "M:{101:1:180415:4:Montenegro:5:1636031140599}"
 7) "M:{101:1:180504:4:Dominican Republic:5:1610011098499}"
 8) "M:{101:1:180726:4:Chad:5:1637081315399}"
 9) "M:{101:1:180810:4:Tunisia:5:1608020722999}"
10) "M:{101:1:180818:4:Mexico:5:1681090140399}"
11) "M:{101:1:181020:4:Belgium:5:1648100961899}"
12) "M:{101:1:181125:4:Djibouti:5:1662041755899}"
13) "M:{101:1:181224:4:Zambia:5:1662070325099}"
14) "M:{101:1:190312:4:Chile:5:1652011207799}"
15) "M:{101:1:190323:4:Brazil:5:1624050541999}"
16) "M:{101:1:190401:4:Ecuador:5:1638120251599}"
17) "M:{101:1:190714:4:Nicaragua:5:1642072229899}"
18) "M:{101:1:190718:4:Saint Martin:5:1655052520899}"
19) "M:{101:1:190808:4:Peru:5:1633051811499}"
20) "M:{101:1:event_date:4:country:5:id}"
127.0.0.1:18100> info keyspace
# Keyspace
db0:keys=40,memKeys=20,flashKeys=0,expires=20,avg_ttl=0
127.0.0.1:18100>

```

(6) query data with using 'thriftserver beeline'
After setup cluster number, start thriftserver.
```
cfc 1
thriftserver restart
```

Like below, SparkSubmit process and executors are launched successfully, 'thriftserver beeline' is available.

 ``` bash
2500 ResourceManager
6294 CoarseGrainedExecutorBackend
2839 SparkSubmit
2586 NodeManager
6266 CoarseGrainedExecutorBackend
6219 ExecutorLauncher
 ```

Using 'ddl_fb_test_101.sql', create table.
``` bash
thriftserver beeline -f ddl_fb_test_101.sql

CREATE TABLE `fb_test` (`user_id` STRING, `name` STRING, `company` STRING, `country` STRING, `event_date` STRING, `data1` STRING, `data2` STRING, `data3` STRING, `data4` STRING, `data5` STRING)
USING r2
OPTIONS (
  `query_result_partition_cnt_limit` '40000',
  `query_result_task_row_cnt_limit` '10000',
  `host` 'localhost',
  `serialization.format` '1',
  `query_result_total_row_cnt_limit` '100000000',
  `group_size` '10',
  `port` '18102',
  `mode` 'nvkvs',
  `partitions` 'user_id country event_date',
  `table` '101'
)
```

From now, SparkSQL is available like this.
``` bash
select event_date, company from fb_test  where event_date > '0';

or

select count(*) from fb_test;

or

select event_date, company, count(*) from fb_test  where event_date > '0' group by event_date, company;
```

## FlashBase Commands
Launch FlashBase CLI like following.

``` bash 
flashbase cli -h [host] -p [port]
```

If only 'flashbase cli' is executed, FlashBase opens port randomly in current server.
``` bash
flashbase cli
```

In 'flashbase cli', with 'info' command, the all status of the redis-server can be checked.

``` bash
$flashbase cli -h localhost -p 18500
localhost:18500> info
# Server
redis_version:3.0.7
redis_git_sha1:2d30588f
redis_git_dirty:0
redis_build_id:990d7b12314566d7
redis_mode:cluster
os:Darwin 17.3.0 x86_64
arch_bits:64
multiplexing_api:kqueue
gcc_version:4.2.1
process_id:52490
run_id:7f5dbe653c947acfef05a2ea9b32068fdf1c36b3
tcp_port:18500
uptime_in_seconds:237167
uptime_in_days:2
hz:10
lru_clock:3547335
config_file:/Users/admin/dev/cluster_5/tsr2-assembly-1.0.0-SNAPSHOT/conf/redis/redis-18500.conf

# Clients
connected_clients:1
client_longest_output_list:0
client_biggest_input_buf:0
blocked_clients:0

# Alert Warnings
[EVICTION_WARNING] partition setting is inefficient, 00Rowgroups ratio is 100

# Memory
isOOM:false
used_memory:75585072
used_memory_human:72.08M
used_memory_rss:5165056
used_memory_peak:83956368
used_memory_peak_human:80.07M
used_memory_lua:36864
used_memory_rocksdb_total:114453440
used_memory_rocksdb_block_cache:100663296
used_memory_rocksdb_mem_table:13790144
used_memory_rocksdb_table_readers:0
used_memory_rocksdb_pinned_block:0
meta_data_memory:851760
percent_of_meta_data_memory:1
used_memory_client_buffer_peak:0
mem_fragmentation_ratio:0.07
mem_allocator:libc

# Persistence
loading:0
rdb_changes_since_last_save:288641
rdb_bgsave_in_progress:0
rdb_last_save_time:1534242338
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:1
rdb_current_bgsave_time_sec:-1
aof_enabled:1
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:-1
aof_current_rewrite_time_sec:-1
aof_last_bgrewrite_status:ok
aof_last_write_status:ok
aof_current_size:101291191
aof_base_size:1
aof_pending_rewrite:0
aof_buffer_length:0
aof_rewrite_buffer_length:0
aof_pending_bio_fsync:0
aof_delayed_fsync:0

# Stats
total_connections_received:49
total_commands_processed:2626085
instantaneous_ops_per_sec:0
total_net_input_bytes:2727904217
total_net_output_bytes:2935287875
instantaneous_input_kbps:0.03
instantaneous_output_kbps:0.00
rejected_connections:0
sync_full:1
sync_partial_ok:9
sync_partial_err:0
expired_keys:0
evicted_keys:0
keyspace_hits:0
keyspace_misses:0
pubsub_channels:0
pubsub_patterns:0
latest_fork_usec:9228
migrate_cached_sockets:0

# Replication
role:master
connected_slaves:1
slave0:ip=127.0.0.1,port=18600,state=online,offset=2731230897,lag=0
master_repl_offset:2731230897
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2730182322
repl_backlog_histlen:1048576

# CPU
used_cpu_sys:124.00
used_cpu_user:170.14
used_cpu_sys_children:1.15
used_cpu_user_children:5.19

# Cluster
cluster_enabled:1

# Keyspace
db0:keys=8884,memKeys=1451,flashKeys=0,expires=7433,avg_ttl=0
localhost:18500>
```

Like 'info keyspace', only specified information can be checked.
``` bash
localhost:18500> info keyspace
# Keyspace
db0:keys=8884,memKeys=1451,flashKeys=0,expires=7433,avg_ttl=0
localhost:18500>

```
