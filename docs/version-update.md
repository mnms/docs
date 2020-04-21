
You can update LightningDB by using the 'deploy' command.

``` bash
> c 1 // alias of 'cluster use 1'
> deploy
(Watch out) Cluster 1 is already deployed. Do you want to deploy again? (y/n) [n]
y
```

**(1) Select installer**

``` bash
Select installer

    [ INSTALLER LIST ]
    (1) lightningdb.release.master.5a6a38.bin
    (2) lightningdb.trial.master.dbcb9e-dirty.bin
    (3) lightningdb.trial.master.dbcb9e.bin

Please enter the number, file path or URL of the installer you want to use.
you can also add a file in list by copy to '$FBPATH/releases/'
1
OK, lightningdb.release.master.5a6a38.bin
```


**(2) Restore**

``` bash
Do you want to restore conf? (y/n)
y
```

If the current settings will be reused, type 'y'.

**(3) Check all settings finally**

``` bash
+-----------------+---------------------------------------------------+
| NAME            | VALUE                                             |
+-----------------+---------------------------------------------------+
| installer       | lightningdb.release.master.5a6a38.bin             |
| nodes           | nodeA                                             |
|                 | nodeB                                             |
|                 | nodeC                                             |
|                 | nodeD                                             |
| master ports    | 18100                                             |
| slave ports     | 18150-18151                                       |
| ssd count       | 3                                                 |
| redis data path | ~/sata_ssd/ssd_                                   |
| redis db path   | ~/sata_ssd/ssd_                                   |
| flash db path   | ~/sata_ssd/ssd_                                   |
+-----------------+---------------------------------------------------+
Do you want to proceed with the deploy accroding to the above information? (y/n)
y
Check status of hosts...
+-----------+--------+
| HOST      | STATUS |
+-----------+--------+
| nodeA     | OK     |
| nodeB     | OK     |
| nodeC     | OK     |
| nodeD     | OK     |
+-----------+--------+
Checking for cluster exist...
+------+--------+
| HOST | STATUS |
+------+--------+
Backup conf of cluster 1...
OK, cluster_1_conf_bak_<time-stamp>
Backup info of cluster 1 at nodeA...
OK, cluster_1_bak_<time-stamp>
Backup info of cluster 1 at nodeB...
OK, cluster_1_bak_<time-stamp>
Backup info of cluster 1 at nodeC...
OK, cluster_1_bak_<time-stamp>
Backup info of cluster 1 at nodeD...
OK, cluster_1_bak_<time-stamp>
Transfer installer and execute...
 - nodeA
 - nodeB
 - nodeC
 - nodeD
Sync conf...
Complete to deploy cluster 1.
Cluster 1 selected.
```

- Backup path of cluster: ${base-directory}/backup/cluster\_${cluster-id}\_bak\_${time-stamp}
- Backup path of conf files: $FBAPTH/conf_backup/cluster_${cluster-id}\_conf_bak\_${time-stamp}


**(4) Restart**


``` bash
> cluster restart
```

After the restart, the new version will be applied.
