#nodes=("flashbase-d01" "flashbase-d02" "flashbase-d03")
#nodes=("flashbase-w01" "flashbase-w02" "flashbase-w03" "flashbase-w04" "flashbase-w05" "flashbase-w06")
nodes=( "localhost")

INSTALLER_PATH=$1

[[ $INSTALLER_PATH == "" ]] && echo "NO ARGS" && echo "cmd <path of installer.bin>" && exit 1
[[ ! -e $INSTALLER_PATH ]] && echo "NO FILE: $INSTALLER_PATH" && exit 1

INSTALLER_BIN=$(basename $INSTALLER_PATH)
DATEMIN=`date +%Y%m%d%H%M%S`
TSR2_DIR=~/tsr2
echo "DATEMIN: $DATEMIN"
echo "INSTALLER PATH: $INSTALLER_PATH"
echo "INSTALLER NAME: $INSTALLER_BIN"

for cluster_num in "1";
do
    CLUSTER_DIR=$TSR2_DIR/cluster_${cluster_num}
    BACKUP_DIR="${CLUSTER_DIR}_bak_$DATEMIN"
    CONF_BACKUP_DIR="${CLUSTER_DIR}_conf_bak_$DATEMIN"
    SR2_HOME=${CLUSTER_DIR}/tsr2-assembly-1.0.0-SNAPSHOT
    SR2_CONF=${SR2_HOME}/conf

    echo "======================================================"
    echo "DEPLOY CLUSTER $cluster_num"
    echo ""
    echo "CLUSTER_DIR: $CLUSTER_DIR"
    echo "SR2_HOME: $SR2_HOME"
    echo "SR2_CONF: $SR2_CONF"
    echo "BACKUP_DIR: $BACKUP_DIR"
    echo "CONF_BACKUP_DIR: $CONF_BACKUP_DIR"
    echo "======================================================"
    echo "backup..."
    mkdir -p ${CONF_BACKUP_DIR}
    cp -rf ${SR2_CONF}/* $CONF_BACKUP_DIR

    echo ""

    for node in ${nodes[@]};
    do
        echo "DEPLOY NODE $node"
        ssh $node "mv ${CLUSTER_DIR} ${BACKUP_DIR}"
        ssh $node "mkdir -p ${CLUSTER_DIR}"
        scp -r $INSTALLER_PATH $node:${CLUSTER_DIR}
        ssh $node "PATH=${PATH}:/usr/sbin; ${CLUSTER_DIR}/${INSTALLER_BIN} --full ${CLUSTER_DIR}"
        rsync -avr $CONF_BACKUP_DIR/* $node:${SR2_CONF}
    done

    echo ""
done

