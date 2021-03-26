# 1. Kafka broker

** 1. Kafka Cluster **

(1) Install kafka

- Install kafka in each server in which kafka cluster is utilized.
- Add `$KAFKA_HOME` path into `~/.bash_profile`.

(2) Install zookeeper

- In each server of kafka cluster, set ` $dataDir`, `$server.1 ~ $server.n` properties in `$KAFKA_HOME/config/zookeeper.properties`.
- For example, if you try to configure kafka cluster with `my-server1`, `my-server2`, set `server.1`, `server.2` fields.

```console
dataDir=/hdd_01/zookeeper
# the port at which the clients will connect
clientPort=2181
# disable the per-ip limit on the number of connections since this is a non-production config
maxClientCnxns=0

initLimit=5
syncLimit=2

# Zookeeper will use these ports (2891, etc.) to connect the individual follower nodes to the leader nodes.
# The other ports (3881, etc.) are used for leader election in the ensemble.
server.1=my-server1:2888:3888
server.2=my-server2:2888:3888
```

- In each server, set `${dataDir}/myid` with its own id.
- For example, use `echo "1" > ${dataDir}/myid` in my-server1 and `echo "2" > ${dataDir}/myid` in my-server2.
- start zookeeper in each server.

``` console
    > $KAFKA_HOME/bin/zookeeper-server-start.sh config/zookeeper.properties &
```

(3) Start kafka broker

- Edit `$KAFKA_HOME/conf/server.properties` in each server,
- Set `Broker ID` in `my-server1`.
```console
    broker.id=1     // '2' in case of my-server2
```

- Configure zookeeper IP and PORT : Add `,` as seperator.
```console
    zookeeper.connect=my-server1:2181,my-server2:2181
```

- Configure a path for Kafka data: Add a directory in each disk for load balancing.
```console
    log.dirs=/hdd_01/kafka,/hdd_02/kafka,/hdd_03/kafka,/hdd_04/kafka
```

- Configure a retention time for keeping record and a retention size limit for each partition.
```console
    # default value: 168
    log.retention.hours=168 

    # '-1' means 'unlimited'.
    log.retention.bytes=-1
```

- Configure a max size of a message.
```console
    # If a size of a produced message exceed this limit, the exception is thrown.
    # If you want to create a message with many rows, increase this value and restart broker.
    # default value: 1000012 byte
    message.max.bytes=1000012
```

- Start kafka server in each server.
```console
    > $KAFKA_HOME/bin/kafka-server-start.sh config/server.properties &
```

- Create topic.
```console
    # --zookeeper localhost:2181 : Need zookeeper host & clientPort, because topics and partition information are stored in zookeeper.
    # --topic nvkvs : For example, set 'nvkvs' as topic name.
    # --partitions 16 : For example, set 2 partitions in each disk and use 16 partitions((# of cluster nodes) X (# of disks in each node) X 2 = 2 X 4 X 2 = 16).
    # --replication-factor 2 : Create 1 follower for each partition.
    > $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 2 --partitions 16 --topic nvkvs
    # Check a generated topic: A broker.id of Replicas is different with a broker.id of Leader.
    > $KAFKA_HOME/bin/kafka-topics.sh --zookeeper localhost:2181 --describe --topic nvkvs
    
    Topic:nvkvs	PartitionCount:16	ReplicationFactor:2	Configs:
	Topic: nvkvs	Partition: 0	Leader: 0	Replicas: 0,1	Isr: 1,0
	Topic: nvkvs	Partition: 1	Leader: 1	Replicas: 1,0	Isr: 1,0
	Topic: nvkvs	Partition: 2	Leader: 0	Replicas: 0,1	Isr: 1,0
	Topic: nvkvs	Partition: 3	Leader: 1	Replicas: 1,0	Isr: 1,0
	Topic: nvkvs	Partition: 4	Leader: 0	Replicas: 0,1	Isr: 1,0
	Topic: nvkvs	Partition: 5	Leader: 1	Replicas: 1,0	Isr: 1,0
	Topic: nvkvs	Partition: 6	Leader: 0	Replicas: 0,1	Isr: 1,0
	Topic: nvkvs	Partition: 7	Leader: 1	Replicas: 1,0	Isr: 1,0
	Topic: nvkvs	Partition: 8	Leader: 0	Replicas: 0,1	Isr: 1,0
	Topic: nvkvs	Partition: 9	Leader: 1	Replicas: 1,0	Isr: 1,0
	Topic: nvkvs	Partition: 10	Leader: 0	Replicas: 0,1	Isr: 1,0
	Topic: nvkvs	Partition: 11	Leader: 1	Replicas: 1,0	Isr: 1,0
	Topic: nvkvs	Partition: 12	Leader: 0	Replicas: 0,1	Isr: 1,0
	Topic: nvkvs	Partition: 13	Leader: 1	Replicas: 1,0	Isr: 1,0
	Topic: nvkvs	Partition: 14	Leader: 0	Replicas: 0,1	Isr: 1,0
	Topic: nvkvs	Partition: 15	Leader: 1	Replicas: 1,0	Isr: 1,0
```

- Delete topic / Modify the number of partitions.
```console
    # Topic delete Command
    > $KAFKA_HOME/bin/kafka-topics.sh --zookeeper localhost:2181 --delete --topic nvkvs

    # Topic partition modification
    > $KAFKA_HOME/bin/kafka-topics.sh --zookeeper localhost:2181/chroot --alter --topic nvkvs --partitions 6
```
  
  
** 2. Kafka Topic Information **

- Consumer list
```console
    > $KAFKA_HOME/bin/kafka-consumer-groups.sh  --list --bootstrap-server localhost:9092
```

- Console consumer start
```console
    > $KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic nvkvs --from-beginning
```

- Consumer offset check
```console
    # Add '--group {consumer group name}'
    > $KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group (Consumer group name)

    TOPIC           PARTITION  CURRENT-OFFSET  LOG-END-OFFSET  LAG             CONSUMER-ID     HOST            CLIENT-ID
    nvkvs           4          272904          272904          0               -               -               -
    nvkvs           12         272904          272904          0               -               -               -
    nvkvs           15         273113          273113          0               -               -               -
    nvkvs           6          272906          272906          0               -               -               -
    nvkvs           0          272907          272907          0               -               -               -
    nvkvs           8          272905          272905          0               -               -               -
    nvkvs           3          273111          273111          0               -               -               -
    nvkvs           9          273111          273111          0               -               -               -
    nvkvs           13         273111          273111          0               -               -               -
    nvkvs           10         272912          272912          0               -               -               -
    nvkvs           1          273111          273111          0               -               -               -
    nvkvs           11         273112          273112          0               -               -               -
    nvkvs           14         272904          272904          0               -               -               -
    nvkvs           7          273110          273110          0               -               -               -
    nvkvs           5          273111          273111          0               -               -               -
    nvkvs           2          272905          272905          0               -               -               -
```

- Consumer offset modification
```console
    # --shift-by <positive_or_negative_integer>
    # --group < name of group to shift>
    > $KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --reset-offsets --shift-by -10000 --execute --group (Consumer 그룹명) --topic nvkvs
```
  
# 2. Kafka consumer

** 1. Kaetlyn Consumer **

- tsr2-kaetlyn edit
```
  KAFKA_SERVER : Kafka Broker의 host:port
  DRIVER_MEMORY, EXECUTOR_MEMORY : A memory of Spark Driver/Excutor의 Memory in Yarn. After start, check 'FGC' count with using 'jstat -gc' and optimize these values.
  EXECUTERS, EXECUTER_CORES : Basically consumers as many as the number of kafka partitions are generated. With this rule, need to optimize the number of EXECUTERS, EXECUTER_CORES.
  JSON_PATH : The path of TABLE json. Do not support hdfs path. This is relative path from tsr2-kaetlyn.
  KAFKA_CONSUMER_GROUP_ID : consumer group id
  KAFKA_CONSUMING_TOPIC_LIST : Topic list with seperator ','.
  JOB_GENERATION_PERIOD : With this period, check latest-offset and execute consuming job.
  MAX_RATE_PER_PARTITION : the maximum offset that a consumer executes within a job period.
```

```console
> cfc 1 (or c01)
> tsr2-kaetlyn edit

#!/bin/bash
###############################################################################
# Common variables
SPARK_CONF=${SPARK_CONF:-$SPARK_HOME/conf}
SPARK_BIN=${SPARK_BIN:-$SPARK_HOME/bin}
SPARK_SBIN=${SPARK_SBIN:-$SPARK_HOME/sbin}
SPARK_LOG=${SPARK_LOG:-$SPARK_HOME/logs}

SPARK_METRICS=${SPARK_CONF}/metrics.properties
SPARK_UI_PORT=${SPARK_UI_PORT:-14040}

KAFKA_SERVER=my-server1:9092

###############################################################################
# Properties for Consumer
DRIVER_MEMORY=2g

EXECUTOR_MEMORY=2g
EXECUTERS=16
EXECUTER_CORES=4

JSON_PATH=~/Flashbase/flashbase-benchmark/json/load_no_skew
KAFKA_CONSUMER_GROUP_ID=nvkvs_redis_connector
KAFKA_CONSUMING_TOPIC_LIST=nvkvs
JOB_GENERATION_PERIOD=1
MAX_RATE_PER_PARTITION=100
...
```

** 2. Kaetlyn Consumer start/stop **

 - Because a kaetlyn consumer is a spark application in yarn cluster, Hadoop/Yarn and spark should already be installed.
 - Start and monitor Driver Log 

```console
> tsr2-kaetlyn consumer start
> tsr2-kaetlyn consumer monitor
```
 - If a consumer is started successfully, a state of application in yarn is set as RUNNING.

```console
> yarn application -list
```

 - Stop : By SIGTERM, stop a current job and update kafka offset.

```console
> tsr2-kaetlyn consumer stop
```
  
** 3. Kaetlyn Log level modification **

- Kaetlyn use a logback as a logger. After kaetlyn consumer start, '$SPARK_HOME/conf/logback-kaetlyn.xml' file is generated.
- to modify driver log level, edit this file.
```console
  > vi $SPARK_HOME/conf/logback-kaetlyn.xml
```
  

# 3. Kafka producer

Start kafka producer.

``` console
kafka-console-producer.sh --broker-list localhost:9092 --topic {topic name} < {filename to ingest}
```

To produce for a kaetlyn consumer,  2 header fields should be included.

``` console
TABLE_ID
SEPARATOR
```

If you use 'kafkacat', you can produce with the additional header fields.(https://docs.confluent.io/3.3.0/app-development/kafkacat-usage.html# )

 ** 1. How to install kafkacat **

- c++ compiler
``` console
$yum install gcc-c++
```

- Download source codes
``` console
$ git clone https://github.com/edenhill/librdkafka
```

- Make and Installation
``` console
$ cd librdkafka
$ ./configure
$ make
$ sudo make install
```

- Move to '/usr/local/lib' and execute below commands.
``` console
$ git clone https://github.com/edenhill/kafkacat
$ cd kafkacat
$ ./configure
$ make
$ sudo make install
```

- How to find Lib path
``` console
$ ldd kafkacat
```

- Create and edit /etc/ld.so.conf.d/usrlocal.conf
``` console
Contents:
/usr/local/lib
```

- Save and execution
``` console
$ ldconfig -v
```

- If 'kafkacat' is shown, kafkacat is installed successfully.
``` console
$kafkacat
```

** 2. Producing with kafkacat **


1) Produce a single file

``` console 
kafkacat -b localhost:9092 -t {topic name} -T -P -H TABLE_ID='{table id}' -H  SEPARATOR='|' -l {filename}
```

2) Produce all files in a directory

 After moving to the directory path,
``` console
ls | xargs -n 1 kafkacat -q -b localhost:9092 -t {topic name} -P -H TABLE_ID='{table id}' -H  SEPARATOR='|' -l
```

** 3. kafka-utils.sh **

With kafka-utils.sh, check the status of kafka broker.

Because 'kafka-utils.sh' exists under sbin path of each cluster, you can use this with 'cfc {cluster number}'.

``` console
[C:6][ltdb@d205 ~]$ which kafka-utils.sh
~/tsr2/cluster_6/tsr2-assembly-1.0.0-SNAPSHOT/sbin/kafka-utils.sh
```

After 'CONSUMER_GROUP_ID' is set, kafka-utils.sh is enabled.

``` console
[C:6][ltdb@d205 ~]$ kafka-utils.sh help
Please, set $CONSUMER_GROUP_ID first.
```

Need to set'kafka-utils.sh'.

``` console
#!/bin/bash
 
CONSUMER_GROUP_ID='nvkvs_redis_connector'  // Need to modify
KAFKA_SERVER=localhost:9092
ZOOKEEPER_SERVER=localhost:2181...
```

``` console
[C:6][ltdb@d205 ~/kafka/config]$ kafka-utils.sh help
kafka-utils.sh offset-check
kafka-utils.sh offset-monitor
kafka-utils.sh offset-earliest topic_name
kafka-utils.sh offset-latest topic_name
kafka-utils.sh offset-move topic_name 10000
kafka-utils.sh error-monitor error_topic_name
kafka-utils.sh consumer-list
kafka-utils.sh topic-check topic_name
kafka-utils.sh topic-create topic_name 10
kafka-utils.sh topic-delete topic_name
kafka-utils.sh topic-config-check topic_name
kafka-utils.sh topic-config-set topic_name config_name config_value
kafka-utils.sh topic-config-remove topic_name config_name
kafka-utils.sh topic-list
kafka-utils.sh message-earliest topic_name
kafka-utils.sh message-latest topic_name
```

If a command needs args, the error messages like below is shown.

``` console
[C:6][ltdb@d205 ~/kafka/config]$ kafka-utils.sh offset-move 
Please, specify topic name & the size of moving offset (ex) kafka-utils.sh offset-move my-topic 100
[C:6][ltdb@d205 ~/kafka/config]$ kafka-utils.sh topic-create
Please, specify topic name and its partition count. (ex) kafka-utils.sh topic-create topic-new 10
[C:6][ltdb@d205 ~/kafka/config]$
```

For example,

``` console
[C:6][ltdb@d205 ~]$ kafka-utils.sh message-earliest nvkvs3
20160711055950|ELG|2635055200|34317|5|6091|1|25|0|11|0|100.0|0.0|0|2846|3|33|0|5|0|-1000|0.0|0.0|94932|1027|0|176|35.2|40|0|7818000000|109816071|10|0|6000000.0|164843|2.75|0|2592|6000000|0.04|1288488|1303|1338|0|530|1|88.33|0|721|67948|428|0|1|108|108.0|108|0|0.0|0|0|0|-1000|1|1|100.0|62|39.0|62.9|23.0|37.1|0|0|0|0|29|10|-7022851.0|59998.0|-117.05|-6865443.5|59998.0|-114.43|4|198060.0|59998.0|22.5|3.3|0|1|5.82|3|1.94||0|0|0|0|0|0|0|0|4|0|0|0|15|14|231|140|0|0|0|0|0|0|0|0|4|0|0|0|15|13|174|110|1|0|0|0|0|0|0|0|0|0|0|0|0|0|1|0|0|0|0|0|0|0|1|0|0|0|0|0|0|0|0|0|0.0|0.0|0.0|0.0|0.0|0.0|570.0|0.0|3.0|0.0|0.0|0.0|0.0|2.0|3.0|3.0|0.0|15.73|0.0|0.0|0.0|0.0|0.0|12.0|22.0|68.0|83.0|339.0|205.0|144.0|54.0|38.0|12.0|0.0|0.0|0.0|0.0|0.0|0.0|100.0|50.55|1:22,2:7|1.0|||||1:1,17:1,23:1|13.67|0|0|0.0|0.0|-1000||-1000||-1000|11|2|05
Processed a total of 1 messages
 
 
[C:6][ltdb@d205 ~]$ kafka-utils.sh topic-list
__consumer_offsets
nvkvs3
topic-error
topic_name
 
 
[C:6][ltdb@d205 ~]$ kafka-utils.sh topic-create ksh 18
Created topic ksh.
 
 
[C:6][ltdb@d205 ~]$ kafka-utils.sh topic-check  ksh
Topic:ksh   PartitionCount:18   ReplicationFactor:2 Configs:
    Topic: ksh  Partition: 0    Leader: 1   Replicas: 1,3   Isr: 1,3
    Topic: ksh  Partition: 1    Leader: 2   Replicas: 2,1   Isr: 2,1
    Topic: ksh  Partition: 2    Leader: 3   Replicas: 3,2   Isr: 3,2
    Topic: ksh  Partition: 3    Leader: 1   Replicas: 1,2   Isr: 1,2
    Topic: ksh  Partition: 4    Leader: 2   Replicas: 2,3   Isr: 2,3
    Topic: ksh  Partition: 5    Leader: 3   Replicas: 3,1   Isr: 3,1
    Topic: ksh  Partition: 6    Leader: 1   Replicas: 1,3   Isr: 1,3
    Topic: ksh  Partition: 7    Leader: 2   Replicas: 2,1   Isr: 2,1
    Topic: ksh  Partition: 8    Leader: 3   Replicas: 3,2   Isr: 3,2
    Topic: ksh  Partition: 9    Leader: 1   Replicas: 1,2   Isr: 1,2
    Topic: ksh  Partition: 10   Leader: 2   Replicas: 2,3   Isr: 2,3
    Topic: ksh  Partition: 11   Leader: 3   Replicas: 3,1   Isr: 3,1
    Topic: ksh  Partition: 12   Leader: 1   Replicas: 1,3   Isr: 1,3
    Topic: ksh  Partition: 13   Leader: 2   Replicas: 2,1   Isr: 2,1
    Topic: ksh  Partition: 14   Leader: 3   Replicas: 3,2   Isr: 3,2
    Topic: ksh  Partition: 15   Leader: 1   Replicas: 1,2   Isr: 1,2
    Topic: ksh  Partition: 16   Leader: 2   Replicas: 2,3   Isr: 2,3
    Topic: ksh  Partition: 17   Leader: 3   Replicas: 3,1   Isr: 3,1
```


