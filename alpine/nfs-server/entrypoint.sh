#!/bin/bash
set -x

## No frill entrypoint ...

[[ -d /exports/ ]] || ( mkdir /exports ; chmod 0777 /exports )
touch /exports/bob

echo "/exports *(rw,fsid=0,no_subtree_check,insecure,no_root_squash,async,no_auth_nlm)" \
  > /etc/exports

mkdir -p \
  /var/lib/nfs/rpc_pipefs \
  /var/lib/nfs/v4recovery \
  /var/lib/nfs/v4root

mount -t nfsd -o nodev,noexec,nosuid nfsd /proc/fs/nfsd
mount -t rpc_pipefs rpc_pipefs /var/lib/nfs/rpc_pipefs

# While NFSv4 doesn't need portmapper it still try to register to it
# and will hang for 3 minutes on a read to /proc/fs/nfsd/portlist
# at startup if this daemon is not started
time rpcbind -w

strace /usr/sbin/rpc.nfsd \
  -G 10 -N 2 -N 3 -V 4 -V 4.1 --no-udp --debug 8 8
# ^^ -G 10 to reduce grace time to 10 seconds -- the lowest allowed -- to allow
#    quicker startup.  Trailing '8' indicate 'nrservs'.

time /usr/sbin/exportfs -rv

time /usr/sbin/rpc.mountd \
  -N 2 -N 3 -V 4 -V 4.1 \
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
  kill $(pidof rpc.rpcbind)
  umount -f /var/lib/nfs/rpc_pipefs
  umount -f /proc/fs/nfsd
  echo > /etc/exports
  echo "Terminated."
  exit 0
}

trap stop TERM SIGINT

# Looping to allow to trap TERM/INT signal
while true; do
    sleep 5
done
