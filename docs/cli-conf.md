
With `conf` commands, you can configure out the cluster.

You can open the template file with the below options(`cluster`/`master`/`slave`/`thriftserver`)

After saving the template file, the configuration will be synchronized with all nodes in the current cluster.

# 1. cluster

`conf cluster` will open `redis.properties` file of the current cluster.

```
matthew@lightningdb:21> conf cluster
Check status of hosts...
OK
Sync conf...
OK
Complete edit.
```

- Example of `redis.properties`

```
#!/bin/bash

## Master hosts and ports
export SR2_REDIS_MASTER_HOSTS=( "192.168.111.41" "192.168.111.44" )
export SR2_REDIS_MASTER_PORTS=( $(seq 20100 20102) )

## Slave hosts and ports (optional)
export SR2_REDIS_SLAVE_HOSTS=( "192.168.111.41"  "192.168.111.44" )
export SR2_REDIS_SLAVE_PORTS=( $(seq 20150 20152) )


## multiple data directory in redis db and flash db
export SSD_COUNT=3
export SR2_REDIS_DATA="/sata_ssd/ssd_02/matthew"
export SR2_REDIS_DB_PATH="/sata_ssd/ssd_02/matthew"
export SR2_FLASH_DB_PATH="/sata_ssd/ssd_02/matthew"
```

# 2. master

`conf master` will open `redis-master.conf.template` file of the current cluster. This file will configure all redis-servers in the current cluster.

```
matthew@lightningdb:21> conf master
Check status of hosts...
OK
Sync conf...
OK
Complete edit.
```

- Example of `redis-master.conf.template`

```
# In short... if you have slaves attached it is suggested that you set a lower
# limit for maxmemory so that there is some free RAM on the system for slave
# output buffers (but this is not needed if the policy is 'noeviction').
#
# maxmemory <bytes>
# maxmemory should be greater than 51mb in TSR2
maxmemory 300mb
```

# 3. thrifserver

`conf thrifserver` will open `thriftserver.properties` file of the current thriftserver.

```
matthew@lightningdb:21> conf thriftserver
Check status of hosts...
OK
Sync conf...
OK
Complete edit.
```

- Example of `thriftserver.properties`

```
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

########################
# Thrift Name
cluster_id=$(echo $SR2_HOME | awk -F "cluster_" '{print $2}' | awk -F '/' '{print $1}')
host=$(hostname)
THRIFT_NAME="ThriftServer_${host}_${cluster_id}"
########################

###############################################################################
# AGGREGATION PUSHDOWN
AGG_PUSHDOWN=true
###############################################################################
```

# 4. sync

With `sync {IP address}` or `sync {hostname}` command, you can load the configurations of all clusters from the remote server to localhost.

```
matthew@lightningdb:21> sync fbg04
Localhost already has the information on the cluster 21. Do you want to overwrite? (y/n) [n]
y
Localhost already has the information on the cluster 20. Do you want to overwrite? (y/n) [n]
n
Importing cluster complete...
```