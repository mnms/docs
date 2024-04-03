# How to use LightningDB on Kubernetes

### 1. ltdb-http v2 - thrift beeline
```
kubectl -n metavision exec -it pod/ltdbv2-beeline-857f578cd9-d7kc4 -- beeline.sh
 
0: jdbc:hive2://ltdbv2-http-svc:13000> select * from files limit 3;

```

- Create table(Do not use ANN)
```
CREATE TABLE IF NOT EXISTS ltdb.metavision.img_feats_noann(
id BIGINT,
is_s3 BOOLEAN,
bucket STRING,
obj_key STRING,
features ARRAY<FLOAT>,
meta STRING
) USING lightning
LOCATION '127.0.0.1:18500'
TBLPROPERTIES ('partition.size'=2, 'partition.0'='bucket','partition.1'='id');
```

- Create table for ANN
```
CREATE TABLE IF NOT EXISTS ltdb.metavision.img_feats(
id BIGINT,
is_s3 BOOLEAN,
bucket STRING,
obj_key STRING,
features ARRAY<FLOAT>,
meta STRING
) USING lightning
LOCATION 'ltdbv2:6379'
TBLPROPERTIES ('partition.size'=2, 'partition.0'='bucket','partition.1'='id', 'feature_idx'='4', 'ann_type'='1', 'feature_dim'='1024', 'ef_construction'='500', 'ann_max_elem'='10000', 'ann_m'='20');
```

- Ingest ANN data (from parquet)
    - parquet 을 받아줄 임시 테이블 생성
```
CREATE TABLE IF NOT EXISTS ltdb.parquet.temptable(
id BIGINT,
is_s3 BOOLEAN,
bucket STRING,
obj_key STRING,
features ARRAY<FLOAT>,
meta STRING
) USING parquet LOCATION 's3a://upload-data/real/vision-ai-private-data_6.csv.ViT-H-14.laion2b_s32b_b79k.975.parquet';
```

- Insert data
```
INSERT INTO ltdb.metavision.img_feats
SELECT
(CAST(RANDOM() * 1000000 AS INTEGER) % 400) AS id,
is_s3,
CONCAT('metavision-', bucket) AS bucket,
obj_key,
features,
meta
FROM
ltdb.parquet.temptable
LIMIT 100;
```

- Query data
```
SELECT * FROM ltdb.metavision.img_feats;
SELECT count(obj_key) FROM ltdb.metavision.img_feats;
```

- Describe table
```
DESCRIBE formatted ltdb.metavision.img_feats;
```

- Drop table
```
DROP TABLE IF EXISTS ltdb.parquet.temptable;
DROP TABLE IF EXISTS ltdb.metavision.img_feats;
```


### 2. Thunderquery CLI tool
```
kubectl -n metavision exec -it thunderquery-68544ff5f7-9shjv -- thunderquery-cli ltdbv2-0.ltdbv2
```

- ANN command
```
select bucket, obj_key, ann(features, [-0.009953999, -0.0006904541, -0.006250763, -0.009839512, 0.012631393, 0.024262842, -0.029540457, -0.01707404, 0.0061618676, 0.029112583, ... , -0.011023628]) as ann_result from ltdb.metavision.img_feats limit 2;
```

- KNN command
```
select bucket, obj_key, euclideandistance(features, [-0.009953999, -0.0006904541, -0.006250763, -0.009839512, 0.012631393, 0.024262842, -0.029540457, -0.01707404, 0.0061618676, 0.029112583, ... , -0.011023628]) as knn_result from ltdb.metavision.img_feats limit 2;
```


### 3. REST API
- Create table
```
$ curl --location --request POST http://metavision.k8s.lightningdb/ltdbv2-http/ingest/table \
--header "Content-Type: text/plain" \
--data "{
'table': 'ltdb.metavision.img_feats',
'schema': [{'name': 'id', 'typ': 'BIGINT'},
{'name': 'is_s3', 'typ': 'BOOLEAN'},
{'name': 'bucket', 'typ': 'STRING'},
{'name': 'obj_key', 'typ': 'STRING'},
{'name': 'features', 'typ': 'ARRAY<FLOAT>'},
{'name': 'meta', 'typ': 'STRING'}],
'loc': 'ltdbv2:6379',
'props': [{'key': 'partition.size', 'val': '2'},
{'key': 'partition.0', 'val': 'bucket'},
{'key': 'partition.1', 'val': 'id'},
{'key': 'feature_idx', 'val': '4'},
{'key': 'ann_type', 'val': '1'},
{'key': 'feature_dim', 'val': '1024'},
{'key': 'ef_construction', 'val': '500'},
{'key': 'ann_max_elem', 'val': '10000'},
{'key': 'ann_m', 'val': '20'}]
}"
```

- Ingest ANN data( from parquet)
```
$ curl --location --request POST http://metavision.k8s.lightningdb/ltdbv2-http/ingest/data \
--header "Content-Type: text/plain" \
--data "{
'src_format': 'parquet',
'src_loc': 's3a://upload-data/real/vision-ai-private-data_6.csv.ViT-H-14.laion2b_s32b_b79k.975.parquet',
'dest_table': 'ltdb.metavision.img_feats',
'limit': 100,
'src_cols_with_random': [{'name': 'id', 'range': 400}],
'src_cols_to_modify': [{'name': 'bucket', 'prefix': 'metavision-'}]
}"
```

- Query data
```
$ curl --location --request POST http://metavision.k8s.lightningdb/ltdbv2-http/query \
--header "Content-Type: text/plain" \
--data "SELECT count(obj_key) FROM ltdb.metavision.img_feats"
```

- Describe table
```
$ curl --location --request GET http://metavision.k8s.lightningdb/ltdbv2-http/ingest/table/ltdb.metavision.img_feats 
```

- Drop table
```
$ curl --location --request DELETE http://metavision.k8s.lightningdb/ltdbv2-http/ingest/table/ltdb.metavision.img_feats 
```

- ANN command
```
$ curl -d 'select bucket, obj_key, ann(features, [-0.009953999, -0.0006904541, -0.006250763, -0.009839512, 0.012631393, 0.024262842, -0.029540457, -0.01707404, 0.0061618676, 0.029112583, ... , -0.011023628]) as ann_result from ltdb.metavision.img_feats limit 2;' http://metavision.k8s.lightningdb/thunderquery/sql 
```

- KNN command
```
$ curl -d 'select bucket, obj_key, euclideandistance(features, [-0.009953999, -0.0006904541, -0.006250763, -0.009839512, 0.012631393, 0.024262842, -0.029540457, -0.01707404, 0.0061618676, ... , -0.011023628]) as ann_result from ltdb.metavision.img_feats limit 2;' http://metavision.k8s.lightningdb/thunderquery/sql 
```