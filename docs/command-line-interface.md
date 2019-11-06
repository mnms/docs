# Command Line Interface

Command Line Interface(CLI) 도구에서 사용할 수 있는 명령어를 설명합니다.

<br/>

## Installing Prerequisites

* Installing prerequisites for flashbase
* Python 2.7


<br/>


## 설치

```
$ pip install fbctl
```

<br/>

## path value


`<sr2-home>` = `<base-directory>/cluster_<cluster-number>/tsr2-assembly-1.0.0-SNAPSHOT`

​
`<user>` = user name of OS ($USER)


`<m/s>` = `master` or `slave`


`<prefix-redis-data>` = `SR2_REDIS_DATA` of `redis.properties`


`<prefix-flash-db-path>` = `SR2_FLASH_DB_PATH` of `redis.properties`


**ssd 사용 시**


`<sr2-redis-data>` = `<prefix-redis-data><number>/<user>`

`<sr2-flash-db-path>` = `<prefix-flash-db-path><number>/<user>/db/db-<port>`


**ssd 미사용 시**


`<sr2-redis-data>` = `<prefix-redis-data>/<user>`

​
`<sr2-flash-db-path>` = `<prefix-flash-db-path>/<user>/db/db-<port>`


<br/>

## 기본 명령어

- [deploy](#deploy)
- [c](#c)
- [monitor](#monitor)
- [ll](#ll)

<br/>

### deploy 

***deploy [<cluster-id=<current-cluster-id\>\>] [--history-save=True]***

flashbase를 설치합니다. 새로 클러스터를 구성할 때 마다 deploy를 진행해야 합니다.

<br/>


**arguments**


* *cluster-id*

deploy를 진행할 cluster를 입력합니다. 1 이상의 정수만 입력할 수 있습니다. 미입력시 현재 사용중인 cluster에서 deploy를 진행합니다.


<br/>


**options**


* *history-save*


deploy 시 입력한 정보 이력을 저장하고 이후 deploy에서 default value로 보여줄지 결정합니다. 저장되는 정보들은 `host`, `number of master`, `replicas`, `number of ssd`, `prefix of (redis data / redis db path / flash db path)` 입니다.

<br/>

**example**

```
> deploy 1
> deploy 2 --history-save=False
```


<br/>

### c 

***c <cluster-id\>***

[cluster use](#cluster-use) 와 동일합니다.

<br/>

**example**

```
> c 1
```

<br/>

### monitor

***monitor***

redis log를 모니터링합니다.

<br/>

**example**

```
> monitor
```

<br/>

### ll 

***ll <level\>***

logging level을 변경합니다.


<br/>


**arguments**


* *level*

사용 가능한 level값은 `debug`, `info`, `warning`, `error` 입니다.

<br/>

**example**
```
> ll warning
```


<br/>
<br/>

## Cluster 명령어

FlashBase Cluster를 관리하는 명령어들은 아래와 같습니다.​

  - [cluster use](#cluster-use)
  - [cluster configure](#cluster-configure)
  - [cluster start](#cluster-start)
  - [cluster stop](#cluster-stop)
  - [cluster create](#cluster-create)
  - [cluster clean](#cluster-clean)
  - [cluster restart](#cluster-restart)
  - [cluster edit](#cluster-edit)
​

<br/>

### cluster use

***cluster use <cluster-id\>***


사용할 cluster를 선택합니다.

<br/>

**example**

```
> cluster use 1
```

<br/>

### cluster configure

***cluster configure***


`redis-<port>.conf` 파일을 생성합니다. 생성된 conf 파일은 redis 실행 시 사용됩니다. conf 파일 생성 시 `redis-master.conf.template` 와 `redis-slave.conf.template` 을 템플릿으로 사용하며 `redis.properties` 의 정보를 사용합니다.

<br/>


**example**

```
> cluster configure
```

<br/>

### cluster start

***cluster start [--profile=False]***
​

cluster start 실행 시 아래의 3가지 기능을 수행합니다.
​

* 기존 log 백업

각 master host와 slave host의 `<sr2-home>/logs/backup/<timestamp-%Y%m%d-%H%M%S>` 에 log 파일을 백업합니다.
​

* 필요 directory 생성

각 master host와 slave host에 `<sr2-redis-data>`, `<sr2-flash-db-path>` 디렉토리를 생성합니다.



* redis process 실행

각 master host와 slave host에 redis process를 실행시킵니다. 실행 시 [cluster configure](#cluster-configure) 에서 생성한 conf 파일을 사용하며 redis의 log는 [monitor](#monitor) 를 통해 확인할 수 있습니다.
​

<br/>

**options**
​

* *profile*
​

redis server 실행 시 아래의 환경변수가 추가되어 실행됩니다.

`MALLOC_CONF=prof_leak:true,lg_prof_sample:0,prof_final:true`

`LD_PRELOAD=$SR2_REDIS_LIB/native/libjemalloc.so`



<br/>

**example**

```
> cluster start
> cluster start --profile
```

<br/>

​
### cluster stop

***cluster stop [--force=False]***
​

모든 redis process를 종료합니다. (SIGINT)

<br/>

**options**

* *force*

redis process를 강제로 종료합니다. (SIGKILL)

<br/>

**example**

```
> cluster stop
> cluster stop --force
```
​
​
<br/>
​

### cluster create

***cluster create [--yes=False]***


클러스터를 구성합니다. 클러스터를 구성할 redis들은 모두 실행중이어야 하고 이미 다른 클러스터에 구성원이 아니어야 합니다.
​

<br/>

**options**


* *yes*

클러스터 구성정보 확인 및 진행여부를 물어보는 부분을 스킵합니다.


<br/>


**example**

```
> cluster create
> cluster create --yes
```

​
<br/>

​
### cluster clean

***cluster clean [--all=False] [--logs=False]***
​

cluster clean 실행 시 아래의 2가지 기능을 수행합니다.
​

* redis conf 삭제


각 master host와 slave host에서 `<sr2-home>/conf/redis/redis-<port>.conf` 를 삭제합니다.


* redis data 삭제
​

각 master host와 slave host에서 `<sr2-flash-db-path>` 와 `<sr2-redis-data>/appendonly-<port>.aof` 그리고 `<sr2-redis-data>/dump-<port>.rdb` 파일을 삭제합니다.
​

<br/>

**options**


* *all*

redis node conf 파일도 같이 삭제합니다.


* *logs*


redis conf 삭제와 redis data 삭제는 진행하지 않습니다. `<sr2-home>/logs/*.log` 파일을 삭제합니다.


<br/>


**example**

```
> cluster clean
> cluster clean --all
> cluster clean --logs
```
​
​
​
### cluster restart

***cluster restart [--force-stop=False] [--profile=False] [--reset=Flase [--cluster=False [--yes=False]]]***

​
cluster를 재시작합니다.

<br/>​

**options**
​

* *force-stop*
​

redis process 종료 시 강제로 종료시킵니다. (SIGKILL)
​

* *profile*
​

클러스터 시작 시 `--profile` 옵션이 활성화됩니다.


* *reset*
​

redis process 종료 후 클러스터 초기화(`cluster clean --all`)를 한 이후 redis process를 실행시킵니다.
​

* *cluster*
​

`--reset` 옵션 사용 시 사용할 수 있습니다. 클러스터 재시작 이후 클러스터 생성를 진행합니다.


* *yes*

`--cluster` 옵션 사용 시 사용할 수 있습니다. 클러스터 생성 시 `--yes` 옵션이 활성화됩니다.
​
<br/>

**example**

```
> cluster restart
> cluster restart --force-stop
> cluster resrart --profile
> cluster restart --reset
> cluster restart --reset --cluster --yes
```
​
​
<br/>​

### cluster edit

***cluster edit <target=main\> [--master=False] [--slave=False]***
​

사용가능한 target값은 `main`, `template` 입니다.
​
<br/>​
​

**arguments**


* *target*

사용가능한 target값은 `main`, `template` 입니다. 기본값은 `main` 입니다.

`main`: `<sr2-home>/conf/redis.properties` 파일을 수정합니다.

`template`: `<sr2-home>/conf/redis-<m/s>.conf.template` 파일을 수정합니다.


<br/>​


**options**


* *master*


target이 `template` 인 경우 사용할 수 있습니다. `<sr2-home>/conf/redis-master.conf.template` 파일을 수정합니다.


* *slave*

 target이 `template` 인 경우 사용할 수 있습니다. `<sr2-home>/conf/redis-slave.conf.template` 파일을 수정합니다.



<br/>​

**example**

```
> cluster edit
> cluster edit template --master
> cluster edit template --slave
```


<br/>​
<br/>​


## Cli 명령어

redis-cli 명령어를 사용할 수 있습니다.

- [cli ping](#)
- [cli info](#)
- [cli config get](#)
- [cli config set](#)
- [cli cluster](#)

<br/>

### cli ping

***cli ping [--all=False] [--host, --port]***


redis 연결 상태를 확인합니다.

<br/>

**options**

* *all*

모든 master host에 명령어를 실행합니다.

* *host*

명령어를 실행할 redis의 host를 설정합니다.

* *port*

명령어를 실행할 redis의 port를 설정합니다.


<br/>

**example**

```
> cli ping
> cli ping --all
> cli ping --host=localhost --port=18100
```


<br/>


### cli info

***cli info <target\> [--host, --port]***

redis 정보를 조회합니다.


<br/>


**arguments**


* *target*

가능한 target값은 `all`, `eviction`, `keyspace`, `memory`, `replication`, `tablespace` 입니다.


<br/>


**options**

* *host*

명령어를 실행할 redis의 host를 설정합니다.

* *port*

명령어를 실행할 redis의 port를 설정합니다.


<br/>


**example**

```
> cli info all
> cli info memory
> cli info tablespace --host=localhost --port=18100
```


<br/>


### cli config get

***cli config get <key\> [--all=False] [--host, --port]***


redis의 config 값을 불러옵니다.

<br/>

**arguments**

* *key*

config key 입니다.

<br/>

**options**

* *host*

명령어를 실행할 redis의 host를 설정합니다.

* *port*

명령어를 실행할 redis의 port를 설정합니다.

<br/>

**example**

```
> cli config get loglevel
> cli config get loglevel --all
> cli config get loglevel --host=localhost --port=18100
```

<br/>


### cli config set

***cli config set <key\> <value\> --save [--all=False] [--host, --port]***


redis의 config 값을 설정합니다.


<br/>

**arguments**

* *key*

config key 입니다.

* *value*

config key에 설정할 value 입니다.

<br/>

**options**

* *save*

`redis-<m/>s>.conf.template` 에도 설정값을 저장할지 결정합니다.

* *host*

명령어를 실행할 redis의 host를 설정합니다.

* *port*

명령어를 실행할 redis의 port를 설정합니다.


<br/>

**example**

```
> cli config set loglevel info --save=False
> cli config set loglevel info --save=True --all
> cli config set loglevel info --save=False --host=localhost --port=18100
```

<br/>

### cli cluster

***cli cluster <target\>***

redis cluster 정보를 조회합니다.

<br/>

**argnments**


* *target*

가능한 target값은 `info`, `nodes`, `slots` 입니다.
​
<br/>

**example**

```
> cli cluster info
> cli cluster nodes
> cli cluster slots
```

<br/>


