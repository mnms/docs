In Zeppelin, you can import the `NYC TAXI Benchmark` file with below link.

[NYC_TAXI_BM_load_and_query.json](https://raw.githubusercontent.com/mnms/ecosystem/master/Zeppelin/NYC_TAXI/NYC_TAXI_BM_load_and_query.json)

**1. Put csv files into HDFS**

```
%sh
hdfs dfs -mkdir /nyc_taxi

hdfs dfs -mkdir /nyc_taxi/csv

hdfs dfs -put /nvme_ssd/nyc_taxi/csv_gz/csv1/* /nyc_taxi/csv
hdfs dfs -put /nvme_ssd/nyc_taxi/csv_gz/csv2/* /nyc_taxi/csv
hdfs dfs -put /nvme_ssd/nyc_taxi/csv_gz/csv3/* /nyc_taxi/csv
hdfs dfs -put /nvme_ssd/nyc_taxi/csv_gz/csv4/* /nyc_taxi/csv
hdfs dfs -put /nvme_ssd/nyc_taxi/csv_gz/csv5/* /nyc_taxi/csv
hdfs dfs -put /nvme_ssd/nyc_taxi/csv_gz/csv6/* /nyc_taxi/csv
```

**2. Create dataframe and load data**

```
%spark

import org.apache.spark.sql.types._

val taxiSchema = StructType(Array(
        StructField("trip_id", IntegerType, true),
        StructField("vendor_id", StringType, true),
        StructField("pickup_datetime", TimestampType, true),
        StructField("dropoff_datetime", TimestampType, true),
        StructField("store_and_fwd_flag", StringType, true),
        StructField("rate_code_id", IntegerType, true),
        StructField("pickup_longitude", DoubleType, true),
        StructField("pickup_latitude", DoubleType, true),
        StructField("dropoff_longitude", DoubleType, true),
        StructField("dropoff_latitude", DoubleType, true),
        StructField("passenger_count", StringType, true),
        StructField("trip_distance", DoubleType, true),
        StructField("fare_amount", DoubleType, true),
        StructField("extra", DoubleType, true),
        StructField("mta_tax", DoubleType, true),
        StructField("tip_amount", DoubleType, true),
        StructField("tolls_amount", DoubleType, true),
        StructField("improvement_surcharge", DoubleType, true),
        StructField("total_amount", DoubleType, true),
        StructField("payment_type", StringType, true),
        StructField("trip_type", IntegerType, true),
        StructField("cab_type", StringType, true),
        StructField("precipitation", DoubleType, true),
        StructField("snow_depth", DoubleType, true),
        StructField("snowfall", DoubleType, true),
        StructField("max_temperature", IntegerType, true),
        StructField("min_temperature", IntegerType, true),
        StructField("average_wind_speed", DoubleType, true),
        StructField("pickup_nyct2010_gid", IntegerType, true),
        StructField("pickup_ctlabel", StringType, true),
        StructField("pickup_borocode", IntegerType, true),
        StructField("pickup_boroname", StringType, true),
        StructField("pickup_ct2010", StringType, true),
        StructField("pickup_boroct2010", StringType, true),
        StructField("pickup_cdeligibil", StringType, true),
        StructField("pickup_ntacode", StringType, true),
        StructField("pickup_ntaname", StringType, true),
        StructField("pickup_puma", StringType, true),
        StructField("dropoff_nyct2010_gid", IntegerType, true),
        StructField("dropoff_ctlabel", StringType, true),
        StructField("dropoff_borocode", IntegerType, true),
        StructField("dropoff_boroname", StringType, true),
        StructField("dropoff_ct2010", IntegerType, true),
        StructField("dropoff_boroct2010", StringType, true),
        StructField("dropoff_cdeligibil", StringType, true),
        StructField("dropoff_ntacode", StringType, true),
        StructField("dropoff_ntaname", StringType, true),
        StructField("dropoff_puma", StringType, true)
    ))
    
    val taxiDF = spark.read.format("csv")
                .option("header", "false")
                .option("delimiter", ",")
                .option("mode", "FAILFAST")
                .schema(taxiSchema)
                .load("/nyc_taxi/csv/*.csv.gz")
                
```

**4. Create temp view for the dataframe**

```
%spark
taxiDF.createOrReplaceTempView("trips")
```

**5. Transform the dataframe for Lightning DB**

```
%spark
import org.apache.spark.sql.functions._
val deltaDf = taxiDF
    .filter($"pickup_datetime".isNotNull && $"passenger_count".isNotNull && $"cab_type".isNotNull)
    .withColumn("pickup_yyyyMMddhh", from_unixtime(unix_timestamp($"pickup_datetime"),  "yyyyMMddhh"))
    .withColumn("round_trip_distance", round($"trip_distance"))
    
deltaDf.printSchema()
```

**6. Create temp view for Lightning DB with r2 options those support Lightning DB as the data source**

```
%spark
val r2Options = Map[String, String]("table" -> "100",
      "host" -> "192.168.111.35",
      "port" -> "18800",
      "partitions" -> "pickup_yyyyMMddhh passenger_count cab_type",
      "mode" -> "nvkvs",
      "rowstore" -> "false",
      "group_size" -> "40",
      "at_least_one_partition_enabled" -> "no")
spark.sqlContext.read.format("r2").schema(deltaDf.schema).options(r2Options).load().createOrReplaceTempView("fb_trips")
```

**7. Load data from the dataframe into Lightning DB**

```
%spark
deltaDf.write
    .format("r2")
    .insertInto("fb_trips")
```

**8. Enable ‘aggregation pushdown’ feature**

```
SET spark.r2.aggregation.pushdown=true
```

**9. Do ‘NYC TAXI Benchmark’**

Q1

```
%sql
SELECT cab_type, count(*) FROM fb_trips GROUP BY cab_type
```

Q2
```
%sql
SELECT passenger_count,
       avg(total_amount)
FROM fb_trips
GROUP BY passenger_count
```

Q3
```
%sql
SELECT passenger_count,
       substring(pickup_yyyyMMddhh, 1, 4),
       count(*)
FROM fb_trips
GROUP BY passenger_count, 
         substring(pickup_yyyyMMddhh, 1, 4)
```

Q4
```
%sql
SELECT passenger_count,
       substring(pickup_yyyyMMddhh, 1, 4),
       round_trip_distance,
       count(*)
FROM fb_trips
GROUP BY 1,
         2,
         3
ORDER BY 2,
         4 desc
```