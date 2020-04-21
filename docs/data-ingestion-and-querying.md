# 1. Create a table

You can create tables in the metastore using standard DDL.

```
CREATE TABLE `pcell` (
    `event_time` STRING,
    `m_10_under` DOUBLE,
    `m_10_19` DOUBLE,
    `m_20_29` DOUBLE,
    `m_30_39` DOUBLE,
    `m_40_49` DOUBLE,
    `m_50_59` DOUBLE,
    `m_60_over` DOUBLE,
    `longitude` DOUBLE,
    `lattitude` DOUBLE,
    `geohash` STRING)
USING r2
OPTIONS (
  `table` '100',
  `host` 'localhost',
  `port` '18100',
  `partitions` 'event_time geohash',
  `mode` 'nvkvs',
  `at_least_one_partition_enabled` 'no',
  `rowstore` 'true'
  )
```

There are various options used to describe storage properties.

- **table** : Positive Integer. The identification of the table. Redis identifies a table with this value.

- **host/port** : The host/port of representative Redis Node. Using this host and port, Spark builds a Redis cluster client that retrieves and inserts data to the Redis cluster.

- **partitions** : The partitions columns. The partition column values are used to distribute data in Redis cluster. That is, the partition column values are concatenated with a colon(:) and used as KEY of Redis which is the criteria distributing data. For more information, you can refer to [Keys distribution model page](https://redis.io/topics/cluster-spec#keys-distribution-model) in Redis.

!!!Tip
    Deciding a partition column properly is a crucial factor for performance because it is related to sharding data to multiple Redis nodes. It is important to try to distribute KEYs to 16384 slots of REDIS evenly and to try to map at least 200 rows for each KEY.

- **mode** : 'nvkvs' for this field

- **at_least_one_partition_enabled** : yes or no. If yes, the queries which do not have partition filter are not permitted.

- **rowstore** : true or false. If yes, all columns are merged and stored in RockDB as one column. It enhances ingesting performance. However, the query performance can be dropped because there is overhead for parsing columns in the Redis layer when retrieving data from RockDB.

!!!Tip
    The metastore of LightningDB only contains metadata/schema of tables.
    The actual data are stored in Lightning DB which consists of Redis & RockDB (Abbreviation: r2), and the table information is stored in metastore.


# 2. Data Ingestion

**(1) Insert data with DataFrameWriter**

You can use DataFrameWriter to write data into LightningDB.

Now, LightingDB only supports "[Append mode](https://spark.apache.org/docs/2.3.1/api/java/org/apache/spark/sql/SaveMode.html#Append)".

```scala
// Create source DataFrame.
val df = spark.sqlContext.read.format("csv")
    .option("header", "false")
    .option("inferSchema", "true")
    .load("/nvme/data_01/csv/")

// "pcell" is a name of table which has R2 options.
df.write.insertInto("pcell")
```

**(2) Insert data with INSERT INTO SELECT query**

```sql
-- pcell : table with R2 option
-- csv_table : table with csv option
-- udf : UDF can be used to transform original data.
INSERT INTO pcell SELECT *, udf(event_time) FROM csv_table
```


# 3. Querying

You can query data with SparkSQL interfaces such as DataFrames and Spark ThriftServer.
Please refer to [Spark SQL guide page](https://spark.apache.org/docs/latest/api/sql/index.html).
