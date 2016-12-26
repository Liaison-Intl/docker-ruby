#!/bin/bash
set -x

## No frill entrypoint ...

[[ -d /exports/ ]] || ( mkdir /exports ; chmod 0777 /exports )
touch /exports/bob
echo "/exports *(rw,fsid=0,no_subtree_check,insecure,no_root_squash,async)" \
  > /etc/exports

time /usr/sbin/rpc.nfsd \
  -N 2 -N 3 -V 4 -V 4.1 --debug 8
time /usr/sbin/exportfs -rv
time /usr/sbin/rpc.mountd \
  -N 2 -N 3 -V 4 -V 4.1 \
  --no-udp \
  --exports-file /etc/exports --debug all

set +x
echo "Initialization complete ($((${SECONDS}/60)) min $((${SECONDS}%60)) sec)"

function stop()
{
  echo "SIGTERM caught, terminating NFS process(es)..."
  set -x
  /usr/sbin/rpc.nfsd 0
  /usr/sbin/exportfs -ua
  /usr/sbin/exportfs -f
  kill $(pidof rpc.mountd)
  echo > /etc/exports
  echo "Terminated."
  exit 0
}

trap stop TERM SIGINT

while true; do
    sleep 5
done
