!!! Note
    This document guides how to use 'flashbase' script for failover.
    If you use LTCLI, you can check the status of failure and operate Lightning DB more easily and powerfully. 
    Therefore, if possible, we recommend LTCLI rather than 'flashbase' script.

# 1. Prerequisite

** 1) Redis **

- Check 'flashbase cluster-rowcount'
- Check 'flashbase cli-all config get flash-db-ttl'
- Check 'flashbase cli-all info keyspace' // 'memKeys'(the number of in-memory data keys)
- Check 'flashbase cli-all info tablespace' // 'totalRowgroups', 'totalRows'
- Check 'flashbase cli-all info eviction' // 'avg full percent'

** 2) Thriftserver **

- Check cron jobs with 'crontab -e'.
- Check table schema and query.
```bash
select * from {table name} where ... limit 1;
```

** 3) System resources **

- Check available memory(nmon, 'free -h')
- check the status of disks(nmon, 'df -h')

# 2. Check the status and failover

** 1) Background **

- If a redis-server is killed, a status of the node is changed to 'disconnected'.

```bash
543f81b6c5d6e29b9871ddbbd07a4524508d27e5 127.0.0.1:18202 master - 1585787616744 1585787612000 0 disconnected
```

- After a single node checked that a redis-server is disconnected, the status of the redis-server is changed to `pFail`.
- After all nodes inf the cluster checked that the node is disconnected,  the status of the redis-server is changed to `Fail`.
- If the node is replicated, the slave of the node is failovered.
- With 'cluster-failover.sh', you can do failover regardless of the status(pFail/Fail).

```bash
543f81b6c5d6e29b9871ddbbd07a4524508d27e5 127.0.0.1:18202 master,fail - 1585787616744 1585787612000 0 disconnected
```

- If `node-{port}.conf` file is lost by disk failure, the redis-server using the conf file creates new uuid.
- Because the previous uuid in the cluster is lost, the uuid is changed to `noaddr`. This `noaddr` uuid should be removed with using `cluster forget` command.

```bash
// previous uuid of 18202
543f81b6c5d6e29b9871ddbbd07a4524508d27e5 :0 master,fail,noaddr - 1585787799235 1585787799235 0 disconnected

// new uuid of 18202
001ce4a87de2f2fc62ff44e2b5387a3f0bb9837c 127.0.0.1:18202 master - 0 1585787800000 0 connected
```

** 2) Check the status of the cluster **

1) check-distribution

Show the distribution of master/slave in each server.

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

- options

```bash
> flashbase find-masters
Use options(no-slave|no-slot|failovered)
```

- no-slave (masters without slaves. Need to add the failbacked slaves to this node)

```bash
> flashbase find-masters no-slave
127.0.0.1:18203
127.0.0.1:18252
```

- no-slot (Not yet added into the cluster or masters without slot)

```bash
> flashbase find-masters no-slot
127.0.0.1:18202
127.0.0.1:18253
```

- failovered (When the cluster is initialized, this node was a slave. But now, the nodes is a master by failover)

```bash
> flashbase find-masters failovered
127.0.0.1:18250
127.0.0.1:18252
127.0.0.1:18253
```

3) find-slaves

- options

```bash
flashbase find-slaves
Use options(failbacked)
```

- failbacked (When the cluster is initialized, this node was a master. But now, the nodes is a slave by failback)

```bash
> flashbase find-slaves failbacked
127.0.0.1:18200
```

4) find-masters-with-dir

- List up the redis-servers with using the disk with HW fault.
- After HW fault, some of these nodes are already killed and the others will be killed in a few minutes.

```bash
> flashbase find-masters-with-dir
Error) Invalid arguments.
ex. 'flashbase find-masters-with-dir 127.0.0.1 /DATA01/nvkvs/nvkvs'

> flashbase find-masters-with-dir 127.0.0.1 /nvdrive0/ssd_01/nvkvs/nvkvs
18200
18204
```


** 3) How to handle HW fault(in case of replication) **

1) cluster-failover.sh

If some redis-servers are disconnected(killed/paused), you can do failover immediately and make the status of the cluster 'ok'.


2) find-nodes-with-dir / find-masters-with-dir / failover-with-dir / kill-with-dir

- List up all nodes or master those are using the disk with HW fault.

```bash
> flashbase find-masters-with-dir
Error) Invalid arguments.
ex. 'flashbase find-masters-with-dir 127.0.0.1 /DATA01/nvkvs/nvkvs'

> flashbase find-masters-with-dir 127.0.0.1 /nvdrive0/ssd_02/nvkvs/nvkvs
18200
18204
```

- Do failover and change the master using the error disk to the slave

```
> failover-with-dir 127.0.0.1 /nvdrive0/ssd_02/nvkvs/nvkvs
127.0.0.1:18250 will be master
127.0.0.1:18254 will be master
OK
```

- with `kill-with-dir`, kill all nodes that use the error disk.
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

- Remove 'noaddr' node

```bash
> flashbase find-noaddr  // The prev uuid. Now not used anymore.
1b5d70b57079a4549a1d2e8d0ac2bd7c50986372 :0 master,fail,noaddr - 1589853266724 1589853265000 1 disconnected

> flashbase forget-noaddr // Remove the 'noaddr' uuid.
(error) ERR Unknown node 1b5d70b57079a4549a1d2e8d0ac2bd7c50986372  // Because newly added node does not know the previous uuid.
OK
OK
OK
OK

> flashbase find-noaddr // Check that the noaddr uuid is removed

```

4) do-replicate

- First of all, make the master/slave pair. If there are many nodes to replicate, [pairing.py](scripts/pairing.py) is helpful.
```
> flashbase find-noslot > slaves

> flashbase find-noslave > masters

> python pairing.py slaves masters
flashbase do-replicate 192.168.0.2:19003 192.168.0.4:19053
flashbase do-replicate 192.168.0.2:19004 192.168.0.4:19054
flashbase do-replicate 192.168.0.2:19005 192.168.0.4:19055
...
```


- Add no-slot master as the slave to no-slave master(replicate)

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

If the slave candidate is not included in the cluster, 'do-replicate' is done after 'cluster meet'.

```bash
> flashbase do-replicate 127.0.0.1:18252 127.0.0.1:18202
Add 127.0.0.1:18252 as slave of master(127.0.0.1:18202)
Fail to get masters uuid
'cluster meet' is done
OK // 'cluster meet' is done successfully
OK // 'cluster replicate' is done successfully
```

5) reset-distribution

To initialize the node distribution, use 'reset-distribution'.

```bash
// Check the distribution of cluster nodes.
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

// Check the distribution of cluster nodes again.
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

When a server need to be shutdown by HW fault or checking, change all masters in the server to slaves by failover of those slaves.

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

** 4) How to handle HW fault(in case of no replication) **

After disk replacement, `nodes-{port number}.conf` is lost.

Therefore a new uuid is generated after restart.

Because the previous uuid in the cluster is lost, the uuid is changed to `noaddr`. This `noaddr` uuid should be removed with using `cluster forget` command.

Because the restarted node with the new uuid has no slot information, a slot range should be assigned by using 'addslots'. 


1) Find `noaddr` node and check its slot range.

```bash
> flashbase find-noaddr
7c84d9bb36ae3fa4caaf75318b59d3d2f6c7e9d8 :0 master,fail,noaddr - 1596769266377 1596769157081 77 disconnected 13261-13311 // '13261-13311' is the lost slot range.
```

2) Add the slot range to the restarted node.

```bash
> flashbase cli -h 192.168.111.35 -p 18317 cluster addslots {13261..13311}
```

3) Increase the epoch of the node and update the cluster information.
```bash
> flashbase cli -h 192.168.111.35 -p 18317 cluster bumpepoch
BUMPED 321
```

4) Remove the noaddr node.
```bash
> flashbase forget-noaddr
```


# 3. Check the status

** 1) Redis **

- Compare 'flashbase cluster-rowcount' with the previous result.
- Compare 'flashbase cli-all config get flash-db-ttl'  with the previous result.
- flashbase cli-all cluster info | grep state:ok | wc -l
- flashbase cli -h {ip} -p {port} cluster nodes
- flashbase cli-all info memory | grep isOOM:true


** 2) yarn & spark **

- Check web ui or 'yarn application -list'.
- In case of spark, 
    - Remove the disk with HW fault in `spark.local.dir` of `spark-default.conf` and restart thriftserver.


** 3) Thriftserver **

- Check cron jobs with 'crontab -e'.
- Check table schema and query.
```bash
select * from {table name} where ... limit 1;
```

** 4) kafka & kaetlyn **

- kafka-utils.sh help // list up options
- kafka-utils.sh topic-check {topic name}    // Check the distribution of Leaders
- kafka-utils.sh offset-check      // Consumer LAG of each partition


** 5) System resources **

- Check available memory
- Check the status of disks
