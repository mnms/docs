!!! Warning
    This document is temporarily written in Korean. This page will be translated into English soon.


# 1. Kafka 설정 및 실행

** 1. Cluster 구성 **

(1) 환경 변수 설정

- Kafka Cluster를 구성할 노드에 Kafka를 각각 설치해주고 ~/.bash_profile에 $KAFKA_HOME을 설정해준다.

(2) Zookeeper 설정 및 시작

- 각 서버 노드에 kafka 설치 후 $KAFKA_HOME/conf/zookeeper.properties 열어서 $dataDir, $server.1 ~ $server.n의 property를 설정한다.  
예로 my-server1, my-server2 두개의 노드에 cluster를 구성한다고 가정하면, server.1, server.2 두개의 노드를 써준다.

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

- 각 노드에서 ${dataDir}/myid 파일에 자신의 id를 쓴다.  
  my-server1에서는 '1'을 써주고 (echo "1" > ${dataDir}/myid) my-server2에서는 '2'를 써준다. (echo "2" > ${dataDir}/myid)

- 각각의 노드에서 zookeeper를 start 한다.

``` console
    > $KAFKA_HOME/bin/zookeeper-server-start.sh config/zookeeper.properties &
```

(3) Kafka Broker 설정 및 시작

- 각 서버 노드에서 $KAFKA_HOME/conf/server.properties 를 열고,
- Broker ID 설정
```console
    # 각각의 노드에서 broker의 id를 기입. 예제에서는 my-server1과 my-server2 두개의 노드에 다른 broker.id를 설정
    broker.id=1 (my-server2에서는 2)
```

- Zookeeper 주소 설정 : Zookeeper Cluster의 IP:clientPort를 ","로 연결
```console
    zookeeper.connect=my-server1:2181,my-server2:2181
```

- Kafka 데이터가 저장될 폴더 지정 : 로드 분산을 위해 Disk마다 폴더를 하나씩 할당
```console
    log.dirs=/hdd_01/kafka,/hdd_02/kafka,/hdd_03/kafka,/hdd_04/kafka
```

- Record 저장 기한 및 Partition 데이터 최대 사이즈 지정
```console
    # 기본값 168이고 이 시간이 지나면 Record가 사라진다.
    # log.retention.hours=168 

    # Partition의 물리적 최대 크기. 크기를 초과하면 디스크에서 메시지가 삭제된다. -1이면 무제한
    # log.retention.bytes=-1
```

- Record하나의 최대 Size 지정
```console
    # Produce된 Record가 이 Size를 넘어가면 Producer에서 Exception이 발생한다. 많은 Row를 한번에 묶어서 메시지를 생성하고 싶다면 이 값을 올려주고 broker를 재시작한다.
    # 기본값은 1000012 byte
    message.max.bytes=1000012
```

- 각각의 노드에서 Kafka 서버 시작
```console
    > $KAFKA_HOME/bin/kafka-server-start.sh config/server.properties &
```

- 토픽 생성 및 확인
```console
    # --zookeeper localhost:2181 : 토픽과 Partition정보는 zookeeper에 저장되기 때문에 zookeeper host & clientPort를 같이 넘겨줘야 한다.
    # --topic nvkvs : 토픽이름을 nvkvs로 생성.
    # --partitions 16 : partition은 Disk당 2개의 파티션을 할당해주었다. 예시에서는 (클러스터의 노드 갯수) X (노드당 디스크 수) X 2 = 2 X 4 X 2 = 16 할당했다.
    # --replication-factor 2 : partition의 follower를 하나씩 만들어주었다. follower는 leader와 다른 노드에 할당되기 때문에 my-server1, my-server2 중 하나가 shutdown되어도 Kafka Cluster가 문제없이 운영될 수 있다.
    > $KAFKA_HOME/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 2 --partitions 16 --topic nvkvs

    # 생성된 Topic을 확인 : 클러스터가 제대로 구성되었다면 Replicas의 broker.id가 Leader의 broker.id가 다르게 표시되는 것을 확인할 수 있다.
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

- 토픽 삭제나 파티션 수 변경
```console
    # Topic 삭제 Command
    > $KAFKA_HOME/bin/kafka-topics.sh --zookeeper localhost:2181 --delete --topic nvkvs

    # Topic Partition 수 변경
    > $KAFKA_HOME/bin/kafka-topics.sh --zookeeper localhost:2181/chroot --alter --topic nvkvs --partitions 6
```
  
  
** 2. Kafka Topic정보 확인하기 **

- Consumer list 확인하기
```console
    > $KAFKA_HOME/bin/kafka-consumer-groups.sh  --list --bootstrap-server localhost:9092
```

- Console consumer 시작
```console
    > $KAFKA_HOME/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic nvkvs --from-beginning
```

- Consumer Offset 체크
```console
    # --group에 확인할 Group명을 써준다.
    > $KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group (Consumer 그룹명)

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

- Consumer Offset 변경
```console
    # --shift-by에 shift시킬 offset를 써준다. 앞으로 이동 시에는 -를 앞에 써주면 된다. 단, 앞으로 이동 시 retention기간이 지난 offset으로는 이동하지 않는다.
    # --group에 shift할 Group명을 써준다.
    > $KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server localhost:9092 --reset-offsets --shift-by -10000 --execute --group (Consumer 그룹명) --topic nvkvs
```
  
# 2. Kaetlyn Consumer 설정 및 시작

** 1. Kaetlyn Consumer 설정 **

- tsr2-kaetlyn edit
```
  KAFKA_SERVER : Kafka Broker의 host:port
  DRIVER_MEMORY, EXECUTOR_MEMORY : Yarn에서 할당해주는 Spark Driver/Excutor의 Memory. 적재 후 jstat -gc를 통해 메모리 사용량과 FGC 카운트를 확인한 후 적당하게 설정해준다.
  EXECUTERS, EXECUTER_CORES : 기본적으로 Kafka Partition 갯수만큼 Consumer가 만들어진다. 이를 고려해 설정 필요
  JSON_PATH : TABLE json이 있는 폴더 path. hdfs파일 경로는 지원하지 않는다. tsr2-kaetlyn을 시작하는 노드에서의 폴더 경로.
  KAFKA_CONSUMER_GROUP_ID : consumer Group ID
  KAFKA_CONSUMING_TOPIC_LIST : Consuming할 Topic List를 콤마(,)로 연결
  JOB_GENERATION_PERIOD : 지정된 sec마다 timer가 돌면서 latest-offset을 확인해서 Consuming Job을 실행한다.
  MAX_RATE_PER_PARTITION : Job Period내에서 Consumer하나가 처리할 수 있는 최대 offset.
```

```console
> cfc 1 (또는 c01)
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

 - 기본적으로 Yarn cluster 상에서 동작하는 Spark Application이므로 Spark이 설치되어 있고 Hadoop/Yarn이 구동되고 있는 노드에서 시작할 수 있다.
 - Start 및 Driver Log Monitoring 

```console
> tsr2-kaetlyn consumer start
> tsr2-kaetlyn consumer monitor
```
 - 성공적으로 시작되었다면 yarn의 application state가 RUNNING이 된다.

```console
> yarn application -list
```

 - Stop하기 : SIGTERM을 받아서 진행 중이던 Job을 마무리하고 Kafka offset을 업데이트 하므로 stop후에 실제 종료되는데 시간이 약간 필요하다.

```console
> tsr2-kaetlyn consumer stop
```
  
** 3. Kaetlyn Log level 조정 **

- logger로 logback을 사용하고 있다. kaetlyn실행 후 '$SPARK_HOME/conf/logback-kaetlyn.xml' 파일이 생성된다. Driver Log level 조정 시에는 이 파일을 편집하면 된다.
```console
  > vi $SPARK_HOME/conf/logback-kaetlyn.xml
```
  

# 3. Kafka producer 설정 및 시작

기본적으로 kafka producing은 아래와 같은 방법으로 할 수 있음

``` console
kafka-console-producer.sh --broker-list localhost:9092 --topic {topic name} < {적재할 filename}
```

하지만, kaetlyn 적재를 위해서는 메시지에 아래 헤더 정보가 포함되어야 한다.

``` console
TABLE_ID
SEPARATOR
```

따라서 kafkacat이라는 tool을 통해 헤더 정보와 함께 producing을 해야 한다.(https://docs.confluent.io/3.3.0/app-development/kafkacat-usage.html# 참고)

 ** 1. kafkacat 설치 방법 **

- c++ compiler 설치
``` console
$yum install gcc-c++
```

- 소스 코드 받기
``` console
$ git clone https://github.com/edenhill/librdkafka
```

- Install
``` console
$ cd librdkafka
$ ./configure
$ make
$ sudo make install
```

- '/usr/local/lib' 로 이동해주어 다음 명령어 실행한다.
``` console
$ git clone https://github.com/edenhill/kafkacat
$ cd kafkacat
$ ./configure
$ make
$ sudo make install
```

- Lib 파일을 찾을 수 없다면
``` console
$ ldd kafkacat
```

- 다음의 파일을 만들고 아래를 추가 /etc/ld.so.conf.d/usrlocal.conf
``` console
Contents:
/usr/local/lib
```

- 저장 후 아래 명령어 실행
``` console
$ ldconfig -v
```

- Kafkacat에 대한 명령어가 나오면 성공
``` console
$kafkacat
```

** 2. kafkacat을 사용한 producing 방법 **

kafkacat이 정상 설치되었으면 아래와 같이 producing이 가능함

1) file 하나만 적재할 경우

``` console 
kafkacat -b localhost:9092 -t {topic name} -T -P -H TABLE_ID='{table id}' -H  SEPARATOR='|' -l {적재할 filename}
```

2) dir에 있는 모든 파일을 적재할 경우

 해당 dir로 이동한 후에,
``` console
ls | xargs -n 1 kafkacat -q -b localhost:9092 -t {topic name} -P -H TABLE_ID='{table id}' -H  SEPARATOR='|' -l
```

** 3. kafka-utils.sh **

Kafka를 좀 더 편리하게 사용하기 위해 kafka-utils.sh를 제공하고 있어 운영 시에는  kafka-utils.sh를 사용할 수 있음

'kafka-utils.sh'는 각 클러스터별 sbin에 있으므로, 'cfc'로 cluster 설정 후 사용이 가능함.

``` console
[C:6][ltdb@d205 ~]$ which kafka-utils.sh
~/tsr2/cluster_6/tsr2-assembly-1.0.0-SNAPSHOT/sbin/kafka-utils.sh
```

아래와 같이 'CONSUMER_GROUP_ID'가 지정되어 있지 않으면 실행이 되지 않으므로,

``` console
[C:6][ltdb@d205 ~]$ kafka-utils.sh help
Please, set $CONSUMER_GROUP_ID first.
```

아래와 같이 'kafka-utils.sh'를 열어서 수정을 해야 함.

``` console
#!/bin/bash
 
CONSUMER_GROUP_ID='nvkvs_redis_connector'  // 수정 필요
KAFKA_SERVER=localhost:9092
ZOOKEEPER_SERVER=localhost:2181...
```

'help'를 통해 가능한 커맨드를 확인할 수 있음.

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

command에 args가 필요한 경우, args없이 입력하면 아래와 같이 가이드 문구가 나옴.

``` console
[C:6][ltdb@d205 ~/kafka/config]$ kafka-utils.sh offset-move 
Please, specify topic name & the size of moving offset (ex) kafka-utils.sh offset-move my-topic 100
[C:6][ltdb@d205 ~/kafka/config]$ kafka-utils.sh topic-create
Please, specify topic name and its partition count. (ex) kafka-utils.sh topic-create topic-new 10
[C:6][ltdb@d205 ~/kafka/config]$
```

사용 예,

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


