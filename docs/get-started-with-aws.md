!!! Note
    This page guides how to start LightningDB automatically only for the case of **AWS EC2 Instance**.

# 1. Access EC2 Instance

Create EC2 Instance for LightningDB and  access with 'Public IP' or 'Public DNS'.

'*.pem' file is also required to access EC2 Instance.

``` bash
$ ssh -i /path/to/.pem ec2-user@${IP_ADDRESS}
```

# 2. Script for setup environment

After access EC2 Instance, run script to setup environment.

``` bash
$ cd ~/flashbase/scripts/userdata/per-boot
$ ./run.sh
```

After 'run.sh' is completed, following jobs are done.

- Create and exchange SSH KEY for user authentication
- Mount disks
- Set Hadoop configurations(core-site.xml, hdfs-site.xml, yarn-site.xml).
    - This settings is default value for starter of Hadoop. To optimize resource or performance, user needs to modify some features with [Hadoop Get Started](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html)
- Set Spark configuration(spark-default.conf.template)
    - To optimize resource and performance, user also need to modify some features with [Spark Configuration](https://spark.apache.org/docs/2.3.0/configuration.html)

# 3. Start LightningDB

LightningDB provides **fbctl** that is [Commands](command-line-interface.md#command-line-interface). With **fbctl**, user can deploy and use LightningDB.

LightningDB supports **Zeppelin** to provide convenience of ingestion and querying data of LightningDB. About **Zeppelin**, [Data Ingestion and Querying](data-ingestion-and-querying.md) page provides some examples.
