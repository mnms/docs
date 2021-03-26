If you want to see the list of Thrift Server commands, use the the `thriftserver` command without any option.

``` bash
NAME
    ltcli thriftserver

SYNOPSIS
    ltcli thriftserver COMMAND

COMMANDS
    COMMAND is one of the following:

     beeline
       Connect to thriftserver command line

     monitor
       Show thriftserver log

     restart
       Thriftserver restart

     start
       Start thriftserver

     stop
       Stop thriftserver
```

# 1. Thriftserver beeline

Connect to the thrift server

``` bash
ec2-user@lightningdb:1> thriftserver beeline
Connecting...
Connecting to jdbc:hive2://localhost:13000
19/11/19 04:45:18 INFO jdbc.Utils: Supplied authorities: localhost:13000
19/11/19 04:45:18 INFO jdbc.Utils: Resolved authority: localhost:13000
19/11/19 04:45:18 INFO jdbc.HiveConnection: Will try to open client transport with JDBC Uri: jdbc:hive2://localhost:13000
Connected to: Spark SQL (version 2.3.1)
Driver: Hive JDBC (version 1.2.1.spark2)
Transaction isolation: TRANSACTION_REPEATABLE_READ
Beeline version 1.2.1.spark2 by Apache Hive
0: jdbc:hive2://localhost:13000> show tables;
+-----------+------------+--------------+--+
| database  | tableName  | isTemporary  |
+-----------+------------+--------------+--+
+-----------+------------+--------------+--+
No rows selected (0.55 seconds)
```

Default value of db url to connect is `jdbc:hive2://$HIVE_HOST:$HIVE_PORT`

You can modify `$HIVE_HOST` and `$HIVE_PORT` by the command `conf thriftserver`

# 2. Thriftserver monitor

You can view the logs of the thrift server in real-time.

``` bash
ec2-user@lightningdb:1> thriftserver monitor
Press Ctrl-C for exit.
19/11/19 04:43:33 INFO storage.BlockManagerMasterEndpoint: Registering block manager ip-172-31-39-147.ap-northeast-2.compute.internal:35909 with 912.3 MB RAM, BlockManagerId(4, ip-172-31-39-147.ap-northeast-2.compute.internal, 35909, None)
19/11/19 04:43:33 INFO cluster.YarnSchedulerBackend$YarnDriverEndpoint: Registered executor NettyRpcEndpointRef(spark-client://Executor) (172.31.39.147:53604) with ID 5
19/11/19 04:43:33 INFO storage.BlockManagerMasterEndpoint: Registering block manager
...
```

# 3. Thriftserver restart

Restart the thrift server.

``` bash
ec2-user@lightningdb:1> thriftserver restart
no org.apache.spark.sql.hive.thriftserver.HiveThriftServer2 to stop
starting org.apache.spark.sql.hive.thriftserver.HiveThriftServer2, logging to /opt/spark/logs/spark-ec2-user-org.apache.spark.sql.hive.thriftserver.HiveThriftServer2-1-ip-172-31-39-147.ap-northeast-2.compute.internal.out
```

# 4. Start thriftserver

Run the thrift server.

``` bash
ec2-user@lightningdb:1> thriftserver start
starting org.apache.spark.sql.hive.thriftserver.HiveThriftServer2, logging to /opt/spark/logs/spark-ec2-user-org.apache.spark.sql.hive.thriftserver.HiveThriftServer2-1-ip-172-31-39-147.ap-northeast-2.compute.internal.out
```

You can view the logs through the command `monitor`.

# 5. Stop thriftserver

Shut down the thrift server.

``` bash
ec2-user@lightningdb:1> thriftserver stop
stopping org.apache.spark.sql.hive.thriftserver.HiveThriftServer2
```