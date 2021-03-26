# 1. ping

You can use `ping` command to check the status of the nodes.

** Options **

- All nodes
    - `cli ping --all`
- A single node
    - `cli ping {hostname} {port}`

** Examples **
```
matthew@lightningdb:21> cli ping --all
alive redis 12/12

matthew@lightningdb:21> cli ping myServer 20101
PONG
```

# 2. config

You can read or write the configuration values of the current cluster.

** Options **

- Read
    - All nodes
        - `cli config get {feature name} --all`
    - A sing node
        - `cli config get -h {hostname} -p {port}`
- Write
    - All nodes
        - `cli config set {feature name} {value} --all`
    - A sing node
        - `cli config set {feature name} {value} -h {hostname} -p {port}`

** Examples **

- Read and write the configuration value of all nodes.

```
matthew@lightningdb:21> cli config get maxmemory --all
+--------+----------------------+--------+
| TYPE   | ADDR                 | RESULT |
+--------+----------------------+--------+
| Master | 192.168.111.41:20100 | 300mb  |
| Master | 192.168.111.41:20101 | 300mb  |
| Master | 192.168.111.41:20102 | 300mb  |
| Master | 192.168.111.44:20100 | 300mb  |
| Master | 192.168.111.44:20101 | 300mb  |
| Master | 192.168.111.44:20102 | 300mb  |
| Slave  | 192.168.111.41:20150 | 300mb  |
| Slave  | 192.168.111.41:20151 | 300mb  |
| Slave  | 192.168.111.41:20152 | 300mb  |
| Slave  | 192.168.111.44:20150 | 300mb  |
| Slave  | 192.168.111.44:20151 | 300mb  |
| Slave  | 192.168.111.44:20152 | 300mb  |
+--------+----------------------+--------+
matthew@lightningdb:21> cli config set maxmemory 500mb --all
success 12/12
matthew@lightningdb:21> cli config get maxmemory --all
+--------+----------------------+--------+
| TYPE   | ADDR                 | RESULT |
+--------+----------------------+--------+
| Master | 192.168.111.41:20100 | 500mb  |
| Master | 192.168.111.41:20101 | 500mb  |
| Master | 192.168.111.41:20102 | 500mb  |
| Master | 192.168.111.44:20100 | 500mb  |
| Master | 192.168.111.44:20101 | 500mb  |
| Master | 192.168.111.44:20102 | 500mb  |
| Slave  | 192.168.111.41:20150 | 500mb  |
| Slave  | 192.168.111.41:20151 | 500mb  |
| Slave  | 192.168.111.41:20152 | 500mb  |
| Slave  | 192.168.111.44:20150 | 500mb  |
| Slave  | 192.168.111.44:20151 | 500mb  |
| Slave  | 192.168.111.44:20152 | 500mb  |
+--------+----------------------+--------+
```

- Read and write the configuration value of a single node.
```
matthew@lightningdb:21> cli config get maxmemory -h myServer -p 20101
500mb
matthew@lightningdb:21> cli config set maxmemory 300mb -h myServer -p 20101
OK
matthew@lightningdb:21> cli config get maxmemory -h myServer -p 20101
300mb
matthew@lightningdb:21>
```
# 3. cluster info

You can get the information and stats of the current cluster.

```
matthew@lightningdb:21> cli cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:12
cluster_size:6
cluster_current_epoch:14
cluster_my_epoch:6
cluster_stats_messages_ping_sent:953859
cluster_stats_messages_pong_sent:917798
cluster_stats_messages_meet_sent:10
cluster_stats_messages_sent:1871667
cluster_stats_messages_ping_received:917795
cluster_stats_messages_pong_received:951370
cluster_stats_messages_meet_received:3
cluster_stats_messages_received:1869168
```

# 4. cluster nodes

You can get the distribution and status of each node.

```
matthew@lightningdb:21> cli cluster nodes
4b8fe9d135670daabe19437e3b840b1c770ffa2f 192.168.111.44:20151 slave 985a2215d2acb3f1612751a13e0d7466d874cfe5 0 1604891127367 10 connected
4dd5dff5008ccd89cf18faef736fe6492eb34d05 192.168.111.41:20152 slave 9bff873f9f5f84cd3b78288524230b5cd1c6190f 0 1604891128000 8 connected
15b3c06c1edeb5d2eeb6c0f35c9f27cf616acd11 192.168.111.44:20101 myself,slave 4b6bc980b33dd1eecc87babfb5762eda9e7921e7 0 1604891118000 13 connected
8a800fbf3518e1a0e6b332516455ef4aa6bb3be9 192.168.111.41:20100 master - 0 1604891130372 1 connected 0-2730
9bff873f9f5f84cd3b78288524230b5cd1c6190f 192.168.111.44:20102 master - 0 1604891126000 6 connected 8193-10923
60f88a9db445997112cf8947931988152767878f 192.168.111.44:20152 slave 974c0540741d89c7569b63345faa852361043e8b 0 1604891122000 11 connected
985a2215d2acb3f1612751a13e0d7466d874cfe5 192.168.111.41:20101 master - 0 1604891125365 5 connected 2731-5461
85de73ca2aa668a79fe5636ec74e68dee6f9b36a 192.168.111.44:20100 master - 0 1604891129371 4 connected 13654-16383
974c0540741d89c7569b63345faa852361043e8b 192.168.111.41:20102 master - 0 1604891124363 2 connected 5462-8192
9c6aef212b6d68d2a0298c1902629e1fdc95f943 192.168.111.41:20150 slave 85de73ca2aa668a79fe5636ec74e68dee6f9b36a 0 1604891128370 4 connected
474303b3b9e9f7b84b157ecf52ce11e153a28716 192.168.111.44:20150 slave 8a800fbf3518e1a0e6b332516455ef4aa6bb3be9 0 1604891126366 13 connected
4b6bc980b33dd1eecc87babfb5762eda9e7921e7 192.168.111.41:20151 master - 0 1604891131375 14 connected 10924-13653
```

# 5. cluster slots

You can get the slot information.

```
matthew@lightningdb:21> cli cluster slots
+-------+-------+----------------+--------+----------------+----------+
| start | end   | m_ip           | m_port | s_ip_0         | s_port_0 |
+-------+-------+----------------+--------+----------------+----------+
| 0     | 2730  | 192.168.111.41 | 20100  | 192.168.111.44 | 20150    |
| 2731  | 5461  | 192.168.111.41 | 20101  | 192.168.111.44 | 20151    |
| 5462  | 8192  | 192.168.111.41 | 20102  | 192.168.111.44 | 20152    |
| 8193  | 10923 | 192.168.111.44 | 20102  | 192.168.111.41 | 20152    |
| 10924 | 13653 | 192.168.111.41 | 20151  | 192.168.111.44 | 20101    |
| 13654 | 16383 | 192.168.111.44 | 20100  | 192.168.111.41 | 20150    |
+-------+-------+----------------+--------+----------------+----------+
```




