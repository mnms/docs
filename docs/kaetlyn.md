# 1. Kafka 설정 및 실행

** 1. Cluster 구성 **

(1) 환경 변수 설정

- Kafka Cluster를 구성할 노드에 Kafka를 각각 설치해주고 ~/.bash_profile에 $KAFKA_HOME을 설정해준다.(필수는 아님)

(2) Zookeeper 설정 및 시작

- 각 서버 노드에 kafka 설치 후 $KAFKA_HOME/conf/zookeeper.properties 열어서 $dataDir, $server.1 ~ $server.n의 property를 설정한다.  
예시로 apollo-w07, apollo-w08 두개의 노드에 cluster를 구성한다고 가정하면, server.1, server.2 두개의 노드를 써주면 된다.

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
server.1=apollo-w07:2888:3888
server.2=apollo-w08:2888:3888
```

- 각 노드에서 ${dataDir}/myid 파일에 자신의 id를 write 해준다.  
  apollo-w07에서는 1을 써주고 (echo "1" > ${dataDir}/myid) apollo-w08에서는 2를 써준다. (echo "2" > ${dataDir}/myid)

- 각각의 노드에서 zookeeper를 start 한다.

``` console
    > $KAFKA_HOME/bin/zookeeper-server-start.sh config/zookeeper.properties &
```

(3) Kafka Broker 설정 및 시작

- 각 서버 노드에서 $KAFKA_HOME/conf/server.properties 를 Open
- Broker ID 설정
```console
    # 각각의 노드에서 broker의 id를 기입. 예제에서는 apollo-w07과 apollo-w08 두개의 노드에 다른 broker.id를 설정
    broker.id=1 (apollo-w08에서는 2)
```

- Zookeeper 주소 설정 : Zookeeper Cluster의 IP:clientPort를 ","로 연결
```console
    zookeeper.connect=apollo-w07:2181,apollo-w08:2181
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
    # --replication-factor 2 : partition의 follower를 하나씩 만들어주었다. follower는 leader와 다른 노드에 할당되기 때문에 apollo-w07, apollo-w08 중 하나가 shutdown되어도 Kafka Cluster가 문제없이 운영될 수 있다.
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

KAFKA_SERVER=apollo-w07:9092

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
  - logger로 logback을 사용하고 있다. kaetlyn실행 후 $SPARK_HOME/conf/logback-kaetlyn.xml 파일이 생성된다. Driver Log level 조정 시에는 이 파일을 편집하면 된다.
  ```console
  > vi $SPARK_HOME/conf/logback-kaetlyn.xml
  ```
  
  
# 3. Kafka Message Generator 설정 및 시작

** 1. Generator 설정 **


- KAFKA_SERVER : Data를 전송할 Kafka 서버 '{IP}:{Port}'
- SAMPLE_DATA_PATH : sample파일이 저장되어 있는 폴더 path
- TABLE_NAME_TO_ID : sample파일의 Table ID를 지정. 여기에 지정되지 않는 파일은 Generation하지 않는다.
- TABLE_NAME_TO_SEPARATOR : sample파일의 Separator를 지정. 여기에 지정되지 않는 파일은 Generation하지 않는다.
- KAFKA_PRODUCE_TOPIC_NAME : producing할 topic명
- GENERATED_EVENT_TIME : 첫번째 Column에 들어갈 evnet time
- DATA_GENERATING_COUNT : sample 파일을 몇번 전송할지 지정. 파일 한번 전송완료하면 다음부터는 - - GENERATED_EVENT_TIME을 5분씩 올려서 전송
- GENERATING_PERIOD : record를 producing할 주기
- RECORD_PER_PERIOD : GENERATING_PERIOD당 생성할 record갯수

   
```console
> cfc 1 (또는 c01)
> tsr2-kaetlyn edit

...

KAFKA_SERVER=d204:9092
...

###############################################################################
# Properties for Generator
SAMPLE_DATA_PATH=~/Flashbase/flashbase-benchmark/sampleData
TABLE_NAME_TO_ID="'AUA_META_IMSI_CEI->101','AUA_AREA_IMSI_CEI->201'"
TABLE_NAME_TO_SEPARATOR="'AUA_META_IMSI_CEI->,','AUA_AREA_IMSI_CEI->,'"
KAFKA_PRODUCE_TOPIC_NAME=nvkvs

## Optional
#GENERATED_EVENT_TIME=20181108101700
#DATA_GENERATING_COUNT=1
#GENERATING_PERIOD=1
#RECORD_PER_PERIOD=2000
```

- Generator 설정 시 RECORD_PER_PERIOD를 너무 크게 잡으면 Message 전송 요청량이 노드의 네트워크 오버헤드보다 더 커져서 TimeoutException이 발생할 수 있다.
(Producer config의 request.timeout.ms 참조)

** 2. Generator Start/Stop **

 - Start 
```console
> tsr2-kaetlyn generator start
```

 - Stop
```console
> tsr2-kaetlyn generator stop
```
