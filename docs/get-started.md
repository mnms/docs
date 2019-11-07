# Get Started with FlashBase

In `./scripts`, you can find all files that are used in this document .

``` bash
-rw-r--r--  1 admin  SDomain Users   701B 11  5 10:07 .use_cluster
-rw-r--r--@ 1 admin  Domain Users   488B 11  5 10:08 ddl_fb_test_101.sql
-rwxr-xr-x@ 1 admin  Domain Users   1.7K 11  5 10:07 deploy-flashbase.sh
-rw-r--r--@ 1 admin  Domain Users   155B 11  5 10:08 test.json
-rw-r--r--@ 1 admin  Domain Users    17K 11  5 10:08 test_data.csv
```

## 1. Optimizing System Parameters

### System Parameters

(1) Edit `/etc/sysctl.conf` like following

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

Notice: In case of application in runtime, use `sudo sysctl -p`

(2) Edit `/etc/security/limits.conf`

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

Notice: In case of application in runtime, use `ulimit -n 65535, ulimit -u 131072`

(3) Edit `/etc/fstab`

Remove SWAP Partition (Comment out SWAP partition with using `#` and reboot)

``` bash
...
#/dev/mapper/centos-swap swap swap defaults 0 0
...
```

Notice: In case of application in runtime, use `swapoff -a`

(4) `/etc/init.d/disable-transparent-hugepages`

``` bash
root@fbg01 ~] cat /etc/init.d/disable-transparent-hugepages
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

- ntp: For clock synchronization between servers over packet-switched, variable-latency data networks.

## 3. Session configuration files

- Edit `~/.bashrc`

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

- Add `~/.use_cluster`

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

## 4. Install FlashBase

(1) Generate directory for deploying FlashBase.

``` bash
mkdir ~/deploy
```

(2) Copy FlashBase binary

``` bash
cp ./flashbase.xxx.bin ~/deploy/
```

(3) Copy `deploy-flashbase.sh`

``` bash
cp deploy-flashbase.sh ~/deploy/
```

(4) Edit `deploy-flashbase.sh`

``` bash
1 #nodes=("flashbase-d01" "flashbase-d02" "flashbase-d03")
2 #nodes=("flashbase-w01" "flashbase-w02" "flashbase-w03" "flashbase-w04" "flashbase-w05" "flashbasew06")
3 nodes=("localhost")
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

- At `line 3`, add the names of servers that create FlashBase cluster. In case of multiple servers, use ` `(whitespace) like `line 1` or `line 2`.
- At `line 17`, type cluster number to deploy.(ex, in case of `cluster_1`, type `1`). Like `for cluster_num in "1" "2" "3";`, serveral clusters can be deployed simultaneously.
- Finally, type `./deploy-flashbase.sh [file name]` to deploy.

``` bash
./deploy-flashbase.sh ./flashbase.xxx.bin
```

(5) Copy `.use_cluster`

``` bash
cp .use_cluster ~/
```

With `.use_cluster` like below, cluster number can be changed.

``` bash
source ~/.use_cluster 1
```

If `cfc` alias is already set in `.bashrc`, you can use `cfc`.

``` bash
cfc 1
```

(6) Check cluster number and version information

``` bash
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

With using `flashbase edit`, open `~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/conf/redis.properties` file.

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

 At `line 4~5`, add hosts and ports of master redis-server.(the number of PORTs is the number of master redis-server in a server)

 At `line 8~9`, add hosts and ports of slave redis-server.(the number of PORTs is the number of slave redis-server in a server)

 At `line 13~15`, set the path to save data files(aof, rdb, db)

 At `line 18`, set the count of disks. With this value, FlashBase calculates the storage path of each redis-server

(8) Setup configuration and features

``` bash
flashbase edit template
```

If `flashbase edit template` is executed, templates of masters and slaves will be open to modify configurations and features.

Following is example.

- maxmemory

``` bash
# maxmemory <bytes>
# maxmemory should be greater than 51mb in TSR2
maxmemory 200mb
```

- flash-db-ttl

``` bash
# for setting ttl value for flash db (default value is 2592000 = 3600 secs * 24 housrs * 30 days)
flash-db-ttl 2592000
```

These values can be checked and set like bellow.

``` bash
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

## 5. Start FlashBase

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

(4) Type `flashbase edit template` and set required configurations

``` bash
flashbase edit template
```

(5) restart cluster with initialization

``` bash
flashbase restart --reset --cluster --yes
```

(6) In case of failure

Move to `$SR2_HOME/logs/redis` and check log files

``` bash
cd $SR2_HOME/logs/redis
```

If there is no hint about error, try like below.

``` bash
DYLD_LIBRARY_PATH=~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/lib/native/ ~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/bin/redis-server ~/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/conf/redis/redis-18101.conf
```
