ETCDCTL_API=3
INSTANCE_ONE_IP=10.0.0.21
INSTANCE_TWO_IP=10.0.0.22
INSTANCE_TRANSIENT_IP=10.0.0.23
INSTANCE_ONE_NAME=etcd-one
INSTANCE_TWO_NAME=etcd-two
INSTANCE_TRANSIENT_NAME=etcd-transient
PERMANENT_CLIENT_PORT=2379
TRANSIENT_CLIENT_PORT=23793
PERMANENT_SERVER_PORT=2380
TRANSIENT_SERVER_PORT=23803
REGISTRY=quay.io/coreos/etcd

## Set these for each instance, one, two, or transient
MY_INSTANCE_IP=${INSTANCE_TRANSIENT_IP}
MY_INSTANCE_NAME=${INSTANCE_TRANSIENT_NAME}
MY_CLIENT_PORT=${TRANSIENT_CLIENT_PORT}
MY_SERVER_PORT=${TRANSIENT_SERVER_PORT}

DATA_DIR=/opt/${MY_INSTANCE_NAME}
#sudo rm -fr ${DATA_DIR}

## Create the transient instance's data directory from the most recent snapshot
#sudo etcdctl --endpoints http://${INSTANCE_ONE_IP}:${PERMANENT_SERVER_PORT} snapshot restore --data-dir /opt/etcd-transient/ /opt/etcd-one/snapshots/snapshot.db-latest
#sudo etcdctl \
#--endpoints http://${INSTANCE_ONE_IP}:${PERMANENT_SERVER_PORT} \
#--name ${MY_INSTANCE_NAME}   \
#--initial-cluster ${INSTANCE_ONE_NAME}=http://${INSTANCE_ONE_IP}:${PERMANENT_SERVER_PORT},${INSTANCE_TWO_NAME}=http://${INSTANCE_TWO_IP}:${PERMANENT_SERVER_PORT},${INSTANCE_TRANSIENT_NAME}=http://${INSTANCE_TRANSIENT_IP}:${TRANSIENT_SERVER_PORT} \
#--initial-advertise-peer-urls http://${MY_INSTANCE_IP}:${MY_SERVER_PORT} \
#snapshot restore \
#--data-dir /opt/etcd-transient/ /opt/etcd-one/snapshots/snapshot.db-latest

## Run the transient instance
sudo podman run  -itd -p ${MY_CLIENT_PORT}:${MY_CLIENT_PORT}   -p ${MY_SERVER_PORT}:${MY_SERVER_PORT}  \
--ip=${MY_INSTANCE_IP} --net etcd-backend-net  --volume=${DATA_DIR}:/etcd-data   \
--name ${MY_INSTANCE_NAME} ${REGISTRY}:latest   \
/usr/local/bin/etcd   \
--data-dir=/etcd-data \
--name ${MY_INSTANCE_NAME}   \
--initial-advertise-peer-urls http://${MY_INSTANCE_IP}:${MY_SERVER_PORT} \
--listen-peer-urls http://0.0.0.0:${MY_SERVER_PORT}   \
--advertise-client-urls http://${MY_INSTANCE_IP}:${MY_CLIENT_PORT} \
--listen-client-urls http://0.0.0.0:${MY_CLIENT_PORT}   \
--initial-cluster-state existing \
--initial-cluster-token two-node-etcd \
--initial-cluster ${INSTANCE_ONE_NAME}=http://${INSTANCE_ONE_IP}:${PERMANENT_SERVER_PORT},${INSTANCE_TWO_NAME}=http://${INSTANCE_TWO_IP}:${PERMANENT_SERVER_PORT},${INSTANCE_TRANSIENT_NAME}=http://${INSTANCE_TRANSIENT_IP}:${TRANSIENT_SERVER_PORT}


