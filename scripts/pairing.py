import sys

if len(sys.argv) < 3:
    print("Usage: " + sys.argv[0] + " [masters' path] [slaves' path]")
    sys.exit(1)

masters = [x.strip() for x in open(sys.argv[1])]
slaves = [x.strip() for x in open(sys.argv[2])]

master_dict = {}
slave_dict = {}

for master in masters:
    split = master.split(":")
    if master_dict.get(split[0], "failed") == "failed":
        master_dict[split[0]] = [split[1]]
    else:
        master_dict[split[0]].append(split[1])

for slave in slaves:
    split = slave.split(":")
    if slave_dict.get(split[0], "failed") == "failed":
        slave_dict[split[0]] = [split[1]]
    else:
        slave_dict[split[0]].append(split[1])

for node in master_dict.keys():
    for slave_node in slave_dict.keys():
        if node != slave_node and len(master_dict[node]) == len(slave_dict[slave_node]):
            master_dict[node].sort()
            slave_dict[slave_node].sort()
            for i in range(len(master_dict[node])):
                print("flashbase do-replicate " + slave_node + ":" + slave_dict[slave_node].pop(0) + " " + node + ":" +
                        master_dict[node].pop(0))
            break

for node in master_dict.keys():
    if len(master_dict[node]) == 0:
        master_dict.pop(node)

for node in slave_dict.keys():
    if len(slave_dict[node]) == 0:
        slave_dict.pop(node)

master_list = master_dict.keys()
slave_list = slave_dict.keys()

master_list.sort(key = lambda x : len(master_dict[x]), reverse=True)
slave_list.sort(key = lambda x : len(master_dict[x]), reverse=True)

for node in master_list:
    for slave_node in slave_list:
        if node != slave_node and len(slave_dict[slave_node]) > 0:
            master_dict[node].sort()
            slave_dict[slave_node].sort()
            size = len(master_dict[node]) if len(master_dict[node]) < len(slave_dict[slave_node]) else len(slave_dict[slave_node])
            for i in range(size):
                print("flashbase do-replicate " + slave_node + ":" + slave_dict[slave_node].pop(0) + " " + node + ":" +
                        master_dict[node].pop(0))
        if len(master_dict[node]) == 0:
            break
