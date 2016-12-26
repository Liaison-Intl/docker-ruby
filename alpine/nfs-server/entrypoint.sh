#!/bin/bash
set -x

## No frill entrypoint ...

[[ -d /exports/ ]] || ( mkdir /exports ; chmod 0777 /exports )
touch /exports/bob
echo "/exports *(rw,fsid=0,no_subtree_check,insecure,no_root_squash,async)" \
  > /etc/exports

time mount -t nfsd nfds /proc/fs/nfsd
/usr/sbin/rpc.nfsd \
  -N 2 -N 3 -V 4 -V 4.1 --debug 8
time /usr/sbin/exportfs -rv
time /usr/sbin/rpc.mountd \
  -N 2 -N 3 -V 4 -V 4.1 \
  --no-udp \
  --exports-file /etc/exports --debug all

set +x
echo "Initialization complete ..."

while true; do
    sleep 5
done
