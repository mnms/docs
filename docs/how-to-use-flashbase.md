!!! Note
    This document guides how to use 'flashbase' script for installation and operation.
    If you use LTCLI, you can deploy and operate Lightning DB more easily and powerfully. 
    Therefore, if possible, we recommend LTCLI rather than 'flashbase' script.


# 1. Deploy
You can download the recommended version of Lightning DB in [Release Notes](release-note.md)

Deploy the Lightning DB binary with using [deploy-flashbase.sh](./scripts/deploy-flashbase.sh).

Type `./deploy-flashbase.sh {binary path} {cluster list}` to deploy.

``` bash
> ./deploy-flashbase.sh ./lightningdb.release.release.flashbase_v1.2.3.95bfc6.bin 1 2 // deploy cluster 1 and cluster 2 with lightningdb.release.release.flashbase_v1.2.3.95bfc6.bin

DATEMIN: 20200811113038
INSTALLER PATH: ./lightningdb.release.release.flashbase_v1.2.3.95bfc6.bin
INSTALLER NAME: lightningdb.release.release.flashbase_v1.2.3.95bfc6.bin
======================================================
DEPLOY CLUSTER 1

CLUSTER_DIR: /Users/myaccount/tsr2/cluster_1
SR2_HOME: /Users/myaccount/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT
SR2_CONF: /Users/myaccount/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/conf
BACKUP_DIR: /Users/myaccount/tsr2/cluster_1_bak_20200811113038
CONF_BACKUP_DIR: /Users/myaccount/tsr2/cluster_1_conf_bak_20200811113038
======================================================
backup...

DEPLOY NODE localhost
lightningdb.release.release.flashbase_v1.2.3.95bfc6.bin                                      100%  126MB 256.8MB/s   00:00
\e[01;32mInstalling tsr2 as full...\e[00m
Skip to create \e[01:31m/Users/myaccount/tsr2/cluster_1\e[00m
\e[01;32mUnarchieving to /Users/myaccount/tsr2/cluster_1...\e[00m
\e[01;32mMaking required directories...\e[00m
\e[01;32mProcessing a native library linkage...\e[00m
\e[01;31mNo ldconfig in $PATH. Fix the problem and try again\e[00m
building file list ... done
logback-kaetlyn.xml.template
logback.xml
redis-master.conf.template
redis-slave.conf.template
redis.conf.sample
redis.properties
sentinel.conf.template
thriftserver.properties
tsr2-kaetlyn.properties
redis/
redis/redis-18500.conf
redis/redis-18501.conf
redis/redis-18502.conf
redis/redis-18503.conf
redis/redis-18504.conf
redis/redis-18505.conf
redis/redis-18506.conf
redis/redis-18507.conf
redis/redis-18508.conf
redis/redis-18509.conf
redis/redis-18600.conf
redis/redis-18601.conf
redis/redis-18602.conf
redis/redis-18603.conf
redis/redis-18604.conf
redis/redis-18605.conf
redis/redis-18606.conf
redis/redis-18607.conf
redis/redis-18608.conf
redis/redis-18609.conf
sample-configure/
sample-configure/etc/
sample-configure/etc/sysctl.conf.sample
sample-configure/etc/profile.d/
sample-configure/etc/profile.d/jdk.sh.sample
sample-configure/hadoop/
sample-configure/hadoop/core-site.xml.sample
sample-configure/hadoop/hdfs-site.xml.sample
sample-configure/hadoop/mapred-site.xml.sample
sample-configure/hadoop/slaves.sample
sample-configure/hadoop/yarn-site.xml.sample
sample-configure/spark/
sample-configure/spark/log4j.properties.sample
sample-configure/spark/metrics.properties.sample
sample-configure/spark/scheduler-site.xml.sample
sample-configure/spark/spark-defaults.conf.sample

sent 995838 bytes  received 2532 bytes  1996740.00 bytes/sec
total size is 1161578  speedup is 1.16

======================================================
DEPLOY CLUSTER 2

CLUSTER_DIR: /Users/myaccount/tsr2/cluster_2
SR2_HOME: /Users/myaccount/tsr2/cluster_2/tsr2-assembly-1.0.0-SNAPSHOT
SR2_CONF: /Users/myaccount/tsr2/cluster_2/tsr2-assembly-1.0.0-SNAPSHOT/conf
BACKUP_DIR: /Users/myaccount/tsr2/cluster_2_bak_20200811113038
CONF_BACKUP_DIR: /Users/myaccount/tsr2/cluster_2_conf_bak_20200811113038
======================================================
backup...

DEPLOY NODE localhost
lightningdb.release.release.flashbase_v1.2.3.95bfc6.bin                                      100%  126MB 232.7MB/s   00:00
\e[01;32mInstalling tsr2 as full...\e[00m
Skip to create \e[01:31m/Users/myaccount/tsr2/cluster_2\e[00m
\e[01;32mUnarchieving to /Users/myaccount/tsr2/cluster_2...\e[00m
\e[01;32mMaking required directories...\e[00m
\e[01;32mProcessing a native library linkage...\e[00m
\e[01;31mNo ldconfig in $PATH. Fix the problem and try again\e[00m
building file list ... done
logback-kaetlyn.xml.template
logback.xml
redis-master.conf.template
redis-slave.conf.template
redis.conf.sample
redis.properties
sentinel.conf.template
thriftserver.properties
tsr2-kaetlyn.properties
redis/
redis/redis-18200.conf
redis/redis-18201.conf
redis/redis-18202.conf
redis/redis-18203.conf
redis/redis-18204.conf
redis/redis-18205.conf
redis/redis-18206.conf
redis/redis-18207.conf
redis/redis-18208.conf
redis/redis-18209.conf
redis/redis-18250.conf
redis/redis-18251.conf
redis/redis-18252.conf
redis/redis-18253.conf
redis/redis-18254.conf
redis/redis-18255.conf
redis/redis-18256.conf
redis/redis-18257.conf
redis/redis-18258.conf
redis/redis-18259.conf
sample-configure/
sample-configure/etc/
sample-configure/etc/sysctl.conf.sample
sample-configure/etc/profile.d/
sample-configure/etc/profile.d/jdk.sh.sample
sample-configure/hadoop/
sample-configure/hadoop/core-site.xml.sample
sample-configure/hadoop/hdfs-site.xml.sample
sample-configure/hadoop/mapred-site.xml.sample
sample-configure/hadoop/slaves.sample
sample-configure/hadoop/yarn-site.xml.sample
sample-configure/spark/
sample-configure/spark/log4j.properties.sample
sample-configure/spark/metrics.properties.sample
sample-configure/spark/scheduler-site.xml.sample
sample-configure/spark/spark-defaults.conf.sample

sent 992400 bytes  received 2532 bytes  663288.00 bytes/sec
total size is 1165442  speedup is 1.17
```

# 2. Create and start a cluster
If you've deployed Lightning DB successfully, you can create and start the clusters.

- **Choose the cluster to use**

To choose the cluster, [.use_cluster](https://raw.githubusercontent.com/mnms/docs/master/docs/scripts/.use_cluster) is used.
``` bash
source ~/.use_cluster.sh 1 // 'source ~/.use_cluster.sh {cluster number}
```
If you add alias in `.bashrc.sh` like below, you can change the cluster easily.
```
alias cfc="source ~/.use_cluster"
```
and type `cfc {cluster number}` to use the specified cluster.

``` bash
cfc 1
```

- **Configure the cluster for initializing**

Open and modify redis.properties file of the cluster by typing 'flashbase edit'.

``` bash
#!/bin/bash

## Master hosts and ports
export SR2_REDIS_MASTER_HOSTS=( "127.0.0.1" )          // need to configure
export SR2_REDIS_MASTER_PORTS=( $(seq 18100 18109) )   // need to configure

## Slave hosts and ports (optional)
export SR2_REDIS_SLAVE_HOSTS=( "127.0.0.1" )            // need to configure in case of replication
export SR2_REDIS_SLAVE_PORTS=( $(seq 18150 18159) )     // need to configure in case of replication

## only single data directory in redis db and flash db
## Must exist below variables; 'SR2_REDIS_DATA', 'SR2_REDIS_DB_PATH' and 'SR2_FLASH_DB_PATH'
[[export]] SR2_REDIS_DATA="/nvdrive0/nvkvs/redis"
[[export]] SR2_REDIS_DB_PATH="/nvdrive0/nvkvs/redis"
[[export]] SR2_FLASH_DB_PATH="/nvdrive0/nvkvs/flash"

## multiple data directory in redis db and flash db
export SSD_COUNT=3     // need to configure
[[export]] HDD_COUNT=3
export SR2_REDIS_DATA="/sata_ssd/ssd_"      // need to configure. With this settings, '/sata_ssd/ssd_01', '/sata_ssd/ssd_02' and '/sata_ssd/ssd_03' are used. 
export SR2_REDIS_DB_PATH="/sata_ssd/ssd_"   // need to configure
export SR2_FLASH_DB_PATH="/sata_ssd/ssd_"   // need to configure

#######################################################
# Example : only SSD data directory
[[export]] SSD_COUNT=3
[[export]] SR2_REDIS_DATA="/ssd_"
[[export]] SR2_REDIS_DB_PATH="/ssd_"
[[export]] SR2_FLASH_DB_PATH="/ssd_"
#######################################################
```

- **Create the cluster**

Type `flashbase restart --reset --cluster --yes`.

``` bash
> flashbase restart --reset --cluster --yes
\e[01;32mStopping master cluster of redis...\e[00m
\e[01;33m - Stopping 127.0.0.1[*]...\e[00m
\e[01;32mStopping slave cluster of redis...\e[00m
\e[01;33m - Stopping 127.0.0.1[*]...\e[00m
\e[01;32mRemoving master node configuration in \e[00m
\e[01;32m - 127.0.0.1\e[00m
\e[01;32mRemoving slave node configuration in \e[00m
\e[01;32m - 127.0.0.1\e[00m
\e[01;32mRemoving redis generated MASTER configuration files...\e[00m
\e[01;32m - 127.0.0.1 \e[00m
\e[01;32mRemoving redis generated SLAVE configuration files...\e[00m
\e[01;32m - 127.0.0.1 \e[00m
\e[01;33m
Redis flashdb path is "/sata_ssd/ssd_#{SSD_NUMBER}/nvkvs/myaccount/db/db-#{PORT}-#{DB_NUMBER}".\e[00m
\e[01;33mRedis dump.rdb path is "/sata_ssd/ssd_#{SSD_NUMBER}/nvkvs/myaccount/dump/dump-#{PORT}.*".\e[00m
\e[01;33mRedis aof path is "/sata_ssd/ssd_#{SSD_NUMBER}/nvkvs/myaccount/appendonly-#{PORT}.aof".
\e[00m
\e[01;32mRemoving flash db directory, appendonly and dump.rdb files in MASTER NODE;\e[00m
\e[01;32m - 127.0.0.1 \e[00m
\e[01;32mRemoving flash db directory, appendonly and dump.rdb files in SLAVE NODE;\e[00m
\e[01;32m - 127.0.0.1 \e[00m
\e[01;32mGenerate redis configuration files for MASTER hosts\e[00m
\e[01;32mGenerate redis configuration files for SLAVE hosts\e[00m
\e[01;32m- Master nodes\e[00m
\e[01;32m -- Copying to 127.0.0.1...\e[00m
\e[01;32m- Slave nodes\e[00m
\e[01;32m -- Copying to 127.0.0.1...\e[00m
\e[01;32mSuccess to configure redis.\e[00m
netstat: t4: unknown or uninstrumented protocol
netstat: t4: unknown or uninstrumented protocol
\e[01;32mBackup redis master log in each MASTER hosts... \e[00m
\e[01;33m - 127.0.0.1\e[00m
\e[01;33m - 127.0.0.1\e[00m
\e[01;32mStarting master nodes : 127.0.0.1 : \e[00m\e[01;32m[18100, 18101, 18102, 18103, 18104, 18105, 18106, 18107, 18108, 18109]...\e[00m
\e[01;32mStarting slave nodes : 127.0.0.1 : \e[00m\e[01;32m[18150, 18151, 18152, 18153, 18154, 18155, 18156, 18157, 18158, 18159]...\e[00m
total_master_num: 10
total_slave_num: 10
num_replica: 1
>>> Creating cluster
>>> Performing hash slots allocation on 20 nodes...
Using 10 masters:
127.0.0.1:18100
127.0.0.1:18101
127.0.0.1:18102
127.0.0.1:18103
127.0.0.1:18104
127.0.0.1:18105
127.0.0.1:18106
127.0.0.1:18107
127.0.0.1:18108
127.0.0.1:18109
Adding replica 127.0.0.1:18150 to 127.0.0.1:18100
Adding replica 127.0.0.1:18151 to 127.0.0.1:18101
Adding replica 127.0.0.1:18152 to 127.0.0.1:18102
Adding replica 127.0.0.1:18153 to 127.0.0.1:18103
Adding replica 127.0.0.1:18154 to 127.0.0.1:18104
Adding replica 127.0.0.1:18155 to 127.0.0.1:18105
Adding replica 127.0.0.1:18156 to 127.0.0.1:18106
Adding replica 127.0.0.1:18157 to 127.0.0.1:18107
Adding replica 127.0.0.1:18158 to 127.0.0.1:18108
Adding replica 127.0.0.1:18159 to 127.0.0.1:18109
M: 7e72dff98fdda09cf97e02420727fd8b6564b6ae 127.0.0.1:18100
   slots:0-1637 (1638 slots) master
M: c3b5e673033758d77680e4534855686649fe5daa 127.0.0.1:18101
   slots:1638-3276 (1639 slots) master
M: ba39bada8a2e393f76d265ea02d3e078c9406a93 127.0.0.1:18102
   slots:3277-4914 (1638 slots) master
M: 16da3917eff32cde8942660324c7374117902b01 127.0.0.1:18103
   slots:4915-6553 (1639 slots) master
M: 5ed447baf1f1c6c454459c24809ffc197809cb6b 127.0.0.1:18104
   slots:6554-8191 (1638 slots) master
M: d4cdcfdfdfb966a74a1bafce8969f956b5312094 127.0.0.1:18105
   slots:8192-9829 (1638 slots) master
M: 6f89f0b44f0a515865173984b95fc3f6fe4e7d72 127.0.0.1:18106
   slots:9830-11468 (1639 slots) master
M: d531628bf7b2afdc095e445d21dedc2549cc4590 127.0.0.1:18107
   slots:11469-13106 (1638 slots) master
M: ae71f4430fba6a019e4111c3d26e27e225764200 127.0.0.1:18108
   slots:13107-14745 (1639 slots) master
M: b3734a60336856f8c4ef08efe763ae3ac32bb94a 127.0.0.1:18109
   slots:14746-16383 (1638 slots) master
S: 128a527bba2823e547e8138a77aebcfec7e55342 127.0.0.1:18150
   replicates 7e72dff98fdda09cf97e02420727fd8b6564b6ae
S: ab72ae8dafc8a3f3229157cf5965bbfa1db6c726 127.0.0.1:18151
   replicates c3b5e673033758d77680e4534855686649fe5daa
S: f6670f4b8570758d509b5a0341a5151abea599ea 127.0.0.1:18152
   replicates ba39bada8a2e393f76d265ea02d3e078c9406a93
S: f004736cb50724f089289af34bd8da2e98b07a0b 127.0.0.1:18153
   replicates 16da3917eff32cde8942660324c7374117902b01
S: 8d0061ff0bc8fcc0e8a9fa5db8d6ab0b7b7ba9d0 127.0.0.1:18154
   replicates 5ed447baf1f1c6c454459c24809ffc197809cb6b
S: 208496ceb24eba1e26611071e185007b1ad552c5 127.0.0.1:18155
   replicates d4cdcfdfdfb966a74a1bafce8969f956b5312094
S: 3d3af1bf3dec40fe0d5dbe1314638733dadb686e 127.0.0.1:18156
   replicates 6f89f0b44f0a515865173984b95fc3f6fe4e7d72
S: bbcba7c269fb8162e0f7ef5807e079ba06fc032b 127.0.0.1:18157
   replicates d531628bf7b2afdc095e445d21dedc2549cc4590
S: 6b3a7f40f36cbe7aaad8ffffa58aefbf591d4967 127.0.0.1:18158
   replicates ae71f4430fba6a019e4111c3d26e27e225764200
S: 11f3c47b736e37b274bbdef95a580a0c89bc9d9b 127.0.0.1:18159
   replicates b3734a60336856f8c4ef08efe763ae3ac32bb94a
Can I set the above configuration? (type 'yes' to accept): >>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join..................................................................................
>>> Performing Cluster Check (using node 127.0.0.1:18100)
M: 7e72dff98fdda09cf97e02420727fd8b6564b6ae 127.0.0.1:18100
   slots:0-1637 (1638 slots) master
M: c3b5e673033758d77680e4534855686649fe5daa 127.0.0.1:18101
   slots:1638-3276 (1639 slots) master
M: ba39bada8a2e393f76d265ea02d3e078c9406a93 127.0.0.1:18102
   slots:3277-4914 (1638 slots) master
M: 16da3917eff32cde8942660324c7374117902b01 127.0.0.1:18103
   slots:4915-6553 (1639 slots) master
M: 5ed447baf1f1c6c454459c24809ffc197809cb6b 127.0.0.1:18104
   slots:6554-8191 (1638 slots) master
M: d4cdcfdfdfb966a74a1bafce8969f956b5312094 127.0.0.1:18105
   slots:8192-9829 (1638 slots) master
M: 6f89f0b44f0a515865173984b95fc3f6fe4e7d72 127.0.0.1:18106
   slots:9830-11468 (1639 slots) master
M: d531628bf7b2afdc095e445d21dedc2549cc4590 127.0.0.1:18107
   slots:11469-13106 (1638 slots) master
M: ae71f4430fba6a019e4111c3d26e27e225764200 127.0.0.1:18108
   slots:13107-14745 (1639 slots) master
M: b3734a60336856f8c4ef08efe763ae3ac32bb94a 127.0.0.1:18109
   slots:14746-16383 (1638 slots) master
M: 128a527bba2823e547e8138a77aebcfec7e55342 127.0.0.1:18150
   slots: (0 slots) master
   replicates 7e72dff98fdda09cf97e02420727fd8b6564b6ae
M: ab72ae8dafc8a3f3229157cf5965bbfa1db6c726 127.0.0.1:18151
   slots: (0 slots) master
   replicates c3b5e673033758d77680e4534855686649fe5daa
M: f6670f4b8570758d509b5a0341a5151abea599ea 127.0.0.1:18152
   slots: (0 slots) master
   replicates ba39bada8a2e393f76d265ea02d3e078c9406a93
M: f004736cb50724f089289af34bd8da2e98b07a0b 127.0.0.1:18153
   slots: (0 slots) master
   replicates 16da3917eff32cde8942660324c7374117902b01
M: 8d0061ff0bc8fcc0e8a9fa5db8d6ab0b7b7ba9d0 127.0.0.1:18154
   slots: (0 slots) master
   replicates 5ed447baf1f1c6c454459c24809ffc197809cb6b
M: 208496ceb24eba1e26611071e185007b1ad552c5 127.0.0.1:18155
   slots: (0 slots) master
   replicates d4cdcfdfdfb966a74a1bafce8969f956b5312094
M: 3d3af1bf3dec40fe0d5dbe1314638733dadb686e 127.0.0.1:18156
   slots: (0 slots) master
   replicates 6f89f0b44f0a515865173984b95fc3f6fe4e7d72
M: bbcba7c269fb8162e0f7ef5807e079ba06fc032b 127.0.0.1:18157
   slots: (0 slots) master
   replicates d531628bf7b2afdc095e445d21dedc2549cc4590
M: 6b3a7f40f36cbe7aaad8ffffa58aefbf591d4967 127.0.0.1:18158
   slots: (0 slots) master
   replicates ae71f4430fba6a019e4111c3d26e27e225764200
M: 11f3c47b736e37b274bbdef95a580a0c89bc9d9b 127.0.0.1:18159
   slots: (0 slots) master
   replicates b3734a60336856f8c4ef08efe763ae3ac32bb94a
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

# 3. Operations

- ** PING**

You can simply check the status of the node with `PING` command.

``` bash
> flashbase cli -h localhost -p 18101
localhost:18101> ping
PONG
localhost:18101>
```

With using `flashbase cli-all`, you can check the status of all nodes.

``` bash
> flashbase cli-all ping
redis client for 127.0.0.1:18100
PONG
redis client for 127.0.0.1:18101
PONG
redis client for 127.0.0.1:18102
PONG
redis client for 127.0.0.1:18103
PONG
redis client for 127.0.0.1:18104
PONG
redis client for 127.0.0.1:18105
PONG
redis client for 127.0.0.1:18106
PONG
redis client for 127.0.0.1:18107
PONG
redis client for 127.0.0.1:18108
PONG
redis client for 127.0.0.1:18109
PONG
redis client for 127.0.0.1:18150
PONG
redis client for 127.0.0.1:18151
PONG
redis client for 127.0.0.1:18152
PONG
redis client for 127.0.0.1:18153
PONG
redis client for 127.0.0.1:18154
PONG
redis client for 127.0.0.1:18155
PONG
redis client for 127.0.0.1:18156
PONG
redis client for 127.0.0.1:18157
PONG
redis client for 127.0.0.1:18158
PONG
redis client for 127.0.0.1:18159
PONG
```

- ** INFO**

With `INFO` command, you can get all information of each node.

``` bash
> flashbase cli -h localhost -p 18101
localhost:18101> info all
# Server
redis_version:3.0.7
redis_git_sha1:29d44e4d
redis_git_dirty:0
redis_build_id:e5a4dd48086abff2
redis_mode:cluster
os:Darwin 18.7.0 x86_64
arch_bits:64
multiplexing_api:kqueue
gcc_version:4.2.1
process_id:42593
run_id:ea34cce757c61d65e344b6c1094b940c3ab46110
tcp_port:18101
uptime_in_seconds:516
uptime_in_days:0
hz:10
lru_clock:3282808
config_file:/Users/myaccount/tsr2/cluster_1/tsr2-assembly-1.0.0-SNAPSHOT/conf/redis/redis-18101.conf

# Clients
connected_clients:1
client_longest_output_list:0
client_biggest_input_buf:0
blocked_clients:0


# Memory
isOOM:false
used_memory:20752816
used_memory_human:19.79M
used_memory_rss:23941120
used_memory_peak:20752816
used_memory_peak_human:19.79M
used_memory_lua:36864
used_memory_rocksdb_total:100663872
used_memory_rocksdb_block_cache:100663296
used_memory_rocksdb_mem_table:576
used_memory_rocksdb_table_readers:0
used_memory_rocksdb_pinned_block:0
meta_data_memory:64
percent_of_meta_data_memory:0
used_memory_client_buffer_peak:0
mem_fragmentation_ratio:1.15
mem_allocator:libc

# Persistence
loading:0
rdb_changes_since_last_save:0
rdb_bgsave_in_progress:0
rdb_last_save_time:1597117812
rdb_last_bgsave_status:ok
rdb_last_bgsave_time_sec:-1
rdb_current_bgsave_time_sec:-1
aof_enabled:1
aof_rewrite_in_progress:0
aof_rewrite_scheduled:0
aof_last_rewrite_time_sec:-1
aof_current_rewrite_time_sec:-1
aof_last_bgrewrite_status:ok
aof_last_write_status:ok
aof_current_size:0
aof_base_size:0
aof_pending_rewrite:0
aof_buffer_length:0
aof_rewrite_buffer_length:0
aof_pending_bio_fsync:0
aof_delayed_fsync:0

# Stats
total_connections_received:5
total_commands_processed:513
instantaneous_ops_per_sec:0
total_net_input_bytes:33954
total_net_output_bytes:173640
instantaneous_input_kbps:0.02
instantaneous_output_kbps:0.00
rejected_connections:0
sync_full:1
sync_partial_ok:0
sync_partial_err:0
expired_keys:0
evicted_keys:0
keyspace_hits:0
keyspace_misses:0
pubsub_channels:0
pubsub_patterns:0
latest_fork_usec:1159
migrate_cached_sockets:0

# Replication
role:master
connected_slaves:1
slave0:ip=127.0.0.1,port=18151,state=online,offset=589,lag=1
master_repl_offset:589
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:2
repl_backlog_histlen:588

# CPU
used_cpu_sys:0.42
used_cpu_user:0.56
used_cpu_sys_children:0.00
used_cpu_user_children:0.00

# Commandstats
cmdstat_ping:calls=4,usec=19,usec_per_call=4.75,usec_std=1.00,usec_max=10
cmdstat_psync:calls=1,usec=17,usec_per_call=17.00,usec_std=0.00,usec_max=17
cmdstat_replconf:calls=416,usec=644,usec_per_call=1.55,usec_std=1.00,usec_max=11
cmdstat_info:calls=2,usec=312,usec_per_call=156.00,usec_std=5.00,usec_max=183
cmdstat_cluster:calls=90,usec=122372,usec_per_call=1359.69,usec_std=19.00,usec_max=1802

# Cluster
cluster_enabled:1

# Keyspace

# Tablespace

# Eviction
evictStat:sleeps=0,fullRowgroup=0,80Rowgroup=0,60Rowgroup=0,40Rowgroup=0,20Rowgroup=0,00Rowgroup=0
recentEvictStat:recent 200 rowgroups' avg full percent:0

# Storage(Disk Usage)
DB0_TTL(sec):2592000
DB0_size(KByte):200
DB0_numFiles:0

# CompressionRatios
CVA_compress_algorithm:zstd
CVA_comp_avg_ratio cannot be calculated because of not enough # of samples
localhost:18101>
```

You can also check the specified information of each node.

``` bash
localhost:18101> info memory
# Memory
isOOM:false
used_memory:20751904
used_memory_human:19.79M
used_memory_rss:23949312
used_memory_peak:20752816
used_memory_peak_human:19.79M
used_memory_lua:36864
used_memory_rocksdb_total:100663872
used_memory_rocksdb_block_cache:100663296
used_memory_rocksdb_mem_table:576
used_memory_rocksdb_table_readers:0
used_memory_rocksdb_pinned_block:0
meta_data_memory:64
percent_of_meta_data_memory:0
used_memory_client_buffer_peak:0
mem_fragmentation_ratio:1.15
mem_allocator:libc
localhost:18101>
localhost:18101> info storage
# Storage(Disk Usage)
DB0_TTL(sec):2592000
DB0_size(KByte):200
DB0_numFiles:0
localhost:18101>
```



- ** CLUSTER**

You can check the status of the cluster with `CLUSTER` command.

``` bash
localhost:18101> cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:20
cluster_size:10
cluster_current_epoch:20
cluster_my_epoch:2
cluster_stats_messages_ping_sent:665
cluster_stats_messages_pong_sent:679
cluster_stats_messages_meet_sent:15
cluster_stats_messages_sent:1359
cluster_stats_messages_ping_received:675
cluster_stats_messages_pong_received:680
cluster_stats_messages_meet_received:4
cluster_stats_messages_received:1359
localhost:18101>
localhost:18101> cluster nodes
d531628bf7b2afdc095e445d21dedc2549cc4590 127.0.0.1:18107 master - 0 1597118527011 8 connected 11469-13106
16da3917eff32cde8942660324c7374117902b01 127.0.0.1:18103 master - 0 1597118524000 4 connected 4915-6553
7e72dff98fdda09cf97e02420727fd8b6564b6ae 127.0.0.1:18100 master - 0 1597118521882 1 connected 0-1637
6b3a7f40f36cbe7aaad8ffffa58aefbf591d4967 127.0.0.1:18158 slave ae71f4430fba6a019e4111c3d26e27e225764200 0 1597118520862 19 connected
d4cdcfdfdfb966a74a1bafce8969f956b5312094 127.0.0.1:18105 master - 0 1597118526000 6 connected 8192-9829
11f3c47b736e37b274bbdef95a580a0c89bc9d9b 127.0.0.1:18159 slave b3734a60336856f8c4ef08efe763ae3ac32bb94a 0 1597118520000 20 connected
5ed447baf1f1c6c454459c24809ffc197809cb6b 127.0.0.1:18104 master - 0 1597118523932 5 connected 6554-8191
8d0061ff0bc8fcc0e8a9fa5db8d6ab0b7b7ba9d0 127.0.0.1:18154 slave 5ed447baf1f1c6c454459c24809ffc197809cb6b 0 1597118521000 15 connected
b3734a60336856f8c4ef08efe763ae3ac32bb94a 127.0.0.1:18109 master - 0 1597118528026 10 connected 14746-16383
f6670f4b8570758d509b5a0341a5151abea599ea 127.0.0.1:18152 slave ba39bada8a2e393f76d265ea02d3e078c9406a93 0 1597118524959 13 connected
128a527bba2823e547e8138a77aebcfec7e55342 127.0.0.1:18150 slave 7e72dff98fdda09cf97e02420727fd8b6564b6ae 0 1597118524000 11 connected
c3b5e673033758d77680e4534855686649fe5daa 127.0.0.1:18101 myself,master - 0 1597118523000 2 connected 1638-3276
6f89f0b44f0a515865173984b95fc3f6fe4e7d72 127.0.0.1:18106 master - 0 1597118522000 7 connected 9830-11468
ba39bada8a2e393f76d265ea02d3e078c9406a93 127.0.0.1:18102 master - 0 1597118520000 3 connected 3277-4914
f004736cb50724f089289af34bd8da2e98b07a0b 127.0.0.1:18153 slave 16da3917eff32cde8942660324c7374117902b01 0 1597118524000 14 connected
ae71f4430fba6a019e4111c3d26e27e225764200 127.0.0.1:18108 master - 0 1597118525985 9 connected 13107-14745
ab72ae8dafc8a3f3229157cf5965bbfa1db6c726 127.0.0.1:18151 slave c3b5e673033758d77680e4534855686649fe5daa 0 1597118523000 12 connected
208496ceb24eba1e26611071e185007b1ad552c5 127.0.0.1:18155 slave d4cdcfdfdfb966a74a1bafce8969f956b5312094 0 1597118520000 16 connected
bbcba7c269fb8162e0f7ef5807e079ba06fc032b 127.0.0.1:18157 slave d531628bf7b2afdc095e445d21dedc2549cc4590 0 1597118513713 18 connected
3d3af1bf3dec40fe0d5dbe1314638733dadb686e 127.0.0.1:18156 slave 6f89f0b44f0a515865173984b95fc3f6fe4e7d72 0 1597118523000 17 connected
localhost:18101>
localhost:18101> cluster slots
 1) 1) (integer) 11469
    2) (integer) 13106
    3) 1) "127.0.0.1"
       2) (integer) 18107
    4) 1) "127.0.0.1"
       2) (integer) 18157
 2) 1) (integer) 4915
    2) (integer) 6553
    3) 1) "127.0.0.1"
       2) (integer) 18103
    4) 1) "127.0.0.1"
       2) (integer) 18153
 3) 1) (integer) 0
    2) (integer) 1637
    3) 1) "127.0.0.1"
       2) (integer) 18100
    4) 1) "127.0.0.1"
       2) (integer) 18150
 4) 1) (integer) 8192
    2) (integer) 9829
    3) 1) "127.0.0.1"
       2) (integer) 18105
    4) 1) "127.0.0.1"
       2) (integer) 18155
 5) 1) (integer) 6554
    2) (integer) 8191
    3) 1) "127.0.0.1"
       2) (integer) 18104
    4) 1) "127.0.0.1"
       2) (integer) 18154
 6) 1) (integer) 14746
    2) (integer) 16383
    3) 1) "127.0.0.1"
       2) (integer) 18109
    4) 1) "127.0.0.1"
       2) (integer) 18159
 7) 1) (integer) 1638
    2) (integer) 3276
    3) 1) "127.0.0.1"
       2) (integer) 18101
    4) 1) "127.0.0.1"
       2) (integer) 18151
 8) 1) (integer) 9830
    2) (integer) 11468
    3) 1) "127.0.0.1"
       2) (integer) 18106
    4) 1) "127.0.0.1"
       2) (integer) 18156
 9) 1) (integer) 3277
    2) (integer) 4914
    3) 1) "127.0.0.1"
       2) (integer) 18102
    4) 1) "127.0.0.1"
       2) (integer) 18152
10) 1) (integer) 13107
    2) (integer) 14745
    3) 1) "127.0.0.1"
       2) (integer) 18108
    4) 1) "127.0.0.1"
       2) (integer) 18158
localhost:18101>
```

- ** CONFIG**

With `CONFIG` command, you can set or get the configuration of each feature.

1) Get 

``` bash
localhost:18101> config get maxmemory
1) "maxmemory"
2) "300mb"
localhost:18101> config set maxmemory 310mb
OK
```

2) Set

``` bash
localhost:18101> config set maxmemory 310mb
OK
localhost:18101> config get maxmemory
1) "maxmemory"
2) "310mb"
```

3) Rewrite

With `config set` command, you can change the configuration only in memory.

To save the modification on disk, use `config rewrite` after setting.

``` bash
localhost:18101> config rewrite
OK
localhost:18101>
```

4) DIR

With `DIR` command, you can check the path of directory that each node uses to save *.rdb, *.aof, db and *.conf files.

``` bash
localhost:18101> config get dir
1) "dir"
2) "/sata_ssd/ssd_03/nvkvs/myaccount"
```

