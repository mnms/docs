!!! Note
    This page guides how to start LightningDB automatically only for the case of **AWS EC2 Instance**.

# 1. Access EC2 Instance

Create EC2 Instance for LightningDB and  access with 'Public IP' or 'Public DNS'.

'*.pem' file is also required to access EC2 Instance.

``` bash
$ ssh -i /path/to/.pem ec2-user@${IP_ADDRESS}
```

# 2. Setup environment

When you access EC2 Instance, following jobs are already done.

- Create and exchange SSH KEY for user authentication
- Mount disks

!!! Warning
    Before starting LightningDB, please check if disk mount is completed with using 'lsblk' like below.

``` bash
[ec2-user@ip-172-31-34-115 ~]$ lsblk
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
xvda    202:0    0   10G  0 disk
└─xvda1 202:1    0   10G  0 part /
nvme0n1 259:0    0  1.7T  0 disk /nvme/data_01
nvme1n1 259:1    0  1.7T  0 disk /nvme/data_02
nvme3n1 259:2    0  1.7T  0 disk /nvme/data_03
nvme2n1 259:3    0  1.7T  0 disk /nvme/data_04
```

- Set Hadoop configurations(core-site.xml, hdfs-site.xml, yarn-site.xml).
    - This settings is default value for starter of Hadoop. 
    - To optimize resource or performance, user needs to modify some features with [Hadoop Get Started](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html)
- Set Spark configuration(spark-default.conf.template)
    - To optimize resource and performance, user also need to modify some features with [Spark Configuration](https://spark.apache.org/docs/2.3.0/configuration.html)

!!! Tip
    To launch Spark application on YARN, start YARN with running 'start-dfs.sh' and 'start-yarn.sh' in order.

# 3. Start LightningDB

LightningDB provides FBCTL that is introduced in [Installation](install-fbctl.md). With FBCTL, you can deploy and use LightningDB.

LightningDB supports Zeppelin to provide convenience of ingestion and querying data of LightningDB. About Zeppelin, [Try out with Zeppelin](try-with-zeppelin.md) page provides some guides.

!!! Tip
    To use Web UI of HDFS, YARN, Spark and Zeppelin, you should add the following ports to 'Edit inbound rules' of 'Security groups' in EC2 Instance.

    - HDFS: 50070
    - YARN: 8088
    - Spark: 4040
    - Zeppelin: 8080