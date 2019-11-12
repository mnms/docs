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
!!! Tip
    In case of application in runtime, use `sudo sysctl -p`

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

!!! Tip
    In case of application in runtime, use `ulimit -n 65535, ulimit -u 131072`

(3) Edit `/etc/fstab`

Remove SWAP Partition (Comment out SWAP partition with using `#` and reboot)

``` bash
...
#/dev/mapper/centos-swap swap swap defaults 0 0
...
```

!!! Tip
    In case of application in runtime, use `swapoff -a`

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

- JDK 1.8 or higher

- gcc 4.8.5 or higher

- glibc 2.17 or higher

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

- [Apache Hadoop 2.6.0](https://archive.apache.org/dist/hadoop/common/hadoop-2.6.0/) (or higher)

- [Apache Spark 2.3 on Hadoop 2.6](https://archive.apache.org/dist/spark/spark-2.3.0/)

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

## 4. Install and Start FlashBase

Use [Command Line Interface](command-line-interface.md#command-line-interface) of FlashBase.
