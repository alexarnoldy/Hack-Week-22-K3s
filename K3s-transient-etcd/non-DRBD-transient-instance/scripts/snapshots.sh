#!/bin/bash

while :
do

INSTANCE_ONE_IP=10.0.0.21
INSTANCE_TWO_IP=10.0.0.22
PERMANENT_SERVER_PORT=2380

## Remove all but the four most recent snapshots

sudo ls -1tr  /opt/etcd-one/snapshots > /tmp/total-snaps
sudo ls -1tr  /opt/etcd-one/snapshots | tail -4 > /tmp/snaps-to-save

diff /tmp/total-snaps /tmp/snaps-to-save | awk '/snapshot.db/ {print$2}' > /tmp/snaps-to-delete

for EACH in $(cat /tmp/snaps-to-delete)
do
	sudo rm -f /opt/etcd-one/snapshots/${EACH}
done

sudo rm /tmp/total-snaps /tmp/snaps-to-save /tmp/snaps-to-delete

## Take a new snapshot of the permanent etcd instance

sudo etcdctl --endpoints http://${INSTANCE_ONE_IP}:${PERMANENT_SERVER_PORT} snapshot save /opt/etcd-one/snapshots/snapshot.db.$(date "+%s")


## The /opt/etcd-one/snapshots/snapshot.db-latest link should consitently point to a complete snapshot

CURRENT_SNAPSHOT=$(sudo ls -1tr  /opt/etcd-one/snapshots | tail -1)
sudo rm /opt/etcd-one/snapshots/snapshot.db-latest
sudo ln /opt/etcd-one/snapshots/${CURRENT_SNAPSHOT} /opt/etcd-one/snapshots/snapshot.db-latest

sleep 30
done
