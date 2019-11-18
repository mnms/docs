# 1. Table Reads & Writes

### Create a table
You can use DataFrameWriter to write data into LightningDB.

Now, LightingDB only supports "[Append mode](https://spark.apache.org/docs/2.3.1/api/java/org/apache/spark/sql/SaveMode.html#Append)".

```scala
df.write.format("r2").insertInto(r2TableName)
```

# 2. Data Ingestion and Querying




# 3. Querying






