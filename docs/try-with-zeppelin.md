# 1. Setting for Zeppelin

You can try LightningDB in Zeppelin notebook.

Firstly, deploy and start the cluster of LightningDB using [Installation](install-fbctl.md) before launching Zeppelin daemon.

Secondly, in order to run LightningDB on the Spark, the jars in the LightningDB should be passed to the Spark.
When EC2 Instance is initialized, the environment variable (`$SPARK_SUBMIT_OPTIONS`) is configured for this reason.
Thus just need to check the setting in `zeppelin-env.sh`.

``` bash
$ vim $ZEPPELIN_HOME/conf/zeppelin-env.sh 
...
LIGHTNINGDB_LIB_PATH=$(eval echo $(cat $FBPATH/config | head -n 1 | awk {'print $2'}))/cluster_$(cat $FBPATH/HEAD)/tsr2-assembly-1.0.0-SNAPSHOT/lib/
if [[ -e $LIGHTNINGDB_LIB_PATH ]]; then
    export SPARK_SUBMIT_OPTIONS="--jars $(find $LIGHTNINGDB_LIB_PATH -name 'tsr2*' -o -name 'spark-r2*' -o -name '*jedis*' -o -name 'commons*' -o -name 'jdeferred*' -o -name 'geospark*' -o -name 'gt-*' | tr '\n' ',')"
fi
...
```

Finally, start Zeppelin daemon.

```bash
$ cd $ZEPPELIN_HOME/bin
$ ./zeppelin-daemon.sh start
```

# 2. Tutorial with Zeppelin

After starting zeppelin daemon, you can access zeppelin UI using browser. The url is [https://your-server-ip:8080](https://your-server-ip:8080).

!!! Tip
    We recommend that you proceed with the tutorial at Chrome browser.

There is [a github page for tutorial](https://github.com/mnms/tutorials).

The repository includes a tool for generating sample csv data and a notebook for tutorial.

You can import the tutorial notebook with its url.

[https://raw.githubusercontent.com/mnms/tutorials/master/zeppelin-notebook/note.json](https://raw.githubusercontent.com/mnms/tutorials/master/zeppelin-notebook/note.json)

![import notebook](images/import_notebook.gif)

The tutorial runs on the spark interpreter of Zeppelin.
Please make sure that the memory of Spark driver is at least 10GB in Spark interpreter setting.

![spark driver memory](images/spark-interpreter.png)

Also, make sure that the timeout of shell command is at least 120000 ms.

![Shell timeout](images/shell-timeout.png)
