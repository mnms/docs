# 1. 선행작업

** 1) Redis **

- 'flashbase cluster-rowcount' 기록
- 'flashbase cli-all config get flash-db-ttl' 기록
- 'flashbase cli-all info keyspace' 확인 // 'memKeys'로 in-memory data key수 확인
- 'flashbase cli-all info tablespace' 확인 // totalRowgroups, totalRows등 적재 현황 확인
- 'flashbase cli-all info eviction'확인  // 'avg full percent' 으로 eviction이 효율적으로 동작하는지 확인

** 2) Thriftserver **

- 'crontab -e'로 관련 cron job 확인
``` bash
#0 0 * * * source /home/nvkvs/.use_cluster 99 && thriftserver stop && echo "`date` stop thriftserver by cron" >> /tmp/spark-thrift-alive.log && sleep 10 && thriftserver start
0 0 * * * source /home/nvkvs/.use_cluster 99 && thriftserver stop && echo "`date` stop thriftserver by cron" >> /tmp/spark-thrift-alive.log
30 0 * * * find /data22/thriftserver-event-logs -type f -mtime +7  | xargs rm -rf
* * * * * source /home/nvkvs/.use_cluster 99 && echo "`date` check-thrift-server-alive" >> /tmp/spark-thrift-alive.log && /home/nvkvs/utils/cron-job-keep-alive-thriftserver.sh >> /tmp/spark-thrift-alive.log
* * * * * source /home/nvkvs/.use_cluster 99 && /home/nvkvs/utils/cron-job-check-spark-executor-jvm-status.sh >> /tmp/spark-executor-jvm.log
* * * * * source /home/nvkvs/.use_cluster 99 && /home/nvkvs/utils/cron-job-check-spark-driver-jvm-status.sh >> /tmp/spark-driver-jvm.log
```
- Table schema 확인
- 작업한 클러스터에 있는 테이블별로 질의
```bash
select * from {table name} where ... limit 1;
```

** 3) 시스템 자원 확인 **

- available 메모리 확인(nmon, 'free -h' 사용)
- disk 사용현황 확인(nmon, 'df -h' 사용)




# 2. redis 장애 현황 파악 및 대응

** 1) 배경 지식**

-  장애 발생으로 해당 노드가 kill되면 아래처럼 'disconnected'가 된다.

```bash
543f81b6c5d6e29b9871ddbbd07a4524508d27e5 127.0.0.1:18202 master - 1585787616744 1585787612000 0 disconnected
```

- 'cluster-node-timeout'이 지나면 pFail(한 노드만 확인한 상태), Fail(다른 노드도 disconnected로 확인한 상태) 상태로 빠지면서 최종적으로 Cluster Fail 상태가 되고, 이중화가 된 경우 Failover가 수행된다. 'cluster-failover.sh'를 수행하면 즉시 failover가 된다.

```bash
543f81b6c5d6e29b9871ddbbd07a4524508d27e5 127.0.0.1:18202 master,fail - 1585787616744 1585787612000 0 disconnected
```

- Disk 장애 등으로 'node-{port}.conf' 가 유실된 경우, 해당 노드를 재시작하게 되면, 'node-{port}.conf' 파일에 있는 myself의 uuid가 유실되어 새로운 uuid를 생성하게 된다. 이와 동시에 기존 클러스터에서 알고 있던 이전 uuid는 해당 노드를 찾을 수 없어 'noaddr'로 표기된다. 이 노드는 'cluster forget'으로 제거해야 한다.

```bash
// 18202의 이전 uuid
543f81b6c5d6e29b9871ddbbd07a4524508d27e5 :0 master,fail,noaddr - 1585787799235 1585787799235 0 disconnected

// 18202의 새로운 uuid
001ce4a87de2f2fc62ff44e2b5387a3f0bb9837c 127.0.0.1:18202 master - 0 1585787800000 0 connected
```

** 2) 현황 파악**

1) check-distribution

서버별 master/slave 분포 현황을 알려준다.

```bash
> flashbase check-distribution
check distribution of masters/slaves...
SERVER NAME | M | S
--------------------------------
127.0.0.1   | 5 | 3
--------------------------------
Total nodes | 5 | 3
```

2) find-masters

- option 확인

```bash
> flashbase find-masters
Use options(no-slave|no-slot|failovered)
```

- no-slave (slave가 없는 master들로, 향후 failback으로 추가된 노드들을 slave로 추가해야 함)

```bash
> flashbase find-masters no-slave
127.0.0.1:18203
127.0.0.1:18252
```

- no-slot (cluster에 추가되지 않았거나 slot없이 master로 남아 있는 노드들로 slave가 되어야 함)

```bash
> flashbase find-masters no-slot
127.0.0.1:18202
127.0.0.1:18253
```

- failovered (초기 설정 시 slave 노드였으나 failover로 master가 된 노드들로 향후 master 분포가 특정노드에 치우쳐졌을 때 원복을 해야함)

```bash
> flashbase find-masters failovered
127.0.0.1:18250
127.0.0.1:18252
127.0.0.1:18253
```

3) find-slaves

- option 확인

```bash
flashbase find-slaves
Use options(failbacked)
```

- failbacked (초기 설정 시 master였으나, 장애 이후 failback되어 현재 slave가 된 노드들로 향후 master 분포가 특정노드에 치우쳐졌을 때 원복을 해야함)

```bash
> flashbase find-slaves failbacked
127.0.0.1:18200
```

4) find-masters-with-dir

특정 서버의 특정 디스크 장애 시 해당 디스크를 사용하는 master(redis-server)들을 listup함. 이 노드들은 이미 죽었거나 향후 disk i/o 발생 시 바로 죽을 노드들로, 문제 확인 시 즉시 failover를 수행해야 함

```bash
> flashbase find-masters-with-dir
Error) Invalid arguments.
ex. 'flashbase find-masters-with-dir 127.0.0.1 /DATA01/nvkvs/nvkvs'

> flashbase find-masters-with-dir 127.0.0.1 /nvdrive0/ssd_01/nvkvs/nvkvs
18200
18204
```


** 3) 대응 방안**

1) cluster-failover.sh

디스크 장애로 cluster state가 'fail'이 된 cluster의 경우, redis-server process가 죽거나 pause 된 상태인데 이 때에는 'cluster-failover.sh'로 failover시켜 즉시 cluster state를 'ok'로 만들 수 있다.

2) find-nodes-with-dir / find-masters-with-dir / failover-with-dir / kill-with-dir

- 디스크 장애가 발생했지만 아직 cluster state가 'fail'이 안된 cluster의 경우, 해당 디스크를 사용하는 master(redis-server)들을 listup하고

```bash
> flashbase find-masters-with-dir
Error) Invalid arguments.
ex. 'flashbase find-masters-with-dir 127.0.0.1 /DATA01/nvkvs/nvkvs'

> flashbase find-masters-with-dir 127.0.0.1 /nvdrive0/ssd_02/nvkvs/nvkvs
18200
18204
```

- 장애 디스크를 사용하는 master들에 대해, 해당 노드의 slave로 하여금 failover를 시켜서 장애디스크를 사용하는 master 노드가 없도록 한다.

```
> failover-with-dir 127.0.0.1 /nvdrive0/ssd_02/nvkvs/nvkvs
127.0.0.1:18250 will be master
127.0.0.1:18254 will be master
OK
```

- 해당 디스크를 바라보는 노드를 모두 죽이기 위해 kill-with-dir를 수행한다.(flashbaes cli-all xxx 동작을 수행하기 위해)
```
> flashbase kill-with-dir 127.0.0.1 /nvdrive0/ssd_02/nvkvs/nvkvs
flashbase kill 18200
flashbase kill 18204
flashbase kill 18253

> flashbase cli-all ping
redis client for 127.0.0.1:18200
Could not connect to Redis at 127.0.0.1:18200: Connection refused
redis client for 127.0.0.1:18201
PONG
redis client for 127.0.0.1:18202
PONG
redis client for 127.0.0.1:18203
PONG
redis client for 127.0.0.1:18204
Could not connect to Redis at 127.0.0.1:18204: Connection refused
redis client for 127.0.0.1:18250
PONG
redis client for 127.0.0.1:18251
PONG
redis client for 127.0.0.1:18252
PONG
redis client for 127.0.0.1:18253
Could not connect to Redis at 127.0.0.1:18253: Connection refused
redis client for 127.0.0.1:18254
PONG
```


3) find-noaddr / forget-noaddr

- 'noaddr' 노드 삭제

```bash
> flashbase find-noaddr  // disk 장애가 발생하기 전에 생성 및 저장된 노드(uuid)
1b5d70b57079a4549a1d2e8d0ac2bd7c50986372 :0 master,fail,noaddr - 1589853266724 1589853265000 1 disconnected

> flashbase forget-noaddr // 'cluster nodes'에서 noaddr 를 가진 노드(uuid)를 삭제한다.
(error) ERR Unknown node 1b5d70b57079a4549a1d2e8d0ac2bd7c50986372  // 새로 추가된 노드들은 기존 uuid정보가 없어 이런 메시지가 뜬다.
OK
OK
OK
OK

> flashbase find-noaddr // noaddr 노드가 모두 제거된 것을 확인한다.

```

4) do-replicate

- 이중화해야 하는 pair가 많고 복잡하게 흩어져있는 경우, [pairing.py](scripts/pairing.py)  스크립트를 활용하면 편리하다.
```
> flashbase find-noslot > slaves

> flashbase find-noslave > masters

> python pairing.py slaves masters
flashbase do-replicate 192.168.0.2:19003 192.168.0.4:19053
flashbase do-replicate 192.168.0.2:19004 192.168.0.4:19054
flashbase do-replicate 192.168.0.2:19005 192.168.0.4:19055
...
```


- no-slot master들을 no-slave master들의 slave로 붙임(replicate)

```bash
> flashbase do-replicate 127.0.0.1:18202 127.0.0.1:18252
Add 127.0.0.1:18202 as slave of master(127.0.0.1:18252)
OK

> flashbase cli -p 18202 info replication
# Replication
role:slave
master_host:127.0.0.1
master_port:18252
master_link_status:down
master_last_io_seconds_ago:-1
master_sync_in_progress:0
slave_repl_offset:1
master_link_down_since_seconds:1585912329
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0

> flashbase do-replicate 127.0.0.1:18253 127.0.0.1:18203
Add 127.0.0.1:18253 as slave of master(127.0.0.1:18203)
OK

> flashbase cli -p 18253 info replication
# Replication
role:slave
master_host:127.0.0.1
master_port:18203
master_link_status:up
master_last_io_seconds_ago:5
master_sync_in_progress:0
slave_repl_offset:29
slave_priority:100
slave_read_only:1
connected_slaves:0
master_repl_offset:0
repl_backlog_active:0
repl_backlog_size:1048576
repl_backlog_first_byte_offset:0
repl_backlog_histlen:0
```

만약 slave로 붙일 노드가 cluster에 포함이 안된 상태라면, 'cluster meet'를 먼저 수행한 후에 replicate를 해야 한다. 이러한 동작도 'do-replicate' 내부에서 수행된다.

```bash
> flashbase do-replicate 127.0.0.1:18252 127.0.0.1:18202
Add 127.0.0.1:18252 as slave of master(127.0.0.1:18202)
Fail to get master's uuid
'cluster meet' is done
OK // 'cluster meet' 이 성공한 OK
OK // 'cluster replicate'가 성공한 OK
```

5) reset-distribution

이후 failover로 특정 서버에 master 노드가 몰린 상황을 해결하려면 'reset-distribution'을 사용한다.

```bash
// cluster nodes 현황 파악
> flashbase check-distribution
check distribution of masters/slaves...
SERVER NAME | M | S
--------------------------------
192.168.111.35 | 4 | 4
192.168.111.38 | 0 | 8
192.168.111.41 | 8 | 0
--------------------------------
Total nodes | 12 | 12

...
// master/slave 배치 상태를 초기 상태로 돌림
> flashbase reset-distribution
192.168.111.38:20600
OK
192.168.111.38:20601
OK
192.168.111.38:20602
OK
192.168.111.38:20603
OK

...

/ /다시 cluster nodes 현황 파악. 고르게 분포됨을 확인함
> flashbase check-distribution
check distribution of masters/slaves...
SERVER NAME | M | S
--------------------------------
192.168.111.35 | 4 | 4
192.168.111.38 | 4 | 4
192.168.111.41 | 4 | 4
--------------------------------
Total nodes | 12 | 12
```

6) force-failover

특정 서버의 장애 또는 HW 교체/점검 등으로 shutdown될 때, 해당 서버의 모든 master 노드들이 slave로 되고 다른 서버에 있는 slave가 master로 되도록 변경 시 'force-failover'를 사용한다.

```bash
> flashbase check-distribution
check distribution of masters/slaves...
SERVER NAME | M | S
--------------------------------
192.168.111.35 | 4 | 4
192.168.111.38 | 4 | 4
192.168.111.41 | 4 | 4
--------------------------------
Total nodes | 12 | 12

> flashbase force-failover 192.168.111.41
all masters in 192.168.111.41 will be slaves and their slaves will promote to masters
192.168.111.35:20651 node will be master!
OK
192.168.111.38:20651 node will be master!
OK
192.168.111.35:20653 node will be master!
OK
192.168.111.38:20653 node will be master!
OK

> flashbase check-distribution
check distribution of masters/slaves...
SERVER NAME | M | S
--------------------------------
192.168.111.35 | 6 | 2
192.168.111.38 | 6 | 2
192.168.111.41 | 0 | 5
--------------------------------
Total nodes | 12 | 9
```

# 3. 작업 후 최종 점검

** 1) Redis **

- 'flashbase cluster-rowcount' 이전 기록과 비교
- 'flashbase cli-all config get flash-db-ttl' 이전 기록과 비교
- flashbase cli-all cluster info | grep state:ok | wc -l
- flashbase cli -h {ip} -p {port} cluster nodes
- flashbase cli-all info memory | grep isOOM:true


** 2) yarn & spark **

- web ui 및 'yarn application -list'로 확인
- spark의 경우, spark 의 spark-default.conf 내에 있는 spark.local.dir에 장애난 디스크 포함되어 있으면 해당 디스크 제거하고 설정 파일 수정하여, thrift server 재시작
- spark의 경우, spark-default.conf 문제가 아니더라도, yarn local dir이 문제가 될 경우, 질의 에러 발생되므로, thrift server 재시작 필요


** 3) Thriftserver **

- 'crontab -e' 확인
``` bash
#0 0 * * * source /home/nvkvs/.use_cluster 99 && thriftserver stop && echo "`date` stop thriftserver by cron" >> /tmp/spark-thrift-alive.log && sleep 10 && thriftserver start
0 0 * * * source /home/nvkvs/.use_cluster 99 && thriftserver stop && echo "`date` stop thriftserver by cron" >> /tmp/spark-thrift-alive.log
30 0 * * * find /data22/thriftserver-event-logs -type f -mtime +7  | xargs rm -rf
* * * * * source /home/nvkvs/.use_cluster 99 && echo "`date` check-thrift-server-alive" >> /tmp/spark-thrift-alive.log && /home/nvkvs/utils/cron-job-keep-alive-thriftserver.sh >> /tmp/spark-thrift-alive.log
* * * * * source /home/nvkvs/.use_cluster 99 && /home/nvkvs/utils/cron-job-check-spark-executor-jvm-status.sh >> /tmp/spark-executor-jvm.log
* * * * * source /home/nvkvs/.use_cluster 99 && /home/nvkvs/utils/cron-job-check-spark-driver-jvm-status.sh >> /tmp/spark-driver-jvm.log
```
- 작업한 클러스터에 있는 테이블별로 질의

```bash
select * from {table name} where ... limit 1;
```

** 4) kafka & kaetlyn **

- kafka-utils.sh help // options 확인
- kafka-utils.sh topic-check {topic name}    // Partition의 Leader가 골고루 분포되어 있는지 확인
- kafka-utils.sh offset-check      // Consumer LAG 가져와지는지 확인


** 5) 시스템 자원 확인 **

- available 메모리 확인
- disk 사용현황 확인
