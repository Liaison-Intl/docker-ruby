#!/bin/bash
set -x

## No frill entrypoint ...

[[ -d /exports/ ]] || ( mkdir /exports ; chmod 0777 /exports )
touch /exports/bob
echo "/exports *(rw,fsid=0,no_subtree_check,insecure,no_root_squash,async)" \
  > /etc/exports

time /usr/sbin/rpc.nfsd \
  -N 2 -N 3 -V 4 -N 4.1 --no-udp -G 10 --debug 8 2
  # -G 10 to reduce grace time to 10 seconds -- the lowest allowed -- to allow
  # much quicker startup.  Otherwise can take up to 6 minute ...
  # trailing '2' indicate 'nrservs'
time /usr/sbin/exportfs -rv
time /usr/sbin/rpc.mountd \
  -N 2 -N 3 -V 4 -N 4.1 \
  --no-udp \
  --exports-file /etc/exports --debug all

set +x
echo "Initialization complete ($((${SECONDS}/60)) min $((${SECONDS}%60)) sec)"
touch /ready

function stop()
{
  # Stop script to allow clean shutdown, otherwise kubernetes might need
  # to wait for a very long time before it can umount the persistent disk
  # that may be mounted on the /exports/ directory
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

# Looping to allow to trap TERM/INT signal
while true; do
    sleep 5
done
