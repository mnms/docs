# Command Line Interface

Command Line Interface(CLI) 도구에서 사용할 수 있는 명령어를 설명합니다.

## Cluster 명령어

FlashBase Cluster를 관리하는 명령어들은 아래와 같습니다.​

* [cluster start](#cluster-start)
* [cluster configure](#cluster-configure)
* [cluster stop](#cluster-stop)
* [cluster clean](#cluster-clean)
* [cluster restart](#cluster-restart)
​
### cluster configure
​
 `redis.properties` 정보를 바탕으로 `redis-master.conf.template`와 `redis-slave.conf.template` 을 통해 `redis-<port>.conf` 파일을 각 master host와 slave host의  `<sr2-home>/conf/redis` 아래에 생성합니다.
​
​
### cluster start
​
cluster start 실행 시 아래의 3가지 기능을 수행합니다.
​
* 기존 log 백업
* 필요 directory 생성
* redis process 실행
​
​
​
##### 기존 log 백업
​
각 master host와 slave host의 `<sr2-home>/logs/backup/<timestamp-%Y%m%d-%H%M%S>` 에 log 파일을 백업합니다.
​
​
​
##### 필요 directory 생성
​
각 master host와 slave host에 `<sr2-redis-data>`, `<sr2-flash-db-path>` 디렉토리를 생성합니다.
​
이미 존재하는 경우 건너뜁니다.
​
​
​
###### ssd 사용 시
​
`<sr2-redis-data>` = `<prefix-redis-data><number>/<user>`
​
`<sr2-flash-db-path>` = `<prefix-flash-db-path><number>/<user>/db/db-<port>`
​
###### ssd 미사용 시
​
`<sr2-redis-data>` = `<prefix-redis-data>/<user>`
​
`<sr2-flash-db-path>` = `<prefix-flash-db-path>/<user>/db/db-<port>`
​
​
​
> `<prefix-redis-data>` = `SR2_REDIS_DATA` of `redis.properties`
>
> `<prefix-flash-db-path>` = `SR2_FLASH_DB_PATH` of `redis.properties`
>
> `<user>` = user name of OS ($USER)
​
​
​
##### redis process 생성
​
각 master host와 slave host에 redis server를 실행시킵니다.
​
적용할 conf 파일 경로: `<sr2-home>/conf/redis/redis-<port>.conf`
​
log 저장 경로: `<sr2-home>/logs/servers-<time-stamp-%Y%m%d-%H%M>-<port>.log`
​
​
​
#### options
​
* --profile
​
  redis server 실행 시 아래의 환경변수가 추가되어 실행됩니다.
​
  * `MALLOC_CONF=prof_leak:true,lg_prof_sample:0,prof_final:true`
​
  * `LD_PRELOAD=$SR2_REDIS_LIB/native/libjemalloc.so`
​
​
​
#### Error
​
* error code 11
​
```
$ cluster start
...
[ErrorCode 11] Fail to start... Must be checked running MASTER redis processes!
We estimate that redis process is <alive-redis-count>.
```
​
사용하려고 하는 master port에 이미 redis process가 실행중인 경우입니다.
​
cluster stop 혹은 kill 등을 통해 해당 port에 실행중인 redis를 종료시켜야 합니다.
​
​
​
* error code 12
​
```
$ cluster start
...
[ErrorCode 12] Fail to start... Must be checked running SLAVE redis processes!
We estimate that redis process is <alive-redis-count>.
```
​
사용하려고 하는 slave port에 이미 redis process가 실행중인 경우입니다.
​
cluster stop 혹은 kill 등을 통해 해당 port에 실행중인 redis를 종료시켜야 합니다.
​
​
​
* conf file not exist
​
```
$ cluster start
...
FileNotExistError: '<sr2-home>/conf/redis/redis-<port>.conf'
```
​
cluster configure 명령어를 실행시킨 후 cluster start를 진행하세요.
​
​
​
* max try error
​
```
$ cluster start
...
max try error
```
​
redis log를 확인하세요.
​
​
​
### cluster stop
​
각 master host와 slave host의 redis process를 종료합니다. (SIGINT)
​
​
​
##### options
​
* --force
​
  redis process를 강제로 종료합니다. (SIGKILL)
​
​
​
### cluster create
​
(준비중)
​
​
​
### cluster clean
​
cluster clean 실행 시 아래의 3가지 기능을 수행합니다.
​
* redis conf 삭제
​
* redis data 삭제
​
​
​
##### redis conf 삭제
​
각 master hostd와 slave host에서 `<sr2-home>/conf/redis/redis-<port>.conf` 를 삭제합니다.
​
​
​
##### redis data 삭제
​
각 master host와 slave host에서 `<sr2-flash-db-path>` 와 `<sr2-redis-data>/appendonly-<port>.aof` 그리고 `<sr2-redis-data>/dump-<port>.rdb` 파일을 삭제합니다.
​
​
​
###### ssd 사용 시
​
`<sr2-redis-data>` = `<prefix-redis-data><number>/<user>`
​
`<sr2-flash-db-path>` = `<prefix-flash-db-path><number>/<user>/db/db-<port>`
​
###### ssd 미사용 시
​
`<sr2-redis-data>` = `<prefix-redis-data>/<user>`
​
`<sr2-flash-db-path>` = `<prefix-flash-db-path>/<user>/db/db-<port>`
​
​
​
> `<prefix-redis-data>` = `SR2_REDIS_DATA` of `redis.properties`
>
> `<prefix-flash-db-path>` = `SR2_FLASH_DB_PATH` of `redis.properties`
>
> `<user>` = user name of OS ($USER)
​
​
​
##### options
​
* --nodes / --reset / --all
​
  redis node conf 파일도 같이 삭제합니다.
​
* --logs
​
  redis conf 삭제와 redis data 삭제는 진행하지 않습니다.
​
  각 master host에서 `<sr2-home>/logs/*.log` 파일을 삭제합니다.
​
​
​
​
​
### cluster restart
​
cluster를 재시작합니다.
​
cluster stop + cluster start
​
​
​
##### options
​
* --force-stop
​
  redis process 종료 시 강제로 종료시킵니다. (SIGKILL)
​
  cluster stop --force + cluster start
​
* --profile
​
  cluster start 시 profile 옵션을 추가합니다.
​
  cluster stop + cluster start --profile
​
* --reset
​
  redis process 종료 후 cluster 초기화를 하고 redis process를 실행시킵니다.
​
  cluster stop + cluster clean --reset + cluster start
​
* --cluster
​
  --reset option 사용 시 사용할 수 있습니다. cluster 재시작 이후 cluster create를 진행합니다.
​
  cluster stop + cluster clean --reset + cluster start + cluster create
​
​
​
### cluster edit
​
cluster edit \<target> 형식입니다. target 파일을 에디터로 수정합니다.
​
사용가능한 target은 main, template, thrift가 있으며 default value는 main입니다.
​
​
​
##### cluster edit main
​
`<sr2-home>/conf/redis.properties` 파일을 에디터로 불러와 수정합니다.
​
​
​
##### cluster edit template --master
​
`<sr2-home>/conf/redis-master.conf.template` 파일을 에디터로 불러와 수정합니다.
​
​
​
##### cluster edit template --slave
​
`<sr2-home>/conf/redis-slave.conf.template` 파일을 에디터로 불러와 수정합니다.
​
​
​
##### cluster edit thrift
​
`<sr2-home>/conf/thriftserver.properties` 파일을 에디터로 불러와 수정합니다.
​
​